/********************************************************************************
SCRIPT DEPENDENCIES: 
etl_dbo.Registration, 
etl_dbo.RegistrationIdentifier
ITEM TYPE: PatientIdentifier
NOTES: 
SCALE:
********************************************************************************/


/*
DROP EXTERNAL TABLE [etl_ctas].[PatientIdentifierCurrentVer]
DROP EXTERNAL TABLE [customer].[PatientIdentifier]
*/


--DROP EXTERNAL TABLE [etl_ctas].[PatientIdentifierCurrentVer]
CREATE EXTERNAL TABLE [etl_ctas].[PatientIdentifierCurrentVer]
WITH (
    LOCATION = 'etl_ctas/PatientIdentifierCurrentVer',
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
INNER JOIN [etl_dbo].[RegistrationIdentifier] AS [ri]
    ON [r].[ExternalDataId] = [ri].[ItemExternalDataId]
    AND [r].[ExternalDataVersion] = [ri].[ItemExternalDataVersion]
    AND [r].[DataSourceCode] = [ri].[DataSourceCode]
WHERE 1 = 1

-----------------------------------------------------------------

IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[PatientIdentifier]
CREATE EXTERNAL TABLE [etl_customer].[PatientIdentifier]
WITH (
		LOCATION = 'etl_customer/PatientIdentifier',
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
    CONVERT(NVARCHAR(50),[Code]) AS [Code],
    CONVERT(NVARCHAR(255),[Name]) AS [Name],
    CONVERT(NVARCHAR(40),[Value]) AS [Value],
    CONVERT(BIT,[IsDefault]) AS [IsDefault],
    CONVERT(NVARCHAR(MAX),[ExtendedProperties]) AS [ExtendedProperties]

FROM (
    SELECT
        NEWID() AS [Id],
        [pr].[ItemSetId] AS [ItemSetId],
        [pr].[DataSourceCode] AS [DataSourceCode],
        [pr].[ExternalDataId] AS [ExternalDataId],
        [cv].[PatientExternalDataId] AS [PatientExternalDataId],
        [pr].[Code] AS [Code],
        [pr].[Name] AS [Name],
        [pr].[Value] AS [Value],
        [pr].[IsDefault] AS [IsDefault],
        [pr].[ExtendedProperties] AS [ExtendedProperties]
    FROM [etl_dbo].[RegistrationIdentifier] AS [pr]
    INNER JOIN [etl_ctas].[PatientIdentifierCurrentVer] AS [cv]
        ON [cv].[ExternalDataId] = [pr].[ItemExternalDataId]
        AND [cv].[ExternalDataVersion] = [pr].[ItemExternalDataVersion]
        AND [cv].[DataSourceCode] = [pr].[DataSourceCode]
        AND [cv].[rn] = 1
    WHERE 1 = 1
) AS [src]