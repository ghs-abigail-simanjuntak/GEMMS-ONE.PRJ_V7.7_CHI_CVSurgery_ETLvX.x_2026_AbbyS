IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')
-- select count(*) from etl_medical.charge
DROP EXTERNAL TABLE etl_medical.Charge
CREATE EXTERNAL TABLE etl_medical.Charge
WITH (
		LOCATION = 'etl_medical/Charge',
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
	CONVERT(nvarchar(101),[Description]) AS [Description],
	CONVERT(nvarchar(MAX),[ChargeNumber]) AS [ChargeNumber],
	CONVERT(datetime,[BillDttm]) AS [BillDttm],
	CONVERT(datetime,[LastUpdatedDttm]) AS [LastUpdatedDttm],
	CONVERT(datetime,[EnteredDttm]) AS [EnteredDttm],
	CONVERT(decimal(18,2),[Amount]) AS [Amount],
	CONVERT(varchar(256),[RenderingPersonExternalDataId]) AS [RenderingPersonExternalDataId],
	CONVERT(varchar(256),[BillingProviderExternalDataId]) AS [BillingProviderExternalDataId],
	CONVERT(varchar(256),[EnteredByExternalDataId]) AS [EnteredByExternalDataId],
	CONVERT(varchar(256),[PerformedByProviderExternalDataId]) AS [PerformedByProviderExternalDataId],
	CONVERT(varchar(256),[LastUpdatedByExternalDataId]) AS [LastUpdatedByExternalDataId],
	CONVERT(varchar(256),[EncounterExternalDataId]) AS [EncounterExternalDataId],
	CONVERT(varchar(256),[VisitExternalDataId]) AS [VisitExternalDataId],
	CONVERT(varchar(256),[FinancialClassExternalDataId]) AS [FinancialClassExternalDataId],
	CONVERT(varchar(256),[ReferringProviderPersonExternalDataId]) AS [ReferringProviderPersonExternalDataId],
	CONVERT(nvarchar(31),[DaysOrUnits]) AS [DaysOrUnits],
	CONVERT(nvarchar(26),[ChargeModifiers]) AS [ChargeModifiers],
	CONVERT(nvarchar(101),[AssociatedDx]) AS [AssociatedDx],
	CONVERT(nvarchar(51),[PlaceOfService]) AS [PlaceOfService],
	CONVERT(nvarchar(5),[RevenueCode]) AS [RevenueCode],
	CONVERT(nvarchar(16),[Cpt]) AS [Cpt],
	CONVERT(nvarchar(16),[Hcpcs]) AS [Hcpcs]
FROM etl_dbo.Charge