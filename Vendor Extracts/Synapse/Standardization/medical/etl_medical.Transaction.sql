IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

DROP EXTERNAL TABLE etl_medical.[Transaction]
CREATE EXTERNAL TABLE etl_medical.[Transaction]
WITH (
		LOCATION = 'etl_medical/Transaction',
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
	CONVERT(varchar(256),[AccountExternalDataId]) AS [AccountExternalDataId],
	CONVERT(nvarchar(MAX),[TransactionNumber]) AS [TransactionNumber],
	CONVERT(nvarchar(MAX),[Description]) AS [Description],
	CONVERT(varchar(256),[PaidByExternalDataId]) AS [PaidByExternalDataId],
	CONVERT(varchar(256),[PaidByInsuranceExternalDataId]) AS [PaidByInsuranceExternalDataId],
	CONVERT(varchar(256),[EnteredByExternalDataId]) AS [EnteredByExternalDataId],
	CONVERT(varchar(256),[LastUpdatedByExternalDataId]) AS [LastUpdatedByExternalDataId],
	CONVERT(datetime,[TransactionDttm]) AS [TransactionDttm],
	CONVERT(datetime,[EnteredDttm]) AS [EnteredDttm],
	CONVERT(datetime,[LastUpdatedDttm]) AS [LastUpdatedDttm],
	CONVERT(datetime,[TransactionPostDttm]) AS [TransactionPostDttm],
	CONVERT(decimal(18,2),[Amount]) AS [Amount],
	CONVERT(nvarchar(51),[Department]) AS [Department],
	CONVERT(nvarchar(101),[BatchNumber]) AS [BatchNumber],
	CONVERT(nvarchar(256),[Location]) AS [Location],
	CONVERT(nvarchar(51),[CheckNumber]) AS [CheckNumber],
	CONVERT(nvarchar(256),[WellKnownTransactionType]) AS [WellKnownTransactionType],
	CONVERT(varchar(256),[EncounterExternalDataId]) AS [EncounterExternalDataId],
	CONVERT(varchar(256),[VisitExternalDataId]) AS [VisitExternalDataId],
	CONVERT(varchar(256),[ClaimExternalDataId]) AS [ClaimExternalDataId],
	CONVERT(varchar(256),[ChargeExternalDataId]) AS [ChargeExternalDataId]
FROM etl_dbo.[Transaction]