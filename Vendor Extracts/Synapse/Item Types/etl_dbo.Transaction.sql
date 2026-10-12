/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: Transaction
NOTES: 
SCALE:
********************************************************************************/
 
DROP EXTERNAL TABLE [etl_dbo].[Transaction]
CREATE EXTERNAL TABLE [etl_dbo].[Transaction]
WITH (
    LOCATION = 'etl_dbo/Transaction',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
-- select top(100)* from [etl_dbo].[Transaction] where typecode = 'payment'
SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(p.[PatientID], '|TX|', COALESCE(p.[PAYID], ''), '|', COALESCE(p.[CHGID], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    p.[PatientID] AS [PatientExternalDataId],
    COALESCE(NULLIF(p.[PAYDATE], ''), NULLIF(p.[XACDATE], '')) AS [ClinicallyRelevantDttm],
    'Payment' AS [TypeCode],
    'Payment' AS [TypeName],
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
    CASE WHEN pc.[PAYFLAG] IN ('G', 'O', 'P') AND p.[PAYORCODE] IS NOT NULL THEN CONCAT('PAYOR|', p.[PAYORCODE]) ELSE NULL END AS [PaidByExternalDataId],
    CASE WHEN pc.[PAYFLAG] IN ('1', '2', '3', '4', '5', '6', 'W', 'C') AND i.[PatientId] IS NOT NULL THEN CONCAT(i.[PatientID], '|', COALESCE(i.[INUM], ''), '|', COALESCE(i.[INSCODE], ''), '|', COALESCE(i.[POLICYNO], '')) ELSE NULL END AS [PaidByInsuranceExternalDataId],
    NULLIF(CONCAT('USER|',p.[USERCODE], ''), '') AS [EnteredByExternalDataId],
    NULLIF(CONCAT('USER|',p.[USERCODE], ''), '') AS [LastUpdatedByExternalDataId],
    NULLIF(p.[PAYDATE], '') AS [TransactionDttm],
    NULLIF(p.[ENTRYDATE], '') AS [EnteredDttm],
    NULLIF(p.[ENTRYDATE], '') AS [LastUpdatedDttm],
    NULLIF(p.[XACDATE], '') AS [TransactionPostDttm],
    -ABS(TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18,2))) AS [Amount],
    p.[PLOCATION] AS [Department],
    NULL AS [BatchNumber],
    p.[PLOCATION] AS [Location],
    p.[CHECKID] AS [CheckNumber],
    -- CASE
    --     WHEN pc.[ACTIVE] = 'N'  THEN 0
    --     WHEN pc.[REFUNDFLAG] = 'Y'  THEN 4
    --     WHEN pc.[PAYFLAG] IN ('1', '2', '3') THEN 6 -- Insurance Payment
    --     WHEN pc.[PAYFLAG] IN ('G', 'O') THEN 5 -- Patient Payment
    --     WHEN pc.[PAYFLAG] IN ('C', 'P') THEN 2 -- Adjustment
    --     ELSE 0
    -- END AS [WellKnownTransactionType],
    CASE
        WHEN pc.[REFUNDFLAG] = 'Y'  THEN 4
        WHEN pc.[PAYFLAG] IN ('1', '2', '3') THEN 6 -- Insurance Payment
        WHEN pc.[PAYFLAG] IN ('G', 'O') THEN 5 -- Patient Payment
        WHEN pc.[PAYFLAG] IN ('C', 'P') THEN 2 -- Adjustment
        ELSE 6
    END AS [WellKnownTransactionType],
    NULL AS [EncounterExternalDataId],
    NULL AS [VisitExternalDataId],
    CASE
        WHEN cl.[INCIDENTNO] IS NOT NULL THEN CONCAT(cl.[PatientID], '|CLAIM|', COALESCE(NULLIF(cl.[INCIDENTNO], ''), ''), '|', COALESCE(NULLIF(cl.[CLAIMID], ''), ''))
        ELSE NULL
    END AS [ClaimExternalDataId],
    CONCAT(p.[PatientID], '|CHG|', COALESCE(p.[CHGID], '')) AS [ChargeExternalDataId]
-- SELECT COUNT(*)
FROM [files].[PAYMENT] p
INNER JOIN [files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = p.[PatientID]
LEFT JOIN [files].[PAYORCODE] pc
    ON pc.[PAYORCODE] = p.[PAYORCODE]
LEFT JOIN [files].[INSURANCE] i
    ON i.[patientid] = p.[patientid]
    AND p.[inscode] = i.[inscode] 
    AND i.inum = '1'
LEFT JOIN [files].[CHARGE] ch
    ON ch.[PatientID] = p.[PatientID]
    AND ch.[CHGID] = p.[CHGID]
LEFT JOIN [files].[CHECK] ck
    ON ck.[PatientID] = p.[PatientID]
    AND ck.[CHECKID] = p.[CHECKID]
LEFT JOIN (
    SELECT DISTINCT * FROM [files].[CLAIM]
) cl
    ON cl.[PatientID] = ch.[PatientID]
    AND cl.[INCIDENTNO] = ch.[INCIDENTNO]
WHERE 1 = 1
AND ch.chgid IS NOT NULL
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
UNION

SELECT
    NEWID() AS [Id],
    2 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(ch.[PatientID], '|TX|CHG|', COALESCE(ch.[CHGID], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    ch.[PatientID] AS [PatientExternalDataId],
    COALESCE(NULLIF(ch.[XACDATE], ''), NULLIF(ch.[BILLDATE], '')) AS [ClinicallyRelevantDttm],
    'Charge' AS [TypeCode],
    'Charge' AS [TypeName],
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
        WHEN cl.[INCIDENTNO] IS NOT NULL THEN CONCAT(cl.[PatientID], '|CLAIM|', COALESCE(NULLIF(cl.[INCIDENTNO], ''), ''), '|', COALESCE(NULLIF(cl.[CLAIMID], ''), ''))
        ELSE NULL
    END AS [ClaimExternalDataId],
    CONCAT(ch.[PatientID], '|CHG|', COALESCE(ch.[CHGID], '')) AS [ChargeExternalDataId]
-- SELECT COUNT(*)
FROM [files].[CHARGE] ch
INNER JOIN [files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = ch.[PatientID]
LEFT JOIN (
    SELECT DISTINCT * FROM [files].[CLAIM]
) cl
    ON cl.[PatientID] = ch.[PatientID]
    AND cl.[INCIDENTNO] = ch.[INCIDENTNO]
WHERE 1 = 1
AND cl.[PatientID] IS NOT NULL