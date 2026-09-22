/********************************************************************************
SCRIPT DEPENDENCIES: [etl_dbo].[RegistrationIdentifier]
ITEM TYPE:RegistrationIdentifier
NOTES: Auto-generated external table creation script.
SCALE:
********************************************************************************/
IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

	--DROP EXTERNAL TABLE etl_medical.RegistrationIdentifier
CREATE EXTERNAL TABLE etl_medical.RegistrationIdentifier
WITH (
		LOCATION = 'etl_medical/RegistrationIdentifier',
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
	CONVERT(nvarchar(51),[Code]) AS [Code],
	CONVERT(nvarchar(256),[Name]) AS [Name],
	CONVERT(nvarchar(41),[Value]) AS [Value],
	CONVERT(bit,[IsDefault]) AS [IsDefault],
	CONVERT(nvarchar(MAX),[ExtendedProperties]) AS [ExtendedProperties]
FROM etl_dbo.RegistrationIdentifier