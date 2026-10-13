/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSConway.files.PROBLEMLIST
ITEM TYPE: Problem
NOTES:
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[Problem]
CREATE EXTERNAL TABLE [etl_dbo].[Problem]
WITH
(
    LOCATION = 'etl_dbo/Problem',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
WITH problem_base AS (
    SELECT
        pl.*,
        CAST(
            COALESCE(
                NULLIF(
                    CONCAT(
                        'problem_',
                        CAST(pl.PatientID AS varchar(50)), '_',
                        COALESCE(NULLIF(CAST(pl.ICD10 AS varchar(50)), ''), NULLIF(CAST(pl.ICD9 AS varchar(50)), ''), NULLIF(CAST(pl.SNOMED AS varchar(50)), ''), 'NO_CODE'), '_',
                        COALESCE(CONVERT(varchar(23), TRY_CAST(pl.STARTDATE AS datetime2), 121), CONVERT(varchar(23), TRY_CAST(pl.ENTRYDATE AS datetime2), 121), 'NO_DATE'), '_',
                        COALESCE(NULLIF(CAST(pl.RANK AS varchar(50)), ''), NULLIF(CAST(pl.DISPLAYRANK AS varchar(50)), ''), '1')
                    ),
                    ''
                ),
                CONCAT('problem_', CAST(pl.PatientID AS varchar(50)), '_', COALESCE(NULLIF(CAST(pl.PROBLEM AS varchar(100)), ''), 'NO_PROBLEM'))
            ) AS varchar(200)
        ) AS BaseExternalDataId,
        ROW_NUMBER() OVER (
            PARTITION BY CAST(
                COALESCE(
                    NULLIF(
                        CONCAT(
                            'problem_',
                            CAST(pl.PatientID AS varchar(50)), '_',
                            COALESCE(NULLIF(CAST(pl.ICD10 AS varchar(50)), ''), NULLIF(CAST(pl.ICD9 AS varchar(50)), ''), NULLIF(CAST(pl.SNOMED AS varchar(50)), ''), 'NO_CODE'), '_',
                            COALESCE(CONVERT(varchar(23), TRY_CAST(pl.STARTDATE AS datetime2), 121), CONVERT(varchar(23), TRY_CAST(pl.ENTRYDATE AS datetime2), 121), 'NO_DATE'), '_',
                            COALESCE(NULLIF(CAST(pl.RANK AS varchar(50)), ''), NULLIF(CAST(pl.DISPLAYRANK AS varchar(50)), ''), '1')
                        ),
                        ''
                    ),
                    CONCAT('problem_', CAST(pl.PatientID AS varchar(50)), '_', COALESCE(NULLIF(CAST(pl.PROBLEM AS varchar(100)), ''), 'NO_PROBLEM'))
                ) AS varchar(200)
            )
            ORDER BY
                COALESCE(
                    TRY_CAST(pl.ENDDATE AS datetime2),
                    TRY_CAST(pl.REPORTED AS datetime2),
                    TRY_CAST(pl.ENTRYDATE AS datetime2),
                    TRY_CAST(pl.STARTDATE AS datetime2),
                    TRY_CAST(pl.APPROXONSET AS datetime2)
                ),
                COALESCE(NULLIF(CAST(pl.ICD10 AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(pl.ICD9 AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(pl.SNOMED AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(pl.PROBLEM10 AS varchar(250)), ''), ''),
                COALESCE(NULLIF(CAST(pl.PROBLEM AS varchar(250)), ''), ''),
                COALESCE(NULLIF(CAST(pl.PROBNOTE AS varchar(2000)), ''), ''),
                COALESCE(NULLIF(CAST(pl.PROV AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(pl.STATUS AS varchar(100)), ''), '')
        ) AS ProblemSequence,
        COUNT(*) OVER (
            PARTITION BY CAST(
                COALESCE(
                    NULLIF(
                        CONCAT(
                            'problem_',
                            CAST(pl.PatientID AS varchar(50)), '_',
                            COALESCE(NULLIF(CAST(pl.ICD10 AS varchar(50)), ''), NULLIF(CAST(pl.ICD9 AS varchar(50)), ''), NULLIF(CAST(pl.SNOMED AS varchar(50)), ''), 'NO_CODE'), '_',
                            COALESCE(CONVERT(varchar(23), TRY_CAST(pl.STARTDATE AS datetime2), 121), CONVERT(varchar(23), TRY_CAST(pl.ENTRYDATE AS datetime2), 121), 'NO_DATE'), '_',
                            COALESCE(NULLIF(CAST(pl.RANK AS varchar(50)), ''), NULLIF(CAST(pl.DISPLAYRANK AS varchar(50)), ''), '1')
                        ),
                        ''
                    ),
                    CONCAT('problem_', CAST(pl.PatientID AS varchar(50)), '_', COALESCE(NULLIF(CAST(pl.PROBLEM AS varchar(100)), ''), 'NO_PROBLEM'))
                ) AS varchar(200)
            )
        ) AS ProblemMultiplicity
    FROM files.problemlist AS pl
    WHERE pl.PatientID IS NOT NULL
      AND (
            NULLIF(LTRIM(RTRIM(CAST(pl.PROBLEM AS varchar(250)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(pl.PROBLEM10 AS varchar(250)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(pl.ICD10 AS varchar(100)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(pl.ICD9 AS varchar(100)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(pl.SNOMED AS varchar(100)))), '') IS NOT NULL
      )
)
SELECT
    NEWID() AS [Id]
   ,1 AS [ItemSetId]
   ,'CHIGEMMS1CV' AS [DataSourceCode]
   ,CASE
        WHEN pb.ProblemMultiplicity > 1 THEN CAST(CONCAT(LEFT(pb.BaseExternalDataId, 188), '_', CAST(pb.ProblemSequence AS varchar(10))) AS varchar(200))
        ELSE pb.BaseExternalDataId
    END AS [ExternalDataId]
   ,'1' AS [ExternalDataVersion]
   ,1 AS [DisplayOrder]
   ,CAST(pb.PatientID AS varchar(100)) AS [PatientExternalDataId]
   ,COALESCE(
        TRY_CAST(pb.STARTDATE AS datetime2),
        TRY_CAST(pb.APPROXONSET AS datetime2),
        TRY_CAST(pb.REPORTED AS datetime2),
        TRY_CAST(pb.ENTRYDATE AS datetime2)
    ) AS [ClinicallyRelevantDttm]
   ,COALESCE(
        NULLIF(CAST(pb.ICD10 AS varchar(100)), ''),
        NULLIF(CAST(pb.ICD9 AS varchar(100)), ''),
        NULLIF(CAST(pb.SNOMED AS varchar(100)), ''),
        'Problem'
    ) AS [TypeCode]
   ,COALESCE(
        NULLIF(CAST(pb.PROBLEM10 AS varchar(250)), ''),
        NULLIF(CAST(pb.PROBLEM AS varchar(250)), ''),
        NULLIF(CAST(pb.SNOMEDDESC AS varchar(250)), ''),
        'Problem'
    ) AS [TypeName]
   ,CAST(
        CASE
            WHEN TRY_CAST(pb.ENDDATE AS datetime2) IS NOT NULL THEN 1
            WHEN UPPER(LTRIM(RTRIM(CAST(pb.STATUS AS varchar(100))))) IN ('INACTIVE', 'RESOLVED', 'DELETED', 'VOID')
                THEN 1
            ELSE 0
        END AS bit
    ) AS [IsInvalidated]
   ,CASE
        WHEN TRY_CAST(pb.ENDDATE AS datetime2) IS NOT NULL THEN TRY_CAST(pb.ENDDATE AS datetime2)
        WHEN UPPER(LTRIM(RTRIM(CAST(pb.STATUS AS varchar(100))))) IN ('INACTIVE', 'RESOLVED', 'DELETED', 'VOID')
            THEN COALESCE(
                TRY_CAST(pb.ENDDATE AS datetime2),
                TRY_CAST(pb.ENTRYDATE AS datetime2),
                TRY_CAST(pb.REPORTED AS datetime2)
            )
        ELSE NULL
    END AS [InvalidatedDttm]
   ,NULL AS [InvalidatedByProviderExternalDataId]
   ,COALESCE(
        TRY_CAST(pb.ENTRYDATE AS datetime2),
        TRY_CAST(pb.REPORTED AS datetime2),
        TRY_CAST(pb.STARTDATE AS datetime2),
        TRY_CAST(pb.APPROXONSET AS datetime2)
    ) AS [ExternalDataCreatedDttm]
   ,COALESCE(
        TRY_CAST(pb.ENDDATE AS datetime2),
        TRY_CAST(pb.REPORTED AS datetime2),
        TRY_CAST(pb.ENTRYDATE AS datetime2),
        TRY_CAST(pb.STARTDATE AS datetime2)
    ) AS [ExternalDataUpdatedDttm]
   ,CASE
        WHEN TRY_CAST(pb.ENDDATE AS datetime2) IS NOT NULL THEN 'Inactive'
        WHEN UPPER(LTRIM(RTRIM(CAST(pb.STATUS AS varchar(100))))) IN ('ACTIVE', 'A', '1', 'CURRENT', 'OPEN')
            THEN 'Active'
        WHEN UPPER(LTRIM(RTRIM(CAST(pb.STATUS AS varchar(100))))) IN ('INACTIVE', 'I', '0', 'RESOLVED', 'CLOSED', 'DELETED', 'VOID')
            THEN 'Inactive'
        ELSE NULLIF(CAST(pb.STATUS AS varchar(100)), '')
    END AS [Status]
   ,COALESCE(
        NULLIF(CAST(pb.PROBLEM10 AS varchar(500)), ''),
        NULLIF(CAST(pb.PROBLEM AS varchar(500)), '')
    ) AS [Title]
   ,CAST(0 AS bit) AS [IsSecure]
   ,NULL AS [VcoSetEntries]
   ,CONVERT(varchar(4000),
        CONCAT(
            '{',
            '"accident":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), pb.ACCIDENT), ''), 'json'), '",',
            '"approxOnset":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(23), TRY_CAST(pb.APPROXONSET AS datetime2), 121), CONVERT(varchar(100), pb.APPROXONSET), ''), 'json'), '",',
            '"probNote":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(2000), pb.PROBNOTE), ''), 'json'), '",',
            '"providerId":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), pb.PROV), ''), 'json'), '",',
            '"providerName":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(250), pb.PROVIDER), ''), 'json'), '",',
            '"rank":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(50), pb.RANK), ''), 'json'), '",',
            '"displayRank":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(50), pb.DISPLAYRANK), ''), 'json'), '",',
            '"reported":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(23), TRY_CAST(pb.REPORTED AS datetime2), 121), CONVERT(varchar(100), pb.REPORTED), ''), 'json'), '"',
            '}'
        )
    ) AS [ExtendedProperties]
   ,NULL AS [ServiceDttm]
   ,NULL AS [Category]
   ,NULLIF(CAST(pb.PROV AS varchar(100)), '') AS [IdentifiedByProviderExternalDataId]
   ,NULLIF(CAST(pb.PROV AS varchar(100)), '') AS [ManagedByProviderExternalDataId]
   ,NULL AS [LastAssessingPersonExternalDataId]
   ,NULLIF(CAST(pb.ICD9 AS varchar(100)), '') AS [Icd9Code]
   ,NULLIF(CAST(pb.ICD10 AS varchar(100)), '') AS [Icd10Code]
   ,NULL AS [MedcinCode]
   ,NULLIF(CAST(pb.SNOMED AS varchar(100)), '') AS [Snomed]
   ,COALESCE(
        TRY_CAST(pb.REPORTED AS datetime2),
        TRY_CAST(pb.ENTRYDATE AS datetime2)
    ) AS [RecordedDttm]
   ,NULLIF(CAST(pb.PROV AS varchar(100)), '') AS [RecordedByExternalDataId]
   ,NULLIF(CAST(pb.PROV AS varchar(100)), '') AS [LastUpdatingProviderExternalDataId]
   ,NULL AS [EncounterExternalDataId]
FROM problem_base AS pb;