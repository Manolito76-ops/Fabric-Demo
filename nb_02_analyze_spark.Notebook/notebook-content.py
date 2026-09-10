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

import sempy.fabric as fabric
import notebookutils
import json

print("=== SCHRITT 1: AKTUELLEN ARBEITSBEREICH AUSLESEN ===")
try:
    current_workspace_id = fabric.resolve_workspace_id()
    print(f"Ihre aktive Workspace-ID lautet: {current_workspace_id}\n")
except Exception as e:
    print(f"Fehler bei Workspace-Ermittlung: {e}\n")

print("=== SCHRITT 2: ALLE ITEMS (LAKEHOUSES) IN DIESEM WORKSPACE AUFLISTEN ===")
try:
    # Listet alle Lakehouses und Notebooks in diesem Arbeitsbereich auf
    items_df = fabric.list_items(workspace=current_workspace_id)
    # Filtert auf Lakehouses, um die ID Ihres 'Demo'-Lakehouses zu finden
    lakehouses = items_df[items_df['Type'] == 'Lakehouse']
    
    for index, row in lakehouses.iterrows():
        print(f"Gefundenes Lakehouse Name: '{row['# display Name']}' | System-ID: {row['Id']}")
    print("\n")
except Exception as e:
    print(f"Fehler beim Auflisten der Items: {e}\n")

print("=== SCHRITT 3: INTERNE ORDNERSTRUKTUR VON 'notebookutils' PRÜFEN ===")
try:
    # Wir schauen, welche Standard-Verzeichnisse für Daten überhaupt existieren
    # 'mssparkutils' wurde in Fabric offiziell zu 'notebookutils' aufgewertet
    base_dirs = notebookutils.fs.ls("/")
    for d in base_dirs:
        print(f"Verfügbarer System-Pfad im Root: {d.path}")
except Exception as e:
    print(f"Fehler beim Prüfen der Root-Pfade: {e}")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************


# CELL ********************

# MAGIC %%html
# MAGIC Großartig! Das ist der absolute Volltreffer und genau die Information, die wir gebraucht haben. Das Rätsel ist gelöst.Was uns diese Diagnose verrät:Ihr Lakehouse Demo hat die 
# MAGIC eindeutige System-ID: 6a4767e2-858d-4d69-85af-d74f53d7a60b.Das Notebook sieht im Root-Verzeichnis zwei verschiedene Pfade (Endpunkte). 
# MAGIC Der erste Pfad in Schritt 3 endet genau auf der ID Ihres Lakehouses Demo!Weil die Kurzpfade (Files/...) bei Ihnen aufgrund des Microsoft-Sitzungsfehlers blockiert sind, 
# MAGIC füttern wir Spark jetzt mit dem absoluten, unfehlbaren Systempfad, den wir gerade live ausgelesen haben. Dieser Pfad umgeht alle virtuellen Laufwerke (wie default oder Demo) 
# MAGIC und greift direkt über die OneLake-Hauptleitung auf Ihre Datei zu.Kopieren Sie diesen Code exakt so in Ihre Zelle und führen Sie ihn aus:

# METADATA ********************

# META {
# META   "language": "html",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# ==============================================================================
# RETTUNGS-SKRIPT: CSV-DATEN ERFOLGREICH IN SPARK LADEN
# ==============================================================================

# sys wird benötigt, um das Skript bei schweren Fehlern sofort sauber zu stoppen
import sys
# notebookutils ist die offizielle Microsoft Fabric Bibliothek für Dateipfade
import notebookutils

print("=== START DES PROGRAMMS ===")

# ------------------------------------------------------------------------------
# SCHRITT 1: PHYSISCHEN SPEICHERPFAD LIVE AUSLESEN
# Warum try/except? Wir sichern uns gegen unvorhersehbare Microsoft-Serverfehler ab.
# ------------------------------------------------------------------------------
try:
    print("[Schritt 1] Ermittle aktuellen Systempfad...")
    
    # ls("/") scannt das Root-Verzeichnis des Linux-Servers im Hintergrund.
    # Es liefert uns die exakte, kryptische OneLake-URL Ihres Lakehouses.
    pfad_liste = notebookutils.fs.ls("/")
    
    # Da pfad_liste ein spezielles Fabric-Listenobjekt ist, greifen wir auf das
    # Attribut '.path' des ersten Elements zu, um die reine URL zu extrahieren.
    standard_pfad = pfad_liste[0].path
    print(f" -> Systempfad erfolgreich ausgelesen: '{standard_pfad}'")

except Exception as e:
    # Falls Microsoft die Verbindung verliert, fängt 'except' den Absturz ab.
    print(f" !!! KRITISCHER FEHLER in Schritt 1: {e}")
    # sys.exit() stoppt die Zelle sofort. Der Code darunter wird gar nicht erst ausgeführt.
    sys.exit()

