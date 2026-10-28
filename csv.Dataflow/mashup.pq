[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Append"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"order csv" = let
  Quelle = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Quelle{[workspaceId = "1d2e0f27-357d-4e97-929a-5f008c66d124"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseName = "lh_demo"]}[Data],
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
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "production csv_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "ProductID", DestinationColumnName = "ProductID"], [SourceColumnName = "Plant", DestinationColumnName = "Plant"], [SourceColumnName = "ProductionDate", DestinationColumnName = "ProductionDate"], [SourceColumnName = "IngestionDateTime", DestinationColumnName = "IngestionDateTime"]}], DynamicSchema = false, UpdateMethod = [Kind = "Append"], TypeSettings = [Kind = "Table"]]]}]
shared #"production csv" = let
  Quelle = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  
  // 1. Steuert Ihren neuen Entwicklungs-Workspace an:
  #"Navigation 1" = Quelle{[workspaceId = "1d2e0f27-357d-4e97-929a-5f008c66d124"]}[Data],
  
  // 2. KORREKTUR: Sucht das Lakehouse jetzt über die exakte Spalte "lakehouseName"!
  #"Navigation 2" = #"Navigation 1"{[lakehouseName = "lh_demo"]}[Data],
  
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "demo"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "production.csv"]}[Content],
  #"Importierte CSV" = Csv.Document(#"Navigation 5", [Delimiter = ";", Columns = 6, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Erste Zeile als Überschriften verwenden" = Table.PromoteHeaders(#"Importierte CSV", [PromoteAllScalars = true]),
  #"Spalte hinzufügen" = Table.AddColumn(#"Erste Zeile als Überschriften verwenden", "IngestionDateTime", each DateTimeZone.RemoveZone(DateTimeZone.SwitchZone(DateTimeZone.UtcNow(),2)), type datetime),
  #"Geänderter Spaltentyp" = Table.TransformColumnTypes(#"Spalte hinzufügen", {{"IngestionDateTime", type text}})
in
  #"Geänderter Spaltentyp";
shared #"supply_chain csv" = let
  Quelle = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Quelle{[workspaceId = "1d2e0f27-357d-4e97-929a-5f008c66d124"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseName = "lh_demo"]}[Data],
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
shared DefaultDestination = let
  Quelle = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = true]),
  #"Navigation 1" = Quelle{[workspaceId = "1d2e0f27-357d-4e97-929a-5f008c66d124"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[warehouseId = "6d1f908a-0adb-46ec-93ae-c8d35d2ff2cf"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Schema = "stg"]}[Data]
in
  #"Navigation 3";
shared #"production csv_DataDestination" = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "1d2e0f27-357d-4e97-929a-5f008c66d124"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "6d1f908a-0adb-46ec-93ae-c8d35d2ff2cf"]}[Data],
  Navigation_3 = Navigation_2{[Schema = "stg"]}[Data],
  TableNavigation = Navigation_3{[Name = "production"]}[Data]
in
  TableNavigation;
