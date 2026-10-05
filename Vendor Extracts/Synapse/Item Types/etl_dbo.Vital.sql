/********************************************************************************
SCRIPT DEPENDENCIES: None identified.
ITEM TYPE: Vital
NOTES:
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[Vital]
-- SELECT COUNT(*) FROM etl_dbo.vital
CREATE EXTERNAL TABLE [etl_dbo].[Vital]
WITH
(
    LOCATION = 'etl_dbo/Vital',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS
SELECT
    NEWID() AS [Id]
   ,1 AS [ItemSetId]
   ,'CHIGEMMS1CV' AS [DataSourceCode]
   ,CAST(
        CASE
            WHEN src.[VitalMultiplicity] > 1 THEN CONCAT(LEFT(src.[BaseExternalDataId], 188), '_', CAST(src.[VitalSequence] AS varchar(10)))
            ELSE src.[BaseExternalDataId]
        END AS varchar(200)
    ) AS [ExternalDataId]
   ,'1' AS [ExternalDataVersion]
   ,1 AS [DisplayOrder]
   ,CAST(src.[PatientID] AS varchar(100)) AS [PatientExternalDataId]
   ,COALESCE(
       TRY_CAST(src.[DATETIME] AS datetime2),
       TRY_CAST(src.[VDATE] AS datetime2),
       TRY_CAST(src.[ENTERED] AS datetime2)
    ) AS [ClinicallyRelevantDttm]
   ,src.[VitalType] AS [TypeCode]
   ,src.[VitalType] AS [TypeName]
   ,CAST(0 AS bit) AS [IsInvalidated]
   ,NULL AS [InvalidatedDttm]
   ,NULL AS [InvalidatedByProviderExternalDataId]
   ,COALESCE(
       TRY_CAST(src.[ENTERED] AS datetime2),
       TRY_CAST(src.[DATETIME] AS datetime2),
       TRY_CAST(src.[VDATE] AS datetime2)
    ) AS [ExternalDataCreatedDttm]
   ,COALESCE(
       TRY_CAST(src.[DATETIME] AS datetime2),
       TRY_CAST(src.[ENTERED] AS datetime2),
       TRY_CAST(src.[VDATE] AS datetime2)
    ) AS [ExternalDataUpdatedDttm]
   ,NULL AS [Status]
   ,NULL AS [Title]
   ,CAST(0 AS bit) AS [IsSecure]
   ,src.[VitalType] AS [VcoSetEntries]
   ,CAST(
        CONCAT(
            '{',
            '"sourceField":"', STRING_ESCAPE(COALESCE(CAST(src.[SourceField] AS varchar(100)), ''), 'json'), '",',
            '"description":"', STRING_ESCAPE(COALESCE(CAST(src.[Description] AS varchar(200)), ''), 'json'), '",',
            '"recordedFlag":"', STRING_ESCAPE(COALESCE(CAST(src.[RECORDEDFLAG] AS varchar(50)), ''), 'json'), '",',
            '"bp":"', STRING_ESCAPE(COALESCE(CAST(src.[BP] AS varchar(100)), ''), 'json'), '",',
            '"result":"', STRING_ESCAPE(COALESCE(CAST(src.[RESULT] AS varchar(500)), ''), 'json'), '"',
            '}'
        ) AS varchar(4000)
    ) AS [ExtendedProperties]
   ,COALESCE(
        TRY_CAST(src.[DATETIME] AS datetime2),
        TRY_CAST(src.[VDATE] AS datetime2)
    ) AS [ServiceDttm]
   ,TRY_CAST(src.[ENTERED] AS datetime2) AS [RecordedDttm]
   ,COALESCE(
        TRY_CAST(src.[DATETIME] AS datetime2),
        TRY_CAST(src.[VDATE] AS datetime2)
    ) AS [PerformedDttm]
   ,NULL AS [PersonExternalDataId]
   ,CAST(src.[VitalValue] AS varchar(200)) AS [Value]
   ,src.[Units] AS [Units]
   ,NULLIF(CAST(src.[PROV] AS varchar(100)), '') AS [PerformingProviderExternalDataId]
   ,NULLIF(CAST(src.[PROV] AS varchar(100)), '') AS [RecordedByExternalDataId]
   ,NULLIF(CAST(src.[PROV] AS varchar(100)), '') AS [LastUpdatingProviderExternalDataId]
   ,NULL AS [OrderExternalDataId]
   ,NULL AS [EncounterExternalDataId]
FROM
(
    SELECT
        v.*
       ,vs.[VitalType]
       ,vs.[VitalValue]
       ,vs.[Units]
       ,vs.[SourceField]
       ,vs.[Description]
       ,CAST(
            CONCAT(
                vs.[VitalType], '_',
                CAST(v.[PatientID] AS varchar(100)), '_',
                CONVERT(
                    varchar(23),
                    COALESCE(
                        TRY_CAST(v.[DATETIME] AS datetime2),
                        TRY_CAST(v.[VDATE] AS datetime2),
                        TRY_CAST(v.[ENTERED] AS datetime2)
                    ),
                    121
                ), '_',
                CAST(vs.[VitalValue] AS varchar(200))
            ) AS varchar(200)
        ) AS [BaseExternalDataId]
       ,ROW_NUMBER() OVER (
            PARTITION BY
                vs.[VitalType],
                CAST(v.[PatientID] AS varchar(100)),
                CONVERT(
                    varchar(23),
                    COALESCE(
                        TRY_CAST(v.[DATETIME] AS datetime2),
                        TRY_CAST(v.[VDATE] AS datetime2),
                        TRY_CAST(v.[ENTERED] AS datetime2)
                    ),
                    121
                ),
                CAST(vs.[VitalValue] AS varchar(200))
            ORDER BY
                COALESCE(TRY_CAST(v.[ENTERED] AS datetime2), TRY_CAST(v.[DATETIME] AS datetime2), TRY_CAST(v.[VDATE] AS datetime2)),
                COALESCE(NULLIF(CAST(v.[PROV] AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(v.[RECORDEDFLAG] AS varchar(50)), ''), ''),
                COALESCE(NULLIF(CAST(v.[RESULT] AS varchar(500)), ''), ''),
                COALESCE(NULLIF(CAST(v.[BP] AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(vs.[SourceField] AS varchar(100)), ''), '')
        ) AS [VitalSequence]
       ,COUNT(*) OVER (
            PARTITION BY
                vs.[VitalType],
                CAST(v.[PatientID] AS varchar(100)),
                CONVERT(
                    varchar(23),
                    COALESCE(
                        TRY_CAST(v.[DATETIME] AS datetime2),
                        TRY_CAST(v.[VDATE] AS datetime2),
                        TRY_CAST(v.[ENTERED] AS datetime2)
                    ),
                    121
                ),
                CAST(vs.[VitalValue] AS varchar(200))
        ) AS [VitalMultiplicity]
    FROM files.vitals AS v
    CROSS APPLY
    (
        VALUES
             ('BloodPressure',          CAST(v.[BP]       AS varchar(200)), 'mmHg',                                   'BP',       CAST(v.[BPDESC]    AS varchar(200)))
            ,('BloodPressureSystolic',  CAST(v.[BPS]      AS varchar(200)), 'mmHg',                                   'BPS',      CAST(v.[BPDESC]    AS varchar(200)))
            ,('BloodPressureDiastolic', CAST(v.[BPD]      AS varchar(200)), 'mmHg',                                   'BPD',      CAST(v.[BPDESC]    AS varchar(200)))
            ,('Glucose',                CAST(v.[GLUCOSE]  AS varchar(200)), NULLIF(CAST(v.[MUNIT] AS varchar(50)), ''), 'GLUCOSE',  NULL)
            ,('HeadSize',               CAST(v.[HEADSIZE] AS varchar(200)), NULLIF(CAST(v.[MUNIT] AS varchar(50)), ''), 'HEADSIZE', NULL)
            ,('Height',                 CAST(v.[HEIGHT]   AS varchar(200)), NULLIF(CAST(v.[MUNIT] AS varchar(50)), ''), 'HEIGHT',   NULL)
            ,('OxygenSaturation',       CAST(v.[O2SAT]    AS varchar(200)), '%',                                      'O2SAT',    NULL)
            ,('Pulse',                  CAST(v.[PULSE]    AS varchar(200)), NULL,                                     'PULSE',    CAST(v.[PULSEDESC] AS varchar(200)))
            ,('RespiratoryRate',        CAST(v.[RESP]     AS varchar(200)), NULL,                                     'RESP',     CAST(v.[RESPDESC]  AS varchar(200)))
            ,('Temperature',            CAST(v.[TEMPR]    AS varchar(200)), NULL,                                     'TEMPR',    CAST(v.[TEMPRDESC] AS varchar(200)))
            ,('Waist',                  CAST(v.[WAIST]    AS varchar(200)), NULLIF(CAST(v.[MUNIT] AS varchar(50)), ''), 'WAIST',    NULL)
            ,('Weight',                 CAST(v.[WEIGHT]   AS varchar(200)), NULLIF(CAST(v.[MUNIT] AS varchar(50)), ''), 'WEIGHT',   NULL)
            ,('Result',                 CAST(v.[RESULT]   AS varchar(200)), NULL,                                     'RESULT',   NULL)
    ) AS vs([VitalType], [VitalValue], [Units], [SourceField], [Description])
    WHERE v.[PatientID] IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(CAST(vs.[VitalValue] AS varchar(200)))), '') IS NOT NULL
) AS src;
