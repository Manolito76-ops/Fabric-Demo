CREATE   PROCEDURE [util].[sp_GetIngestionTime]
    @IngestionTime DATETIME2(6) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Kapselung: Zentrale Generierung der deutschen Ortszeit (CET/CEST)
    SET @IngestionTime = CAST(SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE 'W. Europe Standard Time' AS DATETIME2(6));
END;