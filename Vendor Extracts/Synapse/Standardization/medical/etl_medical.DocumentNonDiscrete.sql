/********************************************************************************
SCRIPT DEPENDENCIES: etl_dbo.Document_EDM_ASS_ND.sql, etl_dbo.Document_EDM_CALL_ND.sql, etl_dbo.Document_EDM_ND.sql, etl_dbo.Document_EDM_NOTE_ND.sql, etl_dbo.Document_ITS_RAD_ND_Table.sql, etl_dbo.Document_ITS_MTDD_ND.sql, etl_dbo.DocumentND_RPT_Table.sql, etl_dbo.DocumentND_RPT_MTHCC_Table.sql
ITEM TYPE: DocumentNonDiscrete
NOTES: Combines DocumentNonDiscrete helper CETAS tables into medical.DocumentNonDiscrete
SCALE:
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[DocumentNonDiscrete]
CREATE EXTERNAL TABLE [etl_medical].[DocumentNonDiscrete]
WITH (
		LOCATION = 'etl_medical/DocumentNonDiscrete',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(uniqueidentifier,[src].[Id]) AS [Id],
	CONVERT(varchar(255),[src].[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(varchar(255),[src].[ItemExternalDataId]) COLLATE SQL_Latin1_General_CP1_CS_AS AS [ItemExternalDataId],
	CONVERT(varchar(255),[src].[ItemExternalDataVersion]) AS [ItemExternalDataVersion],
	CONVERT(int,[src].[SequenceNumber]) AS [SequenceNumber],
	CONVERT(int,[src].[LogicalAttachmentNumber]) AS [LogicalAttachmentNumber],
	CONVERT(int,[src].[ClassificationId]) AS [ClassificationId],
	CONVERT(nvarchar(1024),[src].[AzureBlobPath]) AS [AzureBlobPath],
	CONVERT(nvarchar(4000),[src].[FilePath]) AS [FilePath],
	CONVERT(nvarchar(MAX),[src].[Content]) AS [Content],
	CONVERT(varbinary(MAX),[src].[BinaryContent]) AS [BinaryContent],
	CONVERT(nvarchar(50),[src].[TemplateCode]) AS [TemplateCode],
	CONVERT(nvarchar(50),[src].[VcoTemplateCode]) AS [VcoTemplateCode],
	CONVERT(varchar(50),[src].[DataSourceCode]) AS [DataSourceCode]
FROM [etl_dbo].[DocumentNonDiscrete] as [src]