/********************************************************************************
SCRIPT DEPENDENCIES:
etl_dbo.Registration and etl_dbo.RegistrationEmail
ITEM TYPE: PatientEmail
NOTES: 
SCALE:
********************************************************************************/


--DROP EXTERNAL TABLE [etl_ctas].[PatientEmailCurrentVer]
CREATE EXTERNAL TABLE [etl_ctas].[PatientEmailCurrentVer]
WITH (
    LOCATION = 'etl_ctas/PatientEmailCurrentVer',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS

SELECT
    [r].[ExternalDataVersion],
    [r].[PatientExternalDataId],
    [r].[DataSourceCode],
    [r].[ExternalDataId],
    CONVERT(INT, ROW_NUMBER() OVER (
        PARTITION BY [r].[DataSourceCode], [r].[ExternalDataId]
        ORDER BY [r].[DisplayOrder] DESC
    )) AS [rn]
FROM [etl_dbo].[Registration] AS [r]
INNER JOIN [etl_dbo].[RegistrationEmail] AS [re]
    ON [r].[ExternalDataId] = [re].[ItemExternalDataId]
    AND [r].[ExternalDataVersion] = [re].[ItemExternalDataVersion]
    AND [r].[DataSourceCode] = [re].[DataSourceCode]
WHERE 1 = 1

-----------------------------------------------------------------

IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[PatientEmail]
CREATE EXTERNAL TABLE [etl_customer].[PatientEmail]
WITH (
		LOCATION = 'etl_customer/PatientEmail',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(UNIQUEIDENTIFIER,[Id]) AS [Id],
	CONVERT(INT,[ItemSetId]) AS [ItemSetId],
	CONVERT(VARCHAR(50),[DataSourceCode]) AS [DataSourceCode],
	CONVERT(VARCHAR(255),[ExternalDataId]) AS [ExternalDataId],
	CONVERT(VARCHAR(255),[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(NVARCHAR(254),[Address]) AS [Address],
	CONVERT(BIT,[IsPrimary]) AS [IsPrimary],
	CONVERT(NVARCHAR(MAX),[ExtendedProperties]) AS [ExtendedProperties]

FROM (
    SELECT
        NEWID() AS [Id],
        [pr].[ItemSetId] AS [ItemSetId],
        [pr].[DataSourceCode] AS [DataSourceCode],
        [pr].[ExternalDataId] AS [ExternalDataId],
        [cv].[PatientExternalDataId] AS [PatientExternalDataId],
        [pr].[Address] AS [Address],
        [pr].[IsPrimary] AS [IsPrimary],
        [pr].[ExtendedProperties] AS [ExtendedProperties]
    FROM [etl_dbo].[RegistrationEmail] AS [pr]
    INNER JOIN [etl_ctas].[PatientEmailCurrentVer] AS [cv]
        ON [cv].[ExternalDataId] = [pr].[ItemExternalDataId]
        AND [cv].[ExternalDataVersion] = [pr].[ItemExternalDataVersion]
        AND [cv].[DataSourceCode] = [pr].[DataSourceCode]
        AND [cv].[rn] = 1
    WHERE 1 = 1
) AS [src]
