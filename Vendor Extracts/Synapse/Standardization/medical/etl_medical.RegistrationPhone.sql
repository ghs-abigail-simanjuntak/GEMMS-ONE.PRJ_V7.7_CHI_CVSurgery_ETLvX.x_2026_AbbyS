/********************************************************************************
SCRIPT DEPENDENCIES: [etl_dbo].[RegistrationPhone]
ITEM TYPE:RegistrationPhone
NOTES: Auto-generated external table creation script.
SCALE:
********************************************************************************/
IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

	--DROP EXTERNAL TABLE etl_medical.RegistrationPhone
CREATE EXTERNAL TABLE etl_medical.RegistrationPhone
WITH (
		LOCATION = 'etl_medical/RegistrationPhone',
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
	CONVERT(nvarchar(51),[Number]) AS [Number],
	CONVERT(nvarchar(11),[Type]) AS [Type],
	CONVERT(bit,[IsPrimary]) AS [IsPrimary],
	CONVERT(nvarchar(MAX),[ExtendedProperties]) AS [ExtendedProperties]
FROM etl_dbo.RegistrationPhone



--

