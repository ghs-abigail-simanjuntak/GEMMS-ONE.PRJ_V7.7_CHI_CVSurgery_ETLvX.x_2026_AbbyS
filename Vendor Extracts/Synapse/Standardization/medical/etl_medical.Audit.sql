/********************************************************************************  
SCRIPT DEPENDENCIES: etl_dbo.MedicalAudit.sql
ITEM TYPE: Audit
NOTES:  
SCALE:
********************************************************************************/

IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'medical')
	EXEC('CREATE SCHEMA [medical]')

--DROP EXTERNAL TABLE [medical].[Audit]
CREATE EXTERNAL TABLE [medical].[Audit]
WITH (
		LOCATION = 'medical/Audit',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT 
	CONVERT(UNIQUEIDENTIFIER, [src].[Id]) AS [Id],
	CONVERT(INT, [src].[ItemSetId]) AS [ItemSetId],
	CONVERT(VARCHAR(50), [src].[DataSourceCode]) AS [DataSourceCode],
	CONVERT(VARCHAR(255), [src].[ExternalDataId]) AS [ExternalDataId],
	CONVERT(VARCHAR(255), [src].[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(NVARCHAR(50), [src].[TypeCode]) AS [TypeCode],
	CONVERT(NVARCHAR(255), [src].[TypeName]) AS [TypeName],
	CONVERT(DATETIME, [src].[ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
	CONVERT(DATETIME, [src].[ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
	CONVERT(NVARCHAR(MAX), [src].[ExtendedProperties]) AS [ExtendedProperties],
	CONVERT(VARCHAR(255), [src].[ProviderExternalDataId]) AS [ProviderExternalDataId],
	CONVERT(DATETIME, [src].[AuditedDttm]) AS [AuditedDttm],
	CONVERT(VARCHAR(255), [src].[AuditedItemExternalDataId]) AS [AuditedItemExternalDataId],
	CONVERT(VARCHAR(255), [src].[AuditedItemExternalDataVersion]) AS [AuditedItemExternalDataVersion],
	CONVERT(NVARCHAR(50), [src].[AuditedItemVcoDataType]) AS [AuditedItemVcoDataType]

FROM [etl_ctas].[Audit_Medical] AS [src]
