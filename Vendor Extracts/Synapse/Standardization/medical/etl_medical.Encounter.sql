/********************************************************************************  
SCRIPT DEPENDENCIES:  etl_ctas.Encounter
ITEM TYPE: Encounter  
NOTES:   
SCALE:
********************************************************************************/

IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Encounter]
CREATE EXTERNAL TABLE [etl_medical].[Encounter]
WITH (
		LOCATION = 'etl_medical/Encounter',
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
	CONVERT(varchar(255),[src].[AccountExternalDataId]) AS [AccountExternalDataId],
	CONVERT(nvarchar(MAX),[src].[ReferenceId]) AS [ReferenceId],
	CONVERT(nvarchar(255),[src].[ServiceType]) AS [ServiceType],
	CONVERT(datetime,[src].[EncounterDttm]) AS [EncounterDttm],
	CONVERT(datetime,[src].[CreatedDttm]) AS [CreatedDttm],
	CONVERT(datetime,[src].[LastUpdatedDttm]) AS [LastUpdatedDttm],
	CONVERT(datetime,[src].[EndDttm]) AS [EndDttm],
	CONVERT(varchar(255),[src].[InsuranceExternalDataId]) AS [InsuranceExternalDataId],
	CONVERT(varchar(255),[src].[VisitExternalDataId]) AS [VisitExternalDataId],
	CONVERT(varchar(255),[src].[CreatedByExternalDataId]) AS [CreatedByExternalDataId],
	CONVERT(varchar(255),[src].[AttendingProviderExternalDataId]) AS [AttendingProviderExternalDataId],
	CONVERT(varchar(255),[src].[PrimaryCareProviderExternalDataId]) AS [PrimaryCareProviderExternalDataId],
	CONVERT(varchar(255),[src].[ReferringProviderExternalDataId]) AS [ReferringProviderExternalDataId],
	CONVERT(varchar(255),[src].[SupervisingProviderExternalDataId]) AS [SupervisingProviderExternalDataId],
	CONVERT(varchar(255),[src].[LastUpdatedByExternalDataId]) AS [LastUpdatedByExternalDataId],
	CONVERT(varchar(255),[src].[LocationExternalDataId]) AS [LocationExternalDataId],
	CONVERT(nvarchar(MAX),[src].[LocationName]) AS [LocationName],
	CONVERT(nvarchar(MAX),[src].[OrganizationName]) AS [OrganizationName]

FROM [etl_dbo].[Encounter] AS [src]

WHERE 1 = 1
