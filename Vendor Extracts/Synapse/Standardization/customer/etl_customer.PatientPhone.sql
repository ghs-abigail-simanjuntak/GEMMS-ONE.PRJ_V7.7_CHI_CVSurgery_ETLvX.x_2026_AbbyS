/********************************************************************************
SCRIPT DEPENDENCIES: etl_medical.Registration, etl_medical.RegistrationPhone
ITEM TYPE: PatientPhone
NOTES: 
SCALE:
********************************************************************************/


--DROP EXTERNAL TABLE [etl_ctas].[PatientPhoneCurrentVer]
CREATE EXTERNAL TABLE [etl_ctas].[PatientPhoneCurrentVer]
WITH (
    LOCATION = 'etl_ctas/PatientPhoneCurrentVer',
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
INNER JOIN [etl_dbo].[RegistrationPhone] AS [rp]
    ON [r].[ExternalDataId] = [rp].[ItemExternalDataId]
    AND [r].[ExternalDataVersion] = [rp].[ItemExternalDataVersion]
    AND [r].[DataSourceCode] = [rp].[DataSourceCode]
WHERE 1 = 1

-----------------------------------------------------------------

IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'customer')
	EXEC('CREATE SCHEMA [customer]')

--DROP EXTERNAL TABLE [customer].[PatientPhone]
CREATE EXTERNAL TABLE [customer].[PatientPhone]
WITH (
		LOCATION = 'customer/PatientPhone',
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
    CONVERT(NVARCHAR(50),[Number]) AS [Number],
    CONVERT(NVARCHAR(10),[Type]) AS [Type],
    CONVERT(BIT,[IsPrimary]) AS [IsPrimary],
    CONVERT(NVARCHAR(MAX),[ExtendedProperties]) AS [ExtendedProperties]

FROM (
    SELECT
        NEWID() AS [Id],
        [pr].[ItemSetId] AS [ItemSetId],
        [pr].[DataSourceCode] AS [DataSourceCode],
        [pr].[ExternalDataId] AS [ExternalDataId],
        [cv].[PatientExternalDataId] AS [PatientExternalDataId],
        [pr].[Number] AS [Number],
        [pr].[Type] AS [Type],
        [pr].[IsPrimary] AS [IsPrimary],
        [pr].[ExtendedProperties] AS [ExtendedProperties]
    FROM [etl_dbo].[RegistrationPhone] AS [pr]
    INNER JOIN [etl_ctas].[PatientPhoneCurrentVer] AS [cv]
        ON [cv].[ExternalDataId] = [pr].[ItemExternalDataId]
        AND [cv].[DataSourceCode] = [pr].[DataSourceCode]
        AND [cv].[ExternalDataVersion] = [pr].[ItemExternalDataVersion]
        AND [cv].[rn] = 1
    WHERE 1 = 1
) AS [src]
