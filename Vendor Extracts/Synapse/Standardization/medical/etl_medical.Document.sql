/********************************************************************************
SCRIPT DEPENDENCIES: etl_dbo.Document_ASS, etl_dbo.Document_CALL, etl_dbo.Document_NOTE, etl_dbo.Document_EDM, etl_dbo.Document_ITS_RAD_Table, etl_dbo.Document_ITS_MTDD, etl_dbo.Document_RPT_Table
ITEM TYPE: Document
NOTES: Combines Document CETAS tables into etl_medical.Document 
SCALLE:
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Document]
CREATE EXTERNAL TABLE [etl_medical].[Document]
WITH (
		LOCATION = 'etl_medical/Document',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(uniqueidentifier,[src].[Id]) AS [Id],
	CONVERT(int,[src].[ItemSetId]) AS [ItemSetId],
	CONVERT(varchar(50),[src].[DataSourceCode]) AS [DataSourceCode],
	CONVERT(varchar(255),[src].[ExternalDataId]) COLLATE SQL_Latin1_General_CP1_CS_AS AS [ExternalDataId],
	CONVERT(varchar(255),[src].[ExternalDataVersion]) AS [ExternalDataVersion],
	CONVERT(int,[src].[DisplayOrder]) AS [DisplayOrder],
	CONVERT(varchar(255),[src].[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(datetime,[src].[ClinicallyRelevantDttm]) AS [ClinicallyRelevantDttm],
	CONVERT(nvarchar(50),[src].[TypeCode]) AS [TypeCode],
	CONVERT(nvarchar(255),[src].[TypeName]) AS [TypeName],
	CONVERT(bit,[src].[IsInvalidated]) AS [IsInvalidated],
	CONVERT(datetime,[src].[InvalidatedDttm]) AS [InvalidatedDttm],
	CONVERT(varchar(255),[src].[InvalidatedByProviderExternalDataId]) AS [InvalidatedByProviderExternalDataId],
	CONVERT(datetime,[src].[ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
	CONVERT(datetime,[src].[ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
	CONVERT(nvarchar(100),[src].[Status]) AS [Status],
	CONVERT(nvarchar(MAX),[src].[Title]) AS [Title],
	CONVERT(bit,[src].[IsSecure]) AS [IsSecure],
	CONVERT(nvarchar(MAX),[src].[VcoSetEntries]) AS [VcoSetEntries],
	CONVERT(nvarchar(MAX),[src].[ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(datetime,[src].[ServiceDttm]) AS [ServiceDttm],
	CONVERT(datetime,[src].[RecordedDttm]) AS [RecordedDttm],
	CONVERT(datetime,[src].[AuthoredDttm]) AS [AuthoredDttm],
	CONVERT(varchar(255),[src].[OwningPersonExternalDataId]) AS [OwningPersonExternalDataId],
	CONVERT(varchar(255),[src].[AuthoringProviderExternalDataId]) AS [AuthoringProviderExternalDataId],
	CONVERT(varchar(255),[src].[RecordingPersonExternalDataId]) AS [RecordingPersonExternalDataId],
	CONVERT(varchar(255),[src].[LastUpdatingProviderExternalDataId]) AS [LastUpdatingProviderExternalDataId],
	CONVERT(varchar(255),[src].[EncounterExternalDataId]) AS [EncounterExternalDataId]
FROM [etl_dbo].[Document] AS [src]