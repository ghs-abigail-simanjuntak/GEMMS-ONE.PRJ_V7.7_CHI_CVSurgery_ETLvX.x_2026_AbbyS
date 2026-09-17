/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: Transaction
NOTES: 
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE [etl_dbo].[Transaction]
CREATE EXTERNAL TABLE [etl_dbo].[Transaction]
WITH (
    LOCATION = 'etl_dbo/Transaction',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(p.[PatientID], '|TX|', COALESCE(p.[PAYID], ''), '|', COALESCE(p.[CHGID], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    p.[PatientID] AS [PatientExternalDataId],
    COALESCE(NULLIF(p.[PAYDATE], ''), NULLIF(p.[XACDATE], '')) AS [ClinicallyRelevantDttm],
    COALESCE(NULLIF(pc.[PAYFLAG], ''), NULLIF(p.[DC], ''), NULLIF(p.[PAYORCODE], ''), 'Transaction') AS [TypeCode],
    COALESCE(NULLIF(pc.[PAYDESC], ''), NULLIF(p.[PAYORCODE], ''), 'Transaction') AS [TypeName],
    CASE WHEN p.[STATUS] = 'N' THEN 1 ELSE 0 END AS [IsInvalidated],
    CASE WHEN p.[STATUS] = 'N' THEN COALESCE(NULLIF(p.[PAYDATE], ''), NULLIF(p.[ENTRYDATE], '')) ELSE NULL END AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULLIF(p.[ENTRYDATE], '') AS [ExternalDataCreatedDttm],
    NULLIF(p.[ENTRYDATE], '') AS [ExternalDataUpdatedDttm],
    CASE
        WHEN p.[STATUS] = 'Y' THEN 'Active'
        WHEN p.[STATUS] = 'N' THEN 'Deleted'
        ELSE p.[STATUS]
    END AS [Status],
    COALESCE(NULLIF(pc.[PAYDESC], ''), NULLIF(p.[PAYORCODE], ''), 'Transaction') AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULLIF(ch.[XACDATE], '') AS [ServiceDttm],
    NULLIF(p.[ENTRYDATE], '') AS [RecordedDttm],
    CONCAT('account_',pa.[PatientID]) AS [AccountExternalDataId],
    p.[PAYID] AS [TransactionNumber],
    COALESCE(NULLIF(pc.[PAYDESC], ''), NULLIF(p.[PAYORCODE], ''), 'Transaction') AS [Description],
    CASE WHEN pc.[PAYFLAG] IN ('G', 'O', 'P') THEN CONCAT('PAYOR|', p.[PAYORCODE]) ELSE NULL END AS [PaidByExternalDataId],
    CASE WHEN pc.[PAYFLAG] IN ('1', '2', '3', '4', '5', '6', 'W', 'C') THEN CONCAT('PAYOR|', p.[PAYORCODE]) ELSE NULL END AS [PaidByInsuranceExternalDataId],
    NULLIF(p.[USERCODE], '') AS [EnteredByExternalDataId],
    NULLIF(p.[USERCODE], '') AS [LastUpdatedByExternalDataId],
    NULLIF(p.[PAYDATE], '') AS [TransactionDttm],
    NULLIF(p.[ENTRYDATE], '') AS [EnteredDttm],
    NULLIF(p.[ENTRYDATE], '') AS [LastUpdatedDttm],
    NULLIF(p.[XACDATE], '') AS [TransactionPostDttm],
    CASE
        WHEN p.[DC] = 'CW' THEN -TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18, 2))
        ELSE TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18, 2))
    END AS [Amount],
    p.[PLOCATION] AS [Department],
    NULL AS [BatchNumber],
    p.[PLOCATION] AS [Location],
    p.[CHECKID] AS [CheckNumber],
    CASE
        WHEN pc.[ACTIVE] = 'N'  THEN 0
        WHEN pc.[REFUNDFLAG] = 'Y'  THEN 4
        WHEN pc.[PAYFLAG] IN ('1', '2', '3') THEN 6 -- Insurance Payment
        WHEN pc.[PAYFLAG] IN ('G', 'O') THEN 5 -- Patient Payment
        WHEN pc.[PAYFLAG] IN ('C', 'P') THEN 2 -- Adjustment
        ELSE 0
    END AS [WellKnownTransactionType],
    NULL AS [EncounterExternalDataId],
    NULL AS [VisitExternalDataId],
    CASE
        WHEN NULLIF(ch.[CLAIMID], '') IS NOT NULL THEN CONCAT(ch.[PatientID], '|CLAIM|', COALESCE(ch.[INCIDENTNO], ''), '|', COALESCE(ch.[CLAIMID], ''))
        ELSE NULL
    END AS [ClaimExternalDataId],
    CONCAT(p.[PatientID], '|CHG|', COALESCE(p.[CHGID], '')) AS [ChargeExternalDataId]
