/********************************************************************************  
SCRIPT DEPENDENCIES: etl_ctas.Medication_PHA, 
etl_ctas.Medication_RXM
ITEM TYPE: Medication  
NOTES: Union extract for PHA and RXM medication helpers.
SCALE:  
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Medication]
CREATE EXTERNAL TABLE [etl_medical].[Medication]
WITH (
		LOCATION = 'etl_medical/Medication',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(uniqueidentifier,[src].[Id]) AS [Id],
	CONVERT(int,[src].[ItemSetId]) AS [ItemSetId],
	CONVERT(varchar(50),[src].[DataSourceCode]) AS [DataSourceCode],
	CONVERT(varchar(255),[src].[ExternalDataId]) AS [ExternalDataId],
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
	CONVERT(varchar(255),[src].[AdministeringPersonExternalDataId]) AS [AdministeringPersonExternalDataId],
	CONVERT(varchar(255),[src].[RecordingPersonExternalDataId]) AS [RecordingPersonExternalDataId],
	CONVERT(nvarchar(75),[src].[Strength]) AS [Strength],
	CONVERT(nvarchar(30),[src].[Form]) AS [Form],
	CONVERT(nvarchar(13),[src].[Ndc]) AS [Ndc],
	CONVERT(int,[src].[Ddi]) AS [Ddi],
	CONVERT(varchar(255),[src].[OrderingPersonExternalDataId]) AS [OrderingPersonExternalDataId],
	CONVERT(datetime,[src].[RxDttm]) AS [RxDttm],
	CONVERT(nvarchar(255),[src].[FreeTextSig]) AS [FreeTextSig],
	CONVERT(varchar(255),[src].[LastUpdatedByExternalDataId]) AS [LastUpdatedByExternalDataId],
	CONVERT(varchar(255),[src].[SupervisingPersonExternalDataId]) AS [SupervisingPersonExternalDataId],
	CONVERT(varchar(255),[src].[EncounterExternalDataId]) AS [EncounterExternalDataId],
	CONVERT(varchar(255),[src].[ParentItemExternalDataId]) AS [ParentItemExternalDataId]

FROM [etl_dbo].[Medication] AS [src]