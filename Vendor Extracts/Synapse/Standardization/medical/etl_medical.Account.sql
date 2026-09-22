/********************************************************************************
SCRIPT DEPENDENCIES: 
ITEM TYPE: Account
VERSION: 
NOTES: 
********************************************************************************/

IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Account]
CREATE EXTERNAL TABLE [etl_medical].[Account]
WITH (
		LOCATION = 'etl_medical/Account',
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
	CONVERT(NVARCHAR(255), [src].[WellKnownAccountType]) AS [WellKnownAccountType],
	CONVERT(NVARCHAR(MAX), [src].[Category]) AS [Category],
	CONVERT(NVARCHAR(MAX), [src].[ReferenceId]) AS [ReferenceId],
	CONVERT(NVARCHAR(MAX), [src].[Description]) AS [Description],
	CONVERT(VARCHAR(255), [src].[CreatedByExternalDataId]) AS [CreatedByExternalDataId],
	CONVERT(VARCHAR(255), [src].[LastUpdatedByExternalDataId]) AS [LastUpdatedByExternalDataId],
	CONVERT(DATETIME, [src].[CreatedDttm]) AS [CreatedDttm],
	CONVERT(DATETIME, [src].[HoldDttm]) AS [HoldDttm],
	CONVERT(DATETIME, [src].[LastStatementDttm]) AS [LastStatementDttm],
	CONVERT(DATETIME, [src].[LastUpdatedDttm]) AS [LastUpdatedDttm],
	CONVERT(DATETIME, [src].[LastTransactionDttm]) AS [LastTransactionDttm],
	CONVERT(DECIMAL, [src].[LastStatementAmount]) AS [LastStatementAmount],
	CONVERT(DECIMAL, [src].[ThirtyDayBalanceInterval]) AS [ThirtyDayBalanceInterval],
	CONVERT(DECIMAL, [src].[SixtyDayBalanceInterval]) AS [SixtyDayBalanceInterval],
	CONVERT(DECIMAL, [src].[NinetyDayBalanceInterval]) AS [NinetyDayBalanceInterval],
	CONVERT(DECIMAL, [src].[CurrentBalance]) AS [CurrentBalance],
	CONVERT(DECIMAL, [src].[LastTransactionAmount]) AS [LastTransactionAmount]

FROM [etl_dbo].[Account] AS [src]
