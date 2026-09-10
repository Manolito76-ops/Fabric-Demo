[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"bom csv" = let
  Quelle = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Quelle{[workspaceId = "ba5a0249-6e08-49fe-b8bb-8e4cc68fb755"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "6a4767e2-858d-4d69-85af-d74f53d7a60b"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "demo"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "bom.csv"]}[Content],
  #"Importierte CSV" = Csv.Document(#"Navigation 5", [Delimiter = ";", Columns = 4, QuoteStyle = QuoteStyle.None]),
  // Erste Zeile als Überschrift verwenden
  BomCsv = Table.PromoteHeaders(#"Importierte CSV", [PromoteAllScalars = true]),
  #"Spalte hinzufügen" = Table.AddColumn(BomCsv, "IngestionDateTime", each DateTimeZone.RemoveZone(
        DateTimeZone.SwitchZone(
            DateTimeZone.UtcNow(),
            2
        )
    ), type datetime),
  #"Geänderter Spaltentyp" = Table.TransformColumnTypes(#"Spalte hinzufügen", {{"IngestionDateTime", type text}})
in
  #"Geänderter Spaltentyp";
shared #"order csv" = let
  Quelle = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Quelle{[workspaceId = "ba5a0249-6e08-49fe-b8bb-8e4cc68fb755"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "6a4767e2-858d-4d69-85af-d74f53d7a60b"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "demo"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "order.csv"]}[Content],
  #"Importierte CSV" = Csv.Document(#"Navigation 5", [Delimiter = ";", Columns = 5, QuoteStyle = QuoteStyle.None]),
  #"Erste Zeile als Überschriften verwenden" = Table.PromoteHeaders(#"Importierte CSV", [PromoteAllScalars = true]),
  #"Spalte hinzufügen" = Table.AddColumn(#"Erste Zeile als Überschriften verwenden", "IngestionDateTime", each DateTimeZone.RemoveZone(
        DateTimeZone.SwitchZone(
            DateTimeZone.UtcNow(),
            2
        )
    ), type datetime),
  #"Geänderter Spaltentyp" = Table.TransformColumnTypes(#"Spalte hinzufügen", {{"IngestionDateTime", type text}})
in
  #"Geänderter Spaltentyp";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "production csv_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "ProductionID", DestinationColumnName = "ProductionID"], [SourceColumnName = "ProductID", DestinationColumnName = "ProductID"], [SourceColumnName = "Plant", DestinationColumnName = "Plant"], [SourceColumnName = "Machine", DestinationColumnName = "Machine"], [SourceColumnName = "PlannedQuantity", DestinationColumnName = "PlannedQuantity"], [SourceColumnName = "ProducedQuantity", DestinationColumnName = "ProducedQuantity"], [SourceColumnName = "DefectiveQuantity", DestinationColumnName = "DefectiveQuantity"], [SourceColumnName = "DurationHours", DestinationColumnName = "DurationHours"], [SourceColumnName = "ProductionDate", DestinationColumnName = "ProductionDate"], [SourceColumnName = "IngestionDateTime", DestinationColumnName = "IngestionDateTime"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"production csv" = let
  Quelle = Lakehouse.Contents([
    HierarchicalNavigation = null,
    EnableVorder = true,
    OutputMetadataRefresh = true
  ]),
  #"Navigation 1" = Quelle{[workspaceId = "ba5a0249-6e08-49fe-b8bb-8e4cc68fb755"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "6a4767e2-858d-4d69-85af-d74f53d7a60b"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "demo"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "production.csv"]}[Content],
  #"Importierte CSV" = Csv.Document(
    #"Navigation 5",
    [Delimiter = ";", Columns = 9, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),
  #"Erste Zeile als Überschriften verwenden" = Table.PromoteHeaders(
    #"Importierte CSV",
    [PromoteAllScalars = true]
  ),

  // ÄNDERUNG: Dynamisch ALLE vorhandenen Spalten zu Text konvertieren
  #"Alle Als Text" = Table.TransformColumnTypes(
    #"Erste Zeile als Überschriften verwenden",
    List.Transform(
      Table.ColumnNames(#"Erste Zeile als Überschriften verwenden"),
      each {_, type text}
    )
  ),

  // Greift jetzt sauber auf "Alle Als Text" zu
  #"Spalte hinzufügen" = Table.AddColumn(
    #"Alle Als Text",
    "IngestionDateTime",
    each DateTimeZone.RemoveZone(
      DateTimeZone.SwitchZone(DateTimeZone.UtcNow(), 2)
    ),
    type datetime
  )
in
  #"Spalte hinzufügen";
shared #"supply_chain csv" = let
  Quelle = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Quelle{[workspaceId = "ba5a0249-6e08-49fe-b8bb-8e4cc68fb755"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "6a4767e2-858d-4d69-85af-d74f53d7a60b"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "demo"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "supply_chain.csv"]}[Content],
  #"Importierte CSV" = Csv.Document(#"Navigation 5", [Delimiter = ";", Columns = 10, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Erste Zeile als Überschriften verwenden" = Table.PromoteHeaders(#"Importierte CSV", [PromoteAllScalars = true]),
  #"Geänderter Spaltentyp" = Table.TransformColumnTypes(#"Erste Zeile als Überschriften verwenden", {{"ShipmentID", type text}, {"ProductID", type text}, {"Supplier", type text}, {"Warehouse", type text}, {"OrderedQuantity", Int64.Type}, {"LeadTimeDays", Int64.Type}, {"DelayDays", Int64.Type}, {"OrderStatus", type text}, {"OrderDate", type date}, {"DeliveryDate", type date}}, "de"),
  #"Spalte hinzufügen" = Table.AddColumn(#"Geänderter Spaltentyp", "IngestionDateTime", each DateTimeZone.RemoveZone(
            DateTimeZone.SwitchZone(
                DateTimeZone.UtcNow(),
                2
            )
        ), type datetime),
  #"Geänderter Spaltentyp 1" = Table.TransformColumnTypes(#"Spalte hinzufügen", {{"OrderedQuantity", type text}, {"LeadTimeDays", type text}, {"DelayDays", type text}, {"OrderDate", type text}, {"DeliveryDate", type text}, {"IngestionDateTime", type text}})
in
  #"Geänderter Spaltentyp 1";
shared #"production csv_DataDestination" = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "ba5a0249-6e08-49fe-b8bb-8e4cc68fb755"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "dcd09796-5d33-44f4-84b8-e5f729c624c1"]}[Data],
  Navigation_3 = Navigation_2{[Schema = "stg"]}[Data],
  TableNavigation = Navigation_3{[Name = "production"]}[Data]
in
  TableNavigation;
