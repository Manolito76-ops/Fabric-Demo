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

# ACHTUNG: KI-generierter Code kann Fehler oder Vorgänge enthalten, die Sie nicht beabsichtigt haben. Überprüfen Sie den Code in dieser Zelle sorgfältig, bevor Sie ihn ausführen.

# Welcome to your new notebook
# Type here in the cell editor to add code!
from pyspark.sql.functions import *
from pyspark.sql.types import *

# Schema definition for the IIoT CSV stream file
schema = (
    StructType()
        .add("Timestamp", TimestampType(), True)
        .add("Machine_ID", StringType(), True)
        .add("Machine_Status", StringType(), True)
        .add("Sensor_Temperatur_Celsius", DoubleType(), True)
        .add("Inkrement_Gutmenge", IntegerType(), True)
        .add("Inkrement_Ausschussmenge", IntegerType(), True)
)

# (Optional) Use these to debug the path. Run once, then adjust `file_path` below if needed.
# display(notebookutils.fs.ls("Files"))
# display(notebookutils.fs.ls("Files/IIOT"))

# Path to your CSV in the default Lakehouse Files area.
# If ls() shows a different folder/file name, change this to match exactly.
file_path = "Files/IIOT/iiot_hub_stream.csv"

try:
    df = (
        spark.read.format("csv")
        .option("header", "true")
        .option("delimiter", ";")
        .schema(schema)
        .load(file_path)
    )

    # Show small sample to confirm successful load
 #   display(df.limit(10))

except Exception as e:
    print(f"Failed to load '{file_path}'. Please check that:")
    print("  - The notebook has a default Lakehouse attached (Lakehouse pane on the left).")
    print("  - The folder 'Files/IIOT' exists in that Lakehouse.")
    print("  - The file 'iioi_hub_stream.csv' exists there and the name matches exactly (case-sensitive).")
    print("Original error:", e)

df.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable("IIoT_bronze")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
