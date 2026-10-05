/********************************************************************************
SCRIPT DEPENDENCIES: files.REPOSITORYFILE, files.REPOSITORYFILESPEC, files.REPOSITORYMASTERTYPE
ITEM TYPE: DocumentNonDiscrete
NOTES: Non-discrete document attachment rows reconstructed from repository document metadata and file specs.
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[DocumentNonDiscrete]
CREATE EXTERNAL TABLE [etl_dbo].[DocumentNonDiscrete]
WITH
(
    LOCATION = 'etl_dbo/DocumentNonDiscrete',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS
SELECT
    NEWID() AS [Id],
    rf.[PatientID] AS [PatientExternalDataId],
    CONCAT('REPOSITORY|', CAST(rf.[RespositoryObjectID] AS varchar(100))) AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    NULL AS [SequenceNumber],
    NULL AS [LogicalAttachmentNumber],
    NULL AS [ClassificationId],
    -- CONWAY azure blob path
    -- CONCAT('chi/chigemms1/nondiscrete/azrscclnapp1205.corp.commonspirit.org/conway full extract/clinicalrepository/', REPLACE(rfs.FOLDER,'E:\CV Full Extract\\',''), '/', rfs.ExportName) AS [AzureBlobPath],
    CONCAT('chi/chigemms1/nondiscrete/azrscclnapp1205.corp.commonspirit.org/cv full extract/clinicalrepository/', REPLACE(rfs.FOLDER,'E:\CV Full Extract\\',''), '/', rfs.ExportName) AS [AzureBlobPath],
    -- 'azrscclnapp1205.corp.commonspirit.org\cv full extract\clinicalrepository\' + REPLACE(rfs.FOLDER,'N:\CV Full Extract\\','') + '\' + rfs.ExportName AS [FilePath],
    NULL AS [FilePath],
    NULL AS [Content],
    NULL AS [BinaryContent],
    NULL AS [TemplateCode],
    NULL AS [VcoTemplateCode],
    'CHIGEMMS1CV' AS [DataSourceCode]
-- SELECT TOP(100)*
FROM [files].[REPOSITORYFILE] rf
LEFT JOIN [files].[REPOSITORYFILESPEC] rfs
        ON rfs.[RespositoryObjectID] = rf.[RespositoryObjectID]
LEFT JOIN [files].[REPOSITORYMASTERTYPE] rmt
        ON rmt.[RepositoryTypeID] = rf.[RepositoryTypeID]
WHERE 1 = 1
AND NULLIF(LTRIM(RTRIM(COALESCE(rf.[PatientID], ''))), '') IS NOT NULL
AND NULLIF(LTRIM(RTRIM(COALESCE(rf.[RespositoryObjectID], ''))), '') IS NOT NULL

-- Functional

-- Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
