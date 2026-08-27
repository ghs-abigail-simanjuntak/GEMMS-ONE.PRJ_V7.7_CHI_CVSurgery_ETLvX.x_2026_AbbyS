/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.CHARGENOTES, GEMMSCV.files.COLLECTIONNOTES
ITEM TYPE: AccountNote
NOTES: Account note children sourced from charge notes and collection notes, linked to Account by PatientID.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.AccountNote
CREATE EXTERNAL TABLE etl_dbo.AccountNote
WITH (
    LOCATION = 'etl_dbo/AccountNote',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
WITH note_rows AS (
    SELECT
        cn.[PatientID],
        CONCAT(cn.[PatientID], '|ACCNOTE|CHG|', COALESCE(cn.[CHGID], ''), '|', COALESCE(cn.[ENTERED], ''), '|', COALESCE(cn.[USERCODE], '')) AS [ExternalDataId],
        '1' AS [ExternalDataVersion],
        NULLIF(cn.[ENTERED], '') AS [ClinicallyRelevantDttm],
        'ChargeNote' AS [TypeCode],
        'Charge Note' AS [TypeName],
        0 AS [IsInvalidated],
        NULL AS [InvalidatedDttm],
        NULL AS [InvalidatedByProviderExternalDataId],
        NULLIF(cn.[ENTERED], '') AS [ExternalDataCreatedDttm],
        NULLIF(cn.[ENTERED], '') AS [ExternalDataUpdatedDttm],
        'Active' AS [Status],
        'Charge Note' AS [Title],
        0 AS [IsSecure],
        NULL AS [ExtendedProperties],
        NULL AS [ServiceDttm],
        NULLIF(cn.[ENTERED], '') AS [RecordedDttm],
        NULLIF(cn.[ENTERED], '') AS [AuthoredDttm],
        cn.[PatientID] AS [AccountExternalDataId],
        NULLIF(cn.[USERCODE], '') AS [AuthoredByPersonExternalDataId],
        NULL AS [EncounterExternalDataId],
        cn.[CNOTE] AS [Note],
        NULL AS [WellKnownPriority]
    FROM GEMMSCV.[files].[CHARGENOTES] cn

    UNION ALL

    SELECT
        col.[PatientID],
        CONCAT(col.[PatientID], '|ACCNOTE|COLL|', COALESCE(col.[MSGID], ''), '|', COALESCE(col.[MDATE], ''), '|', COALESCE(col.[USERCODE], '')) AS [ExternalDataId],
        '1' AS [ExternalDataVersion],
        NULLIF(col.[MDATE], '') AS [ClinicallyRelevantDttm],
        'CollectionNote' AS [TypeCode],
        'Collection Note' AS [TypeName],
        CASE WHEN col.[STATUS] = 'N' THEN 1 ELSE 0 END AS [IsInvalidated],
        CASE WHEN col.[STATUS] = 'N' THEN NULLIF(col.[MDATE], '') ELSE NULL END AS [InvalidatedDttm],
        NULL AS [InvalidatedByProviderExternalDataId],
        NULLIF(col.[MDATE], '') AS [ExternalDataCreatedDttm],
        NULLIF(col.[MDATE], '') AS [ExternalDataUpdatedDttm],
        CASE WHEN NULLIF(col.[STATUS], '') IS NOT NULL THEN col.[STATUS] ELSE 'Active' END AS [Status],
        'Collection Note' AS [Title],
        0 AS [IsSecure],
        NULL AS [ExtendedProperties],
        NULL AS [ServiceDttm],
        NULLIF(col.[MDATE], '') AS [RecordedDttm],
        NULLIF(col.[MDATE], '') AS [AuthoredDttm],
        col.[PatientID] AS [AccountExternalDataId],
        NULLIF(col.[USERCODE], '') AS [AuthoredByPersonExternalDataId],
        NULL AS [EncounterExternalDataId],
        col.[MSGTEXT] AS [Note],
        CASE WHEN col.[STATUS] = 'N' THEN 'Low' ELSE NULL END AS [WellKnownPriority]
    FROM GEMMSCV.[files].[COLLECTIONNOTES] col
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    nr.[ExternalDataId],
    nr.[ExternalDataVersion],
    1 AS [DisplayOrder],
    nr.[PatientID] AS [PatientExternalDataId],
    nr.[ClinicallyRelevantDttm],
    nr.[TypeCode],
    nr.[TypeName],
    nr.[IsInvalidated],
    nr.[InvalidatedDttm],
    nr.[InvalidatedByProviderExternalDataId],
    nr.[ExternalDataCreatedDttm],
    nr.[ExternalDataUpdatedDttm],
    nr.[Status],
    nr.[Title],
    nr.[IsSecure],
    nr.[ExtendedProperties],
    nr.[ServiceDttm],
    nr.[RecordedDttm],
    nr.[AuthoredDttm],
    nr.[AccountExternalDataId],
    nr.[AuthoredByPersonExternalDataId],
    nr.[EncounterExternalDataId],
    nr.[Note],
    nr.[WellKnownPriority]
FROM note_rows nr
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = nr.[PatientID]
WHERE 1 = 1
  AND NULLIF(LTRIM(RTRIM(COALESCE(nr.[Note], ''))), '') IS NOT NULL
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
