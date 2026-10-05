/********************************************************************************
SCRIPT DEPENDENCIES: None identified.
ITEM TYPE: Order
NOTES:
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[Order]
CREATE EXTERNAL TABLE [etl_dbo].[Order]
WITH
(
    LOCATION = 'etl_dbo/Order',
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
            WHEN src.OrderMultiplicity > 1 THEN CONCAT(src.BaseExternalDataId, '|', CAST(src.OrderSequence AS varchar(10)))
            ELSE src.BaseExternalDataId
        END AS varchar(225)
    ) AS [ExternalDataId]
   ,'1' AS [ExternalDataVersion]
   ,1 AS [DisplayOrder]
   ,CAST(src.PatientID AS varchar(100)) AS [PatientExternalDataId]
   ,COALESCE(
        src.OrderDttm,
        src.OpenDttm,
        src.DrawDttm,
        src.ExpectDttm,
        src.DoneDttm,
        src.ReviewDttm,
        TRY_CAST(src.[DATETIME] AS datetime2)
    ) AS [ClinicallyRelevantDttm]
   ,'Order' AS [TypeCode]
   ,'Order' AS [TypeName]
   ,CAST(
        CASE
            WHEN UPPER(LTRIM(RTRIM(CAST(src.STATUS AS varchar(100))))) IN ('CANCELLED', 'CANCELED', 'REFUSED', 'VOID', 'INACTIVE')
                THEN 1
            WHEN UPPER(LTRIM(RTRIM(CAST(src.OPENSTATUS AS varchar(100))))) IN ('CLOSED', 'CANCELLED', 'CANCELED', 'REFUSED', 'VOID')
                THEN 1
            WHEN UPPER(LTRIM(RTRIM(CAST(src.REFUSESTATUS AS varchar(100))))) IN ('Y', 'YES', '1', 'TRUE', 'REFUSED')
                THEN 1
            ELSE 0
        END AS bit
    ) AS [IsInvalidated]
   ,COALESCE(
        src.StatusDttm,
        src.ReviewDttm,
        src.DoneDttm,
        CASE
            WHEN UPPER(LTRIM(RTRIM(CAST(src.REFUSESTATUS AS varchar(100))))) IN ('Y', 'YES', '1', 'TRUE', 'REFUSED')
                THEN TRY_CAST(src.REFUSEDATE AS datetime2)
            ELSE NULL
        END
    ) AS [InvalidatedDttm]
   ,src.InvalidatedByProviderExternalDataId AS [InvalidatedByProviderExternalDataId]
   ,COALESCE(
        src.OpenDttm,
        src.OrderDttm,
        TRY_CAST(src.[DATETIME] AS datetime2)
    ) AS [ExternalDataCreatedDttm]
   ,COALESCE(
        src.StatusDttm,
        src.ReviewDttm,
        src.DoneDttm,
        src.DrawDttm,
        src.OpenDttm,
        src.OrderDttm,
        TRY_CAST(src.[DATETIME] AS datetime2)
    ) AS [ExternalDataUpdatedDttm]
   ,COALESCE(
        NULLIF(CAST(src.STATUS AS varchar(100)), ''),
        NULLIF(CAST(src.OPENSTATUS AS varchar(100)), ''),
        CASE
            WHEN UPPER(LTRIM(RTRIM(CAST(src.REFUSESTATUS AS varchar(100))))) IN ('Y', 'YES', '1', 'TRUE', 'REFUSED')
                THEN 'Refused'
            ELSE NULL
        END
    ) AS [Status]
   ,COALESCE(
        NULLIF(CAST(src.ODESC AS varchar(500)), ''),
        NULLIF(CAST(src.NAME AS varchar(500)), ''),
        NULLIF(CAST(src.DIAGNOSIS AS varchar(500)), '')
    ) AS [Title]
   ,CAST(0 AS bit) AS [IsSecure]
   ,CASE
        WHEN UPPER(LTRIM(RTRIM(CAST(src.STAT AS varchar(50))))) IN ('Y', 'YES', '1', 'TRUE', 'STAT')
            THEN 'STAT'
        ELSE NULL
    END AS [VcoSetEntries]
   ,CAST(
        CONCAT(
            '{',
            '"sourceOrderId":"', STRING_ESCAPE(COALESCE(CAST(src.ID AS varchar(100)), ''), 'json'), '",',
            '"dept":"', STRING_ESCAPE(COALESCE(CAST(src.DEPT AS varchar(100)), ''), 'json'), '",',
            '"facility":"', STRING_ESCAPE(COALESCE(CAST(src.FACILITY AS varchar(250)), ''), 'json'), '",',
            '"icd9":"', STRING_ESCAPE(COALESCE(CAST(src.ICD9 AS varchar(100)), ''), 'json'), '",',
            '"diagnosis":"', STRING_ESCAPE(COALESCE(CAST(src.DIAGNOSIS AS varchar(1000)), ''), 'json'), '",',
            '"measure":"', STRING_ESCAPE(COALESCE(CAST(src.MEASURE AS varchar(250)), ''), 'json'), '",',
            '"result":"', STRING_ESCAPE(COALESCE(CAST(src.ORESULT AS varchar(1000)), ''), 'json'), '",',
            '"memo":"', STRING_ESCAPE(COALESCE(CAST(src.OMEMO AS varchar(1000)), ''), 'json'), '",',
            '"reviewMemo":"', STRING_ESCAPE(COALESCE(CAST(src.RMEMO AS varchar(1000)), ''), 'json'), '",',
            '"referral":"', STRING_ESCAPE(COALESCE(CAST(src.REFERRAL AS varchar(100)), ''), 'json'), '",',
            '"rdoc":"', STRING_ESCAPE(COALESCE(CAST(src.RDOC AS varchar(100)), ''), 'json'), '",',
            '"rdoc2":"', STRING_ESCAPE(COALESCE(CAST(src.RDOC2 AS varchar(100)), ''), 'json'), '",',
            '"prov2":"', STRING_ESCAPE(COALESCE(CAST(src.PROV2 AS varchar(100)), ''), 'json'), '",',
            '"drawProv":"', STRING_ESCAPE(COALESCE(CAST(src.DRAWPROV AS varchar(100)), ''), 'json'), '",',
            '"reviewProv":"', STRING_ESCAPE(COALESCE(CAST(src.REVIEWPROV AS varchar(100)), ''), 'json'), '",',
            '"refuseStatus":"', STRING_ESCAPE(COALESCE(CAST(src.REFUSESTATUS AS varchar(100)), ''), 'json'), '",',
            '"refuseUser":"', STRING_ESCAPE(COALESCE(CAST(src.REFUSEUSER AS varchar(100)), ''), 'json'), '",',
            '"orderSequence":"', STRING_ESCAPE(CAST(src.OrderSequence AS varchar(10)), 'json'), '"',
            '}'
        ) AS varchar(4000)
    ) AS [ExtendedProperties]
   ,src.DrawDttm AS [ServiceDttm]
   ,src.OpenDttm AS [RecordedDttm]
   ,COALESCE(
        src.OrderDttm,
        src.OpenDttm,
        TRY_CAST(src.[DATETIME] AS datetime2)
    ) AS [OrderDttm]
   ,src.OrderingProviderExternalDataId AS [OrderingProviderExternalDataId]
   ,src.ApprovingProviderExternalDataId AS [ApprovingProviderExternalDataId]
   ,src.PerformingProviderExternalDataId AS [PerformingProviderExternalDataId]
   ,src.RecordedByExternalDataId AS [RecordedByExternalDataId]
   ,src.LastUpdatingProviderExternalDataId AS [LastUpdatingProviderExternalDataId]
   ,src.CollectingProviderExternalDataId AS [CollectingProviderExternalDataId]
   ,NULL AS [EncounterExternalDataId]
FROM
(
    SELECT
        lo.*
       ,dt.OrderDttm
       ,dt.OpenDttm
       ,dt.DrawDttm
       ,dt.ExpectDttm
       ,dt.DoneDttm
       ,dt.ReviewDttm
       ,dt.StatusDttm
       ,CAST(
            COALESCE(
                NULLIF(CAST(lo.ID AS varchar(100)), ''),
                CONCAT(
                    'LABORDER_',
                    CAST(lo.PatientID AS varchar(50)), '_',
                    COALESCE(NULLIF(CAST(lo.ORDERCODE AS varchar(100)), ''), NULLIF(CAST(lo.NAME AS varchar(100)), ''), 'NO_CODE'), '_',
                    COALESCE(CONVERT(varchar(23), dt.OrderDttm, 121), 'NO_DATE')
                )
            ) AS varchar(200)
        ) AS BaseExternalDataId
       ,ROW_NUMBER() OVER (
            PARTITION BY CAST(
                COALESCE(
                    NULLIF(CAST(lo.ID AS varchar(100)), ''),
                    CONCAT(
                        'LABORDER_',
                        CAST(lo.PatientID AS varchar(50)), '_',
                        COALESCE(NULLIF(CAST(lo.ORDERCODE AS varchar(100)), ''), NULLIF(CAST(lo.NAME AS varchar(100)), ''), 'NO_CODE'), '_',
                        COALESCE(CONVERT(varchar(23), dt.OrderDttm, 121), 'NO_DATE')
                    )
                ) AS varchar(200)
            )
            ORDER BY
                CAST(lo.PatientID AS varchar(50)),
                COALESCE(dt.OrderDttm, dt.OpenDttm, dt.DrawDttm, dt.ExpectDttm, dt.DoneDttm, dt.ReviewDttm, TRY_CAST(lo.[DATETIME] AS datetime2)),
                COALESCE(dt.StatusDttm, dt.ReviewDttm, dt.DoneDttm, dt.DrawDttm, dt.OpenDttm, dt.OrderDttm),
                COALESCE(NULLIF(CAST(lo.STATUS AS varchar(100)), ''), NULLIF(CAST(lo.OPENSTATUS AS varchar(100)), ''), NULLIF(CAST(lo.REFUSESTATUS AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(lo.ORDERCODE AS varchar(100)), ''), NULLIF(CAST(lo.NAME AS varchar(255)), ''), NULLIF(CAST(lo.ODESC AS varchar(255)), ''), ''),
                COALESCE(NULLIF(CAST(lo.PROV AS varchar(100)), ''), NULLIF(CAST(lo.STATUSPROV AS varchar(100)), ''), NULLIF(CAST(lo.REFUSEUSER AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(lo.OMEMO AS varchar(1000)), ''), NULLIF(CAST(lo.RMEMO AS varchar(1000)), ''), '')
        ) AS OrderSequence
       ,COUNT(*) OVER (
            PARTITION BY CAST(
                COALESCE(
                    NULLIF(CAST(lo.ID AS varchar(100)), ''),
                    CONCAT(
                        'LABORDER_',
                        CAST(lo.PatientID AS varchar(50)), '_',
                        COALESCE(NULLIF(CAST(lo.ORDERCODE AS varchar(100)), ''), NULLIF(CAST(lo.NAME AS varchar(100)), ''), 'NO_CODE'), '_',
                        COALESCE(CONVERT(varchar(23), dt.OrderDttm, 121), 'NO_DATE')
                    )
                ) AS varchar(200)
            )
        ) AS OrderMultiplicity
       ,CASE
            WHEN invalid_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(invalid_user.[USERID] AS varchar(100)))
            WHEN invalid_provider.[DOCTOR] IS NOT NULL THEN CONCAT('PROVIDER|', CAST(invalid_provider.[DOCTOR] AS varchar(100)))
            ELSE NULL
        END AS InvalidatedByProviderExternalDataId
       ,CASE
            WHEN ordering_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(ordering_user.[USERID] AS varchar(100)))
            WHEN ordering_provider.[DOCTOR] IS NOT NULL THEN CONCAT('PROVIDER|', CAST(ordering_provider.[DOCTOR] AS varchar(100)))
            ELSE NULL
        END AS OrderingProviderExternalDataId
       ,CASE
            WHEN approving_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(approving_user.[USERID] AS varchar(100)))
            WHEN approving_provider.[DOCTOR] IS NOT NULL THEN CONCAT('PROVIDER|', CAST(approving_provider.[DOCTOR] AS varchar(100)))
            ELSE NULL
        END AS ApprovingProviderExternalDataId
       ,CASE
            WHEN performing_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(performing_user.[USERID] AS varchar(100)))
            WHEN performing_provider.[DOCTOR] IS NOT NULL THEN CONCAT('PROVIDER|', CAST(performing_provider.[DOCTOR] AS varchar(100)))
            ELSE NULL
        END AS PerformingProviderExternalDataId
       ,CASE
            WHEN recorded_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(recorded_user.[USERID] AS varchar(100)))
            ELSE NULL
        END AS RecordedByExternalDataId
       ,CASE
            WHEN lastup_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(lastup_user.[USERID] AS varchar(100)))
            WHEN lastup_provider.[DOCTOR] IS NOT NULL THEN CONCAT('PROVIDER|', CAST(lastup_provider.[DOCTOR] AS varchar(100)))
            ELSE NULL
        END AS LastUpdatingProviderExternalDataId
       ,CASE
            WHEN performing_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(performing_user.[USERID] AS varchar(100)))
            WHEN performing_provider.[DOCTOR] IS NOT NULL THEN CONCAT('PROVIDER|', CAST(performing_provider.[DOCTOR] AS varchar(100)))
            ELSE NULL
        END AS CollectingProviderExternalDataId
    FROM files.laborders AS lo
    CROSS APPLY
    (
        SELECT
             COALESCE(
                 TRY_CAST(CONCAT(CAST(lo.ORDERDATE AS varchar(50)), ' ', NULLIF(CAST(lo.ORDERTIME AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(lo.ORDERDATE AS datetime2)
             ) AS OrderDttm
            ,TRY_CAST(lo.OPENDATE AS datetime2) AS OpenDttm
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(lo.DRAWDATE AS varchar(50)), ' ', NULLIF(CAST(lo.DRAWTIME AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(lo.DRAWDATE AS datetime2)
             ) AS DrawDttm
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(lo.EXPECTDATE AS varchar(50)), ' ', NULLIF(CAST(lo.EXPECTTIME AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(lo.EXPECTDATE AS datetime2)
             ) AS ExpectDttm
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(lo.DONEDATE AS varchar(50)), ' ', NULLIF(CAST(lo.DONETIME AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(lo.DONEDATE AS datetime2)
             ) AS DoneDttm
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(lo.REVIEWDATE AS varchar(50)), ' ', NULLIF(CAST(lo.REVIEWTIME AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(lo.REVIEWDATE AS datetime2)
             ) AS ReviewDttm
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(lo.STATUSDATE AS varchar(50)), ' ', NULLIF(CAST(lo.STATUSTIME AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(lo.STATUSDATE AS datetime2)
             ) AS StatusDttm
    ) AS dt
    LEFT JOIN [files].[USERS] AS invalid_user
        ON invalid_user.[USERID] = COALESCE(NULLIF(CAST(lo.STATUSPROV AS varchar(100)), ''), NULLIF(CAST(lo.REFUSEUSER AS varchar(100)), ''))
    LEFT JOIN [files].[PROVIDERDOCTORCODEMASTER] AS invalid_provider
        ON invalid_provider.[DOCTOR] = COALESCE(NULLIF(CAST(lo.STATUSPROV AS varchar(100)), ''), NULLIF(CAST(lo.REFUSEUSER AS varchar(100)), ''))
        OR invalid_provider.[USERCODE] = COALESCE(NULLIF(CAST(lo.STATUSPROV AS varchar(100)), ''), NULLIF(CAST(lo.REFUSEUSER AS varchar(100)), ''))
    LEFT JOIN [files].[USERS] AS ordering_user
        ON ordering_user.[USERID] = NULLIF(CAST(lo.PROV AS varchar(100)), '')
    LEFT JOIN [files].[PROVIDERDOCTORCODEMASTER] AS ordering_provider
        ON ordering_provider.[DOCTOR] = NULLIF(CAST(lo.PROV AS varchar(100)), '')
        OR ordering_provider.[USERCODE] = NULLIF(CAST(lo.PROV AS varchar(100)), '')
    LEFT JOIN [files].[USERS] AS approving_user
        ON approving_user.[USERID] = NULLIF(CAST(lo.STATUSPROV AS varchar(100)), '')
    LEFT JOIN [files].[PROVIDERDOCTORCODEMASTER] AS approving_provider
        ON approving_provider.[DOCTOR] = NULLIF(CAST(lo.STATUSPROV AS varchar(100)), '')
        OR approving_provider.[USERCODE] = NULLIF(CAST(lo.STATUSPROV AS varchar(100)), '')
    LEFT JOIN [files].[USERS] AS performing_user
        ON performing_user.[USERID] = NULLIF(CAST(lo.DRAWPROV AS varchar(100)), '')
    LEFT JOIN [files].[PROVIDERDOCTORCODEMASTER] AS performing_provider
        ON performing_provider.[DOCTOR] = NULLIF(CAST(lo.DRAWPROV AS varchar(100)), '')
        OR performing_provider.[USERCODE] = NULLIF(CAST(lo.DRAWPROV AS varchar(100)), '')
    LEFT JOIN [files].[USERS] AS recorded_user
        ON recorded_user.[USERID] = NULLIF(CAST(lo.OPENUSER AS varchar(100)), '')
    LEFT JOIN [files].[USERS] AS lastup_user
        ON lastup_user.[USERID] = COALESCE(
            NULLIF(CAST(lo.STATUSPROV AS varchar(100)), ''),
            NULLIF(CAST(lo.REVIEWPROV AS varchar(100)), ''),
            NULLIF(CAST(lo.PROV2 AS varchar(100)), '')
        )
    LEFT JOIN [files].[PROVIDERDOCTORCODEMASTER] AS lastup_provider
        ON lastup_provider.[DOCTOR] = COALESCE(
            NULLIF(CAST(lo.STATUSPROV AS varchar(100)), ''),
            NULLIF(CAST(lo.REVIEWPROV AS varchar(100)), ''),
            NULLIF(CAST(lo.PROV2 AS varchar(100)), '')
        )
        OR lastup_provider.[USERCODE] = COALESCE(
            NULLIF(CAST(lo.STATUSPROV AS varchar(100)), ''),
            NULLIF(CAST(lo.REVIEWPROV AS varchar(100)), ''),
            NULLIF(CAST(lo.PROV2 AS varchar(100)), '')
        )
    WHERE lo.PatientID IS NOT NULL
      AND (
            NULLIF(LTRIM(RTRIM(CAST(lo.NAME AS varchar(255)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(lo.ODESC AS varchar(255)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(lo.ORDERCODE AS varchar(100)))), '') IS NOT NULL
      )
) AS src;



