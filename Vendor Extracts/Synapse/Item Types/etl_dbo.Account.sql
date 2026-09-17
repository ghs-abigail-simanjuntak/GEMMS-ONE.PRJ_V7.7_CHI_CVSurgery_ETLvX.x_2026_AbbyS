/********************************************************************************
SCRIPT DEPENDENCIES: 
ITEM TYPE: Account
NOTES: 
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Account
CREATE EXTERNAL TABLE etl_dbo.Account
WITH (
    LOCATION = 'etl_dbo/Account',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('account_',pa.[PatientID]) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    pa.[PatientID] AS [PatientExternalDataId],
    pd.[LASTVISIT] AS [ClinicallyRelevantDttm],
    COALESCE(pd.[PTYPE], 'Patient Account') AS [TypeCode],
    COALESCE(pd.[PTYPE], 'Patient Account') AS [TypeName],
    NULL AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    CASE
        WHEN NULLIF(LTRIM(RTRIM(pd.[DECEASED])), '') IS NOT NULL AND LTRIM(RTRIM(pd.[DECEASED])) NOT IN ('0', 'N', 'No') THEN 0
        ELSE 1
    END AS [Status],
    NULL AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    pd.[LASTVISIT] AS [RecordedDttm],
    0 AS [WellKnownAccountType],
    NULL AS [Category],
    pa.[ACCOUNT] AS [ReferenceId],
    NULL AS [Description],
    NULL AS [CreatedByExternalDataId],
    NULL AS [LastUpdatedByExternalDataId],
    NULL AS [CreatedDttm],
    NULL AS [HoldDttm],
    NULL AS [LastStatementDttm],
    NULL AS [LastUpdatedDttm],
    pd.[LASTPAY] AS [LastTransactionDttm],
    NULL AS [LastStatementAmount],
    NULL AS [ThirtyDayBalanceInterval],
    NULL AS [SixtyDayBalanceInterval],
    NULL AS [NinetyDayBalanceInterval],
    NULL AS [CurrentBalance],
    NULL AS [LastTransactionAmount]
-- SELECT TOP(100)*
FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
    ON pd.[PatientID] = pa.[PatientID]
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)