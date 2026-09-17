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
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(cn.[PatientID], '|ACCNOTE|CHG|', COALESCE(cn.[CHGID], ''), '|', COALESCE(cn.[ENTERED], ''), '|', COALESCE(cn.[USERCODE], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    cn.[PatientID] AS [PatientExternalDataId],
    NULLIF(cn.[ENTERED], '') AS [ClinicallyRelevantDttm],
    'ChargeNote' AS [TypeCode],
    'Charge Note' AS [TypeName],
    NULL AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    NULL AS [Status],
    'Charge Note' AS [Title],
    NULL AS [IsSecure],
    CONVERT(VARCHAR(8000),
    JSON_MODIFY(
            '{
                "user":""
            }',
        '$."user"',CONVERT(VARCHAR(100), cn.[USERCODE]))
    ) AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    NULLIF(cn.[ENTERED], '') AS [RecordedDttm],
    NULLIF(cn.[ENTERED], '') AS [AuthoredDttm],
    CONCAT('account_',pa.[PatientID]) AS [AccountExternalDataId],
    NULL AS [AuthoredByPersonExternalDataId],
    NULL AS [EncounterExternalDataId],
    cn.[CNOTE] AS [Note],
    NULL AS [WellKnownPriority]
-- SELECT TOP(100)*
FROM GEMMSCV.[files].[CHARGENOTES] cn
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = cn.[PatientID]
WHERE 1 = 1
  AND NULLIF(LTRIM(RTRIM(COALESCE(cn.[CNOTE], ''))), '') IS NOT NULL

UNION ALL

SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(col.[PatientID], '|ACCNOTE|COLL|', COALESCE(col.[MSGID], ''), '|', COALESCE(col.[MDATE], ''), '|', COALESCE(col.[USERCODE], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    col.[PatientID] AS [PatientExternalDataId],
    NULLIF(col.[MDATE], '') AS [ClinicallyRelevantDttm],
    'CollectionNote' AS [TypeCode],
    'Collection Note' AS [TypeName],
    NULL AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    col.[STATUS] AS [Status],
    'Collection Note' AS [Title],
    NULL AS [IsSecure],
    CONVERT(VARCHAR(8000),
    JSON_MODIFY(
            '{
                "user":""
            }',
        '$."user"',CONVERT(VARCHAR(100), col.[USERCODE]))
    ) AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    NULLIF(col.[MDATE], '') AS [RecordedDttm],
    NULLIF(col.[MDATE], '') AS [AuthoredDttm],
    CONCAT('account_',pa.[PatientID]) AS [AccountExternalDataId],
    NULL AS [AuthoredByPersonExternalDataId],
    NULL AS [EncounterExternalDataId],
    col.[MSGTEXT] AS [Note],
    NULL AS [WellKnownPriority]
-- SELECT TOP(100)* 
FROM GEMMSCV.[files].[COLLECTIONNOTES] col
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = col.[PatientID]
WHERE 1 = 1
  AND NULLIF(LTRIM(RTRIM(COALESCE(col.[MSGTEXT], ''))), '') IS NOT NULL
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
