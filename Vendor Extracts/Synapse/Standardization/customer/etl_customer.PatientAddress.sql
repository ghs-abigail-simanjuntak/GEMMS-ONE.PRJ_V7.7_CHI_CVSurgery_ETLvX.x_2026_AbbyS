/********************************************************************************
SSCRIPT DEPENDENCIES: 
etl_dbo.Registration 
etl_dbo.RegistrationAddress
ITEM TYPE: PatientAddress
NOTES: 
SCALE:
********************************************************************************/


/*
DROP EXTERNAL TABLE [etl_ctas].[PatientAddressCurrentVer]
DROP EXTERNAL TABLE [customer].[PatientAddress]
*/

--DROP EXTERNAL TABLE [etl_ctas].[PatientAddressCurrentVer]
CREATE EXTERNAL TABLE [etl_ctas].[PatientAddressCurrentVer]
WITH (
    LOCATION = 'etl_ctas/PatientAddressCurrentVer',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS

SELECT
    [r].[ExternalDataVersion],
    [r].[PatientExternalDataId],
    [r].[DataSourceCode],
    [r].[ExternalDataId],
    CONVERT(int, ROW_NUMBER() OVER (
        PARTITION BY [r].[DataSourceCode], [r].[ExternalDataId]
        ORDER BY [r].[DisplayOrder] DESC
    )) AS [rn]
FROM [etl_dbo].[Registration] AS [r]
INNER JOIN [etl_dbo].[RegistrationAddress] AS [ra]
    ON [r].[ExternalDataId] = [ra].[ItemExternalDataId]
    AND [r].[ExternalDataVersion] = [ra].[ItemExternalDataVersion]
    AND [r].[DataSourceCode] = [ra].[DataSourceCode]
WHERE 1 = 1

-----------------------------------------------------------------

IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[PatientAddress]
CREATE EXTERNAL TABLE [etl_customer].[PatientAddress]
WITH (
		LOCATION = 'etl_customer/PatientAddress',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(uniqueidentifier,[Id]) AS [Id],
	CONVERT(int,[ItemSetId]) AS [ItemSetId],
	CONVERT(varchar(50),[DataSourceCode]) AS [DataSourceCode],
	CONVERT(varchar(255),[ExternalDataId]) AS [ExternalDataId],
	CONVERT(varchar(255),[PatientExternalDataId]) AS [PatientExternalDataId],
	CONVERT(nvarchar(100),[AddressLine1]) AS [AddressLine1],
	CONVERT(nvarchar(100),[AddressLine2]) AS [AddressLine2],
	CONVERT(nvarchar(12),[PostalCode]) AS [PostalCode],
	CONVERT(nvarchar(150),[City]) AS [City],
	CONVERT(nvarchar(2),[StateCode]) AS [StateCode],
	CONVERT(nvarchar(2),[CountryCode]) AS [CountryCode],
	CONVERT(bit,[IsPrimary]) AS [IsPrimary],
	CONVERT(nvarchar(MAX),[ExtendedProperties]) AS [ExtendedProperties]

FROM (
    SELECT
        NEWID() AS [Id],
        [pr].[ItemSetId] AS [ItemSetId],
        [pr].[DataSourceCode] AS [DataSourceCode],
        [pr].[ExternalDataId] AS [ExternalDataId],
        [cv].[PatientExternalDataId] AS [PatientExternalDataId],
        [pr].[AddressLine1] AS [AddressLine1],
        [pr].[AddressLine2] AS [AddressLine2],
        [pr].[PostalCode] AS [PostalCode],
        [pr].[City] AS [City],
        [pr].[StateCode] AS [StateCode],
        [pr].[CountryCode] AS [CountryCode],
        [pr].[IsPrimary] AS [IsPrimary],
        [pr].[ExtendedProperties] AS [ExtendedProperties]
    FROM [etl_dbo].[RegistrationAddress] AS [pr]
    INNER JOIN [etl_ctas].[PatientAddressCurrentVer] AS [cv]
        ON [cv].[ExternalDataId] = [pr].[ItemExternalDataId]
        AND [cv].[ExternalDataVersion] = [pr].[ItemExternalDataVersion]
        AND [cv].[DataSourceCode] = [pr].[DataSourceCode]
        AND [cv].[rn] = 1
    WHERE 1 = 1
) AS [src]
