/********************************************************************************
SCRIPT DEPENDENCIES: files.CHARGE, files.CLAIM
ITEM TYPE: ClaimCharge
VERSION:
NOTES: One row per charge line as it appears on its claim episode.
       ItemExternalDataId matches the ExternalDataId format from etl_dbo.ClaimNew.
       ChargeExternalDataId matches the ChargeExternalDataId format from etl_dbo.Transaction.
********************************************************************************/
--DROP EXTERNAL TABLE etl_dbo.ClaimCharge
CREATE EXTERNAL TABLE etl_dbo.ClaimCharge
WITH (
		LOCATION = 'etl_dbo/ClaimCharge',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
AS
SELECT
	NEWID() AS [Id],
	1 AS [ItemSetId],
	'CHIGEMMS1CV' AS [DataSourceCode],
	CONCAT(ch.[PatientID], '|CLAIMCHARGE|', COALESCE(ch.[CHGID], '')) AS [ExternalDataId],
	ch.[PatientID] AS [PatientExternalDataId],
	NULL AS [ExtendedProperties],
	CASE
		WHEN cl.[INCIDENTNO] IS NOT NULL THEN CONCAT(cl.[PatientID], '|CLAIM|', COALESCE(NULLIF(cl.[INCIDENTNO], ''), ''), '|', COALESCE(NULLIF(cl.[CLAIMID], ''), ''))
		ELSE NULL
	END AS [ItemExternalDataId],
	'1' AS [ItemExternalDataVersion],
	ch.[PROVIDER] AS [BillingProviderCode],
	TRY_CAST(NULLIF(ch.[CHGAMOUNT], '') AS decimal(18, 2)) AS [ChargeAmount],
	COALESCE(NULLIF(ch.[CPT], ''), NULLIF(ch.[CPTPRINT], '')) AS [CptHcpcsCode],
	NULLIF(ch.[MODIFIER], '') AS [CptHcpcsModifier1],
	NULL AS [CptHcpcsModifier2],
	NULL AS [CptHcpcsModifier3],
	NULL AS [CptHcpcsModifier4],
	NULLIF(ch.[XACDATE], '') AS [DateOfServiceFromDttm],
	COALESCE(NULLIF(ch.[XACDATE2], ''), NULLIF(ch.[XACDATE], '')) AS [DateOfServiceToDttm],
	NULLIF(ch.[CUNITS], '') AS [DaysOrUnits],
	NULLIF(ch.[ICD9], '') AS [DiagnosisPointer],
	NULL AS [EmgIndicator],
	NULL AS [EpsdtIndicator],
	NULL AS [EpsdtIndicatorReasonCode],
	NULL AS [IdQualifier],
	NULL AS [NonCoveredCharges],
	NULLIF(ch.[FACILITY], '') AS [PlaceOfService],
	NULL AS [RevenueCode],
	NULLIF(ch.[PROCDESC], '') AS [RevenueDescription],
	NULL AS [UnlabeledChargeItems],
	NULL AS [ChargeSetSequence],
	NULL AS [FamilyPlanIndicator],
	NULL AS [UnlabeledField49],
	NULL AS [ClaimChargeOtherInfo],
	NULL AS [IdQualifierValue],
	NULLIF(ch.[RDOC], '') AS [RenderingProviderId],
	NULL AS [RenderingProviderIdQual],
	CONCAT(ch.[PatientID], '|CHG|', COALESCE(ch.[CHGID], '')) AS [ChargeExternalDataId],
	'1' AS [ChargeExternalDataVersion]
FROM [files].[CHARGE] ch
LEFT JOIN (
	SELECT DISTINCT * FROM [files].[CLAIM]
) cl
	ON cl.[PatientID] = ch.[PatientID]
   AND cl.[INCIDENTNO] = ch.[INCIDENTNO]
WHERE 1 = 1
AND cl.patientid IS NOT NULL
