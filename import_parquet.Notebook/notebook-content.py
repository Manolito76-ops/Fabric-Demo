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

# 1. Konfiguration & Pfade definieren
# Pfad im Lakehouse, wo deine hochgeladenen Parquet-Dateien liegen (z.B. im Files-Bereich)
# Du hast im UI eine konkrete Datei ausgewählt, deshalb verwenden wir hier den vollständigen Dateipfad.

source_parquet_path = "Files/raw_parquet_data/part-00000-f100ec46-273f-4525-b802-33da606a0e1a-c000.snappy.parquet"

# Name der finalen Delta-Tabelle im Metastore (erscheint automatisch unter "Tabellen")
target_table_name = "supply_chain_delta"

print(f"⏳ Lese Parquet-Daten ein von: {source_parquet_path}")

# 2. Parquet-Dateien einlesen
# Spark erkennt automatisch, ob es eine einzelne Datei oder ein ganzer Ordner voller Parquet-Dateien ist

df = spark.read.parquet(source_parquet_path)

# Kurze Kontrolle der Struktur
print("Schema der geladenen Daten:")
df.printSchema()
print(f"Anzahl Zeilen: {df.count()}")

print(f"🚀 Konvertiere und registriere als Delta-Tabelle: {target_table_name}")

# 3. Als Delta-Tabelle im Metastore speichern
# .saveAsTable() erstellt die Ordnerstruktur im Hintergrund UND registriert sie im Metastore
(
    df.write
      .format("delta")
      .mode("overwrite")
      .saveAsTable(target_table_name)
)

print(f"✅ Fertig! Die Delta-Tabelle '{target_table_name}' ist jetzt im Metastore verfügbar.")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
