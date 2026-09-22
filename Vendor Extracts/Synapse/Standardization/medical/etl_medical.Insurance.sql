/********************************************************************************  
SCRIPT DEPENDENCIES: 
[etl_dbo].[Insurance],
[etl_dbo].[Insurance_BAR] --Accounting specific
ITEM TYPE: [Insurance]  
NOTES: 
SCALE: 
********************************************************************************/

IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Insurance]
CREATE EXTERNAL TABLE [etl_medical].[Insurance]
WITH (
		LOCATION = 'etl_medical/Insurance',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(UNIQUEIDENTIFIER, [src].[Id]) AS [Id],
	CONVERT(INT, [src].[ItemSetId]) AS [ItemSetId],
	CONVERT(VARCHAR(50), [src].[DataSourceCode]) AS [DataSourceCode],
	CONVERT(VARCHAR(255), [src].[ExternalDataId]) AS [ExternalDataId],
	CONVERT(VARCHAR(255), [src].[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(VARCHAR(255), [src].[PayorExternalDataId]) AS [PayorExternalDataId],
	CONVERT(NVARCHAR(MAX), [src].[Name]) AS [Name],
	CONVERT(NVARCHAR(MAX), [src].[ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(DATETIME, [src].[ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
	CONVERT(DATETIME, [src].[ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm]

FROM [etl_dbo].[Insurance] AS [src]