# ------------------------------------------------------------------------------
# SCHRITT 2: DEN DATEIPFAD ZUSAMMENBAUEN
# ------------------------------------------------------------------------------
try:
    print("\n[Schritt 2] Baue Pfad zur CSV-Datei zusammen...")
    
    # f-String (Formatierter String): Wir hängen das Verzeichnis Ihrer CSV-Datei
    # dynamisch an den eben ausgelesenen Hauptpfad an.
    vollstaendiger_pfad = f"{standard_pfad}/Files/orders/2019.csv"
    print(f" -> Finaler Pfad definiert: '{vollstaendiger_pfad}'")

except Exception as e:
    print(f" !!! FEHLER in Schritt 2: {e}")
    sys.exit()

# ------------------------------------------------------------------------------
# SCHRITT 3: SPARK LADEBEFEHL (DIE DATEN IN DAS DATAFRAME ZWINGEN)
# ------------------------------------------------------------------------------
try:
    print("\n[Schritt 3] Lade Daten in das Spark DataFrame (df)...")
    
    # WICHTIG: Der Backslash (\) am Zeilenende erlaubt es uns, einen langen 
    # Befehl über mehrere Zeilen zu schreiben, ohne dass Python einen Syntaxfehler wirft.
    df = spark.read.format("csv") \
        .option("header", "false") \
        .option("inferSchema", "true") \
        .load(vollstaendiger_pfad)
        
    print(" -> ERFOLG: Daten befinden sich jetzt einsatzbereit in der Variable 'df'!")
    print(f" -> Spaltenstruktur: {df.columns}")

except Exception as e:
    print(f" !!! FEHLER beim Laden der Daten (Spark-Load): {e}")
    sys.exit()

# ------------------------------------------------------------------------------
# SCHRITT 4: TEXTBASIERTE DATENVORSCHAU (UMGEHUNG DES # display-ABSTURZES)
# ------------------------------------------------------------------------------
try:
    print("\n[Schritt 4] Zeige die ersten 5 Datenzeilen als reinen Text an...")
    
    # .show(5) ist die textbasierte Rettung. Im Gegensatz zu # display() versucht 
    # .show() nicht, eine schicke HTML-Tabelle zu bauen, wodurch es absolut 
    # immun gegen Abstürze durch Sonderzeichen (wie Kommas in Spaltenüberschriften) ist.
    df.show(5)
    
    print("\n=== PROGRAMM ERFOLGREICH BEENDET ===")

except Exception as e:
    print(f" !!! FEHLER bei der Textausgabe: {e}")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Distinct Behandlung, Ermittlung des absoluten Datei-Pfades
from pyspark.sql.types import *
import notebookutils
from pyspark.sql.functions import *

print("=== SCHRITT 1: DEFINE SCHEMA ===")
orderSchema = StructType([
   StructField("SalesOrderNumber", StringType(), True),
   StructField("SalesOrderLineNumber", IntegerType(), True),
   StructField("OrderDate", DateType(), True),
   StructField("CustomerName", StringType(), True),
   StructField("Email", StringType(), True),
   StructField("Item", StringType(), True),
   StructField("Quantity", IntegerType(), True),
   StructField("UnitPrice", FloatType(), True),
   StructField("Tax", FloatType(), True)
])

print("=== SCHRITT 2: ERMITTLE PFAD AUTOMATISCH ===")
pfad_liste = notebookutils.fs.ls("/")
standard_pfad = pfad_liste[0].path
vollstaendiger_pfad = f"{standard_pfad}/Files/orders/*.csv"
print(f" -> Pfad erfolgreich ermittelt: {vollstaendiger_pfad}")

print("=== SCHRITT 3: LADEN MIT SCHEMA ===")
df = spark.read.format("csv") \
   .schema(orderSchema) \
   .option("header", "false") \
   .load(vollstaendiger_pfad)

print("=== SCHRITT 4: AUSGABE & ANALYSEN ===")

# 4.1 Eindeutige Jahre ermitteln
df_year = df.select(year("OrderDate").alias("Year")).distinct()
# display(df_year)            

# 4.2 Kunden-Filter für Produkt 'Road-250 Red, 52'
customers_250 = df.select("CustomerName", "Email").where(df['Item'] == 'Road-250 Red, 52')
print("Kunden (Road-250) - Gesamtzeilen: ", customers_250.count())
print("Kunden (Road-250) - Eindeutige Accounts: ", customers_250.distinct().count())
# display(customers_250.distinct())

# 4.3 Auswahl korrigiert (Nutzt jetzt .select)
customers_all = df.select('CustomerName', 'Email', 'Item')
print("Alle Kundenbeziehungen - Gesamt: ", customers_all.count())
print("Alle Kundenbeziehungen - Eindeutig: ", customers_all.distinct().count())

# 4.4 Kunden-Filter für Produkt 'Road-150 Red, 52'
customers_150 = df.select("CustomerName", "Email").where(df['Item'] == 'Road-150 Red, 52')
print("Kunden (Road-150) - Gesamtzeilen: ", customers_150.count())
print("Kunden (Road-150) - Eindeutige Accounts: ", customers_150.distinct().count())

# 4.5 Aggregation mit sauberem Spaltennamen
productSales = df.select("Item", "Quantity").groupBy("Item").sum("Quantity")
# display(productSales)

from pyspark.sql.functions import *

