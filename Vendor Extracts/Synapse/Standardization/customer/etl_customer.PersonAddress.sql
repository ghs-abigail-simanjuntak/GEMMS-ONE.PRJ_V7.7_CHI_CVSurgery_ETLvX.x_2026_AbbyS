/********************************************************************************  
SCRIPT DEPENDENCIES: 
etl_dbo.PersonAddress_Contact.sql
ITEM TYPE: PersonAddress  
NOTES: 
SCALE: 
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[PersonAddress]
CREATE EXTERNAL TABLE [etl_customer].[PersonAddress]
WITH (
		LOCATION = 'etl_customer/PersonAddress',
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
	CONVERT(nvarchar(100),[AddressLine1]) AS [AddressLine1],
	CONVERT(nvarchar(100),[AddressLine2]) AS [AddressLine2],
	CONVERT(nvarchar(12),[PostalCode]) AS [PostalCode],
	CONVERT(nvarchar(150),[City]) AS [City],
	CONVERT(nvarchar(2),[StateCode]) AS [StateCode],
	CONVERT(nvarchar(2),[CountryCode]) AS [CountryCode],
	CONVERT(bit,[IsPrimary]) AS [IsPrimary]

FROM [etl_dbo].[PersonAddress]
