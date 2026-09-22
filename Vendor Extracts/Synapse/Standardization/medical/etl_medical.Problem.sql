/********************************************************************************  
SCRIPT DEPENDENCIES: etl_dbo.Problem_ABS, 
etl_dbo.Problem_Diag, 
etl_dbo.Problem_Admit
etl_dbo.Problems_FamilyHx,
etl_dbo.Problems
ITEM TYPE: Problem
NOTES: 
SCALE:  
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Problem]
CREATE EXTERNAL TABLE [etl_medical].[Problem]
WITH (
		LOCATION = 'etl_medical/Problem',
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
	CONVERT(NVARCHAR(50), [Category]) AS [Category],
	CONVERT(VARCHAR(255), [IdentifiedByProviderExternalDataId]) AS [IdentifiedByProviderExternalDataId],
	CONVERT(VARCHAR(255), [ManagedByProviderExternalDataId]) AS [ManagedByProviderExternalDataId],
	CONVERT(VARCHAR(255), [LastAssessingPersonExternalDataId]) AS [LastAssessingPersonExternalDataId],
	CONVERT(NVARCHAR(10), [Icd9Code]) AS [Icd9Code],
	CONVERT(NVARCHAR(10), [Icd10Code]) AS [Icd10Code],
	CONVERT(INT, [MedcinCode]) AS [MedcinCode],
	CONVERT(NVARCHAR(15), [Snomed]) AS [Snomed],
	CONVERT(DATETIME, [RecordedDttm]) AS [RecordedDttm],
	CONVERT(VARCHAR(255), [RecordedByExternalDataId]) AS [RecordedByExternalDataId],
	CONVERT(VARCHAR(255), [LastUpdatingProviderExternalDataId]) AS [LastUpdatingProviderExternalDataId],
	CONVERT(VARCHAR(255), [EncounterExternalDataId]) AS [EncounterExternalDataId]
FROM [etl_dbo].[Problem]