yearlySales = df.select(year(col("OrderDate")).alias("Year")).groupBy("Year").count().orderBy("Year")

display(yearlySales)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

customers = df.select('CustomerName', 'Email', 'OrderDate')

print(customers.count())
print(customers.distinct().count())


# display(customers.distinct())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# from pyspark.sql.functions import *

yearlySales = df.select(year(col("OrderDate")).alias("Year")) \
                .groupBy("Year") \
                .count() \
                .orderBy("Year")

display(yearlySales)


# Wenn du .agg() nutzt, öffnest du quasi einen "Bereich" für Spaltenfunktionen. Hier drin darfst du die Funktion count("*")
# aufrufen und ihr direkt ein .alias() verpassen. Du sparst dir also das spätere Umbenennen.

yearlySales2 = df.select(year(col("OrderDate")).alias("Year")) \
                 .groupBy("Year") \
                 .agg(count("*").alias("Anzahl_Bestellungen")) \
                 .orderBy("Year")

display(yearlySales2)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import year

print("=== EINDEUTIGE JAHRE AUS CUSTOMERS ERMITTELN ===")

# 1. Wir fügen eine neue Spalte 'Year' hinzu, die das Jahr extrahiert
# 2. Wir wählen nur diese Spalte aus, filtern auf eindeutige Werte und sortieren
# Was es tut: Dieser Befehl nimmt Ihr bestehendes DataFrame customers und fügt eine neue Spalte hinzu (oder überschreibt eine bestehende)
# Der Inhalt: Hier rufen wir die PySpark-Funktion year() auf und füttern sie mit Ihrer Datumsspalte "OrderDate". PySpark berechnet nun für 
# jede einzelne Zeile blitzschnell das Kalenderjahr. An dieser Stelle des Fließbands hat unsere Tabelle also temporär vier Spalten: CustomerName, Email, OrderDate und die brandneue Spalte Year.
# .select("Year")Was es tut: Jetzt schrumpfen wir die Tabelle radikal zusammen. Dieser Befehl entspricht exakt dem SELECT Year aus SQL [^4311272].Die Syntax: 
# Wir sagen Spark: „Die Spalten für Name, E-Mail und das genaue Datum interessieren mich ab jetzt nicht mehr. Schneide bitte alle Spalten ab und behalte ab hier nur noch die Spalte namens "Year".
# .distinct()Was es tut: Das ist das direkte Gegenstück zum SQL-Befehl SELECT DISTINCT.Die Syntax: Da in der Spalte Year jetzt für jede einzelne Bestellung das Jahr steht (also zum Beispiel 50.000 Mal die Zahl 2019), 
# scannt dieser Befehl die verbliebene Spalte und löscht alle Duplikate. Jede Jahreszahl bleibt dadurch exakt ein einziges Mal in der Tabelle übrig.
# .sort("Year")Was es tut: Entspricht exakt dem ORDER BY Year ASC in SQL.Die Syntax: Da Spark die Daten auf vielen Servern im Hintergrund gleichzeitig verarbeitet, fliegen die eindeutigen Jahre nach dem .distinct() 
# oft wild durcheinander (z. B. erst 2021, dann 2019). Dieser Befehl bringt die verbliebenen Zeilen in eine saubere, aufsteigende Reihenfolge.
df_years = customers.withColumn("Year", year("OrderDate")) \
                    .select("Year") \
                    .distinct() \
                    .sort("Year")

# 3. Ergebnis im Notebook anzeigen
df_years.show()



# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # Friendly Name

# MARKDOWN ********************

