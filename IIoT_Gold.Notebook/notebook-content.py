# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "6a4767e2-858d-4d69-85af-d74f53d7a60b",
# META       "default_lakehouse_name": "lh_demo",
# META       "default_lakehouse_workspace_id": "ba5a0249-6e08-49fe-b8bb-8e4cc68fb755",
# META       "known_lakehouses": [
# META         {
# META           "id": "6a4767e2-858d-4d69-85af-d74f53d7a60b"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

from pyspark.sql.functions import *
from pyspark.sql.types import *
from pyspark.sql.window import Window

# 1. Daten aus der vorhandenen Bronze-Tabelle laden
df_bronze = spark.read.table("IIoT_bronze")

# Vorbereitung für Dimensionen
windowSpec_machine = Window.orderBy("Machine_ID")
windowSpec_status = Window.orderBy("Machine_Status")

# =====================================================================
# DIMENSION 1 & 2: Maschinen & Status
# =====================================================================
dim_machine = (
    df_bronze.select("Machine_ID").distinct().filter(col("Machine_ID").isNotNull())
    .withColumn("Machine_Key", row_number().over(windowSpec_machine).cast(IntegerType()))
    .select("Machine_Key", "Machine_ID")
)
dim_machine.write.format("delta").mode("overwrite").option("overwriteSchema", "true").saveAsTable("gold.Dim_Machine")

dim_status = (
    df_bronze.select("Machine_Status").distinct().filter(col("Machine_Status").isNotNull())
    .withColumn("Status_Key", row_number().over(windowSpec_status).cast(IntegerType()))
    .select("Status_Key", "Machine_Status")
)
dim_status.write.format("delta").mode("overwrite").option("overwriteSchema", "true").saveAsTable("gold.Dim_Status")

# =====================================================================
# DIMENSION 3: Reine Datumsdimension (Dim_Date)
# =====================================================================
# 1. Min und Max Timestamp direkt aus der Tabelle ziehen
time_bounds = df_bronze.select(min("Timestamp").alias("min_t"), max("Timestamp").alias("max_t")).first()

# 2. Werte sauber als Python-Date-Objekte extrahieren
start_date_val = time_bounds["min_t"].date()
end_date_val = time_bounds["max_t"].date()

# 3. Die Anzahl der Tage direkt in Python berechnen (Absolut fehlerfrei!)
days_count = (end_date_val - start_date_val).days + 1

# 4. Das Startdatum als String für die Spark-Funktion vorbereiten
start_date_str = start_date_val.strftime("%Y-%m-%d")

# 5. Datumsdimension in Spark generieren
dim_date = (
    spark.range(0, int(days_count))
    .withColumn("Datum", expr(f"date_add('{start_date_str}', cast(id as int))"))
    # Der reine Datumsschlüssel (z.B. 20260729)
    .withColumn("Date_Key", date_format(col("Datum"), "yyyyMMdd").cast(IntegerType()))
    .withColumn("Jahr", year(col("Datum")))
    .withColumn("Monat", month(col("Datum")))
    .withColumn("Kalenderwoche", weekofyear(col("Datum")))
    .withColumn("Wochentag", date_format(col("Datum"), "EEEE"))
    .select("Date_Key", "Datum", "Jahr", "Monat", "Kalenderwoche", "Wochentag")
)

dim_date.write.format("delta").mode("overwrite").option("overwriteSchema", "true").saveAsTable("gold.Dim_Date")

print(f"Dim_Date erfolgreich erstellt! Zeitraum: {start_date_str} bis {end_date_val.strftime('%Y-%m-%d')} ({days_count} Tage).")



# =====================================================================
# DIMENSION 4: Fixe 24-Stunden-Dimension (Dim_Hour)
# =====================================================================
# Erzeugt exakt 24 Zeilen (0 bis 23) für Schicht- und Tageszeit-Analysen
dim_hour = (
    spark.range(0, 24)
    .withColumn("Hour_Key", col("id").cast(IntegerType()))
    .withColumn("Stunde_Name", concat(col("Hour_Key"), lit(":00 Uhr")))
    # Schichten logisch einteilen (Beispiel)
    .withColumn("Schicht", 
        when((col("Hour_Key") >= 6) & (col("Hour_Key") < 14), "Frühschicht")
        .when((col("Hour_Key") >= 14) & (col("Hour_Key") < 22), "Spätschicht")
        .otherwise("Nachtschicht")
    )
    .select("Hour_Key", "Stunde_Name", "Schicht")
)
dim_hour.write.format("delta").mode("overwrite").option("overwriteSchema", "true").saveAsTable("gold.Dim_Hour")

# =====================================================================
# FAKTEN-TABELLE: Fact_IIoT_Hourly mit getrennten Keys (Date_Key & Hour_Key)
# =====================================================================
fact_base = (
    df_bronze
    .withColumn("Stunde_Trunc", date_trunc("hour", col("Timestamp")))
    .groupBy("Stunde_Trunc", "Machine_ID", "Machine_Status")
    .agg(
        round(avg("Sensor_Temperatur_Celsius"), 1).alias("Avg_Temperatur_Celsius"),
        sum("Inkrement_Gutmenge").alias("Total_Gutmenge"),
        sum("Inkrement_Ausschussmenge").alias("Total_Ausschussmenge")
    )
    # Befüllung der zwei getrennten Schlüssel-Spalten
    .withColumn("Date_Key", date_format(col("Stunde_Trunc"), "yyyyMMdd").cast(IntegerType()))
    .withColumn("Hour_Key", hour(col("Stunde_Trunc")).cast(IntegerType()))
)

fact_iiot_hourly = (
    fact_base
    .join(dim_machine, "Machine_ID", "left")
    .join(dim_status, "Machine_Status", "left")
    .select(
        "Date_Key",
        "Hour_Key",
        "Machine_Key", 
        "Status_Key", 
        "Avg_Temperatur_Celsius", 
        "Total_Gutmenge", 
        "Total_Ausschussmenge"
    )
    .orderBy("Date_Key", "Hour_Key", "Machine_Key")
)

fact_iiot_hourly.write.format("delta").mode("overwrite").option("overwriteSchema", "true").saveAsTable("gold.Fact_IIoT_Hourly")

print("Das Zwei-Schlüssel-Sternschema wurde erfolgreich im gold-Schema generiert!")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
