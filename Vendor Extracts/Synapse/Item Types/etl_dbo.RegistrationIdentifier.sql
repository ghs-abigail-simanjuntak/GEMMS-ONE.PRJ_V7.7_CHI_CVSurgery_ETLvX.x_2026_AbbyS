/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT
ITEM TYPE: RegistrationIdentifier
NOTES: Child registration identifier rows provide PatientID, account number, and MRN values.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.RegistrationIdentifier
CREATE EXTERNAL TABLE etl_dbo.RegistrationIdentifier
WITH (
    LOCATION = 'etl_dbo/RegistrationIdentifier',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
WITH registration_base AS (
    SELECT
        pa.[PatientID] AS [ExternalDataId],
        '1' AS [ExternalDataVersion],
        pa.[ACCOUNT],
        pa.[MRN]
    FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
), identifier_rows AS (
    SELECT
        rb.[ExternalDataId],
        rb.[ExternalDataVersion],
        'PATIENTID' AS [Code],
        'Legacy Patient Id' AS [Name],
        rb.[ExternalDataId] AS [Value],
        0 AS [IsDefault]
    FROM registration_base rb

    UNION ALL

    SELECT
        rb.[ExternalDataId],
        rb.[ExternalDataVersion],
        'ACCOUNT' AS [Code],
        'Chart Number' AS [Name],
        rb.[ACCOUNT] AS [Value],
        0 AS [IsDefault]
    FROM registration_base rb
    WHERE NULLIF(LTRIM(RTRIM(COALESCE(rb.[ACCOUNT], ''))), '') IS NOT NULL

    UNION ALL

    SELECT
        rb.[ExternalDataId],
        rb.[ExternalDataVersion],
        'MRN' AS [Code],
        'Medical Record Number' AS [Name],
        rb.[MRN] AS [Value],
        1 AS [IsDefault]
    FROM registration_base rb
    WHERE NULLIF(LTRIM(RTRIM(COALESCE(rb.[MRN], ''))), '') IS NOT NULL
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(ir.[ExternalDataId], '|IDENT|', ir.[Code]) AS [ExternalDataId],
    ir.[ExternalDataId] AS [ItemExternalDataId],
    ir.[ExternalDataVersion] AS [ItemExternalDataVersion],
    ir.[Code] AS [Code],
    ir.[Name] AS [Name],
    ir.[Value] AS [Value],
    ir.[IsDefault] AS [IsDefault],
    NULL AS [ExtendedProperties]
FROM identifier_rows ir
WHERE 1 = 1
--Functional

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
