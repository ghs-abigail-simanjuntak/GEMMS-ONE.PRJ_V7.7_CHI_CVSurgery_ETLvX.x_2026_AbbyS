/********************************************************************************  
SCRIPT DEPENDENCIES:  [etl_dbo].[Visit]
ITEM TYPE: Visit  
NOTES:  
SCALE:
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Visit]
CREATE EXTERNAL TABLE [etl_medical].[Visit]
WITH (
		LOCATION = 'etl_medical/Visit',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(UNIQUEIDENTIFIER, [src].[Id]) AS [Id],
	CONVERT(INT, [src].[ItemSetId]) AS [ItemSetId],
	CONVERT(VARCHAR(50), [src].[DataSourceCode]) AS [DataSourceCode],
	CONVERT(VARCHAR(255), [src].[ExternalDataId]) AS [ExternalDataId],
	CONVERT(VARCHAR(255), [src].[ExternalDataVersion]) AS [ExternalDataVersion],
	CONVERT(INT, [src].[DisplayOrder]) AS [DisplayOrder],
	CONVERT(VARCHAR(255), [src].[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(DATETIME, [src].[ClinicallyRelevantDttm]) AS [ClinicallyRelevantDttm],
	CONVERT(NVARCHAR(50), [src].[TypeCode]) AS [TypeCode],
	CONVERT(NVARCHAR(255), [src].[TypeName]) AS [TypeName],
	CONVERT(BIT, [src].[IsInvalidated]) AS [IsInvalidated],
	CONVERT(DATETIME, [src].[InvalidatedDttm]) AS [InvalidatedDttm],
	CONVERT(VARCHAR(255), [src].[InvalidatedByProviderExternalDataId]) AS [InvalidatedByProviderExternalDataId],
	CONVERT(DATETIME, [src].[ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
	CONVERT(DATETIME, [src].[ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
	CONVERT(NVARCHAR(100), [src].[Status]) AS [Status],
	CONVERT(NVARCHAR(MAX), [src].[Title]) AS [Title],
	CONVERT(BIT, [src].[IsSecure]) AS [IsSecure],
	CONVERT(NVARCHAR(MAX), [src].[VcoSetEntries]) AS [VcoSetEntries],
	CONVERT(NVARCHAR(MAX), [src].[ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(DATETIME, [src].[ServiceDttm]) AS [ServiceDttm],
	CONVERT(DATETIME, [src].[RecordedDttm]) AS [RecordedDttm],
	CONVERT(VARCHAR(255), [src].[AccountExternalDataId]) AS [AccountExternalDataId],
	CONVERT(NVARCHAR(255), [src].[WellKnownVisitType]) AS [WellKnownVisitType],
	CONVERT(NVARCHAR(MAX), [src].[ReferenceId]) AS [ReferenceId],
	CONVERT(NVARCHAR(MAX), [src].[Location]) AS [Location],
	CONVERT(NVARCHAR(255), [src].[ServiceType]) AS [ServiceType],
	CONVERT(DATETIME, [src].[VisitDttm]) AS [VisitDttm],
	CONVERT(DATETIME, [src].[LastUpdatedDttm]) AS [LastUpdatedDttm],
	CONVERT(DATETIME, [src].[CreatedDttm]) AS [CreatedDttm],
	CONVERT(DATETIME, [src].[EndDttm]) AS [EndDttm],
	CONVERT(VARCHAR(255), [src].[InsuranceExternalDataId]) AS [InsuranceExternalDataId],
	CONVERT(VARCHAR(255), [src].[AttendingProviderExternalDataId]) AS [AttendingProviderExternalDataId],
	CONVERT(VARCHAR(255), [src].[CreatedByExternalDataId]) AS [CreatedByExternalDataId],
	CONVERT(VARCHAR(255), [src].[LastUpdatedByExternalDataId]) AS [LastUpdatedByExternalDataId],
	CONVERT(VARCHAR(255), [src].[PrimaryCareProviderExternalDataId]) AS [PrimaryCareProviderExternalDataId],
	CONVERT(VARCHAR(255), [src].[ReferringProviderExternalDataId]) AS [ReferringProviderExternalDataId],
	CONVERT(VARCHAR(255), [src].[SupervisingProviderExternalDataId]) AS [SupervisingProviderExternalDataId]

FROM [etl_dbo].[Visit] AS [src]