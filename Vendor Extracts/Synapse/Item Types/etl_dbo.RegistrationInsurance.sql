/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.INSURANCE
ITEM TYPE: RegistrationInsurance
NOTES: Child registration insurance rows linked to Registration by PatientID and version 1.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.RegistrationInsurance
CREATE EXTERNAL TABLE etl_dbo.RegistrationInsurance
WITH (
    LOCATION = 'etl_dbo/RegistrationInsurance',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
WITH registration_base AS (
    SELECT
        pa.[PatientID] AS [ExternalDataId],
        '1' AS [ExternalDataVersion]
    FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(rb.[ExternalDataId], '|REGINS|', COALESCE(ins.[INUM], ''), '|', COALESCE(ins.[INSCODE], ''), '|', COALESCE(ins.[POLICYNO], '')) AS [ExternalDataId],
    rb.[ExternalDataId] AS [ItemExternalDataId],
    rb.[ExternalDataVersion] AS [ItemExternalDataVersion],
    CONCAT(COALESCE(ins.[PatientID], ''), '|', COALESCE(ins.[INUM], ''), '|', COALESCE(ins.[INSCODE], ''), '|', COALESCE(ins.[POLICYNO], '')) AS [InsuranceExternalDataId],
    CASE ins.[INUM]
        WHEN 1 THEN 'Primary'
        WHEN 2 THEN 'Secondary'
        WHEN 3 THEN 'Tertiary'
        WHEN 4 THEN 'Quaternary'
        WHEN 5 THEN 'Quinary'
        WHEN 6 THEN 'Senary'
        ELSE 'Other'
    END AS [Priority],
    NULL AS [ExtendedProperties]
FROM registration_base rb
INNER JOIN GEMMSCV.[files].[INSURANCE] ins
    ON ins.[PatientID] = rb.[ExternalDataId]
WHERE 1 = 1
--Functional

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
