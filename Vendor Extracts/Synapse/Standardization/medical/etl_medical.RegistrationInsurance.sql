/********************************************************************************
SCRIPT DEPENDENCIES: [etl_dbo].[RegistrationInsurance]
ITEM TYPE:RegistrationInsurance
NOTES: Auto-generated external table creation script.
SCALE:
********************************************************************************/
IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

	--DROP EXTERNAL TABLE etl_medical.RegistrationInsurance
CREATE EXTERNAL TABLE etl_medical.RegistrationInsurance
WITH (
		LOCATION = 'etl_medical/RegistrationInsurance',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS
SELECT
	CONVERT(uniqueidentifier,[Id]) AS [Id],
	CONVERT(int,[ItemSetId]) AS [ItemSetId],
	CONVERT(varchar(51),[DataSourceCode]) AS [DataSourceCode],
	CONVERT(varchar(256),[ExternalDataId]) AS [ExternalDataId],
	CONVERT(varchar(256),[ItemExternalDataId]) AS [ItemExternalDataId],
	CONVERT(varchar(256),[ItemExternalDataVersion]) AS [ItemExternalDataVersion],
	CONVERT(varchar(256),[InsuranceExternalDataId]) AS [InsuranceExternalDataId],
	CONVERT(nvarchar(51),[Priority]) AS [Priority],
	CONVERT(nvarchar(MAX),[ExtendedProperties]) AS [ExtendedProperties]
FROM etl_dbo.RegistrationInsurance