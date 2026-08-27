/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.PAYMENT, GEMMSCV.files.PAYORCODE, GEMMSCV.files.CHARGE
ITEM TYPE: Transaction
NOTES: Payment-led transaction reconstruction linked to Account by PatientID, with charge and payor enrichment.
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
    p.[PatientID] AS [AccountExternalDataId],
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
        WHEN pc.[PAYFLAG] IN ('1', '2', '3', '4', '5', '6') THEN 'InsurancePayment'
        WHEN pc.[PAYFLAG] IN ('G', 'O', 'P') THEN 'PatientPayment'
        WHEN pc.[PAYFLAG] = 'W' OR p.[DC] = 'CW' THEN 'WriteOff'
        WHEN pc.[PAYFLAG] = 'C' THEN 'Adjustment'
        ELSE 'Payment'
    END AS [WellKnownTransactionType],
    NULL AS [EncounterExternalDataId],
    NULL AS [VisitExternalDataId],
    CASE
        WHEN NULLIF(ch.[CLAIMID], '') IS NOT NULL THEN CONCAT(ch.[PatientID], '|CLAIM|', COALESCE(ch.[INCIDENTNO], ''), '|', COALESCE(ch.[CLAIMID], ''))
        ELSE NULL
    END AS [ClaimExternalDataId],
    CONCAT(p.[PatientID], '|CHG|', COALESCE(p.[CHGID], '')) AS [ChargeExternalDataId]
FROM GEMMSCV.[files].[PAYMENT] p
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = p.[PatientID]
LEFT JOIN GEMMSCV.[files].[PAYORCODE] pc
    ON pc.[PAYORCODE] = p.[PAYORCODE]
LEFT JOIN GEMMSCV.[files].[CHARGE] ch
    ON ch.[PatientID] = p.[PatientID]
   AND ch.[CHGID] = p.[CHGID]
WHERE 1 = 1
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