# Kurzfassung:
# Lakehouse/demo/Files/... ist ein logischer „Friendly Name“-Pfad, kein echter Speicherpfad. In deiner aktuellen Umgebung ist diese Friendly‑Name‑Auflösung (bzw. die entsprechenden Mounts) nicht aktiv/verfügbar, deshalb knallt dieser Pfad mit „FriendlyNameSupportDisabled / Bad Request“. Der physische OneLake‑Pfad, den wir per notebookutils.fs.ls("/") auslesen, umgeht dieses Problem.
# 
# Etwas detaillierter:
# 
# Zwei Welten von Pfaden in Fabric
# 
# Logische/Friendly‑Name‑Pfadvarianten, z. B.
# Files/orders/2019.csv (relativ zum Default Lakehouse)
# Lakehouse/demo/Files/... (die Form, die du probiert hast)
# Physische OneLake‑Pfadvarianten, z. B.
# abfss://<workspaceId>@<onelake-endpoint>/<lakehouseId>.Lakehouse/Files/orders/2019.csv
# oder genau das, was notebookutils.fs.ls("/") zurückgibt (das verwenden wir im Skript).
# Was normalerweise funktioniert
# 
# In einem „normal“ konfigurierten Notebook mit einem Default‑Lakehouse kannst du einfach:
# Python
# 
# df = spark.read.csv("Files/orders/*.csv")
# 
# Wenn zusätzlich Friendly‑Name‑Mounts aktiv sind, funktionieren teils auch Pfade wie:
# Python
# 
# "Lakehouse/demo/Files/orders/*.csv"
# 
# Diese Friendly‑Name‑Ebene sitzt wie eine virtuelle Festplatte über OneLake.
# Was bei dir passiert
# 
# Laut der Logik, die wir vorher gesehen haben, wirft OneLake/Microsoft einen Fehler vom Typ „FriendlyNameSupportDisabled“ o. Ä.
# Das bedeutet:
# Die Friendly‑Name‑Schicht ist in dieser Sitzung/Umgebung nicht nutzbar,
# Spark bekommt die Anfrage Lakehouse/demo/Files/... und weiß nicht, wie es diesen Pfad nach OneLake auflösen soll.
# Daher schlägt der Pfad Lakehouse/demo/Files/orders/*.csv fehl, obwohl die Datei im Lakehouse selbst durchaus existiert.
# Warum der „Root‑Pfad“-Trick funktioniert
# 
# notebookutils.fs.ls("/") fragt direkt das Root des bereitgestellten OneLake‑Speichers ab und gibt dir etwas wie:
# Text
# 
# abfss://<workspaceId>@<onelake-endpoint>/<lakehouseId>.Lakehouse
# 
# Wenn wir dann
# Python
# 
# vollstaendiger_pfad = f"{standard_pfad}/Files/orders/*.csv"
# 
# bauen, arbeiten wir direkt auf diesem physischen abfss://‑Pfad – ohne Friendly‑Name‑Mounts, die bei dir Probleme machen.
# OneLake versteht diesen Pfad immer, solange das Lakehouse und die Datei existieren.
# Was du dir merken kannst
# 
# Wenn Files/... oder Lakehouse/<Name>/Files/... zickt, liegt es fast immer an:
# falschem/default Lakehouse,
# fehlenden/inkonsistenten Friendly‑Name‑Mounts,
# oder an einem Bug/Limit in der aktuellen Fabric‑Sitzung.
# Der physische OneLake‑Pfad (über notebookutils.fs.ls("/") oder direkt abfss://...) ist die „harte“ Wahrheit und funktioniert auch dann, wenn die Friendly‑Name‑Ebene ausfällt.
# Wenn du möchtest, kann ich dir auch eine kompakte Variante zeigen, wie du ganz ohne ls("/") direkt aus notebookutils.runtime.context einen stabilen abfss://‑Pfad zum Lakehouse aufbaust.


# CELL ********************

# 1. Daten einlesen (nutzt den kurzen Friendly Path)
df = spark.read.csv("Files/orders/*.csv", header=True, inferSchema=True)

# 2. Daten im Notebook anzeigen
# display(df.limit(5))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # 🏷️ Etablierte Namenskonventionen in Microsoft Fabric
# 
# In der Enterprise-Praxis wird für Fabric-Elemente ein festes **Präfix-System** nach dem Muster `[Typ]_[Projekt/Thema]_[Umgebung]` genutzt. Das verhindert das Chaos bei den unübersichtlichen Browser-Reitern.
# 
# ---
# 
# ### 📋 Best-Practice-Präfixe für die Typenerkennung
# 
# | Item-Typ | Präfix | Beispiel (Entwicklung) | Beispiel (Produktion) |
# | :--- | :--- | :--- | :--- |
# | **Notebook** | `nb_` | `nb_orders_transform_dev` | `nb_orders_transform_prod` |
# | **Lakehouse** | `lh_` | `lh_demo_dev` | `lh_demo_prod` |
# | **Data Pipeline** | `pl_` | `pl_ingest_sap_dev` | `pl_ingest_sap_prod` |
# | **Dataflow Gen2** | `df_` | `df_clean_customers_dev` | `df_clean_customers_prod` |
# | **Semantic Model** | `sem_` | `sem_sales_reporting_dev` | `sem_sales_reporting_prod` |
# | **Power BI Report** | `rep_` | `rep_executive_dashboard` | `rep_executive_dashboard` |
# 
# ---
# 
# ### 💡 3 Profi-Tipps für die Benennung im Alltag
# 
# * **Kleinschreibung für Präfixe:** Nutze immer Kleinbuchstaben für das Kürzel (`lh_`, `nb_`), gefolgt von einem Unterstrich. Das liest sich im Browser-Tab am schnellsten.
# * **Der SQL-Endpunkt-Automatismus:** Da Fabric den SQL-Analyse-Endpunkt immer exakt so benennt wie das Lakehouse (nur mit grauem Zusatz), hilft das Präfix `lh_` doppelt, um beide Reiter sofort zuzuordnen.
# * **Umgebungen trennen:** Gewöhne dir das Suffix `_dev` (Development) an. Wenn du später Pipelines baust, erkennst du sofort, ob du im Test- oder Echtheitsmodus arbeitest.


# MARKDOWN ********************

