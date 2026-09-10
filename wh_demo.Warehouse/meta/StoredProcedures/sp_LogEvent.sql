CREATE PROCEDURE [meta].[sp_LogEvent]
    @EventType      VARCHAR(20),          -- 'RUN_START', 'RUN_END', 'TABLE_LOAD'
    @ExecutionID    VARCHAR(36),          -- @pipeline().RunId aus Fabric
    @PipelineName   VARCHAR(100) = NULL,  -- @pipeline().Pipeline
    @TargetSchema   VARCHAR(50)  = NULL,  -- z.B. 'gold'
    @TargetTable    VARCHAR(100) = NULL,  -- z.B. 'FactOrder'
    @RowsAffected   BIGINT       = NULL,  -- Anzahl kopierter Zeilen
    @StartTime      DATETIME2(6) = NULL,  -- Startzeitstempel
    @EndTime        DATETIME2(6) = NULL,  -- Endzeitstempel
    @Status         VARCHAR(20)  = NULL,  -- 'RUNNING', 'SUCCESS', 'FAILED'
    @ErrorMessage   VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- A. Pipeline-Start
    IF @EventType = 'RUN_START'
    BEGIN
        INSERT INTO [meta].[ExecutionRun] ([ExecutionID], [PipelineName], [Status], [StartTime])
        VALUES (@ExecutionID, @PipelineName, COALESCE(@Status, 'RUNNING'), @StartTime);
    END

    -- B. Pipeline-Ende (Erfolg oder Fehler)
    ELSE IF @EventType = 'RUN_END'
    BEGIN
        UPDATE [meta].[ExecutionRun]
        SET [Status]       = @Status,
            [EndTime]      = @EndTime,
            [ErrorMessage] = @ErrorMessage
        WHERE [ExecutionID] = @ExecutionID;
    END

    -- C. Einzelner Tabellen-Load (Activities in Child-Pipeline)
    ELSE IF @EventType = 'TABLE_LOAD'
    BEGIN
        INSERT INTO [meta].[TableLoadLog] (
            [ExecutionID], [TargetSchema], [TargetTable], 
            [RowsAffected], [StartTime], [EndTime], [Status], [ErrorMessage]
        )
        VALUES (
            @ExecutionID, @TargetSchema, @TargetTable, 
            @RowsAffected, @StartTime, @EndTime, @Status, @ErrorMessage
        );
    END
END;