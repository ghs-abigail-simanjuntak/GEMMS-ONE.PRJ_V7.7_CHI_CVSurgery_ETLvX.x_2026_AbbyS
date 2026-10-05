/********************************************************************************
SCRIPT DEPENDENCIES: 
ITEM TYPE: Allergy
NOTES: 
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[Allergy]
CREATE EXTERNAL TABLE [etl_dbo].[Allergy]
WITH
(
    LOCATION = 'etl_dbo/Allergy',
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
            WHEN src.[AllergyMultiplicity] > 1 THEN CONCAT(LEFT(src.[BaseExternalDataId], 243), '|', CAST(src.[AllergySequence] AS varchar(10)))
            ELSE src.[BaseExternalDataId]
        END AS varchar(255)
    ) AS [ExternalDataId]
   ,'1' AS [ExternalDataVersion]
   ,1 AS [DisplayOrder]
   ,CAST(src.[PatientID] AS varchar(100)) AS [PatientExternalDataId]
   ,COALESCE(
       TRY_CAST(src.[REPORTED] AS datetime2),
       TRY_CAST(src.[ALLERGYSTATED] AS datetime2),
       TRY_CAST(src.[DELDATE] AS datetime2)
    ) AS [ClinicallyRelevantDttm]
   ,'Allergy' AS [TypeCode]
   ,'Allergy' AS [TypeName]
   ,CAST(
        CASE
          WHEN TRY_CAST(src.[DELDATE] AS datetime2) IS NOT NULL THEN 1
          WHEN NULLIF(LTRIM(RTRIM(CAST(src.[DELREASON] AS varchar(500)))), '') IS NOT NULL THEN 1
          WHEN UPPER(LTRIM(RTRIM(CAST(src.[ASTATUS] AS varchar(50))))) IN ('I', 'INACTIVE', '0', 'NO', 'N', 'D', 'DELETED') THEN 1
            ELSE 0
        END AS bit
    ) AS [IsInvalidated]
   ,TRY_CAST(src.[DELDATE] AS datetime2) AS [InvalidatedDttm]
   ,NULL AS [InvalidatedByProviderExternalDataId]
   ,COALESCE(
       TRY_CAST(src.[REPORTED] AS datetime2),
       TRY_CAST(src.[ALLERGYSTATED] AS datetime2)
    ) AS [ExternalDataCreatedDttm]
   ,COALESCE(
       TRY_CAST(src.[DELDATE] AS datetime2),
       TRY_CAST(src.[REPORTED] AS datetime2),
       TRY_CAST(src.[ALLERGYSTATED] AS datetime2)
    ) AS [ExternalDataUpdatedDttm]
   ,CASE
       WHEN TRY_CAST(src.[DELDATE] AS datetime2) IS NOT NULL THEN 'Inactive'
       WHEN NULLIF(LTRIM(RTRIM(CAST(src.[DELREASON] AS varchar(500)))), '') IS NOT NULL THEN 'Inactive'
       WHEN UPPER(LTRIM(RTRIM(CAST(src.[ASTATUS] AS varchar(50))))) IN ('Y', 'A', 'ACTIVE', '1', 'CURRENT', 'YES') THEN 'Active'
       WHEN UPPER(LTRIM(RTRIM(CAST(src.[ASTATUS] AS varchar(50))))) IN ('I', 'INACTIVE', '0', 'NO', 'N', 'D', 'DELETED') THEN 'Inactive'
       ELSE NULLIF(CAST(src.[ASTATUS] AS varchar(50)), '')
    END AS [Status]
   ,CAST(src.[ALLERGY] AS varchar(255)) AS [Title]
   ,CAST(0 AS bit) AS [IsSecure]
   ,NULL AS [VcoSetEntries]
   ,CONVERT(varchar(4000),
        CONCAT(
            '{',
            '"severity":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), src.[SEVERITY]), ''), 'json'), '",',
            '"memo":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(2000), src.[MEMO]), ''), 'json'), '",',
            '"conceptType":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), src.[ConceptType]), ''), 'json'), '",',
            '"compositeDescription":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(500), src.[COMPOSITEDESCRIPTION]), ''), 'json'), '",',
            '"reported":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(23), TRY_CAST(src.[REPORTED] AS datetime2), 121), ''), 'json'), '",',
            '"source":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), src.[SOURCE]), ''), 'json'), '",',
            '"statusSource":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(50), src.[ASTATUS]), ''), 'json'), '",',
            '"providerSourceId":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), src.[PROV]), ''), 'json'), '",',
            '"deleteReason":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(500), src.[DELREASON]), ''), 'json'), '",',
            '"reaction":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(500), src.[REACTION]), ''), 'json'), '"',
            '}'
        )
    ) AS [ExtendedProperties]
   ,NULL AS [ServiceDttm]
   ,TRY_CAST(src.[REPORTED] AS datetime2) AS [RecordedDttm]
   ,CAST(
        CASE
            WHEN UPPER(COALESCE(src.[ALLERGY], '')) LIKE '%DRUG%' THEN 1
            WHEN UPPER(COALESCE(src.[ALLERGYSTATED], '')) LIKE '%DRUG%' THEN 1
            WHEN UPPER(COALESCE(src.[ALLERGY], '')) LIKE '%MED%' THEN 1
            WHEN UPPER(COALESCE(src.[ALLERGYSTATED], '')) LIKE '%MED%' THEN 1
            ELSE 0
        END AS bit
    ) AS [IsMedication]
   ,COALESCE(
        NULLIF(CAST(src.[SEVERITY] AS varchar(100)), ''),
        NULLIF(CAST(src.[SOURCE] AS varchar(100)), ''),
        NULLIF(CAST(src.[ConceptType] AS varchar(100)), '')
    ) AS [Classification]
   ,CAST(src.[REACTION] AS varchar(500)) AS [ReactionDescription]
   ,NULLIF(CAST(src.[PROV] AS varchar(100)), '') AS [PerformingProviderExternalDataId]
   ,NULLIF(CAST(src.[PROV] AS varchar(100)), '') AS [RecordedByExternalDataId]
   ,NULLIF(CAST(src.[DELUSER] AS varchar(100)), '') AS [LastUpdatingProviderExternalDataId]
   ,NULL AS [EncounterExternalDataId]
FROM
(
    SELECT
        a.*
       ,CAST(
            CONCAT(
                a.[PatientID],
                '|ALLERGY|',
                COALESCE(LTRIM(RTRIM(a.[COMPOSITEALLERGYID])), ''),
                '|',
                COALESCE(LTRIM(RTRIM(a.[ALLERGY])), ''),
                '|',
                COALESCE(CONVERT(varchar(23), TRY_CAST(a.[ALLERGYSTATED] AS datetime2), 121), ''),
                '|',
                COALESCE(CONVERT(varchar(23), TRY_CAST(a.[DELDATE] AS datetime2), 121), ''),
                '|',
                COALESCE(LTRIM(RTRIM(a.[DELREASON])), ''),
                '|',
                COALESCE(LTRIM(RTRIM(a.[REACTION])), ''),
                '|',
                COALESCE(LTRIM(RTRIM(a.[ConceptType])), ''),
                '|',
                COALESCE(LTRIM(RTRIM(a.[ASTATUS])), ''),
                '|',
                COALESCE(LTRIM(RTRIM(a.[DELUSER])), ''),
                '|',
                COALESCE(CONVERT(varchar(23), TRY_CAST(a.[REPORTED] AS datetime2), 121), '')
            ) AS varchar(255)
        ) AS [BaseExternalDataId]
       ,ROW_NUMBER() OVER (
            PARTITION BY
                CONCAT(
                    a.[PatientID],
                    '|ALLERGY|',
                    COALESCE(LTRIM(RTRIM(a.[COMPOSITEALLERGYID])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[ALLERGY])), ''),
                    '|',
                    COALESCE(CONVERT(varchar(23), TRY_CAST(a.[ALLERGYSTATED] AS datetime2), 121), ''),
                    '|',
                    COALESCE(CONVERT(varchar(23), TRY_CAST(a.[DELDATE] AS datetime2), 121), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[DELREASON])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[REACTION])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[ConceptType])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[ASTATUS])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[DELUSER])), ''),
                    '|',
                    COALESCE(CONVERT(varchar(23), TRY_CAST(a.[REPORTED] AS datetime2), 121), '')
                )
            ORDER BY
                COALESCE(TRY_CAST(a.[REPORTED] AS datetime2), TRY_CAST(a.[ALLERGYSTATED] AS datetime2), TRY_CAST(a.[DELDATE] AS datetime2)),
                COALESCE(NULLIF(CAST(a.[PROV] AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(a.[MEMO] AS varchar(2000)), ''), ''),
                COALESCE(NULLIF(CAST(a.[SOURCE] AS varchar(100)), ''), '')
        ) AS [AllergySequence]
       ,COUNT(*) OVER (
            PARTITION BY
                CONCAT(
                    a.[PatientID],
                    '|ALLERGY|',
                    COALESCE(LTRIM(RTRIM(a.[COMPOSITEALLERGYID])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[ALLERGY])), ''),
                    '|',
                    COALESCE(CONVERT(varchar(23), TRY_CAST(a.[ALLERGYSTATED] AS datetime2), 121), ''),
                    '|',
                    COALESCE(CONVERT(varchar(23), TRY_CAST(a.[DELDATE] AS datetime2), 121), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[DELREASON])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[REACTION])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[ConceptType])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[ASTATUS])), ''),
                    '|',
                    COALESCE(LTRIM(RTRIM(a.[DELUSER])), ''),
                    '|',
                    COALESCE(CONVERT(varchar(23), TRY_CAST(a.[REPORTED] AS datetime2), 121), '')
                )
        ) AS [AllergyMultiplicity]
    FROM [files].[ALLERGY] AS a
    INNER JOIN [files].[PATIENTACCOUNT] AS p
        ON p.[PatientID] = a.[PatientID]
    WHERE a.[PatientID] IS NOT NULL
) AS src;