/********************************************************************************
SCRIPT DEPENDENCIES: [etl_dbo].[RegistrationAddress]
ITEM TYPE:RegistrationAddress
NOTES: Auto-generated external table creation script.
SCALE:
********************************************************************************/
IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

	--DROP EXTERNAL TABLE etl_medical.RegistrationAddress
CREATE EXTERNAL TABLE etl_medical.RegistrationAddress
WITH (
		LOCATION = 'etl_medical/RegistrationAddress',
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
	CONVERT(nvarchar(101),[AddressLine1]) AS [AddressLine1],
	CONVERT(nvarchar(101),[AddressLine2]) AS [AddressLine2],
	CONVERT(nvarchar(13),[PostalCode]) AS [PostalCode],
	CONVERT(nvarchar(151),[City]) AS [City],
	CONVERT(nvarchar(6),[StateCode]) AS [StateCode],
	CONVERT(nvarchar(3),[CountryCode]) AS [CountryCode],
	CONVERT(bit,[IsPrimary]) AS [IsPrimary],
	CONVERT(nvarchar(MAX),[ExtendedProperties]) AS [ExtendedProperties]
FROM etl_dbo.RegistrationAddress