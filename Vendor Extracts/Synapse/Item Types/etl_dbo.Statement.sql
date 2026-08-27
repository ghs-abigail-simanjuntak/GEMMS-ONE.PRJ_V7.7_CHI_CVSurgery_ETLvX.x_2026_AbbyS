/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.CLAIMSTATEMENTRUNDATES, GEMMSCV.files.CHARGE, GEMMSCV.files.PAYMENT, GEMMSCV.files.PAYORCODE
ITEM TYPE: Statement
NOTES: Statement rows grouped by patient and statement run date, linked to Account by PatientID.
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
WITH statement_charges AS (
    SELECT
        sr.[PatientID],
        sr.[RUNDATE],
        pa.[ACCOUNT] AS [AccountNumber],
        SUM(TRY_CAST(NULLIF(ch.[CHGAMOUNT], '') AS decimal(18, 2))) AS [TotalCharges]
    FROM GEMMSCV.[files].[CLAIMSTATEMENTRUNDATES] sr
    INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
        ON pa.[PatientID] = sr.[PatientID]
    LEFT JOIN GEMMSCV.[files].[CHARGE] ch
        ON ch.[PatientID] = sr.[PatientID]
       AND ch.[CHGID] = sr.[CHGID]
    GROUP BY sr.[PatientID], sr.[RUNDATE], pa.[ACCOUNT]
),
statement_payments AS (
    SELECT
        sr.[PatientID],
        sr.[RUNDATE],
        SUM(CASE WHEN p.[STATUS] = 'Y' THEN TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18, 2)) ELSE 0 END) AS [TotalPayments],
        SUM(CASE WHEN pc.[PAYFLAG] IN ('1', '2', '3', '4', '5', '6') AND p.[STATUS] = 'Y' THEN TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18, 2)) ELSE 0 END) AS [InsurancePayments],
        SUM(CASE WHEN pc.[PAYFLAG] IN ('G', 'O', 'P') AND p.[STATUS] = 'Y' THEN TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18, 2)) ELSE 0 END) AS [PatientPayments],
        SUM(CASE WHEN pc.[PAYFLAG] IN ('C', 'W') OR p.[DC] = 'CW' THEN TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18, 2)) ELSE 0 END) AS [Adjustments]
    FROM GEMMSCV.[files].[CLAIMSTATEMENTRUNDATES] sr
    LEFT JOIN GEMMSCV.[files].[PAYMENT] p
        ON p.[PatientID] = sr.[PatientID]
       AND p.[CHGID] = sr.[CHGID]
       AND NULLIF(p.[PAYDATE], '') <= NULLIF(sr.[RUNDATE], '')
    LEFT JOIN GEMMSCV.[files].[PAYORCODE] pc
        ON pc.[PAYORCODE] = p.[PAYORCODE]
    GROUP BY sr.[PatientID], sr.[RUNDATE]
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(sc.[PatientID], '|STMT|', COALESCE(sc.[RUNDATE], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    sc.[PatientID] AS [PatientExternalDataId],
    sc.[RUNDATE] AS [ClinicallyRelevantDttm],
    'Statement' AS [TypeCode],
    'Statement' AS [TypeName],
    0 AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    sc.[RUNDATE] AS [ExternalDataCreatedDttm],
    sc.[RUNDATE] AS [ExternalDataUpdatedDttm],
    'Active' AS [Status],
    CONCAT('Statement ', COALESCE(sc.[RUNDATE], '')) AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    sc.[RUNDATE] AS [RecordedDttm],
    sc.[PatientID] AS [AccountExternalDataId],
    'Statement run for patient account' AS [Description],
    sc.[AccountNumber] AS [AccountNumber],
    sc.[RUNDATE] AS [LastUpdatedDttm],
    sc.[RUNDATE] AS [StatementDttm],
    sc.[RUNDATE] AS [EndDttm],
    NULL AS [AssignedToExternalDataId],
    NULL AS [CreatedByExternalDataId],
    NULL AS [PaidByExternalDataId],
    NULL AS [PaidByInsuranceExternalDataId],
    NULL AS [LastUpdatedByExternalDataId],
    NULL AS [RecordedByExternalDataId],
    COALESCE(sc.[TotalCharges], 0) AS [TotalCharges],
    COALESCE(sc.[TotalCharges], 0) - COALESCE(sp.[TotalPayments], 0) AS [PatientBalance],
    NULL AS [InsuranceBalance],
    COALESCE(sp.[InsurancePayments], 0) AS [InsurancePayments],
    COALESCE(sp.[PatientPayments], 0) AS [PatientPayments],
    COALESCE(sp.[TotalPayments], 0) AS [TotalPayments],
    NULL AS [InsuranceOpeningBalance],
    NULL AS [PatientOpeningBalance],
    COALESCE(sp.[Adjustments], 0) AS [Adjustments],
    NULL AS [EncounterExternalDataId],
    NULL AS [VisitExternalDataId]
FROM statement_charges sc
LEFT JOIN statement_payments sp
    ON sp.[PatientID] = sc.[PatientID]
   AND sp.[RUNDATE] = sc.[RUNDATE]
WHERE 1 = 1
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