-- SELECT TOP(100)*
FROM GEMMSCV.[files].[PAYMENT] p
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = p.[PatientID]
LEFT JOIN GEMMSCV.[files].[PAYORCODE] pc
    ON pc.[PAYORCODE] = p.[PAYORCODE]
LEFT JOIN GEMMSCV.[files].[CHARGE] ch
    ON ch.[PatientID] = p.[PatientID]
   AND ch.[CHGID] = p.[CHGID]
LEFT JOIN GEMMSCV.[files].[CHECK] ck
    ON ck.[PatientID] = p.[PatientID]
   AND ck.[CHECKID] = p.[CHECKID]
WHERE 1 = 1
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
UNION

SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(ch.[PatientID], '|TX|CHG|', COALESCE(ch.[CHGID], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    ch.[PatientID] AS [PatientExternalDataId],
    COALESCE(NULLIF(ch.[XACDATE], ''), NULLIF(ch.[BILLDATE], '')) AS [ClinicallyRelevantDttm],
    ch.[PTYPE] AS [TypeCode],
    ch.[FEETYPE] AS [TypeName],
    CASE WHEN ch.[STATUS] = 'N' THEN 1 ELSE 0 END AS [IsInvalidated],
    CASE WHEN ch.[STATUS] = 'N' THEN COALESCE(NULLIF(ch.[DENYDATE], ''), NULLIF(ch.[BILLDATE2], '')) ELSE NULL END AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    ch.[STATUS] AS [Status],
    COALESCE(NULLIF(ch.[PROCDESC], ''), NULLIF(ch.[CPTPRINT], ''), NULLIF(ch.[CPT], ''), 'Transaction') AS [Title],
    NULL AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULLIF(ch.[XACDATE], '') AS [ServiceDttm],
    NULLIF(ch.[ENTRYDATE], '') AS [RecordedDttm],
    CONCAT('Account_',pa.[PatientID]) AS [AccountExternalDataId],
    ch.[CHGID] AS [TransactionNumber],
    COALESCE(NULLIF(ch.[PROCDESC], ''), NULLIF(ch.[CPTPRINT], ''), NULLIF(ch.[CPT], ''), 'Transaction') AS [Description],
    NULL AS [PaidByExternalDataId],
    NULL AS [PaidByInsuranceExternalDataId],
    NULL AS [EnteredByExternalDataId],
    NULL AS [LastUpdatedByExternalDataId],
    NULLIF(ch.[BILLDATE], '') AS [TransactionDttm],
    NULLIF(ch.[ENTRYDATE], '') AS [EnteredDttm],
    NULLIF(ch.[BILLDATE2], '') AS [LastUpdatedDttm],
    NULLIF(ch.[XACDATE], '') AS [TransactionPostDttm],
    TRY_CAST(NULLIF(ch.[CHGAMOUNT], '') AS decimal(18, 2)) AS [Amount],
    ch.[FACILITY] AS [Department],
    NULL AS [BatchNumber],
    ch.[FACILITY] AS [Location],
    NULL AS [CheckNumber],
    3 AS [WellKnownTransactionType],
    NULL AS [EncounterExternalDataId],
    NULL AS [VisitExternalDataId],
    CASE
        WHEN NULLIF(ch.[CLAIMID], '') IS NOT NULL THEN CONCAT(ch.[PatientID], '|CLAIM|', COALESCE(ch.[INCIDENTNO], ''), '|', COALESCE(ch.[CLAIMID], ''))
        ELSE NULL
    END AS [ClaimExternalDataId],
    CONCAT(ch.[PatientID], '|CHG|', COALESCE(ch.[CHGID], '')) AS [ChargeExternalDataId]
-- SELECT COUNT(*)
FROM GEMMSCV.[files].[CHARGE] ch
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = ch.[PatientID]
WHERE 1 = 1
