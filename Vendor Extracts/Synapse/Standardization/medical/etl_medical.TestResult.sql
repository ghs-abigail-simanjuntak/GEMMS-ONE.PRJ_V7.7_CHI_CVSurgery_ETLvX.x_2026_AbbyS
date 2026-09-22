/********************************************************************************  
SCRIPT DEPENDENCIES: 
etl_dbo.TestResult_BBK_BB, 
etl_dbo.TestResult_BBK_Product, 
etl_dbo.TestResult_Lab, 
etl_dbo.TestResult_Micro
ITEM TYPE: TestResult
NOTES: 
SCALE:  
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[TestResult]
CREATE EXTERNAL TABLE [etl_medical].[TestResult]
WITH (
		LOCATION = 'etl_medical/TestResult',
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
	CONVERT(NVARCHAR(2), [AbnormalFlag]) AS [AbnormalFlag],
	CONVERT(NVARCHAR(255), [ReferenceRange]) AS [ReferenceRange],
	CONVERT(NVARCHAR(MAX), [Value]) AS [Value],
	CONVERT(NVARCHAR(30), [Units]) AS [Units],
	CONVERT(NVARCHAR(10), [LoincCode]) AS [LoincCode],
	CONVERT(VARCHAR(255), [ResultExternalDataId]) AS [ResultExternalDataId],
	CONVERT(DATETIME, [ResultedDttm]) AS [ResultedDttm],
	CONVERT(NVARCHAR(18), [SnomedCode]) AS [SnomedCode],
	CONVERT(VARCHAR(255), [PerformingProviderExternalDataId]) AS [PerformingProviderExternalDataId],
	CONVERT(VARCHAR(255), [RecordedByExternalDataId]) AS [RecordedByExternalDataId],
	CONVERT(VARCHAR(255), [LastUpdatingProviderExternalDataId]) AS [LastUpdatingProviderExternalDataId],
	CONVERT(VARCHAR(255), [VerifiedByExternalDataId]) AS [VerifiedByExternalDataId],
	CONVERT(VARCHAR(255), [EncounterExternalDataId]) AS [EncounterExternalDataId]
FROM [etl_dbo].[TestResult]