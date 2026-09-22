/********************************************************************************  
SCRIPT DEPENDENCIES: 
etl_dbo.PersonPhone_Contact.sql
ITEM TYPE: PersonPhone  
NOTES: 
SCALE: 
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[PersonPhone]
CREATE EXTERNAL TABLE [etl_customer].[PersonPhone]
WITH (
		LOCATION = 'etl_customer/PersonPhone',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(uniqueidentifier,[Id]) AS [Id],
	CONVERT(int,[ItemSetId]) AS [ItemSetId],
	CONVERT(varchar(50),[DataSourceCode]) AS [DataSourceCode],
	CONVERT(varchar(255),[ExternalDataId]) AS [ExternalDataId],
	CONVERT(varchar(255),[ItemExternalDataId]) AS [ItemExternalDataId],
	CONVERT(nvarchar(10),[Type]) AS [Type],
	CONVERT(nvarchar(50),[Number]) AS [Number],
	CONVERT(bit,[IsPrimary]) AS [IsPrimary]

FROM [etl_dbo].[PersonPhone]