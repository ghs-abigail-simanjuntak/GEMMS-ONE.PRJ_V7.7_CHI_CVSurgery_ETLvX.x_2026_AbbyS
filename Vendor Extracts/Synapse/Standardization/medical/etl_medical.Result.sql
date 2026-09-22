/********************************************************************************  
SCRIPT DEPENDENCIES: 
etl_dbo.Result_BBK_BB, 
etl_dbo.Result_BBK_Product, 
etl_dbo.Result_Lab, 
etl_dbo.Result_Micro
ITEM TYPE: Result
NOTES: 
SCALE:  
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Result]
CREATE EXTERNAL TABLE [etl_medical].[Result]
WITH (
		LOCATION = 'etl_medical/Result',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(UNIQUEIDENTIFIER, [Id]) AS [Id],
	CONVERT(INT, [ItemSetId]) AS [ItemSetId],
	CONVERT(VARCHAR(50), [DataSourceCode]) AS [DataSourceCode],
	CONVERT(VARCHAR(255), [ExternalDataId]) AS [ExternalDataId],
	CONVERT(VARCHAR(255), [ExternalDataVersion]) AS [ExternalDataVersion],
	CONVERT(INT, [DisplayOrder]) AS [DisplayOrder],
	CONVERT(VARCHAR(255), [PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(DATETIME, [ClinicallyRelevantDttm]) AS [ClinicallyRelevantDttm],
	CONVERT(NVARCHAR(50), [TypeCode]) AS [TypeCode],
	CONVERT(NVARCHAR(255), [TypeName]) AS [TypeName],
	CONVERT(BIT, [IsInvalidated]) AS [IsInvalidated],
	CONVERT(DATETIME, [InvalidatedDttm]) AS [InvalidatedDttm],
	CONVERT(VARCHAR(255), [InvalidatedByProviderExternalDataId]) AS [InvalidatedByProviderExternalDataId],
	CONVERT(DATETIME, [ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
	CONVERT(DATETIME, [ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
	CONVERT(NVARCHAR(100), [Status]) AS [Status],
	CONVERT(NVARCHAR(MAX), [Title]) AS [Title],
	CONVERT(BIT, [IsSecure]) AS [IsSecure],
	CONVERT(NVARCHAR(MAX), [VcoSetEntries]) AS [VcoSetEntries],
	CONVERT(NVARCHAR(MAX), [ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(DATETIME, [ServiceDttm]) AS [ServiceDttm],
	CONVERT(DATETIME, [RecordedDttm]) AS [RecordedDttm],
	CONVERT(VARCHAR(255), [OrderExternalDataId]) AS [OrderExternalDataId],
	CONVERT(NVARCHAR(255), [OrderName]) AS [OrderName],
	CONVERT(DATETIME, [ResultedDttm]) AS [ResultedDttm],
	CONVERT(DATETIME, [OrderDttm]) AS [OrderDttm],
	CONVERT(NVARCHAR(255), [PerformingLocationName]) AS [PerformingLocationName],
	CONVERT(VARCHAR(255), [OrderingProviderExternalDataId]) AS [OrderingProviderExternalDataId],
	CONVERT(VARCHAR(255), [EncounterExternalDataId]) AS [EncounterExternalDataId]
FROM [etl_dbo].[Result]

