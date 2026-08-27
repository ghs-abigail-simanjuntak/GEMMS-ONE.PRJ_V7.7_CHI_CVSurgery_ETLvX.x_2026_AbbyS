/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.PATIENTDEMOGRAPHICS, GEMMSCV.files.GUARANTOR, GEMMSCV.files.INSURANCE, GEMMSCV.files.CHARGE, GEMMSCV.files.PAYMENT, GEMMSCV.files.CLAIMSTATEMENTRUNDATES
ITEM TYPE: Account
NOTES: Parent financial account item keyed by PatientID so child billing domains can link through AccountExternalDataId.
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
WITH charge_summary AS (
    SELECT
        ch.[PatientID],
        SUM(TRY_CAST(NULLIF(ch.[CHGAMOUNT], '') AS decimal(18, 2))) AS [TotalCharges],
        MAX(NULLIF(ch.[ENTRYDATE], '')) AS [LastChargeEntryDttm],
        MAX(NULLIF(ch.[BILLDATE], '')) AS [LastBillDttm]
    FROM GEMMSCV.[files].[CHARGE] ch
    GROUP BY ch.[PatientID]
),
payment_summary AS (
    SELECT
        p.[PatientID],
        SUM(CASE WHEN p.[STATUS] = 'Y' THEN TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18, 2)) ELSE 0 END) AS [TotalPayments],
        MAX(CASE WHEN p.[STATUS] = 'Y' THEN NULLIF(p.[PAYDATE], '') END) AS [LastTransactionDttm],
        MAX(NULLIF(p.[ENTRYDATE], '')) AS [LastUpdatedDttm]
    FROM GEMMSCV.[files].[PAYMENT] p
    GROUP BY p.[PatientID]
),
last_payment AS (
    SELECT
        p.[PatientID],
        TRY_CAST(NULLIF(p.[XACAMOUNT], '') AS decimal(18, 2)) AS [LastTransactionAmount],
        ROW_NUMBER() OVER (
            PARTITION BY p.[PatientID]
            ORDER BY NULLIF(p.[PAYDATE], '') DESC, NULLIF(p.[ENTRYDATE], '') DESC, NULLIF(p.[PAYID], '') DESC
        ) AS [rn]
    FROM GEMMSCV.[files].[PAYMENT] p
    WHERE p.[STATUS] = 'Y'
),
statement_totals AS (
    SELECT
        sr.[PatientID],
        sr.[RUNDATE],
        SUM(TRY_CAST(NULLIF(ch.[CHGAMOUNT], '') AS decimal(18, 2))) AS [StatementAmount],
        ROW_NUMBER() OVER (
            PARTITION BY sr.[PatientID]
            ORDER BY NULLIF(sr.[RUNDATE], '') DESC
        ) AS [rn]
    FROM GEMMSCV.[files].[CLAIMSTATEMENTRUNDATES] sr
    LEFT JOIN GEMMSCV.[files].[CHARGE] ch
        ON ch.[PatientID] = sr.[PatientID]
       AND ch.[CHGID] = sr.[CHGID]
    GROUP BY sr.[PatientID], sr.[RUNDATE]
),
insurance_summary AS (
    SELECT
        ins.[PatientID],
        STRING_AGG(
            CONCAT(
                COALESCE(ins.[INUM], ''),
                ':',
                COALESCE(ins.[INSCODE], ''),
                CASE WHEN NULLIF(ins.[INSPLAN], '') IS NOT NULL THEN ':' + ins.[INSPLAN] ELSE '' END
            ),
            '|'
        ) AS [InsuranceSummary]
    FROM GEMMSCV.[files].[INSURANCE] ins
    GROUP BY ins.[PatientID]
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    pa.[PatientID] AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    pa.[PatientID] AS [PatientExternalDataId],
    COALESCE(st.[RUNDATE], ps.[LastTransactionDttm], pd.[LASTVISIT]) AS [ClinicallyRelevantDttm],
    COALESCE(NULLIF(pd.[PTYPE], ''), NULLIF(pd.[FEETYPE], ''), 'PatientAccount') AS [TypeCode],
    'Patient Account' AS [TypeName],
    0 AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULL AS [ExternalDataCreatedDttm],
    ps.[LastUpdatedDttm] AS [ExternalDataUpdatedDttm],
    CASE
        WHEN NULLIF(LTRIM(RTRIM(pd.[DECEASED])), '') IS NOT NULL AND LTRIM(RTRIM(pd.[DECEASED])) NOT IN ('0', 'N', 'No') THEN 'Deceased'
        ELSE 'Active'
    END AS [Status],
    CONCAT('Account ', COALESCE(pa.[ACCOUNT], pa.[PatientID])) AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    pd.[LASTVISIT] AS [RecordedDttm],
    'Patient' AS [WellKnownAccountType],
    COALESCE(NULLIF(pd.[PTYPE], ''), NULLIF(pd.[FEETYPE], '')) AS [Category],
    pa.[ACCOUNT] AS [ReferenceId],
    CONCAT('Financial account for patient ', COALESCE(pa.[ACCOUNT], pa.[PatientID])) AS [Description],
    NULL AS [CreatedByExternalDataId],
    NULL AS [LastUpdatedByExternalDataId],
    NULL AS [CreatedDttm],
    NULL AS [HoldDttm],
    st.[RUNDATE] AS [LastStatementDttm],
    ps.[LastUpdatedDttm] AS [LastUpdatedDttm],
    ps.[LastTransactionDttm] AS [LastTransactionDttm],
    st.[StatementAmount] AS [LastStatementAmount],
    NULL AS [ThirtyDayBalanceInterval],
    NULL AS [SixtyDayBalanceInterval],
    NULL AS [NinetyDayBalanceInterval],
    COALESCE(cs.[TotalCharges], 0) - COALESCE(ps.[TotalPayments], 0) AS [CurrentBalance],
    lp.[LastTransactionAmount] AS [LastTransactionAmount]
FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
    ON pd.[PatientID] = pa.[PatientID]
LEFT JOIN GEMMSCV.[files].[GUARANTOR] g
    ON g.[PatientID] = pa.[PatientID]
LEFT JOIN charge_summary cs
    ON cs.[PatientID] = pa.[PatientID]
LEFT JOIN payment_summary ps
    ON ps.[PatientID] = pa.[PatientID]
LEFT JOIN last_payment lp
    ON lp.[PatientID] = pa.[PatientID]
   AND lp.[rn] = 1
LEFT JOIN statement_totals st
    ON st.[PatientID] = pa.[PatientID]
   AND st.[rn] = 1
LEFT JOIN insurance_summary ins
    ON ins.[PatientID] = pa.[PatientID]
WHERE 1 = 1
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)