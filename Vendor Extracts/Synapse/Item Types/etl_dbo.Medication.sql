/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PRESCRIPTIONHISTORY
ITEM TYPE: Medication
NOTES: Direct medication reconstruction from PRESCRIPTIONHISTORY, using the validated medication source view.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Medication
CREATE EXTERNAL TABLE etl_dbo.Medication
WITH (
    LOCATION = 'etl_dbo/Medication',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(rx.[PatientID], '|RX|', COALESCE(rx.[PRESCRIPTI], ''), '|', COALESCE(rx.[RXDATE], ''), '|', COALESCE(rx.[DRUGNAME], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    rx.[PatientID] AS [PatientExternalDataId],
    NULLIF(rx.[RXDATE], '') AS [ClinicallyRelevantDttm],
    COALESCE(NULLIF(rx.[RXNORM], ''), NULLIF(rx.[NDC], ''), NULLIF(rx.[IDC9], '')) AS [TypeCode],
    rx.[DRUGNAME] AS [TypeName],
    CASE
        WHEN NULLIF(rx.[STOPDATE], '') IS NOT NULL THEN 1
        WHEN NULLIF(rx.[ACTIVEFLAG], '') IS NOT NULL AND rx.[ACTIVEFLAG] NOT IN ('Y', 'A', 'Active') THEN 1
        ELSE 0
    END AS [IsInvalidated],
    NULLIF(rx.[STOPDATE], '') AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULLIF(rx.[ORIGDATE], '') AS [ExternalDataCreatedDttm],
    NULLIF(rx.[STOPDATE], '') AS [ExternalDataUpdatedDttm],
    CASE
        WHEN NULLIF(rx.[STOPDATE], '') IS NOT NULL THEN 'Stopped'
        WHEN rx.[ACTIVEFLAG] = 'Y' THEN 'Active'
        WHEN NULLIF(rx.[ACTIVEFLAG], '') IS NOT NULL THEN rx.[ACTIVEFLAG]
        ELSE NULL
    END AS [Status],
    rx.[DRUGNAME] AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    NULLIF(rx.[ORIGDATE], '') AS [RecordedDttm],
    NULL AS [AdministeringPersonExternalDataId],
    NULL AS [RecordingPersonExternalDataId],
    rx.[PRESCRIPTI] AS [Strength],
    NULL AS [Form],
    rx.[NDC] AS [Ndc],
    NULL AS [Ddi],
    NULL AS [OrderingPersonExternalDataId],
    NULLIF(rx.[RXDATE], '') AS [RxDttm],
    rx.[INSTRUCTIO] AS [FreeTextSig],
    NULLIF(rx.[STOPUSER], '') AS [LastUpdatedByExternalDataId],
    NULL AS [SupervisingPersonExternalDataId],
    NULL AS [EncounterExternalDataId],
    NULL AS [ParentItemExternalDataId]
FROM GEMMSCV.[files].[PRESCRIPTIONHISTORY] rx
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] p
    ON p.[PatientID] = rx.[PatientID]
WHERE 1 = 1
--Functional

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