# # 🏛️ Arbeitsbereiche (Workspaces) und Artefakte in Microsoft Fabric
# 
# Um die Struktur in Fabric zu verstehen, hilft das Bild eines **Großraumbüros**:
# * Der **Arbeitsbereich (Workspace)** ist dein eigenes Projektbüro.
# * Die **Artefakte** sind die Werkzeuge, Maschinen und Aktenschränke, die in diesem Büro stehen.
# 
# ---
# 
# ## 🏢 1. Was macht man mit Arbeitsbereichen (Workspaces)?
# 
# Ein Arbeitsbereich ist die oberste Organisationseinheit in Fabric. Du nutzt ihn für drei Kernaufgaben:
# 
# * **Zusammenarbeit & Berechtigungen:** Du teilst nicht einzelne Notebooks, sondern den ganzen Workspace. Wer Zugriff auf den Workspace hat, kann (je nach Rolle) alle darin liegenden Elemente sehen oder bearbeiten.
# * **Kapazitäts-Zuweisung:** Jeder Workspace ist an eine Fabric-Kapazität (Rechenleistung/Lizenz) gekoppelt. Als Admin bestimmst du hier, welcher Workspace wie viel "Power" vom Server bekommt.
# * **Strukturierung von Projekten:** Man erstellt meist separate Workspaces pro Abteilung (z.B. `ws_controlling`) oder pro Entwicklungsstufe (`ws_sales_dev`, `ws_sales_prod`).
# 
# ---
# 
# ## 🛠️ 2. Was macht man mit den anderen Artefakten?
# 
# Jedes "Element", das du in Fabric anlegst, wird als **Artefakt** bezeichnet. Sie greifen wie Zahnräder ineinander, um Daten von der Quelle bis zum fertigen Bericht zu transportieren:
# 
# ### 📥 Datenbeschaffung (Data Factory)
# * **Data Pipelines (`pl_`):** Das ist der "Logistik-Manager". Pipelines steuern den zeitlichen Ablauf. Sie sagen: *"Hole jeden Morgen um 05:00 Uhr die Daten aus der SQL-Datenbank und starte danach das Notebook."*
# * **Dataflows Gen2 (`df_`):** Das ist die "Waschstraße" für Low-Code-Entwickler (Power Query). Hier klickst du dir Transformationen visuell zusammen (z.B. Spalten filtern, Datentypen ändern), ohne Code zu schreiben.
# 
# ### 🗄️ Datenspeicherung & Verarbeitung (Data Engineering / Science)
# * **Lakehouse (`lh_`):** Dein zentraler Datensee. Hier landen rohe CSV/Parquet-Dateien im Ordner `Files` und strukturierte Delta-Tabellen im Ordner `Tables`.
# * **Notebooks (`nb_`):** Die "High-Code-Werkstatt". Hier schreibst du deinen Spark-Code (Python/Scala), um riesige Datenmengen blitzschnell zu bereinigen, zu aggregieren oder Machine-Learning-Modelle zu trainieren.
# 
# ### 📊 Datenbereitstellung & Visualisierung (Power BI / Real-Time)
# * **Semantic Models (`sem_`):** Das logische Datenmodell. Es verbindet deine Tabellen aus dem Lakehouse, definiert Beziehungen (z.B. *Kunden* verknüpft mit *Umsatz*) und enthält Berechnungen (Measures). Es nutzt den **Direct Lake-Modus** für Echtzeit-Zugriff ohne Datenkopie.
# * **Power BI Reports (`rep_`):** Die finale Fassade. Das interaktive Dashboard mit Grafiken, Diagrammen und Filtern, das sich die Manager und Fachabteilungen ansehen, um Entscheidungen zu treffen.


# MARKDOWN ********************

# ## 🏷️ Namenskonvention für Arbeitsbereiche (Workspaces)
# 
# Da Arbeitsbereiche die Klammer um alle deine Tools bilden, nutzt man hier meist das Schema: `ws_[Abteilung/Projekt]_[Umgebung]`.
# 
# | Artefakt-Typ | Präfix | Beispiel (Entwicklung) | Beispiel (Produktion) |
# | :--- | :--- | :--- | :--- |
# | **Workspace** | `ws_` | `ws_sales_analytics_dev` | `ws_sales_analytics_prod` |
# | **Deployment Pipeline** | `dpl_` | `dpl_sales_release` | *(Steuert den Code-Transport)* |
# 
# ---
# 
# ## 📋 Das vollständige Zusammenspiel im Browser-Tab
# 
# Wenn du künftig deine Komponenten im selben Projekt öffnest, erkennst du anhand der Browser-Reiter sofort blind, in welcher Ebene du dich bewegst:
# 
# ```text
# [ws_sales_dev]       -> Dein aktueller Arbeitsbereich (Das Projektbüro)
#   ├── [pl_ingest]    -> Die Daten-Pipeline (Holt die Rohdaten ab)
#   ├── [lh_sales]     -> Das Lakehouse (Hier liegen die Daten im OneLake)
#   ├── [nb_transform] -> Das Notebook (Dein 3-Zeiler Spark-Code zur Bereinigung)
#   └── [sem_reporting]-> Das Semantic Model (Die Logik/Beziehungen für Power BI)


# MARKDOWN ********************

# # Transform and Filter

# CELL ********************

from pyspark.sql.functions import *

# Create Year and Month columns
transformed_df = df.withColumn("Year", year(col("OrderDate"))).withColumn("Month", month(col("OrderDate")))

