CREATE PROCEDURE [meta].[sp_LogTableLoad]
    @ExecutionID     VARCHAR(36),
    @TargetSchema    VARCHAR(50),
    @TargetTable     VARCHAR(100),
    @LoadType        VARCHAR(20),
    @RowsAffected    BIGINT,
    @StartTime       DATETIME2(6),
    @EndTime         DATETIME2(6),
    @Status          VARCHAR(20),
    @ErrorMessage    VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Berechnung der Ausführungsdauer in Sekunden
    DECLARE @DurationSeconds DECIMAL(10, 2) = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;

    INSERT INTO [meta].[TableLoadLog] (
        [ExecutionID],
        [TargetSchema],
        [TargetTable],
        [LoadType],
        [RowsAffected],
        [StartTime],
        [EndTime],
        [DurationSeconds],
        [Status],
        [ErrorMessage]
    )
    VALUES (
        @ExecutionID,
        @TargetSchema,
        @TargetTable,
        @LoadType,
        @RowsAffected,
        @StartTime,
        @EndTime,
        @DurationSeconds,
        @Status,
        @ErrorMessage
    );
END;