IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

	--DROP EXTERNAL TABLE etl_medical.Vital
CREATE EXTERNAL TABLE etl_medical.Vital
WITH (
		LOCATION = 'etl_medical/Vital',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS
SELECT
	CONVERT(uniqueidentifier,[Id]) AS [Id],
	CONVERT(int,[ItemSetId]) AS [ItemSetId],
	CONVERT(varchar(51),[DataSourceCode]) AS [DataSourceCode],
	CONVERT(varchar(256),[ExternalDataId]) AS [ExternalDataId],
	CONVERT(varchar(256),[ExternalDataVersion]) AS [ExternalDataVersion],
	CONVERT(int,[DisplayOrder]) AS [DisplayOrder],
	CONVERT(varchar(256),[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(datetime,[ClinicallyRelevantDttm]) AS [ClinicallyRelevantDttm],
	CONVERT(nvarchar(51),[TypeCode]) AS [TypeCode],
	CONVERT(nvarchar(256),[TypeName]) AS [TypeName],
	CONVERT(bit,[IsInvalidated]) AS [IsInvalidated],
	CONVERT(datetime,[InvalidatedDttm]) AS [InvalidatedDttm],
	CONVERT(varchar(256),[InvalidatedByProviderExternalDataId]) AS [InvalidatedByProviderExternalDataId],
	CONVERT(datetime,[ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
	CONVERT(datetime,[ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
	CONVERT(nvarchar(101),[Status]) AS [Status],
	CONVERT(nvarchar(MAX),[Title]) AS [Title],
	CONVERT(bit,[IsSecure]) AS [IsSecure],
	CONVERT(nvarchar(MAX),[VcoSetEntries]) AS [VcoSetEntries],
	CONVERT(nvarchar(MAX),[ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(datetime,[ServiceDttm]) AS [ServiceDttm],
	CONVERT(datetime,[RecordedDttm]) AS [RecordedDttm],
	CONVERT(datetime,[PerformedDttm]) AS [PerformedDttm],
	CONVERT(varchar(256),[PersonExternalDataId]) AS [PersonExternalDataId],
	CONVERT(nvarchar(256),[Value]) AS [Value],
	CONVERT(nvarchar(31),[Units]) AS [Units],
	CONVERT(varchar(256),[PerformingProviderExternalDataId]) AS [PerformingProviderExternalDataId],
	CONVERT(varchar(256),[RecordedByExternalDataId]) AS [RecordedByExternalDataId],
	CONVERT(varchar(256),[LastUpdatingProviderExternalDataId]) AS [LastUpdatingProviderExternalDataId],
	CONVERT(varchar(256),[OrderExternalDataId]) AS [OrderExternalDataId],
	CONVERT(varchar(256),[EncounterExternalDataId]) AS [EncounterExternalDataId]
FROM etl_dbo.Vital