# Create the new FirstName and LastName fields
transformed_df = transformed_df.withColumn("FirstName", split(col("CustomerName"), " ").getItem(0)).withColumn("LastName", split(col("CustomerName"), " ").getItem(1))

# Filter and reorder columns
transformed_df = transformed_df["SalesOrderNumber", "SalesOrderLineNumber", "OrderDate", "Year", "Month", "FirstName", "LastName", "Email", "Item", "Quantity", "UnitPrice", "Tax"]

# # display the first five orders
# display(transformed_df.limit(5))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # 📘 Pfadangaben
# 
# Dieses Dokument fasst die wichtigsten Erkenntnisse, Fehlerbehebungen und Best Practices aus den Praxis-Übungen zusammen.
# 
# ---
# 
# ## 🛠️ 1. Fehlerbehebung: "FriendlyNameSupportDisabled" / Bad Request
# 
# Wenn der logische Pfad `Lakehouse/demo/Files/...` oder `Files/...` fehlschlägt, obwohl die Datei im UI sichtbar ist, liegt das an einer fehlenden oder inaktiven Standard-Verknüpfung im Notebook.
# 
# ### 🔄 Die zwei Pfad-Welten in Fabric
# * **Logischer Pfad (Friendly Name):** `Files/orders/2019.csv`  
#   *Sitzt wie eine virtuelle Festplatte über dem Speicher. Funktioniert nur, wenn ein Default-Lakehouse zugewiesen ist.*
# * **Physischer Pfad (Die Wahrheit):** `abfss://[Workspace_ID]@[Target]/.Lakehouse/Files/...`  
#   *Direktzugriff auf den OneLake-Speicher. Funktioniert immer, ist aber lang und kryptisch.*
# 
# ### 🎯 Die Lösung: Default-Lakehouse zuweisen
# 1. Öffne das Notebook und klicke ganz links auf das Symbol für **Datenelemente** (Zylinder-Symbol).
# 2. Falls die Leiste leer ist: Klicke auf **"Aus OneLake-Katalog"** (Existing Lakehouse) und füge das gewünschte Lakehouse hinzu.
# 3. Stelle sicher, dass das Lakehouse im Explorer visuell als **(Standard)** oder **(Default)** markiert ist (erkennbar an einer kleinen blauen Stecknadel).
# 4. **Wichtig:** Starte die Spark-Sitzung danach einmal neu, um die Mount-Pfade frisch einzulesen!
# 
# ### 🐌 Hinweis zum "Kaltstart" (Cold Start)
# Beim ersten Ausführen einer Zelle nach einer Pause kann der Vorgang **30 Sekunden bis 2 Minuten** dauern. Fabric muss im Hintergrund erst eine virtuelle Maschine (Spark-Session) für dich reservieren und hochfahren. Danach reagieren alle weiteren Zellen in Bruchteilen von Sekunden.
# 
# ---
# 
# # 🏷️ Namenskonventionen (Naming Conventions) im Enterprise-Einsatz
# 
# Um das Chaos bei unübersichtlichen Browser-Reitern (Tabs) zu verhindern, wird für alle Elemente ein festes Präfix-System nach dem Muster `[Typ]_[Projekt]_[Umgebung]` genutzt.
# 
# ### 📋 Best-Practice-Präfixe
# 
# | Artefakt-Typ | Präfix | Beispiel (Entwicklung) | Beispiel (Produktion) |
# | :--- | :--- | :--- | :--- |
# | **Workspace** | `ws_` | `ws_sales_analytics_dev` | `ws_sales_analytics_prod` |
# | **Lakehouse** | `lh_` | `lh_demo_dev` | `lh_demo_prod` |
# | **Notebook** | `nb_` | `nb_orders_transform_dev` | `nb_orders_transform_prod` |
# | **Data Pipeline** | `pl_` | `pl_ingest_sap_dev` | `pl_ingest_sap_prod` |
# | **Dataflow Gen2** | `df_` | `df_clean_customers_dev` | `df_clean_customers_prod` |
# | **Semantic Model** | `sem_` | `sem_sales_reporting_dev` | `sem_sales_reporting_prod` |
# | **Power BI Report** | `rep_` | `rep_executive_dashboard` | `rep_executive_dashboard` |
# 
# > **💡 Wichtig für Lakehouses:** Fabric erstellt automatisch einen *SQL-Analyse-Endpunkt*, der exakt wie das Lakehouse heißt. Durch das Präfix `lh_` im Namen siehst du im Browser-Tab sofort, welcher Reiter zum eigentlichen Speicher gehört und welcher zur SQL-Leseansicht.
# 
# ---
# 
# ```python


# MARKDOWN ********************

