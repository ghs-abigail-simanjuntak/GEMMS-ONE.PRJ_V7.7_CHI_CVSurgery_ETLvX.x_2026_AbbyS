/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSConway.files.PRESCRIPTIONHISTORY, GEMMSConway.files.PROVIDERDOCTORCODEMASTER, GEMMSConway.files.USERS
ITEM TYPE: Medication
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[Medication]
CREATE EXTERNAL TABLE [etl_dbo].[Medication]
WITH
(
    LOCATION = 'etl_dbo/Medication',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS
WITH medication_base AS (
    SELECT
        ph.*,
        COALESCE(
            TRY_CAST(ph.RXDATE AS datetime2),
            TRY_CAST(ph.ORIGDATE AS datetime2),
            TRY_CAST(ph.STOPDATE AS datetime2)
        ) AS ClinicallyRelevantDttm,
        COALESCE(
            TRY_CAST(ph.ORIGDATE AS datetime2),
            TRY_CAST(ph.RXDATE AS datetime2)
        ) AS ExternalDataCreatedDttm,
        COALESCE(
            TRY_CAST(ph.STOPDATE AS datetime2),
            TRY_CAST(ph.RXDATE AS datetime2),
            TRY_CAST(ph.ORIGDATE AS datetime2)
        ) AS ExternalDataUpdatedDttm,
        CAST(
            COALESCE(
                NULLIF(
                    CONCAT(
                        'RX_',
                        CAST(ph.PatientID AS varchar(50)), '_',
                        COALESCE(NULLIF(CAST(ph.RXDATE AS varchar(50)), ''), NULLIF(CAST(ph.ORIGDATE AS varchar(50)), ''), 'NO_DATE'), '_',
                        COALESCE(NULLIF(CAST(ph.NDC AS varchar(100)), ''), NULLIF(CAST(ph.RXNORM AS varchar(100)), ''), NULLIF(CAST(ph.DRUGNAME AS varchar(100)), ''), 'NO_DRUG')
                    ),
                    ''
                ),
                CONCAT('RX_', CAST(ph.PatientID AS varchar(50)), '_', COALESCE(NULLIF(CAST(ph.DRUGNAME AS varchar(100)), ''), 'NO_DRUG'))
            ) AS varchar(200)
        ) AS BaseExternalDataId,
        ROW_NUMBER() OVER (
            PARTITION BY CAST(
                COALESCE(
                    NULLIF(
                        CONCAT(
                            'RX_',
                            CAST(ph.PatientID AS varchar(50)), '_',
                            COALESCE(NULLIF(CAST(ph.RXDATE AS varchar(50)), ''), NULLIF(CAST(ph.ORIGDATE AS varchar(50)), ''), 'NO_DATE'), '_',
                            COALESCE(NULLIF(CAST(ph.NDC AS varchar(100)), ''), NULLIF(CAST(ph.RXNORM AS varchar(100)), ''), NULLIF(CAST(ph.DRUGNAME AS varchar(100)), ''), 'NO_DRUG')
                        ),
                        ''
                    ),
                    CONCAT('RX_', CAST(ph.PatientID AS varchar(50)), '_', COALESCE(NULLIF(CAST(ph.DRUGNAME AS varchar(100)), ''), 'NO_DRUG'))
                ) AS varchar(200)
            )
            ORDER BY
                COALESCE(
                    TRY_CAST(ph.STOPDATE AS datetime2),
                    TRY_CAST(ph.RXDATE AS datetime2),
                    TRY_CAST(ph.ORIGDATE AS datetime2)
                ),
                COALESCE(NULLIF(CAST(ph.NDC AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(ph.RXNORM AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(ph.DRUGNAME AS varchar(255)), ''), ''),
                COALESCE(NULLIF(CAST(ph.INSTRUCTIO AS varchar(2000)), ''), ''),
                COALESCE(NULLIF(CAST(ph.DISPENSE AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(ph.DAYSSUPPLY AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(ph.REFILLS AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(ph.REASON AS varchar(2000)), ''), ''),
                COALESCE(NULLIF(CAST(ph.SOURCE AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(ph.PROV AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(ph.STOPUSER AS varchar(100)), ''), '')
        ) AS MedicationSequence,
        COUNT(*) OVER (
            PARTITION BY CAST(
                COALESCE(
                    NULLIF(
                        CONCAT(
                            'RX_',
                            CAST(ph.PatientID AS varchar(50)), '_',
                            COALESCE(NULLIF(CAST(ph.RXDATE AS varchar(50)), ''), NULLIF(CAST(ph.ORIGDATE AS varchar(50)), ''), 'NO_DATE'), '_',
                            COALESCE(NULLIF(CAST(ph.NDC AS varchar(100)), ''), NULLIF(CAST(ph.RXNORM AS varchar(100)), ''), NULLIF(CAST(ph.DRUGNAME AS varchar(100)), ''), 'NO_DRUG')
                        ),
                        ''
                    ),
                    CONCAT('RX_', CAST(ph.PatientID AS varchar(50)), '_', COALESCE(NULLIF(CAST(ph.DRUGNAME AS varchar(100)), ''), 'NO_DRUG'))
                ) AS varchar(200)
            )
        ) AS MedicationMultiplicity
    FROM files.prescriptionhistory AS ph
    WHERE ph.PatientID IS NOT NULL
      AND (
            NULLIF(LTRIM(RTRIM(CAST(ph.DRUGNAME AS varchar(255)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(ph.NDC AS varchar(100)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(ph.RXNORM AS varchar(100)))), '') IS NOT NULL
      )
)
SELECT
    NEWID() AS [Id]
   ,1 AS [ItemSetId]
   ,'CHIGEMMS1CV' AS [DataSourceCode]
   ,CASE
        WHEN mb.MedicationMultiplicity > 1 THEN CAST(CONCAT(LEFT(mb.BaseExternalDataId, 188), '_', CAST(mb.MedicationSequence AS varchar(10))) AS varchar(200))
        ELSE mb.BaseExternalDataId
    END AS [ExternalDataId]
   ,'1' AS [ExternalDataVersion]
   ,1 AS [DisplayOrder]
   ,CAST(mb.PatientID AS varchar(100)) AS [PatientExternalDataId]
   ,mb.ClinicallyRelevantDttm AS [ClinicallyRelevantDttm]
   ,'Medication' AS [TypeCode]
   ,'Medication' AS [TypeName]
   ,CAST(
        CASE
            WHEN TRY_CAST(mb.STOPDATE AS datetime2) IS NOT NULL THEN 1
            WHEN UPPER(LTRIM(RTRIM(CAST(mb.ACTIVEFLAG AS varchar(50))))) IN ('N', 'NO', '0', 'FALSE', 'F', 'INACTIVE', 'DISCONTINUED', 'STOPPED')
                THEN 1
            ELSE 0
        END AS bit
    ) AS [IsInvalidated]
   ,CASE
        WHEN TRY_CAST(mb.STOPDATE AS datetime2) IS NOT NULL THEN TRY_CAST(mb.STOPDATE AS datetime2)
        WHEN UPPER(LTRIM(RTRIM(CAST(mb.ACTIVEFLAG AS varchar(50))))) IN ('N', 'NO', '0', 'FALSE', 'F', 'INACTIVE', 'DISCONTINUED', 'STOPPED')
            THEN COALESCE(
                TRY_CAST(mb.STOPDATE AS datetime2),
                TRY_CAST(mb.RXDATE AS datetime2),
                TRY_CAST(mb.ORIGDATE AS datetime2)
            )
        ELSE NULL
    END AS [InvalidatedDttm]
       ,invalid_actor.ExternalDataId AS [InvalidatedByProviderExternalDataId]
   ,mb.ExternalDataCreatedDttm AS [ExternalDataCreatedDttm]
   ,mb.ExternalDataUpdatedDttm AS [ExternalDataUpdatedDttm]
   ,CASE
        WHEN TRY_CAST(mb.STOPDATE AS datetime2) IS NOT NULL THEN 'Discontinued'
        WHEN UPPER(LTRIM(RTRIM(CAST(mb.ACTIVEFLAG AS varchar(50))))) IN ('Y', 'YES', '1', 'TRUE', 'T', 'ACTIVE')
            THEN 'Active'
        WHEN UPPER(LTRIM(RTRIM(CAST(mb.ACTIVEFLAG AS varchar(50))))) IN ('N', 'NO', '0', 'FALSE', 'F', 'INACTIVE', 'DISCONTINUED', 'STOPPED')
            THEN 'Discontinued'
        ELSE NULLIF(CAST(mb.ACTIVEFLAG AS varchar(50)), '')
    END AS [Status]
   ,CAST(mb.DRUGNAME AS varchar(255)) AS [Title]
   ,CAST(0 AS bit) AS [IsSecure]
   ,CASE
        WHEN TRY_CAST(mb.STOPDATE AS datetime2) IS NOT NULL THEN 'Discontinued'
        WHEN UPPER(LTRIM(RTRIM(CAST(mb.ACTIVEFLAG AS varchar(50))))) IN ('Y', 'YES', '1', 'TRUE', 'T', 'ACTIVE')
            THEN 'Active'
        WHEN UPPER(LTRIM(RTRIM(CAST(mb.ACTIVEFLAG AS varchar(50))))) IN ('N', 'NO', '0', 'FALSE', 'F', 'INACTIVE', 'DISCONTINUED', 'STOPPED')
            THEN 'Discontinued'
        ELSE NULL
    END AS [VcoSetEntries]
   ,CONVERT(varchar(4000),
        CONCAT(
            '{',
            '"daysSupply":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.DAYSSUPPLY), ''), 'json'), '",',
            '"dispense":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.DISPENSE), ''), 'json'), '",',
            '"rxNorm":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.RXNORM), ''), 'json'), '",',
            '"csaSched":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.CSASCHED), ''), 'json'), '",',
            '"idc9":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.IDC9), ''), 'json'), '",',
            '"reason":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(2000), mb.REASON), ''), 'json'), '",',
            '"refills":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.REFILLS), ''), 'json'), '",',
            '"source":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.SOURCE), ''), 'json'), '",',
            '"origDate":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(23), TRY_CAST(mb.ORIGDATE AS datetime2), 121), CONVERT(varchar(100), mb.ORIGDATE), ''), 'json'), '",',
            '"rxDate":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(23), TRY_CAST(mb.RXDATE AS datetime2), 121), CONVERT(varchar(100), mb.RXDATE), ''), 'json'), '",',
            '"stopDate":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(23), TRY_CAST(mb.STOPDATE AS datetime2), 121), CONVERT(varchar(100), mb.STOPDATE), ''), 'json'), '",',
            '"activeFlag":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(50), mb.ACTIVEFLAG), ''), 'json'), '",',
            '"providerSourceId":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.PROV), ''), 'json'), '",',
            '"stopUserSourceId":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(100), mb.STOPUSER), ''), 'json'), '"',
            '}'
        )
    ) AS [ExtendedProperties]
   ,NULL AS [ServiceDttm]
   ,COALESCE(
        TRY_CAST(mb.RXDATE AS datetime2),
        TRY_CAST(mb.ORIGDATE AS datetime2)
    ) AS [RecordedDttm]
   ,NULL AS [AdministeringPersonExternalDataId]
       ,recording_actor.ExternalDataId AS [RecordingPersonExternalDataId]
   ,NULL AS [Strength]
   ,NULL AS [Form]
   ,NULLIF(CAST(mb.NDC AS varchar(100)), '') AS [Ndc]
   ,NULL AS [Ddi]
       ,recording_actor.ExternalDataId AS [OrderingPersonExternalDataId]
   ,TRY_CAST(mb.RXDATE AS datetime2) AS [RxDttm]
   ,CAST(
        CONCAT(
            COALESCE(CAST(mb.DRUGNAME AS varchar(255)), ''),
            CASE WHEN NULLIF(LTRIM(RTRIM(CAST(mb.INSTRUCTIO AS varchar(2000)))), '') IS NOT NULL
                 THEN CONCAT(' ', CAST(mb.INSTRUCTIO AS varchar(2000)))
                 ELSE ''
            END
        ) AS varchar(2000)
    ) AS [FreeTextSig]
   ,invalid_actor.ExternalDataId AS [LastUpdatedByExternalDataId]
   ,NULL AS [SupervisingPersonExternalDataId]
   ,NULL AS [EncounterExternalDataId]
   ,NULL AS [ParentItemExternalDataId]
FROM medication_base AS mb
OUTER APPLY (
    SELECT TOP (1)
        resolved.ExternalDataId
    FROM (
        SELECT
            1 AS Precedence,
            CONCAT('USER|', CAST(u.[USERID] AS varchar(100))) AS ExternalDataId
        FROM [files].[USERS] AS u
        WHERE u.[USERID] = NULLIF(CAST(mb.STOPUSER AS varchar(100)), '')

        UNION ALL

        SELECT
            2 AS Precedence,
            CONCAT('PROVIDER|', CAST(p.[DOCTOR] AS varchar(100))) AS ExternalDataId
        FROM [files].[PROVIDERDOCTORCODEMASTER] AS p
        WHERE p.[DOCTOR] = NULLIF(CAST(mb.STOPUSER AS varchar(100)), '')
           OR p.[USERCODE] = NULLIF(CAST(mb.STOPUSER AS varchar(100)), '')
    ) AS resolved
    ORDER BY resolved.Precedence, resolved.ExternalDataId
) AS invalid_actor
OUTER APPLY (
    SELECT TOP (1)
        resolved.ExternalDataId
    FROM (
        SELECT
            1 AS Precedence,
            CONCAT('USER|', CAST(u.[USERID] AS varchar(100))) AS ExternalDataId
        FROM [files].[USERS] AS u
        WHERE u.[USERID] = NULLIF(CAST(mb.PROV AS varchar(100)), '')

        UNION ALL

        SELECT
            2 AS Precedence,
            CONCAT('PROVIDER|', CAST(p.[DOCTOR] AS varchar(100))) AS ExternalDataId
        FROM [files].[PROVIDERDOCTORCODEMASTER] AS p
        WHERE p.[DOCTOR] = NULLIF(CAST(mb.PROV AS varchar(100)), '')
           OR p.[USERCODE] = NULLIF(CAST(mb.PROV AS varchar(100)), '')
    ) AS resolved
    ORDER BY resolved.Precedence, resolved.ExternalDataId
) AS recording_actor;