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
SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('Mrn_', CAST(pa.PatientID AS varchar(100))) AS [ExternalDataId],
    CAST(pa.PatientID AS varchar(100)) AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    'MRN' AS [Code],
    'MRN' AS [Name],
    CAST(pa.MRN AS varchar(100)) AS [Value],
    CAST(1 AS bit) AS [IsDefault],
    NULL AS [ExtendedProperties]
FROM files.patientaccount AS pa
WHERE 1 = 1
AND NULLIF(LTRIM(RTRIM(COALESCE(pa.[MRN], ''))), '') IS NOT NULL

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
