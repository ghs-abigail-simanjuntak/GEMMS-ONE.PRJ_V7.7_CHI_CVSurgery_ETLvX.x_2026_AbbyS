/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.CHARGE
ITEM TYPE: Charge
NOTES: Direct charge-line reconstruction from CHARGE, linked to Account by PatientID.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Charge
CREATE EXTERNAL TABLE etl_dbo.Charge
WITH (
    LOCATION = 'etl_dbo/Charge',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(ch.[PatientID], '|CHG|', COALESCE(ch.[CHGID], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    ch.[PatientID] AS [PatientExternalDataId],
    COALESCE(NULLIF(ch.[XACDATE], ''), NULLIF(ch.[BILLDATE], '')) AS [ClinicallyRelevantDttm],
    COALESCE(NULLIF(ch.[CPT], ''), NULLIF(ch.[CPTPRINT], ''), NULLIF(ch.[FEETYPE], ''), 'Charge') AS [TypeCode],
    COALESCE(NULLIF(ch.[PROCDESC], ''), NULLIF(ch.[CPTPRINT], ''), NULLIF(ch.[CPT], ''), 'Charge') AS [TypeName],
    CASE WHEN ch.[STATUS] = 'N' THEN 1 ELSE 0 END AS [IsInvalidated],
    CASE WHEN ch.[STATUS] = 'N' THEN COALESCE(NULLIF(ch.[DENYDATE], ''), NULLIF(ch.[BILLDATE2], '')) ELSE NULL END AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULLIF(ch.[ENTRYDATE], '') AS [ExternalDataCreatedDttm],
    NULLIF(ch.[BILLDATE2], '') AS [ExternalDataUpdatedDttm],
    CASE
        WHEN ch.[STATUS] = 'Y' THEN 'Active'
        WHEN ch.[STATUS] = 'N' THEN 'Deleted'
        ELSE ch.[STATUS]
    END AS [Status],
    COALESCE(NULLIF(ch.[PROCDESC], ''), NULLIF(ch.[CPTPRINT], ''), NULLIF(ch.[CPT], ''), 'Charge') AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULLIF(ch.[XACDATE], '') AS [ServiceDttm],
    NULLIF(ch.[ENTRYDATE], '') AS [RecordedDttm],
    ch.[PatientID] AS [AccountExternalDataId],
    ch.[PROCDESC] AS [Description],
    ch.[CHGID] AS [ChargeNumber],
    NULLIF(ch.[BILLDATE], '') AS [BillDttm],
    NULLIF(ch.[BILLDATE2], '') AS [LastUpdatedDttm],
    NULLIF(ch.[ENTRYDATE], '') AS [EnteredDttm],
    TRY_CAST(NULLIF(ch.[CHGAMOUNT], '') AS decimal(18, 2)) AS [Amount],
    NULLIF(ch.[RDOC], '') AS [RenderingPersonExternalDataId],
    NULLIF(ch.[PROVIDER], '') AS [BillingProviderExternalDataId],
    NULLIF(ch.[USERCODE], '') AS [EnteredByExternalDataId],
    NULLIF(ch.[PROVIDER], '') AS [PerformedByProviderExternalDataId],
    NULLIF(ch.[USERCODE], '') AS [LastUpdatedByExternalDataId],
    NULL AS [EncounterExternalDataId],
    NULL AS [VisitExternalDataId],
    NULL AS [FinancialClassExternalDataId],
    NULL AS [ReferringProviderPersonExternalDataId],
    TRY_CAST(NULLIF(ch.[CUNITS], '') AS decimal(18, 2)) AS [DaysOrUnits],
    ch.[MODIFIER] AS [ChargeModifiers],
    ch.[ICD9] AS [AssociatedDx],
    ch.[FACILITY] AS [PlaceOfService],
    NULL AS [RevenueCode],
    ch.[CPT] AS [Cpt],
    ch.[CPTPRINT] AS [Hcpcs]
FROM GEMMSCV.[files].[CHARGE] ch
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = ch.[PatientID]
WHERE 1 = 1
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