# # 📊 PySpark-Spaltenauswahl: Die unterschiedlichen Schreibweisen bei DataFrames
# 
# Beim Arbeiten mit PySpark-DataFrames gibt es verschiedene Philosophien und Syntax-Varianten, um Spalten auszuwählen oder zu manipulieren. Unter der Motorhaube nutzt PySpark für alle Varianten dieselbe **Catalyst-Optimierungs-Engine** – das bedeutet, alle Schreibweisen sind technisch absolut identisch und exakt gleich schnell! Die Unterschiede liegen rein in der Lesbarkeit, Flexibilität und Herkunft der Syntax.
# 
# ---
# 
# ## 🏛️ Variante 1: Die SQL-Schreibweise (`.select`)
# 
# Diese Variante nutzt reine Strings innerhalb der `.select()`-Methode und fühlt sich sehr stark nach klassischem SQL an.
# 
# ```python
# # Auswahl von Spalten als einfache Text-Strings
# df_sql = df.select("OrderDate", "CustomerID")
# 
# ```
# 
# ### 🎯 Einsatzbereich
# 
# Schnelle Datensichtung, einfaches Filtern oder Laden von bestehenden Feldern.
# 
# ### 🟢 Vorteile
# 
# * **Maximale Lesbarkeit:** Der Code bleibt extrem schlank und sauber.
# * **Intuitiv für SQL-Umsteiger:** Wer SQL beherrscht, versteht diese Logik sofort, da sie dem klassischen `SELECT column1, column2 FROM table` entspricht.
# 
# ### 🔴 Nachteile
# 
# * **Eingeschränkte Dynamik:** Man kann innerhalb der reinen Strings keine direkten mathematischen Berechnungen, Aliase (Umbenennungen) oder komplexen logischen Operationen durchführen.
# 
# ---
# 
# ## 🐍 Variante 2: Die native Python/Pandas-Schreibweise (`[]`)
# 
# Diese Variante greift über eckige Klammern direkt auf das DataFrame-Objekt zu und extrahiert die Spalten-Objekte (die sogenannten `Column`-Objekte).
# 
# ```python
# # Auswahl von Spalten über eine Liste in eckigen Klammern
# df_pandas = df[["OrderDate", "CustomerID"]]
# 
# ```
# 
# ### 🎯 Einsatzbereich
# 
# Wenn man bestehende Skripte aus der klassischen Python-Bibliothek *Pandas* portiert oder Spaltennamen dynamisch über Python-Listen übergibt.
# 
# ### 🟢 Vorteile
# 
# * **Heimatgefühl für Python-Devs:** Wirkt für erfahrene Python-Entwickler, die intensiv mit Data Science-Bibliotheken arbeiten, sofort vertraut.
# * **Einfache Variablen-Übergabe:** Ermöglicht es, vorbereitete Listen von Spaltennamen direkt in die Klammern zu übergeben.
# 
# ### 🔴 Nachteile
# 
# * **Verschachtelungs-Chaos:** Kann bei komplexen Transformationen und stark verschachtelten Klammern (z. B. beim Filtern und gleichzeitigen Aggregieren) optisch sehr schnell unübersichtlich werden.
# 
# ---
# 
# ## 🚀 Variante 3: Die Profi-Schreibweise (`.select` + `col`)
# 
# Der unangefochtene Enterprise-Standard kombiniert die `.select()`-Methode mit der expliziten `col()`-Funktion aus den PySpark-SQL-Funktionen.
# 
# ```python
# from pyspark.sql.functions import col
# 
# # Auswahl und Manipulation über explizite Spalten-Objekte
# df_profi = df.select(col("OrderDate"), col("CustomerID"))
# 
# ```
# 
# ### 🎯 Einsatzbereich
# 
# Der Standard für alle echten Data-Engineering-Pipelines und fortgeschrittenen Transformationen.
# 
# ### 🟢 Vorteile
# 
# * **Absolute Flexibilität:** Nur mit dieser Schreibweise lassen sich direkt mathematische oder logische Berechnungen anstellen.
# * **In-Line Transformationen:** Erlaubt direkte Modifikationen wie Berechnungen (`col("Preis") * 1.19`), Typkonvertierungen (`.cast()`) oder direkte Umbenennungen (`.alias()`) in einer einzigen Zeile.
# 
# ### 🔴 Nachteile
# 
# * **Boilerplate-Code:** Erfordert zu Beginn den Import der `col`-Funktion aus `pyspark.sql.functions` und macht die Codezeilen minimal länger.
# 
# ---
# 
# ## 💡 Praxis-Empfehlung & Richtlinie für die Labs
# 
# 1. **Für einfaches Sichten & Laden:** Nutze Variante 1 (`df.select("Spalte")`). Das spart wertvolle Tipparbeit und hält den Code bei der initialen Datenanalyse angenehm kurz.
# 2. **Sobald gerechnet, gefiltert oder umbenannt wird:** Wechsle sofort auf Variante 3 mit `col()`. Das verhindert, dass du deinen Code später mühsam umbauen musst, wenn neue Berechnungen (wie z. B. Datumsformatierungen oder MwSt-Aufschläge) hinzukommen.


# MARKDOWN ********************

# # How-to transform data files

# CELL ********************

from pyspark.sql.functions import *

# Create Year and Month columns
transformed_df = df.withColumn("Year", year(col("OrderDate"))).withColumn("Month", month(col("OrderDate")))

# Create the new FirstName and LastName fields
transformed_df = transformed_df.withColumn("FirstName", split(col("CustomerName"), " ").getItem(0)).withColumn("LastName", split(col("CustomerName"), " ").getItem(1))
display(transformed_df.limit(5))

