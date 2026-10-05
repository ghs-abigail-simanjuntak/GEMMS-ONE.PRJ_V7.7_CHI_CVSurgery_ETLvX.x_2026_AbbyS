/********************************************************************************
SCRIPT DEPENDENCIES: files.REPOSITORYFILE, files.REPOSITORYFILESPEC, files.REPOSITORYMASTERTYPE
ITEM TYPE: Document
NOTES: Document rows reconstructed from repository document metadata and file specs.
SCALE:
********************************************************************************/

-- DROP EXTERNAL TABLE [etl_dbo].[Document]
CREATE EXTERNAL TABLE [etl_dbo].[Document]
WITH
(
    LOCATION = 'etl_dbo/Document',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS
SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('REPOSITORY|', CAST(rf.[RespositoryObjectID] AS varchar(100))) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    rf.[PatientID] AS [PatientExternalDataId],
    COALESCE(CONVERT(varchar(23), CAST(rf.[CreateDate] AS datetime)+ CAST(rf.[CreateTime] AS datetime),121),rf.[SVCDATE] ) AS [ClinicallyRelevantDttm],
    'Document' AS [TypeCode],
    'Document' AS [TypeName],
    NULL AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    rf.[STATUS] AS [Status],
    rmt.[DocTypeName] AS [Title],
    NULL AS [IsSecure],
    NULL AS [VcoSetEntries],
    CONVERT(VARCHAR(4000),
        CONCAT(
            '{',
            '"repositoryObjectId":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), rf.[RespositoryObjectID]), ''), 'json'), '",',
            '"folder":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(2000), rfs.[FOLDER]), ''), 'json'), '",',
            '"exportName":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), rfs.[ExportName]), ''), 'json'), '",',
            '"docTypeName":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), rmt.[DocTypeName]), ''), 'json'), '",',
            '"chartDisplayName":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), rmt.[ChartDisplayName]), ''), 'json'), '",',
            '"createdDate":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(23), TRY_CAST(rf.[CREATEDATE] AS datetime2), 121), ''), 'json'), '",',
            '"serviceDate":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(23), TRY_CAST(rf.[SVCDATE] AS datetime2), 121), ''), 'json'), '",',
            '"changedDate":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(23), TRY_CAST(rf.[CHGDATE] AS datetime2), 121), ''), 'json'), '",',
            '"flagDate":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(23), TRY_CAST(rf.[FLAGDATE] AS datetime2), 121), ''), 'json'), '",',
            '"prov":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), rf.[PROV]), ''), 'json'), '",',
            '"prov2":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), rf.[PROV2]), ''), 'json'), '",',
            '"provsup":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), rf.[PROVSUP]), ''), 'json'), '"',
            '}'
        )
    ) AS [ExtendedProperties],
    TRY_CAST(rf.[SVCDATE] AS datetime2) AS [ServiceDttm],
    TRY_CAST(rf.[CREATEDATE] AS datetime2) AS [RecordedDttm],
    NULL AS [AuthoredDttm],
    NULL AS [OwningPersonExternalDataId],
    NULL AS [RecordingPersonExternalDataId],
    NULL AS [AuthoringProviderExternalDataId],
    CASE
        WHEN NULLIF(CAST(COALESCE(rf.[PROVSUP], rf.[PROV2], rf.[PROV]) AS varchar(100)), '') IS NOT NULL THEN CONCAT('USER|', CAST(COALESCE(rf.[PROVSUP], rf.[PROV2], rf.[PROV]) AS varchar(100)))
        ELSE NULL
    END AS [LastUpdatingProviderExternalDataId],
    NULL AS [EncounterExternalDataId]
-- SELECT TOP(100) rmt.*
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