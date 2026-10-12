/********************************************************************************
SCRIPT DEPENDENCIES: files.REPOSITORYFILE, files.REPOSITORYFILESPEC, files.REPOSITORYMASTERTYPE, GEMMSCV.files.PATIENTACCOUNT
ITEM TYPE: DocumentNonDiscrete
NOTES: Non-discrete document attachment rows reconstructed from repository document metadata and file specs.
    Manual documents matched directly to source MRNs and repository titles.
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[DocumentNonDiscrete]
-- select COUNT(*) from [etl_dbo].[DocumentNonDiscrete]
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
    CONVERT(varchar(255), rf.[PatientID]) AS [PatientExternalDataId],
    CONCAT('REPOSITORY|', CAST(rf.[RespositoryObjectID] AS varchar(100))) AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    1 AS [SequenceNumber],
    NULL AS [LogicalAttachmentNumber],
    NULL AS [ClassificationId],
    -- CONWAY azure blob path
    -- CONCAT('chi/chigemms1/nondiscrete/azrscclnapp1205.corp.commonspirit.org/conway full extract/clinicalrepository/', REPLACE(rfs.FOLDER,'E:\CV Full Extract\\',''), '/', rfs.ExportName) AS [AzureBlobPath],
    -- CONCAT('chi/chigemms1/nondiscrete/azrscclnapp1205.corp.commonspirit.org/cv full extract/clinicalrepository',
    -- CASE
    --     WHEN rfs.FOLDER IS NULL OR LTRIM(RTRIM(rfs.FOLDER)) = '' THEN ''
    --     ELSE CONCAT('/',LOWER(REPLACE(rfs.FOLDER,'E:\CV Full Extract\\','')))
    -- END,
    -- '/',rfs.ExportName) AS [AzureBlobPath],
    REPLACE(REPLACE(CONCAT(
    'chi/chigemms1/nondiscrete/azrscclnapp1205.corp.commonspirit.org/cv full extract/clinicalrepository',
    CASE
        WHEN NULLIF(
            LTRIM(RTRIM(REPLACE(rfs.FOLDER,'E:\CV Full Extract\','')))
        , '') IS NULL
        THEN ''
        ELSE CONCAT(
            '/',
            LOWER(REPLACE(rfs.FOLDER,'E:\CV Full Extract\',''))
        )
    END,
    '/',
    rfs.ExportName
    ), '\', ''), '//', '/') AS [AzureBlobPath],
    -- 'azrscclnapp1205.corp.commonspirit.org\cv full extract\clinicalrepository\' + REPLACE(rfs.FOLDER,'N:\CV Full Extract\\','') + '\' + rfs.ExportName AS [FilePath],
    CAST(NULL AS nvarchar(4000)) AS [FilePath],
    CAST(NULL AS nvarchar(max)) AS [Content],
    CAST(NULL AS varbinary(max)) AS [BinaryContent],
    CAST(NULL AS nvarchar(50)) AS [TemplateCode],
    CAST(NULL AS nvarchar(50)) AS [VcoTemplateCode],
    'CHIGEMMS1CV' AS [DataSourceCode]
-- SELECT COUNT(*)
FROM [files].[REPOSITORYFILE] rf
LEFT JOIN [files].[REPOSITORYFILESPEC] rfs
        ON rfs.[RespositoryObjectID] = rf.[RespositoryObjectID]
LEFT JOIN [files].[REPOSITORYMASTERTYPE] rmt
        ON rmt.[RepositoryTypeID] = rf.[RepositoryTypeID]
WHERE 1 = 1
AND NULLIF(LTRIM(RTRIM(COALESCE(rf.[PatientID], ''))), '') IS NOT NULL
AND NULLIF(LTRIM(RTRIM(COALESCE(rf.[RespositoryObjectID], ''))), '') IS NOT NULL
AND NULLIF(LTRIM(RTRIM(COALESCE(rfs.[ExportName], ''))), '') IS NOT NULL
-- Functional

-- Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
UNION ALL

SELECT
    NEWID() AS [Id],
    CONVERT(varchar(255), manual_rf.PatientID) AS [PatientExternalDataId],
    CONCAT('REPOSITORY|', CAST(manual_rf.RespositoryObjectID AS varchar(100))) AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    1 AS [SequenceNumber],
    CAST(NULL AS int) AS [LogicalAttachmentNumber],
    CAST(NULL AS int) AS [ClassificationId],
    CONVERT(nvarchar(1024), CONCAT(
        'chi/chigemms1/nondiscrete/azrscclnapp1205.corp.commonspirit.org/cv full extract/clinicalrepository/manual/',
        requested.Mrn, '_', manual_rmt.DocTypeName, '.pdf'
    )) AS [AzureBlobPath],
    NULL AS [FilePath],
    NULL AS [Content],
    NULL AS [BinaryContent],
    NULL AS [TemplateCode],
    NULL AS [VcoTemplateCode],
    'CHIGEMMS1CV' AS [DataSourceCode]
FROM OPENJSON(N'[
    {"mrn":"5019628","title":"Home Health"},
    {"mrn":"5027901","title":"Pathology"},
    {"mrn":"5027918","title":"Diagnostic - Cath"},
    {"mrn":"5027918","title":"Nurses Notes - Office"},
    {"mrn":"5027992","title":"Financial Policy Form"},
    {"mrn":"5027997","title":"Demographics"},
    {"mrn":"5027997","title":"Correspondence - Incoming"},
    {"mrn":"5028155","title":"Orders"},
    {"mrn":"5028155","title":"Laboratory Results - Scanned"},
    {"mrn":"5028155","title":"Transesophegeal Echo - TEE"},
    {"mrn":"5028189","title":"Patient Photograph"},
    {"mrn":"5028193","title":"Hepatobiliary"},
    {"mrn":"5028193","title":"Patient Photograph"},
    {"mrn":"5028232","title":"Insurance Card"},
    {"mrn":"5028235","title":"Insurance Card"},
    {"mrn":"5028241","title":"Chest Xray"},
    {"mrn":"5028244","title":"Insurance Card"},
    {"mrn":"5028244","title":"Patient Education"},
    {"mrn":"5028250","title":"Hospital Progress Notes"},
    {"mrn":"5028284","title":"Office - H and P"},
    {"mrn":"5028284","title":"Miscellaneous - Forms"},
    {"mrn":"5028284","title":"Hospital - H and P"},
    {"mrn":"5028373","title":"Patient Education"},
    {"mrn":"5028376","title":"Financial Policy Form"},
    {"mrn":"5029382","title":"Home Health"},
    {"mrn":"5029566","title":"Hospital Discharge Summary"},
    {"mrn":"5029580","title":"Patient Letters"},
    {"mrn":"5029589","title":"Pulmonary Functions"},
    {"mrn":"5029746","title":"Questionnaire"},
    {"mrn":"5029746","title":"HIPAA Contact Form"},
    {"mrn":"5029746","title":"Nurses Notes - Office"},
    {"mrn":"5029767","title":"Transesophegeal Echo - TEE"},
    {"mrn":"5029767","title":"Nurses Notes - Office"},
    {"mrn":"5029770","title":"Echocardiography Results"},
    {"mrn":"5029772","titlePrefix":"Pre Authorizations - Referral not"},
    {"mrn":"5029772","title":"Nurses Notes - Office"},
    {"mrn":"5029773","title":"Demographics"},
    {"mrn":"5029781","title":"Surgical Operative Reports"},
    {"mrn":"5029790","title":"Hospital - H and P"},
    {"mrn":"5029827","title":"Correspondence - Incoming"},
    {"mrn":"5029864","title":"Cardiology Consult"},
    {"mrn":"5032380","title":"Patient Education"}
]')
WITH (
    Mrn nvarchar(50) '$.mrn',
    Title nvarchar(255) '$.title',
    TitlePrefix nvarchar(255) '$.titlePrefix'
) AS requested
INNER JOIN [GEMMSCV].[files].[PATIENTACCOUNT] pa
    ON pa.MRN = requested.Mrn
INNER JOIN [files].[REPOSITORYFILE] manual_rf
    ON manual_rf.PatientID = pa.PatientID
INNER JOIN [files].[REPOSITORYMASTERTYPE] manual_rmt
    ON manual_rmt.RepositoryTypeID = manual_rf.RepositoryTypeID
    AND (
        manual_rmt.DocTypeName = requested.Title
        OR (requested.Title IS NULL AND manual_rmt.DocTypeName LIKE requested.TitlePrefix + '%')
    )
WHERE NULLIF(LTRIM(RTRIM(COALESCE(manual_rf.PatientID, ''))), '') IS NOT NULL
    AND NULLIF(LTRIM(RTRIM(COALESCE(manual_rf.RespositoryObjectID, ''))), '') IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM [files].[REPOSITORYFILESPEC] manual_rfs
        WHERE manual_rfs.RespositoryObjectID = manual_rf.RespositoryObjectID
            AND NULLIF(LTRIM(RTRIM(COALESCE(manual_rfs.ExportName, ''))), '') IS NOT NULL
    );