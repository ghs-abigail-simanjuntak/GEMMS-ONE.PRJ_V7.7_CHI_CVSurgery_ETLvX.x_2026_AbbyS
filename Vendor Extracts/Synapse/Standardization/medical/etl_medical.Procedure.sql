/********************************************************************************  
SCRIPT DEPENDENCIES: 
etl_dbo.Procedure_Operations, 
etl_dbo.Procedure_Procedures
ITEM TYPE: Procedure
NOTES: 
SCALE:  
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Procedure]
CREATE EXTERNAL TABLE [etl_medical].[Procedure]
WITH (
		LOCATION = 'etl_medical/Procedure',
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
	CONVERT(DATETIME, [PerformedDttm]) AS [PerformedDttm],
	CONVERT(VARCHAR(255), [PerformingPersonExternalDataId]) AS [PerformingPersonExternalDataId],
	CONVERT(VARCHAR(255), [OrderingPersonExternalDataId]) AS [OrderingPersonExternalDataId],
	CONVERT(DATETIME, [OrderedDttm]) AS [OrderedDttm],
	CONVERT(NVARCHAR(100), [Description]) AS [Description],
	CONVERT(NVARCHAR(100), [Laterality]) AS [Laterality],
	CONVERT(VARCHAR(255), [EncounterExternalDataId]) AS [EncounterExternalDataId],
	CONVERT(NVARCHAR(255), [Location]) AS [Location]
FROM [etl_dbo].[Procedure]