# Filter and reorder columns
transformed_df = transformed_df["SalesOrderNumber", "SalesOrderLineNumber", "OrderDate", "Year", "Month", "FirstName", "LastName", "Email", "Item", "Quantity", "UnitPrice", "Tax"]

# Display the first five orders
display(transformed_df.limit(5))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # Save 

# CELL ********************

transformed_df.write.mode("overwrite").parquet('Files/transformed_data/orders')

print ("Transformed data saved!")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

orders_df = spark.read.format("parquet").load("Files/transformed_data/orders")
display(orders_df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # Save data in partitioned files

# MARKDOWN ********************


# CELL ********************

orders_df.write.partitionBy("Year","Month").mode("overwrite").parquet("Files/partitioned_data")

print ("Transformed data saved!")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

orders_2021_df = spark.read.format("parquet").load("Files/partitioned_data/Year=2021/Month=*")

display(orders_2021_df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # Work with tables and SQL

# CELL ********************

# Create a new table
df.write.format("delta").saveAsTable("salesorders")

# Get the table description
spark.sql("DESCRIBE EXTENDED salesorders").show(truncate=False)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df = spark.sql("SELECT * FROM dbo.salesorders LIMIT 1000")

display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# Wenn du echte Tabellen in einem anderen Schema als dbo ablegen willst, musst du das direkt über dein Spark-Notebook machen. Spark nutzt dafür das Konzept von Datenbanken/Namespaces, die Fabric dann eins zu eins als SQL-Schema spiegelt.
# 
# Führe folgenden Code in einer Notebook-Zelle aus:

# CELL ********************

# 1. Erstelle ein neues Schema (Namespace) im Lakehouse
spark.sql("CREATE DATABASE IF NOT EXISTS finanzen")

# 2. Schreibe dein DataFrame in das neue Schema
df.write.format("delta").mode("overwrite").saveAsTable("finanzen.aktien_kurse")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# MAGIC %%sql
# MAGIC SELECT YEAR(OrderDate) AS OrderYear,
# MAGIC       SUM((UnitPrice * Quantity) + Tax) AS GrossRevenue
# MAGIC FROM salesorders
# MAGIC GROUP BY YEAR(OrderDate)
# MAGIC ORDER BY OrderYear;

# METADATA ********************

# META {
# META   "language": "sparksql",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # matplotlib

# CELL ********************


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from matplotlib import pyplot as plt
sqlQuery = "SELECT CAST(YEAR(OrderDate) AS CHAR(4)) AS OrderYear, \
               SUM((UnitPrice * Quantity) + Tax) AS GrossRevenue, \
               COUNT(DISTINCT SalesOrderNumber) AS YearlyCounts \
           FROM salesorders \
           GROUP BY CAST(YEAR(OrderDate) AS CHAR(4)) \
           ORDER BY OrderYear"
df_spark = spark.sql(sqlQuery)



# matplotlib requires a Pandas dataframe, not a Spark one
df_sales = df_spark.toPandas()

# Create a bar plot of revenue by year
plt.bar(x=df_sales['OrderYear'], height=df_sales['GrossRevenue'])

# Display the plot
plt.show()

# Clear the plot area
plt.clf()

# Create a bar plot of revenue by year
plt.bar(x=df_sales['OrderYear'], height=df_sales['GrossRevenue'], color='orange')

# Customize the chart
plt.title('Revenue by Year')
plt.xlabel('Year')
plt.ylabel('Revenue')
plt.grid(color='#95a5a6', linestyle='--', linewidth=2, axis='y', alpha=0.7)
plt.xticks(rotation=45)

# Show the figure
plt.show()

# Clear the plot area
plt.clf()

# Create a figure for 2 subplots (1 row, 2 columns)
fig, ax = plt.subplots(1, 2, figsize = (10,4))

# Create a bar plot of revenue by year on the first axis
ax[0].bar(x=df_sales['OrderYear'], height=df_sales['GrossRevenue'], color='orange')
ax[0].set_title('Revenue by Year')

# Create a pie chart of yearly order counts on the second axis
ax[1].pie(df_sales['YearlyCounts'])
ax[1].set_title('Orders per Year')
ax[1].legend(df_sales['OrderYear'])

# Add a title to the Figure
fig.suptitle('Sales Data')

# Show the figure
plt.show()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # seaborn library
# While matplotlib enables you to create different chart types, it can require some complex code to achieve the best results. For this reason, new libraries have been built on matplotlib to abstract its complexity and enhance its capabilities. One such library is seaborn.

# CELL ********************

import seaborn as sns
import warnings

# Clear the plot area
plt.clf()

# Suppress FutureWarning from seaborn
warnings.filterwarnings('ignore', message='use_inf_as_na', category=FutureWarning)

# Create a bar chart
ax = sns.barplot(x="OrderYear", y="GrossRevenue", data=df_sales)

plt.show()

plt.clf()

# Set the visual theme for seaborn
sns.set_theme(style="whitegrid")

# Create a bar chart
ax = sns.barplot(x="OrderYear", y="GrossRevenue", data=df_sales)

plt.show()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
