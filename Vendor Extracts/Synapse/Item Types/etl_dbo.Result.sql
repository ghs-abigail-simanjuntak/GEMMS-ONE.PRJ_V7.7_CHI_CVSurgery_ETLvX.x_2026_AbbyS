/********************************************************************************
SCRIPT DEPENDENCIES: None identified.
ITEM TYPE: Result
NOTES:
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[Result]
CREATE EXTERNAL TABLE [etl_dbo].[Result]
WITH
(
    LOCATION = 'etl_dbo/Result',
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
            WHEN src.[ResultMultiplicity] > 1 THEN CONCAT(LEFT(src.[BaseExternalDataId], 188), '_', CAST(src.[ResultSequence] AS varchar(10)))
            ELSE src.[BaseExternalDataId]
        END AS varchar(200)
    ) AS [ExternalDataId]
   ,'1' AS [ExternalDataVersion]
   ,1 AS [DisplayOrder]
   ,src.[PatientExternalDataId] AS [PatientExternalDataId]
   ,COALESCE(
        TRY_CAST(src.[DATEBACK] AS datetime2),
        TRY_CAST(src.[DATELOAD] AS datetime2),
        TRY_CAST(src.[DATEIN] AS datetime2)
    ) AS [ClinicallyRelevantDttm]
   ,COALESCE(NULLIF(CAST(src.[OBSERVE_ID] AS varchar(100)), ''), 'LabResult') AS [TypeCode]
   ,COALESCE(NULLIF(CAST(src.[OBSERVE_DESC] AS varchar(250)), ''), NULLIF(CAST(src.[OBSERVE_ID] AS varchar(100)), ''), 'Lab Result') AS [TypeName]
   ,CAST(
        CASE
            WHEN UPPER(LTRIM(RTRIM(CAST(src.[STATUS] AS varchar(100))))) IN ('CANCELLED', 'CANCELED', 'DELETED', 'VOID', 'ERROR')
                THEN 1
            ELSE 0
        END AS bit
    ) AS [IsInvalidated]
   ,CASE
        WHEN UPPER(LTRIM(RTRIM(CAST(src.[STATUS] AS varchar(100))))) IN ('CANCELLED', 'CANCELED', 'DELETED', 'VOID', 'ERROR')
            THEN COALESCE(
                TRY_CAST(src.[DATELOAD] AS datetime2),
                TRY_CAST(src.[DATEBACK] AS datetime2),
                TRY_CAST(src.[DATEIN] AS datetime2)
            )
        ELSE NULL
    END AS [InvalidatedDttm]
   ,NULL AS [InvalidatedByProviderExternalDataId]
   ,COALESCE(
        TRY_CAST(src.[DATEIN] AS datetime2),
        TRY_CAST(src.[DATELOAD] AS datetime2),
        TRY_CAST(src.[DATEBACK] AS datetime2)
    ) AS [ExternalDataCreatedDttm]
   ,COALESCE(
        TRY_CAST(src.[DATELOAD] AS datetime2),
        TRY_CAST(src.[DATEBACK] AS datetime2),
        TRY_CAST(src.[DATEIN] AS datetime2)
    ) AS [ExternalDataUpdatedDttm]
   ,NULLIF(CAST(src.[STATUS] AS varchar(100)), '') AS [Status]
   ,COALESCE(NULLIF(CAST(src.[ORDER_DESC] AS varchar(500)), ''), NULLIF(CAST(src.[OBSERVE_DESC] AS varchar(250)), '')) AS [Title]
   ,CAST(0 AS bit) AS [IsSecure]
   ,NULL AS [VcoSetEntries]
   ,CAST(
        CONCAT(
            '{',
            '"sourceOrderId":"', STRING_ESCAPE(COALESCE(src.[SourceOrderId], ''), 'json'), '",',
            '"abnormal":"', STRING_ESCAPE(COALESCE(CAST(src.[ABNORMAL] AS varchar(100)), ''), 'json'), '",',
            '"refRange":"', STRING_ESCAPE(COALESCE(CAST(src.[REF_RANGE] AS varchar(250)), ''), 'json'), '",',
            '"source":"', STRING_ESCAPE(COALESCE(CAST(src.[SOURCE] AS varchar(100)), ''), 'json'), '",',
            '"sourceFlag":"', STRING_ESCAPE(COALESCE(CAST(src.[SOURCEFLAG] AS varchar(100)), ''), 'json'), '",',
            '"tComment":"', STRING_ESCAPE(COALESCE(CAST(src.[TCOMMENT] AS varchar(2000)), ''), 'json'), '",',
            '"tSequence":"', STRING_ESCAPE(COALESCE(CAST(src.[TSEQUENCE] AS varchar(50)), ''), 'json'), '",',
            '"tSubSeq":"', STRING_ESCAPE(COALESCE(CAST(src.[TSUBSEQ] AS varchar(50)), ''), 'json'), '",',
            '"tSubSeqA":"', STRING_ESCAPE(COALESCE(CAST(src.[TSUBSEQA] AS varchar(50)), ''), 'json'), '"',
            '}'
        ) AS varchar(4000)
    ) AS [ExtendedProperties]
   ,NULL AS [ServiceDttm]
   ,COALESCE(
        TRY_CAST(src.[DATEIN] AS datetime2),
        TRY_CAST(src.[DATELOAD] AS datetime2)
    ) AS [RecordedDttm]
   ,ol.[ResolvedOrderExternalDataId] AS [OrderExternalDataId]
   ,NULLIF(CAST(src.[ORDER_DESC] AS varchar(500)), '') AS [OrderName]
   ,COALESCE(
        TRY_CAST(src.[DATEBACK] AS datetime2),
        TRY_CAST(src.[DATELOAD] AS datetime2),
        TRY_CAST(src.[DATEIN] AS datetime2)
    ) AS [ResultedDttm]
   ,TRY_CAST(src.[DATEIN] AS datetime2) AS [OrderDttm]
   ,NULLIF(CAST(src.[SOURCE] AS varchar(250)), '') AS [PerformingLocationName]
   ,NULLIF(CAST(src.[UPIN] AS varchar(100)), '') AS [OrderingProviderExternalDataId]
   ,NULL AS [EncounterExternalDataId]
FROM
(
    SELECT
        l.*
       ,rb.[PatientExternalDataId]
       ,rb.[SourceOrderId]
       ,rb.[BaseExternalDataId]
       ,ROW_NUMBER() OVER (
            PARTITION BY rb.[BaseExternalDataId]
            ORDER BY
                COALESCE(TRY_CAST(l.[DATEBACK] AS datetime2), TRY_CAST(l.[DATELOAD] AS datetime2), TRY_CAST(l.[DATEIN] AS datetime2))
               ,COALESCE(NULLIF(CAST(l.[STATUS] AS varchar(100)), ''), '')
               ,COALESCE(NULLIF(CAST(l.[OBSERVE_VALUE] AS varchar(500)), ''), '')
               ,COALESCE(NULLIF(CAST(l.[OBSERVE_DESC] AS varchar(250)), ''), '')
               ,COALESCE(NULLIF(CAST(l.[SOURCE] AS varchar(100)), ''), '')
               ,COALESCE(NULLIF(CAST(l.[TCOMMENT] AS varchar(2000)), ''), '')
               ,COALESCE(NULLIF(CAST(l.[ORDER_DESC] AS varchar(500)), ''), '')
        ) AS [ResultSequence]
       ,COUNT(*) OVER (
            PARTITION BY rb.[BaseExternalDataId]
        ) AS [ResultMultiplicity]
    FROM files.labresults AS l
    CROSS APPLY
    (
        SELECT
            CAST(l.[PatientID] AS varchar(100)) AS [PatientExternalDataId]
           ,NULLIF(LTRIM(RTRIM(CAST(l.[ORDER_ID] AS varchar(100)))), '') AS [SourceOrderId]
           ,CAST(
                COALESCE(
                    NULLIF(
                        CONCAT(
                            'LR_',
                            CAST(l.[PatientID] AS varchar(50)), '_',
                            CAST(l.[ORDER_ID] AS varchar(100)), '_',
                            CAST(l.[OBSERVE_ID] AS varchar(100)), '_',
                            CAST(l.[TSEQUENCE] AS varchar(50)), '_',
                            CAST(l.[TSUBSEQ] AS varchar(50)), '_',
                            CAST(l.[TSUBSEQA] AS varchar(50))
                        ),
                        ''
                    ),
                    CONCAT(
                        'LR_',
                        CAST(l.[PatientID] AS varchar(50)), '_',
                        CONVERT(
                            varchar(23),
                            COALESCE(
                                TRY_CAST(l.[DATEBACK] AS datetime2),
                                TRY_CAST(l.[DATELOAD] AS datetime2),
                                TRY_CAST(l.[DATEIN] AS datetime2)
                            ),
                            121
                        )
                    )
                ) AS varchar(200)
            ) AS [BaseExternalDataId]
    ) AS rb
    WHERE l.[PatientID] IS NOT NULL
      AND (
            NULLIF(LTRIM(RTRIM(CAST(l.[OBSERVE_VALUE] AS varchar(500)))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(CAST(l.[OBSERVE_DESC] AS varchar(250)))), '') IS NOT NULL
      )
) AS src
LEFT JOIN
(
    SELECT
        oc.[PatientExternalDataId]
       ,oc.[SourceOrderId]
       ,MIN(
            CAST(
                CASE
                    WHEN oc.[OrderMultiplicity] > 1 THEN CONCAT(oc.[BaseExternalDataId], '|', CAST(oc.[OrderSequence] AS varchar(10)))
                    ELSE oc.[BaseExternalDataId]
                END AS varchar(225)
            )
        ) AS [ResolvedOrderExternalDataId]
    FROM
    (
        SELECT
            CAST(lo.[PatientID] AS varchar(100)) AS [PatientExternalDataId]
           ,ob.[SourceOrderId]
           ,ob.[BaseExternalDataId]
           ,ROW_NUMBER() OVER (
                PARTITION BY ob.[BaseExternalDataId]
                ORDER BY
                    CAST(lo.[PatientID] AS varchar(50))
                   ,COALESCE(dt.[OrderDttm], dt.[OpenDttm], dt.[DrawDttm], dt.[ExpectDttm], dt.[DoneDttm], dt.[ReviewDttm], TRY_CAST(lo.[DATETIME] AS datetime2))
                   ,COALESCE(dt.[StatusDttm], dt.[ReviewDttm], dt.[DoneDttm], dt.[DrawDttm], dt.[OpenDttm], dt.[OrderDttm])
                   ,COALESCE(NULLIF(CAST(lo.[STATUS] AS varchar(100)), ''), NULLIF(CAST(lo.[OPENSTATUS] AS varchar(100)), ''), NULLIF(CAST(lo.[REFUSESTATUS] AS varchar(100)), ''), '')
                   ,COALESCE(NULLIF(CAST(lo.[ORDERCODE] AS varchar(100)), ''), NULLIF(CAST(lo.[NAME] AS varchar(255)), ''), NULLIF(CAST(lo.[ODESC] AS varchar(255)), ''), '')
                   ,COALESCE(NULLIF(CAST(lo.[PROV] AS varchar(100)), ''), NULLIF(CAST(lo.[STATUSPROV] AS varchar(100)), ''), NULLIF(CAST(lo.[REFUSEUSER] AS varchar(100)), ''), '')
                   ,COALESCE(NULLIF(CAST(lo.[OMEMO] AS varchar(1000)), ''), NULLIF(CAST(lo.[RMEMO] AS varchar(1000)), ''), '')
            ) AS [OrderSequence]
           ,COUNT(*) OVER (
                PARTITION BY ob.[BaseExternalDataId]
            ) AS [OrderMultiplicity]
        FROM files.laborders AS lo
        CROSS APPLY
        (
            SELECT
                 COALESCE(
                     TRY_CAST(CONCAT(CAST(lo.[ORDERDATE] AS varchar(50)), ' ', NULLIF(CAST(lo.[ORDERTIME] AS varchar(50)), '')) AS datetime2),
                     TRY_CAST(lo.[ORDERDATE] AS datetime2)
                 ) AS [OrderDttm]
                ,TRY_CAST(lo.[OPENDATE] AS datetime2) AS [OpenDttm]
                ,COALESCE(
                     TRY_CAST(CONCAT(CAST(lo.[DRAWDATE] AS varchar(50)), ' ', NULLIF(CAST(lo.[DRAWTIME] AS varchar(50)), '')) AS datetime2),
                     TRY_CAST(lo.[DRAWDATE] AS datetime2)
                 ) AS [DrawDttm]
                ,COALESCE(
                     TRY_CAST(CONCAT(CAST(lo.[EXPECTDATE] AS varchar(50)), ' ', NULLIF(CAST(lo.[EXPECTTIME] AS varchar(50)), '')) AS datetime2),
                     TRY_CAST(lo.[EXPECTDATE] AS datetime2)
                 ) AS [ExpectDttm]
                ,COALESCE(
                     TRY_CAST(CONCAT(CAST(lo.[DONEDATE] AS varchar(50)), ' ', NULLIF(CAST(lo.[DONETIME] AS varchar(50)), '')) AS datetime2),
                     TRY_CAST(lo.[DONEDATE] AS datetime2)
                 ) AS [DoneDttm]
                ,COALESCE(
                     TRY_CAST(CONCAT(CAST(lo.[REVIEWDATE] AS varchar(50)), ' ', NULLIF(CAST(lo.[REVIEWTIME] AS varchar(50)), '')) AS datetime2),
                     TRY_CAST(lo.[REVIEWDATE] AS datetime2)
                 ) AS [ReviewDttm]
                ,COALESCE(
                     TRY_CAST(CONCAT(CAST(lo.[STATUSDATE] AS varchar(50)), ' ', NULLIF(CAST(lo.[STATUSTIME] AS varchar(50)), '')) AS datetime2),
                     TRY_CAST(lo.[STATUSDATE] AS datetime2)
                 ) AS [StatusDttm]
        ) AS dt
        CROSS APPLY
        (
            SELECT
                NULLIF(LTRIM(RTRIM(CAST(lo.[ID] AS varchar(100)))), '') AS [SourceOrderId]
               ,CAST(
                    COALESCE(
                        NULLIF(CAST(lo.[ID] AS varchar(100)), ''),
                        CONCAT(
                            'LABORDER_',
                            CAST(lo.[PatientID] AS varchar(50)), '_',
                            COALESCE(NULLIF(CAST(lo.[ORDERCODE] AS varchar(100)), ''), NULLIF(CAST(lo.[NAME] AS varchar(100)), ''), 'NO_CODE'), '_',
                            COALESCE(CONVERT(varchar(23), dt.[OrderDttm], 121), 'NO_DATE')
                        )
                    ) AS varchar(200)
                ) AS [BaseExternalDataId]
        ) AS ob
    ) AS oc
    WHERE oc.[SourceOrderId] IS NOT NULL
    GROUP BY
        oc.[PatientExternalDataId]
       ,oc.[SourceOrderId]
) AS ol
    ON src.[PatientExternalDataId] = ol.[PatientExternalDataId]
   AND src.[SourceOrderId] = ol.[SourceOrderId];