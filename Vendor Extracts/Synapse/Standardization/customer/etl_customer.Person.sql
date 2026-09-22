/********************************************************************************  
SCRIPT DEPENDENCIES:    
etl_dbo.Person_Contact, 
etl_dbo.Person_Docs, 
etl_dbo.Person_Docs2, 
etl_dbo.Person_MTUsers, 
etl_dbo.Person_AuthPerson, 
etl_dbo.Person_UNK
ITEM TYPE: Person
NOTES: 
SCALE: 
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[Person]
CREATE EXTERNAL TABLE [etl_customer].[Person]
WITH (
		LOCATION = 'etl_customer/Person',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(UNIQUEIDENTIFIER, [Id]) AS [Id],
	CONVERT(INT, [ItemSetId]) AS [ItemSetId],
	CONVERT(VARCHAR(50), [DataSourceCode]) AS [DataSourceCode],
	CONVERT(VARCHAR(255), [ExternalDataId]) AS [ExternalDataId],
	CONVERT(NVARCHAR(100), [FirstName]) AS [FirstName],
	CONVERT(NVARCHAR(50), [LastName]) AS [LastName],
	CONVERT(NVARCHAR(20), [MiddleName]) AS [MiddleName],
	CONVERT(NVARCHAR(5), [Prefix]) AS [Prefix],
	CONVERT(NVARCHAR(10), [Suffix]) AS [Suffix],
	CONVERT(NVARCHAR(50), [SourceSystemUserIdentifier]) AS [SourceSystemUserIdentifier],
	CONVERT(BIT, [IsSourceSystemUser]) AS [IsSourceSystemUser],
	CONVERT(NVARCHAR(20), [Credentials]) AS [Credentials],
	CONVERT(NVARCHAR(10), [Npi]) AS [Npi],
	CONVERT(DATETIME, [ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
	CONVERT(DATETIME, [ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
	CONVERT(NVARCHAR(MAX), [SignatureFilePath]) AS [SignatureFilePath],
	CONVERT(VARBINARY(MAX), [SignatureBinaryContent]) AS [SignatureBinaryContent],
	CONVERT(NVARCHAR(MAX), [ExtendedProperties]) AS [ExtendedProperties]
FROM [etl_dbo].[Person]