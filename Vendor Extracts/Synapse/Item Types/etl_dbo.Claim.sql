/********************************************************************************
SCRIPT DEPENDENCIES: files.CLAIM, files.CHARGE, files.CLAIMHISTORY, files.CLAIMREMITHISTORY, files.CLAIMINSURANCE, files.PATIENTACCOUNT, files.PATIENTDEMOGRAPHICS, files.GUARANTOR
ITEM TYPE: Claim
NOTES: One row per claim episode (PatientID + INCIDENTNO), sourced from CLAIM.
       CHARGE/CLAIMHISTORY/CLAIMREMITHISTORY/CLAIMINSURANCE are rolled up to that
       same grain first, so joining them cannot multiply the claim row count.
SCALE:
********************************************************************************/

-- DROP EXTERNAL TABLE etl_dbo.Claim
CREATE EXTERNAL TABLE etl_dbo.Claim
WITH (
    LOCATION = 'etl_dbo/Claim',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS
SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(cl.[PatientID], '|CLAIM|', COALESCE(NULLIF(cl.[INCIDENTNO], ''), ''), '|', COALESCE(NULLIF(cl.[CLAIMID], ''), '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    cl.[PatientID] AS [PatientExternalDataId],
    COALESCE(NULLIF(cl.[ADMDATE], ''), NULLIF(cl.[INCDATE1], ''), NULLIF(cl.[SYMPTOMDATE], ''), '1900-01-01') AS [ClinicallyRelevantDttm],
    'Claim' AS [TypeCode],
    'Billing Claim' AS [TypeName],
    0 AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULLIF(cl.[ADMDATE], '') AS [ExternalDataCreatedDttm],
    NULLIF(chs.[LastRunDate], '') AS [ExternalDataUpdatedDttm],
    COALESCE(NULLIF(cl.[PSTATUS], ''), NULLIF(cl.[BILLFLAG], ''), 'Active') AS [Status],
    CONCAT('Claim ', COALESCE(NULLIF(chg.[ChargeClaimId], ''), NULLIF(chs.[LastSubmittedClaimId], ''), cl.[INCIDENTNO])) AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    CONVERT(VARCHAR(4000),
        CONCAT(
            '{"claimTableClaimId":"', COALESCE(REPLACE(CONVERT(VARCHAR(100), cl.[CLAIMID]), '"', '\"'), ''), '"',
            ',"chargeCount":', COALESCE(CONVERT(VARCHAR(20), chg.[ChargeCount]), '0'),
            ',"chargeClaimId":"', COALESCE(REPLACE(CONVERT(VARCHAR(100), chg.[ChargeClaimId]), '"', '\"'), ''), '"',
            ',"claimHistoryRunCount":', COALESCE(CONVERT(VARCHAR(20), chs.[RunCount]), '0'),
            ',"claimHistoryLastRunDate":"', COALESCE(CONVERT(VARCHAR(23), TRY_CAST(chs.[LastRunDate] AS datetime2), 121), ''), '"',
            ',"claimHistoryLastSubmittedClaimId":"', COALESCE(REPLACE(CONVERT(VARCHAR(100), chs.[LastSubmittedClaimId]), '"', '\"'), ''), '"',
            ',"claimHistoryProvider":"', COALESCE(REPLACE(CONVERT(VARCHAR(100), chs.[LastProvider]), '"', '\"'), ''), '"',
            ',"remitCount":', COALESCE(CONVERT(VARCHAR(20), crh.[RemitCount]), '0'),
            ',"payorClaimId":"', COALESCE(REPLACE(CONVERT(VARCHAR(100), crh.[PayorClaimId]), '"', '\"'), ''), '"',
            ',"insuranceCount":', COALESCE(CONVERT(VARCHAR(20), cis.[InsuranceCount]), '0'),
            ',"primaryInsuranceCode":"', COALESCE(REPLACE(CONVERT(VARCHAR(100), cis.[PrimaryInsuranceCode]), '"', '\"'), ''), '"',
            '}'
        )
    ) AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    NULLIF(cl.[ADMDATE], '') AS [RecordedDttm],
    CONCAT('account_',pa.[PatientID]) AS [AccountExternalDataId],
    COALESCE(NULLIF(chg.[ChargeClaimId], ''), NULLIF(chs.[LastSubmittedClaimId], '')) AS [ClaimNumber],
    cl.[FACCODE] AS [Location],
    COALESCE(NULLIF(cl.[ADMDATE], ''), NULLIF(cl.[INCDATE1], '')) AS [ClaimDttm],
    NULLIF(chs.[LastRunDate], '') AS [LastUpdatedDttm],
    NULL AS [ServiceProviderExternalDataId],
    NULL AS [PaidByInsuranceExternalDataId],
    NULL AS [RecordedByExternalDataId],
    NULL AS [LastUpdatedByExternalDataId],
    NULL AS [ClaimProviderExternalDataId],
    crh.[TotalWriteOff] AS [TotalClaimWriteOffAmount],
    crh.[TotalPaid] AS [TotalClaimInsuranceAmount],
    NULL AS [EncounterExternalDataId],
    NULL AS [VisitExternalDataId],
    cl.[REMARK] AS [AdditionalClaimInformation],
    NULLIF(cl.[ADMDATE], '') AS [AdmissionDttm],
    NULL AS [AdmissionHour],
    NULL AS [AdmissionSource],
    cl.[ADMTYPE] AS [AdmissionType],
    -- CASE
    --     WHEN NULLIF(LTRIM(RTRIM(cl.[ASSIGN])), '') IN ('Y', '1', 'Yes', 'YES', 'True', 'TRUE') THEN 1
    --     WHEN NULLIF(LTRIM(RTRIM(cl.[ASSIGN])), '') IN ('N', '0', 'No', 'NO', 'False', 'FALSE') THEN 0
    --     ELSE NULL
    -- END AS [AlternateBenefitIndicator],
    NULL AS [AlternateBenefitIndicator],
    NULL AS [AttendingPhysicianDesc],
    NULL AS [BillingProviderAtypical],
    NULL AS [BillingProviderIdTypical],
    NULL AS [BillingProviderInfoPersonFirstName],
    NULL AS [BillingProviderInfoPersonMiddleName],
    NULL AS [BillingProviderInfoPersonLastName],
    NULL AS [BillingProviderInfoPersonFullName],
    NULL AS [BillingProviderInfoAddressLine1],
    NULL AS [BillingProviderInfoAddressLine2],
    NULL AS [BillingProviderInfoAddressPostalCode],
    NULL AS [BillingProviderInfoAddressCity],
    NULL AS [BillingProviderInfoAddressCountryCode],
    NULL AS [BillingProviderInfoAddressStateCode],
    NULL AS [BillingProviderInfoAddressFull],
    NULL AS [BillingProviderInfoPhoneType],
    NULL AS [BillingProviderInfoPhoneNumber],
    NULL AS [BillingProviderInfoPhoneFull],
    NULL AS [BillingProviderNpi],
    NULL AS [BillingProviderOtherIdentifierA],
    NULL AS [BillingProviderOtherIdentifierB],
    NULL AS [BillingProviderOtherIdentifierC],
    NULL AS [BillSubmissionSignatureDttm],
    NULL AS [BillSubmissionSignatureText],
    cl.[BILLFLAG] AS [ClaimCodes],
    NULL AS [CoInsuranceDays],
    -- CASE
    --     WHEN NULLIF(LTRIM(RTRIM(cl.[ACCIDENT])), '') IN ('Y', '1', 'Yes', 'YES', 'True', 'TRUE') THEN 1
    --     WHEN NULLIF(LTRIM(RTRIM(cl.[ACCIDENT])), '') IN ('N', '0', 'No', 'NO', 'False', 'FALSE') THEN 0
    --     ELSE NULL
    -- END 
    NULL AS [ConditionRelatedToAutoAccidentIndicator],
    -- cl.[ACCIDENTSTATE] AS [ConditionRelatedToAutoAccidentStateIndicator],
    NULL AS [ConditionRelatedToAutoAccidentStateIndicator],
    NULL AS [ConditionRelatedToEmploymentIndicator],
    NULL AS [ConditionRelatedToOtherAccidentIndicator],
    NULL AS [CoveredDays],
    NULLIF(cl.[SYMPTOMDATE], '') AS [DttmOfCurrentIllness],
    cl.[DIAG1] AS [DiagnosisCode1],
    cl.[DIAG2] AS [DiagnosisCode2],
    cl.[DIAG3] AS [DiagnosisCode3],
    cl.[DIAG4] AS [DiagnosisCode4],
    NULL AS [DischargeHour],
    NULL AS [ECode],
    NULL AS [FederalIdTaxNumber],
    NULLIF(cl.[INCDATE1], '') AS [FirstDttmOfCurrentIllness],
    NULL AS [IcnA],
    NULL AS [IcnB],
    NULL AS [IcnC],
    NULLIF(cl.[HOSPDATE1], '') AS [IllnessHospitalizationFromDttm],
    NULLIF(cl.[HOSPDATE2], '') AS [IllnessHospitalizationToDttm],
    NULL AS [InsuredAddressLine1],
    NULL AS [InsuredAddressLine2],
    NULL AS [InsuredAddressPostalCode],
    NULL AS [InsuredAddressCity],
    NULL AS [InsuredAddressCountryCode],
    NULL AS [InsuredAddressStateCode],
    NULL AS [InsuredAddressFull],
    NULL AS [InsuredMemberAuthorizedSignatureText],
    NULL AS [InsuredMemberAuthorizedSignatureIsOnFile],
    NULL AS [LifetimeReserveDays],
    NULL AS [MedicaidResubmissionCode],
    NULL AS [MedicaidResubmissionReferenceNumber],
    cl.[REMARK] AS [MiscComment],
    NULL AS [NonCoveredDays],
    NULL AS [NonLabeledField],
    NULL AS [OtherDiagnosisCode],
    crh.[PayorClaimId] AS [OtherClaimId],
    NULL AS [OtherClaimDttm],
    NULL AS [OtherDxCodeA],
    NULL AS [OtherDxCodeB],
    NULL AS [OtherDxCodeC],
    NULL AS [OtherDxCodeD],
    NULL AS [OtherDxCodeE],
    NULL AS [OtherDxCodeF],
    NULL AS [OtherDxCodeG],
    NULL AS [OtherDxCodeH],
    NULL AS [OtherDxCodeI],
    NULL AS [OtherDxCodeJ],
    NULL AS [OtherDxCodeK],
    NULL AS [OtherDxCodeL],
    cl.[DOCTORADM] AS [OtherPhysicianIdA],
    cl.[DOCTOROP] AS [OtherPhysicianIdB],
    cl.[PROC2] AS [OtherProcedureCode1],
    NULL AS [OtherProcedureCode2],
    NULL AS [OtherProcedureCode3],
    NULL AS [OtherProcedureCode4],
    NULL AS [OtherProcedureCode5],
    NULL AS [OtherProcedureDttm1],
    NULL AS [OtherProcedureDttm2],
    NULL AS [OtherProcedureDttm3],
    NULL AS [OtherProcedureDttm4],
    NULL AS [OtherProcedureDttm5],
    NULL AS [OutsideLabCharges],
    NULL AS [OutsideLabIndicator],
    pa.[ACCOUNT] AS [PatientAccountNumber],
    pd.[ADDRESS] AS [PatientAddressLine1],
    NULL AS [PatientAddressLine2],
    pd.[ZIP] AS [PatientAddressPostalCode],
    pd.[CITY] AS [PatientAddressCity],
    'US' AS [PatientAddressCountryCode],
    pd.[STATE] AS [PatientAddressStateCode],
    NULLIF(CONCAT(pd.[ADDRESS], CASE WHEN NULLIF(pd.[CITY], '') IS NOT NULL THEN ', ' + pd.[CITY] ELSE '' END, CASE WHEN NULLIF(pd.[STATE], '') IS NOT NULL THEN ', ' + pd.[STATE] ELSE '' END, CASE WHEN NULLIF(pd.[ZIP], '') IS NOT NULL THEN ' ' + pd.[ZIP] ELSE '' END), '') AS [PatientAddressFull],
    NULLIF(pa.[DOB], '') AS [PatientDob],
    pd.[EMPLOYED] AS [PatientEmploymentStatus],
    pa.[SEX] AS [PatientGender],
    pd.[MARITAL] AS [PatientMaritalStatus],
    pa.[MRN] AS [PatientMedicalRecordNumber],
    pa.[PFNAME] AS [PatientPersonFirstName],
    pa.[PMNAME] AS [PatientPersonMiddleName],
    pa.[PLNAME] AS [PatientPersonLastName],
    NULLIF(LTRIM(RTRIM(CONCAT(COALESCE(pa.[PFNAME], ''), CASE WHEN NULLIF(pa.[PMNAME], '') IS NOT NULL THEN ' ' + pa.[PMNAME] ELSE '' END, CASE WHEN NULLIF(pa.[PLNAME], '') IS NOT NULL THEN ' ' + pa.[PLNAME] ELSE '' END))), '') AS [PatientPersonFullName],
    NULL AS [PatientPhoneFull],
    NULL AS [PatientAuthorizedSignatureText],
    NULL AS [PatientAuthorizedSignatureIsOnFile],
    NULL AS [PatientAuthorizedVirtualSignatureDttm],
    NULL AS [PatientAuthorizedVirtualSignatureText],
    pd.[PTYPE] AS [PatientStatus],
    cl.[DIAG1] AS [PrincipalDxCode],
    cl.[PROC1] AS [PrincipalProcedureCode],
    NULL AS [PrincipalProcedureDttm],
    NULL AS [ProcedureCodingMethod],
    NULL AS [ProviderAuthorizedVirtualSignatureDttm],
    NULL AS [ProviderRepresentativeSignatureText],
    NULL AS [ProviderRepresentativeSignatureIsOnFile],
    NULL AS [ReferringProviderPersonFirstName],
    NULL AS [ReferringProviderPersonMiddleName],
    NULL AS [ReferringProviderPersonLastName],
    NULL AS [ReferringProviderPersonFullName],
    cl.[REFERRAL] AS [ReferringProviderIdNumber],
    NULL AS [ReferringProviderNpiNumber],
    cl.[REMARK] AS [RemarksA],
    NULL AS [RemarksB],
    NULL AS [RemarksC],
    NULL AS [RemarksD],
    NULL AS [ReservedForLocalUse],
    g.[GFNAME] AS [ResponsiblePartyInfoPersonFirstName],
    g.[GMNAME] AS [ResponsiblePartyInfoPersonMiddleName],
    g.[GLNAME] AS [ResponsiblePartyInfoPersonLastName],
    NULL AS [ResponsiblePartyInfoPersonTitle],
    NULLIF(LTRIM(RTRIM(CONCAT(COALESCE(g.[GFNAME], ''), CASE WHEN NULLIF(g.[GMNAME], '') IS NOT NULL THEN ' ' + g.[GMNAME] ELSE '' END, CASE WHEN NULLIF(g.[GLNAME], '') IS NOT NULL THEN ' ' + g.[GLNAME] ELSE '' END))), '') AS [ResponsiblePartyInfoPersonFullName],
    g.[ADDRESS] AS [ResponsiblePartyInfoAddressLine1],
    NULL AS [ResponsiblePartyInfoAddressLine1B],
    NULL AS [ResponsiblePartyInfoAddressLine2],
    g.[ZIP] AS [ResponsiblePartyInfoAddressPostalCode],
    g.[CITY] AS [ResponsiblePartyInfoAddressCity],
    'US' AS [ResponsiblePartyInfoAddressCountryCode],
    g.[STATE] AS [ResponsiblePartyInfoAddressStateCode],
    NULLIF(CONCAT(g.[ADDRESS], CASE WHEN NULLIF(g.[CITY], '') IS NOT NULL THEN ', ' + g.[CITY] ELSE '' END, CASE WHEN NULLIF(g.[STATE], '') IS NOT NULL THEN ', ' + g.[STATE] ELSE '' END, CASE WHEN NULLIF(g.[ZIP], '') IS NOT NULL THEN ' ' + g.[ZIP] ELSE '' END), '') AS [ResponsiblePartyInfoAddressFull],
    NULL AS [ServiceFacilityInfoAddressLine1],
    NULL AS [ServiceFacilityInfoAddressLine2],
    NULL AS [ServiceFacilityInfoAddressPostalCode],
    NULL AS [ServiceFacilityInfoAddressCity],
    NULL AS [ServiceFacilityInfoAddressCountryCode],
    NULL AS [ServiceFacilityInfoAddressStateCode],
    NULL AS [ServiceFacilityInfoAddressFull],
    NULL AS [ServiceFacilityInfoPhoneFull],
    NULL AS [ServiceFacilityNpi],
    NULL AS [ServiceFacilityAtypical],
    cl.[FACCODE] AS [ServiceFacilityName],
    NULL AS [StatementCoversPeriodFromDttm],
    NULL AS [StatementCoversPeriodToDttm],
    chg.[TotalClaimCharges] AS [TotalClaimCharges],
    NULL AS [TypeOfBill],
    NULL AS [Ub92UnlabeledField1],
    NULL AS [UnableToWorkFromDttm],
    NULL AS [UnableToWorkToDttm],
    NULL AS [ValueCode39A],
    NULL AS [ValueCode39B],
    NULL AS [ValueCode39C],
    NULL AS [ValueCode39D],
    NULL AS [ValueCode40A],
    NULL AS [ValueCode40B],
    NULL AS [ValueCode40C],
    NULL AS [ValueCode40D],
    NULL AS [ValueCode41A],
    NULL AS [ValueCode41B],
    NULL AS [ValueCode41C],
    NULL AS [ValueCode41D],
    NULL AS [ValueCodeAmt39A],
    NULL AS [ValueCodeAmt39B],
    NULL AS [ValueCodeAmt39C],
    NULL AS [ValueCodeAmt39D],
    NULL AS [ValueCodeAmt40A],
    NULL AS [ValueCodeAmt40B],
    NULL AS [ValueCodeAmt40C],
    NULL AS [ValueCodeAmt40D],
    NULL AS [ValueCodeAmt41A],
    NULL AS [ValueCodeAmt41B],
    NULL AS [ValueCodeAmt41C],
    NULL AS [ValueCodeAmt41D],
    NULL AS [VoucherNumber],
    NULL AS [PpsCode],
    NULL AS [Stat],
    NULL AS [QualDateOfCurrentIllness],
    NULL AS [QualOtherDate],
    NULL AS [QualReferringProv],
    NULL AS [ChargePageThresholdContinueText],
    NULL AS [DiagnosisCode5],
    NULL AS [DiagnosisCode6],
    NULL AS [DiagnosisCode7],
    NULL AS [DiagnosisCode8],
    NULL AS [DiagnosisCode9],
    NULL AS [DiagnosisCode10],
    NULL AS [DiagnosisCode11],
    NULL AS [DiagnosisCode12],
    NULL AS [FederalIdTaxNumberType],
    NULL AS [IcdTypeIndicator],
    NULL AS [PatientStatusIndicator],
    NULL AS [RenderingProviderName],
    NULL AS [ReservedForNucc2012],
    NULL AS [AttendingPhysicianFirstName],
    NULL AS [AttendingPhysicianId],
    NULL AS [AttendingPhysicianIdQual],
    NULL AS [AttendingPhysicianLastName],
    NULL AS [AttendingPhysicianNpi],
    NULL AS [OccurrenceCode31B],
    NULL AS [OccurrenceCode32B],
    NULL AS [OccurrenceDttm31B],
    NULL AS [OccurrenceDttm32B],
    NULL AS [OccurrenceSpanCode36B],
    NULL AS [OccurrenceSpanFromDttm36B],
    NULL AS [OccurrenceSpanToDttm36B],
    NULL AS [OtherDxCodeM],
    NULL AS [OtherDxCodeN],
    NULL AS [OtherDxCodeO],
    NULL AS [OtherDxCodeP],
    NULL AS [OtherDxCodeQ],
    NULL AS [OtherPhysicianIdA57A],
    NULL AS [OtherPhysicianIdB57B],
    NULL AS [OtherPhysicianIdC57C],
    NULL AS [OtherPhysicianIdQualA],
    NULL AS [OtherPhysicianIdQualB],
    NULL AS [OtherPhysicianFirstNameA],
    NULL AS [OtherPhysicianFirstNameB],
    NULL AS [OtherPhysicianLastNameA],
    NULL AS [OtherPhysicianLastNameB],
    NULL AS [OtherPhysicianNpia],
    NULL AS [OtherPhysicianNpib],
    NULL AS [OtherPhysicianNpiQualA],
    NULL AS [OtherPhysicianNpiQualB],
    NULL AS [PatientNameId],
    NULL AS [PatientRfvCodeB],
    NULL AS [PatientRfvCodeC],
    NULL AS [TotalNonCoveredCharges],
    NULL AS [UnlabeledField07],
    NULL AS [UnlabeledField30A],
    NULL AS [UnlabeledField30B],
    NULL AS [UnlabeledField37A],
    NULL AS [UnlabeledField37B],
    NULL AS [UnlabeledField68A],
    NULL AS [UnlabeledField68B],
    NULL AS [UnlabeledField73],
    NULL AS [UnlabeledField75],
    NULL AS [EciB],
    NULL AS [EciC],
    NULL AS [CodeCode81A],
    NULL AS [CodeCode81B],
    NULL AS [CodeCode81C],
    NULL AS [CodeCode81D],
    NULL AS [CodeQual81A],
    NULL AS [CodeQual81B],
    NULL AS [CodeQual81C],
    NULL AS [CodeQual81D],
    NULL AS [CodeValue81A],
    NULL AS [CodeValue81B],
    NULL AS [CodeValue81C],
    NULL AS [CodeValue81D],
    NULL AS [OperatingPhysicianFirstName],
    NULL AS [OperatingPhysicianId],
    NULL AS [OperatingPhysicianIdQual],
    NULL AS [OperatingPhysicianLastName],
    NULL AS [OperatingPhysicianNpi],
    NULL AS [AdmitDiagnosisCode],
    NULL AS [ConditionCode18],
    NULL AS [ConditionCode19],
    NULL AS [ConditionCode20],
    NULL AS [ConditionCode21],
    NULL AS [ConditionCode22],
    NULL AS [ConditionCode23],
    NULL AS [ConditionCode24],
    NULL AS [ConditionCode25],
    NULL AS [ConditionCode26],
    NULL AS [ConditionCode27],
    NULL AS [ConditionCode28],
    NULL AS [EciA],
    NULL AS [OccurrenceCode31A],
    NULL AS [OccurrenceCode32A],
    NULL AS [OccurrenceCode33A],
    NULL AS [OccurrenceCode33B],
    NULL AS [OccurrenceCode34A],
    NULL AS [OccurrenceCode34B],
    NULL AS [OccurrenceDttm31A],
    NULL AS [OccurrenceDttm32A],
    NULL AS [OccurrenceDttm33A],
    NULL AS [OccurrenceDttm33B],
    NULL AS [OccurrenceDttm34A],
    NULL AS [OccurrenceDttm34B],
    NULL AS [OccurrenceSpanCode35A],
    NULL AS [OccurrenceSpanCode35B],
    NULL AS [OccurrenceSpanCode36A],
    NULL AS [OccurrenceSpanFromDttm35A],
    NULL AS [OccurrenceSpanToDttm35A],
    NULL AS [OccurrenceSpanFromDttm35B],
    NULL AS [OccurrenceSpanToDttm35B],
    NULL AS [OccurrenceSpanFromDttm36A],
    NULL AS [OccurrenceSpanToDttm36A],
    NULL AS [OtherClaimIdQual],
    NULL AS [PatientRfvCodeA],
    NULL AS [RefProvOtherIdQual],
    NULL AS [ResNucc1NubcRemarksA],
    NULL AS [ResNucc2NubcRemarksB],
    NULL AS [ResNucc3NubcRemarksC],
    NULL AS [ResNucc4NubcRemarksD]
-- SELECT TOP(100)* -- 40591
FROM (
    SELECT DISTINCT * FROM [files].[CLAIM]
) cl
INNER JOIN [files].[PATIENTACCOUNT] pa
    ON pa.[PatientID] = cl.[PatientID]
LEFT JOIN [files].[PATIENTDEMOGRAPHICS] pd
    ON pd.[PatientID] = cl.[PatientID]
LEFT JOIN [files].[GUARANTOR] g
    ON g.[PatientID] = cl.[PatientID]
LEFT JOIN (
    -- Charge totals per claim episode
    SELECT
        ch.[PatientID],
        ch.[INCIDENTNO],
        COUNT(*) AS [ChargeCount],
        SUM(TRY_CAST(NULLIF(ch.[CHGAMOUNT], '') AS decimal(18, 2))) AS [TotalClaimCharges],
        MAX(NULLIF(ch.[CLAIMID], '')) AS [ChargeClaimId]
    FROM (
        SELECT DISTINCT * FROM [files].[CHARGE]
    ) ch
    GROUP BY
        ch.[PatientID],
        ch.[INCIDENTNO]
) chg
    ON chg.[PatientID] = cl.[PatientID]
   AND chg.[INCIDENTNO] = cl.[INCIDENTNO]
LEFT JOIN (
    -- Claim submission run history per claim episode
    SELECT
        chs.[PatientID],
        chs.[INCIDENTNO],
        COUNT(*) AS [RunCount],
        MAX(NULLIF(chs.[RUNDATE], '')) AS [LastRunDate],
        MAX(NULLIF(CONVERT(VARCHAR(100), chs.[CLAIMID]), '')) AS [LastSubmittedClaimId],
        MAX(NULLIF(chs.[PROVID], '')) AS [LastProvider]
    FROM (
        SELECT DISTINCT * FROM [files].[CLAIMHISTORY]
    ) chs
    GROUP BY
        chs.[PatientID],
        chs.[INCIDENTNO]
) chs
    ON chs.[PatientID] = cl.[PatientID]
   AND chs.[INCIDENTNO] = cl.[INCIDENTNO]
LEFT JOIN (
    -- Remit/payment totals per claim episode, bridged through CHARGE (CLAIMREMITHISTORY has no INCIDENTNO)
    SELECT
        ch.[PatientID],
        ch.[INCIDENTNO],
        COUNT(*) AS [RemitCount],
        SUM(TRY_CAST(NULLIF(crh.[PAID], '') AS decimal(18, 2))) AS [TotalPaid],
        SUM(TRY_CAST(NULLIF(crh.[ALLOWED], '') AS decimal(18, 2))) AS [TotalAllowed],
        SUM(
            COALESCE(TRY_CAST(NULLIF(crh.[REDUCTION1], '') AS decimal(18, 2)), 0) +
            COALESCE(TRY_CAST(NULLIF(crh.[REDUCTION2], '') AS decimal(18, 2)), 0) +
            COALESCE(TRY_CAST(NULLIF(crh.[REDUCTION3], '') AS decimal(18, 2)), 0)
        ) AS [TotalWriteOff],
        MAX(NULLIF(crh.[PAYORCLAIMID], '')) AS [PayorClaimId]
    FROM (
        SELECT DISTINCT * FROM [files].[CLAIMREMITHISTORY]
    ) crh
    INNER JOIN (
        SELECT DISTINCT * FROM [files].[CHARGE]
    ) ch
        ON ch.[PatientID] = crh.[PatientID]
       AND ch.[CHGID] = crh.[CHGID]
    GROUP BY
        ch.[PatientID],
        ch.[INCIDENTNO]
) crh
    ON crh.[PatientID] = cl.[PatientID]
   AND crh.[INCIDENTNO] = cl.[INCIDENTNO]
LEFT JOIN (
    -- Insurance coverage per claim episode
    SELECT
        ci.[PatientID],
        ci.[INCIDENTNO],
        COUNT(*) AS [InsuranceCount],
        MIN(NULLIF(ci.[INSCODE], '')) AS [PrimaryInsuranceCode]
    FROM (
        SELECT DISTINCT * FROM [files].[CLAIMINSURANCE]
    ) ci
    GROUP BY
        ci.[PatientID],
        ci.[INCIDENTNO]
) cis
    ON cis.[PatientID] = cl.[PatientID]
   AND cis.[INCIDENTNO] = cl.[INCIDENTNO]
WHERE 1 = 1
--Functional

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
