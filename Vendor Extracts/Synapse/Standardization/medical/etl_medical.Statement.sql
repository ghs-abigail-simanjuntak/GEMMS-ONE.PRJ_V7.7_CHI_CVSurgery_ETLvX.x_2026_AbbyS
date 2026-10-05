IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

	--DROP EXTERNAL TABLE etl_medical.Statement
CREATE EXTERNAL TABLE etl_medical.Statement
WITH (
		LOCATION = 'etl_medical/Statement',
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
	CONVERT(nvarchar(MAX),[Description]) AS [Description],
	CONVERT(nvarchar(MAX),[AccountNumber]) AS [AccountNumber],
	CONVERT(datetime,[LastUpdatedDttm]) AS [LastUpdatedDttm],
	CONVERT(datetime,[StatementDttm]) AS [StatementDttm],
	CONVERT(datetime,[EndDttm]) AS [EndDttm],
	CONVERT(varchar(256),[AssignedToExternalDataId]) AS [AssignedToExternalDataId],
	CONVERT(varchar(256),[CreatedByExternalDataId]) AS [CreatedByExternalDataId],
	CONVERT(varchar(256),[PaidByExternalDataId]) AS [PaidByExternalDataId],
	CONVERT(varchar(256),[PaidByInsuranceExternalDataId]) AS [PaidByInsuranceExternalDataId],
	CONVERT(varchar(256),[LastUpdatedByExternalDataId]) AS [LastUpdatedByExternalDataId],
	CONVERT(varchar(256),[RecordedByExternalDataId]) AS [RecordedByExternalDataId],
	CONVERT(decimal(18,2),[TotalCharges]) AS [TotalCharges],
	CONVERT(decimal(18,2),[PatientBalance]) AS [PatientBalance],
	CONVERT(decimal(18,2),[InsuranceBalance]) AS [InsuranceBalance],
	CONVERT(decimal(18,2),[InsurancePayments]) AS [InsurancePayments],
	CONVERT(decimal(18,2),[PatientPayments]) AS [PatientPayments],
	CONVERT(decimal(18,2),[TotalPayments]) AS [TotalPayments],
	CONVERT(decimal(18,2),[InsuranceOpeningBalance]) AS [InsuranceOpeningBalance],
	CONVERT(decimal(18,2),[PatientOpeningBalance]) AS [PatientOpeningBalance],
	CONVERT(decimal(18,2),[Adjustments]) AS [Adjustments],
	CONVERT(varchar(256),[EncounterExternalDataId]) AS [EncounterExternalDataId],
	CONVERT(varchar(256),[VisitExternalDataId]) AS [VisitExternalDataId]
FROM etl_dbo.Statement