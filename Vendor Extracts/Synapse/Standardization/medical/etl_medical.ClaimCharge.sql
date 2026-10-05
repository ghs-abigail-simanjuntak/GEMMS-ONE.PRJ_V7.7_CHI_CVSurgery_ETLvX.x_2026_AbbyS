IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

	--DROP EXTERNAL TABLE etl_medical.ClaimCharge
CREATE EXTERNAL TABLE etl_medical.ClaimCharge
WITH (
		LOCATION = 'etl_medical/ClaimCharge',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS
SELECT
	CONVERT(uniqueidentifier,[Id]) AS [Id],
	CONVERT(int,[ItemSetId]) AS [ItemSetId],
	CONVERT(varchar(51),[DataSourceCode]) AS [DataSourceCode],
	CONVERT(varchar(256),[ExternalDataId]) AS [ExternalDataId],
	CONVERT(varchar(256),[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(nvarchar(MAX),[ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(varchar(256),[ItemExternalDataId]) AS [ItemExternalDataId],
	CONVERT(varchar(256),[ItemExternalDataVersion]) AS [ItemExternalDataVersion],
	CONVERT(nvarchar(51),[BillingProviderCode]) AS [BillingProviderCode],
	CONVERT(decimal(18,2),[ChargeAmount]) AS [ChargeAmount],
	CONVERT(nvarchar(11),[CptHcpcsCode]) AS [CptHcpcsCode],
	CONVERT(nvarchar(11),[CptHcpcsModifier1]) AS [CptHcpcsModifier1],
	CONVERT(nvarchar(11),[CptHcpcsModifier2]) AS [CptHcpcsModifier2],
	CONVERT(nvarchar(11),[CptHcpcsModifier3]) AS [CptHcpcsModifier3],
	CONVERT(nvarchar(11),[CptHcpcsModifier4]) AS [CptHcpcsModifier4],
	CONVERT(datetime,[DateOfServiceFromDttm]) AS [DateOfServiceFromDttm],
	CONVERT(datetime,[DateOfServiceToDttm]) AS [DateOfServiceToDttm],
	CONVERT(nvarchar(31),[DaysOrUnits]) AS [DaysOrUnits],
	CONVERT(nvarchar(51),[DiagnosisPointer]) AS [DiagnosisPointer],
	CONVERT(nvarchar(11),[EmgIndicator]) AS [EmgIndicator],
	CONVERT(nvarchar(3),[EpsdtIndicator]) AS [EpsdtIndicator],
	CONVERT(nvarchar(3),[EpsdtIndicatorReasonCode]) AS [EpsdtIndicatorReasonCode],
	CONVERT(bit,[IdQualifier]) AS [IdQualifier],
	CONVERT(decimal(18,2),[NonCoveredCharges]) AS [NonCoveredCharges],
	CONVERT(nvarchar(51),[PlaceOfService]) AS [PlaceOfService],
	CONVERT(nvarchar(5),[RevenueCode]) AS [RevenueCode],
	CONVERT(nvarchar(MAX),[RevenueDescription]) AS [RevenueDescription],
	CONVERT(nvarchar(51),[UnlabeledChargeItems]) AS [UnlabeledChargeItems],
	CONVERT(int,[ChargeSetSequence]) AS [ChargeSetSequence],
	CONVERT(nvarchar(3),[FamilyPlanIndicator]) AS [FamilyPlanIndicator],
	CONVERT(nvarchar(251),[UnlabeledField49]) AS [UnlabeledField49],
	CONVERT(nvarchar(251),[ClaimChargeOtherInfo]) AS [ClaimChargeOtherInfo],
	CONVERT(nvarchar(4),[IdQualifierValue]) AS [IdQualifierValue],
	CONVERT(nvarchar(16),[RenderingProviderId]) AS [RenderingProviderId],
	CONVERT(nvarchar(16),[RenderingProviderIdQual]) AS [RenderingProviderIdQual],
	CONVERT(varchar(256),[ChargeExternalDataId]) AS [ChargeExternalDataId],
	CONVERT(varchar(256),[ChargeExternalDataVersion]) AS [ChargeExternalDataVersion]
FROM etl_dbo.ClaimCharge