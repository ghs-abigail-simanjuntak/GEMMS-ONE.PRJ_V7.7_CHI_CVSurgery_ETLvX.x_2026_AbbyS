/********************************************************************************  
SCRIPT DEPENDENCIES: 
etl_dbo.Order_BBK_BB, 
etl_dbo.Order_BBK_Product, 
etl_dbo.Order_Lab, 
etl_dbo.Order_Micro, 
etl_dbo.Order_Other
ITEM TYPE: Order
NOTES: 
SCALE:  
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Order]
CREATE EXTERNAL TABLE [etl_medical].[Order]
WITH (
		LOCATION = 'etl_medical/Order',
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
	CONVERT(DATETIME, [OrderDttm]) AS [OrderDttm],
	CONVERT(VARCHAR(255), [OrderingProviderExternalDataId]) AS [OrderingProviderExternalDataId],
	CONVERT(VARCHAR(255), [ApprovingProviderExternalDataId]) AS [ApprovingProviderExternalDataId],
	CONVERT(VARCHAR(255), [PerformingProviderExternalDataId]) AS [PerformingProviderExternalDataId],
	CONVERT(VARCHAR(255), [RecordedByExternalDataId]) AS [RecordedByExternalDataId],
	CONVERT(VARCHAR(255), [LastUpdatingProviderExternalDataId]) AS [LastUpdatingProviderExternalDataId],
	CONVERT(VARCHAR(255), [CollectingProviderExternalDataId]) AS [CollectingProviderExternalDataId],
	CONVERT(VARCHAR(255), [EncounterExternalDataId]) AS [EncounterExternalDataId]

FROM
	(
		SELECT
			[Id],
			[ItemSetId],
			[DataSourceCode],
			[ExternalDataId],
			[ExternalDataVersion],
			[DisplayOrder],
			[PatientExternalDataId],
			[ClinicallyRelevantDttm],
			[TypeCode],
			[TypeName],
			[IsInvalidated],
			[InvalidatedDttm],
			[InvalidatedByProviderExternalDataId],
			[ExternalDataCreatedDttm],
			[ExternalDataUpdatedDttm],
			[Status],
			[Title],
			[IsSecure],
			[VcoSetEntries],
			[ExtendedProperties],
			[ServiceDttm],
			[RecordedDttm],
			[OrderDttm],
			[OrderingProviderExternalDataId],
			[ApprovingProviderExternalDataId],
			[PerformingProviderExternalDataId],
			[RecordedByExternalDataId],
			[LastUpdatingProviderExternalDataId],
			[CollectingProviderExternalDataId],
			[EncounterExternalDataId]
		FROM [etl_dbo].[Order] AS [src]
	) AS [src]

