/********************************************************************************
SCRIPT DEPENDENCIES: 
etl_dbo.Allergy_OE, 
etl_dbo.Allergy_ClassGenericIngredient, 
etl_dbo.Allergy_CodedAllergies,
etl_dbo.Allergy_Uncoded,
etl_dbo.Allergy_AuditAllergies,
etl_dbo.Allergy_NKA
ITEM TYPE: Allergy  
NOTES: Check which CTAS scripts you have populated for Allegies! Might need to union all some more tables into this script, comment others out.
SCALE:
********************************************************************************/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'etl_medical')
    EXEC('CREATE SCHEMA [etl_medical]');
GO

DROP EXTERNAL TABLE etl_medical.Allergy;

CREATE EXTERNAL TABLE etl_medical.Allergy
WITH
(
    LOCATION = 'etl_medical/Allergy',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS
SELECT
    CONVERT(uniqueidentifier, [Id]) AS [Id],
    CONVERT(int, [ItemSetId]) AS [ItemSetId],
    CONVERT(varchar(50), [DataSourceCode]) AS [DataSourceCode],
    CONVERT(varchar(255), [ExternalDataId]) AS [ExternalDataId],
    CONVERT(varchar(255), [ExternalDataVersion]) AS [ExternalDataVersion],
    CONVERT(int, [DisplayOrder]) AS [DisplayOrder],
    CONVERT(varchar(255), [PatientExternalDataId]) AS [PatientExternalDataId],
    CONVERT(datetime, [ClinicallyRelevantDttm]) AS [ClinicallyRelevantDttm],
    CONVERT(nvarchar(50), [TypeCode]) AS [TypeCode],
    CONVERT(nvarchar(255), [TypeName]) AS [TypeName],
    CONVERT(bit, [IsInvalidated]) AS [IsInvalidated],
    CONVERT(datetime, [InvalidatedDttm]) AS [InvalidatedDttm],
    CONVERT(varchar(255), [InvalidatedByProviderExternalDataId]) AS [InvalidatedByProviderExternalDataId],
    CONVERT(datetime, [ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
    CONVERT(datetime, [ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
    CONVERT(nvarchar(100), [Status]) AS [Status],
    CONVERT(nvarchar(MAX), [Title]) AS [Title],
    CONVERT(bit, [IsSecure]) AS [IsSecure],
    CONVERT(nvarchar(MAX), [VcoSetEntries]) AS [VcoSetEntries],
    CONVERT(nvarchar(MAX), [ExtendedProperties]) AS [ExtendedProperties],
    CONVERT(datetime, [ServiceDttm]) AS [ServiceDttm],
    CONVERT(datetime, [RecordedDttm]) AS [RecordedDttm],
    CONVERT(bit, [IsMedication]) AS [IsMedication],
    CONVERT(nvarchar(50), [Classification]) AS [Classification],
    CONVERT(nvarchar(255), [ReactionDescription]) AS [ReactionDescription],
    CONVERT(varchar(255), [PerformingProviderExternalDataId]) AS [PerformingProviderExternalDataId],
    CONVERT(varchar(255), [RecordedByExternalDataId]) AS [RecordedByExternalDataId],
    CONVERT(varchar(255), [LastUpdatingProviderExternalDataId]) AS [LastUpdatingProviderExternalDataId],
    CONVERT(varchar(255), [EncounterExternalDataId]) AS [EncounterExternalDataId]
FROM
    etl_dbo.Allergy

