/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: Statement
NOTES:
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Statement
CREATE EXTERNAL TABLE etl_dbo.Statement
WITH (
    LOCATION = 'etl_dbo/Statement',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(sr.[PatientID], '|STMT|', COALESCE(sr.[RUNDATE], ''),sr.CHGID) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    sr.[PatientID] AS [PatientExternalDataId],
    sr.[RUNDATE] AS [ClinicallyRelevantDttm],
    'Statement' AS [TypeCode],
    'Statement' AS [TypeName],
    NULL AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    NULL AS [Status],
    'Statement' AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    sr.[RUNDATE] AS [RecordedDttm],
    sr.[PatientID] AS [AccountExternalDataId],
    NULL AS [Description],
    pa.[ACCOUNT] AS [AccountNumber],
    sr.[RUNDATE] AS [LastUpdatedDttm],
    sr.[RUNDATE] AS [StatementDttm],
    sr.[RUNDATE] AS [EndDttm],
    NULL AS [AssignedToExternalDataId],
    NULL AS [CreatedByExternalDataId],
    NULL AS [PaidByExternalDataId],
    NULL AS [PaidByInsuranceExternalDataId],
    NULL AS [LastUpdatedByExternalDataId],
    NULL AS [RecordedByExternalDataId],
    NULL AS [TotalCharges],
    NULL AS [PatientBalance],
    NULL AS [InsuranceBalance],
    NULL AS [InsurancePayments],
    NULL AS [PatientPayments],
    NULL AS [TotalPayments],
    NULL AS [InsuranceOpeningBalance],
    NULL AS [PatientOpeningBalance],
    NULL AS [Adjustments],
    NULL AS [EncounterExternalDataId],
    NULL AS [VisitExternalDataId]
-- SELECT COUNT(*)
-- SELECT TOP(100)*
FROM GEMMSCV.[files].[CLAIMSTATEMENTRUNDATES] sr
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = sr.[PatientID]
WHERE 1 = 1
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
