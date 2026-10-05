IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

	--DROP EXTERNAL TABLE etl_medical.AccountNote
CREATE EXTERNAL TABLE etl_medical.AccountNote
WITH (
		LOCATION = 'etl_medical/AccountNote',
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
	CONVERT(nvarchar(MAX),[ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(datetime,[ServiceDttm]) AS [ServiceDttm],
	CONVERT(datetime,[RecordedDttm]) AS [RecordedDttm],
	CONVERT(datetime,[AuthoredDttm]) AS [AuthoredDttm],
	CONVERT(varchar(256),[AccountExternalDataId]) AS [AccountExternalDataId],
	CONVERT(varchar(256),[AuthoredByPersonExternalDataId]) AS [AuthoredByPersonExternalDataId],
	CONVERT(varchar(256),[EncounterExternalDataId]) AS [EncounterExternalDataId],
	CONVERT(nvarchar(MAX),[Note]) AS [Note],
	CONVERT(nvarchar(256),[WellKnownPriority]) AS [WellKnownPriority]
FROM 
    etl_dbo.AccountNote