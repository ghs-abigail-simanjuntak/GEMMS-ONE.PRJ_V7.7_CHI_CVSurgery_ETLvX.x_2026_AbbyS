/********************************************************************************  
SCRIPT DEPENDENCIES: etl_ctas.Payor.sql
ITEM TYPE: Payor
NOTES: 
SCALE: 
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[Payor]
CREATE EXTERNAL TABLE [etl_customer].[Payor]
WITH (
		LOCATION = 'etl_customer/Payor',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(UNIQUEIDENTIFIER, [src].[Id]) AS [Id],
	CONVERT(INT, [src].[ItemSetId]) AS [ItemSetId],
	CONVERT(VARCHAR(50), [src].[DataSourceCode]) AS [DataSourceCode],
	CONVERT(VARCHAR(255), [src].[ExternalDataId]) AS [ExternalDataId],
	CONVERT(NVARCHAR(MAX), [src].[Name]) AS [Name],
	CONVERT(NVARCHAR(MAX), [src].[ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(DATETIME, [src].[ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
	CONVERT(DATETIME, [src].[ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm]

FROM [etl_dbo].[Payor] AS [src]