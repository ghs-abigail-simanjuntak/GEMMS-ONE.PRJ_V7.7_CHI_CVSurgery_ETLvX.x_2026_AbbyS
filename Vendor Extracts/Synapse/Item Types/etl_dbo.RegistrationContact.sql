/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.PATIENTDEMOGRAPHICS, GEMMSCV.files.GUARANTOR
ITEM TYPE: RegistrationContact
NOTES: Child registration contact rows include emergency contact and guarantor contact evidence.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.RegistrationContact
CREATE EXTERNAL TABLE etl_dbo.RegistrationContact
WITH (
    LOCATION = 'etl_dbo/RegistrationContact',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
WITH registration_base AS (
    SELECT
        pa.[PatientID] AS [ExternalDataId],
        '1' AS [ExternalDataVersion],
        pd.[EMERGENCYCONTACT],
        pd.[EMERGENCYPHONE]
    FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
    LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
        ON pd.[PatientID] = pa.[PatientID]
), guarantor_base AS (
    SELECT
        pa.[PatientID] AS [ExternalDataId],
        '1' AS [ExternalDataVersion],
        g.[GLNAME],
        g.[GFNAME],
        g.[GMNAME],
        g.[GSSN],
        g.[ADDRESS],
        g.[CITY],
        g.[STATE],
        g.[ZIP],
        g.[PHONE]
    FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
    INNER JOIN GEMMSCV.[files].[GUARANTOR] g
        ON g.[PatientID] = pa.[PatientID]
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(rb.[ExternalDataId], '|CONTACT|EMERGENCY') AS [ExternalDataId],
    rb.[ExternalDataId] AS [ItemExternalDataId],
    rb.[ExternalDataVersion] AS [ItemExternalDataVersion],
    NULL AS [PersonExternalDataId],
    'Emergency' AS [Type],
    NULL AS [ExtendedProperties]
FROM registration_base rb
WHERE 1 = 1
--Functional
AND (
    NULLIF(LTRIM(RTRIM(COALESCE(rb.[EMERGENCYCONTACT], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(rb.[EMERGENCYPHONE], ''))), '') IS NOT NULL
)

UNION ALL

SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(gb.[ExternalDataId], '|CONTACT|GUARANTOR') AS [ExternalDataId],
    gb.[ExternalDataId] AS [ItemExternalDataId],
    gb.[ExternalDataVersion] AS [ItemExternalDataVersion],
    CONCAT('GUAR|', gb.[ExternalDataId], '|', COALESCE(gb.[GLNAME], ''), '|', COALESCE(gb.[GFNAME], '')) AS [PersonExternalDataId],
    'Guarantor' AS [Type],
    NULL AS [ExtendedProperties]
FROM guarantor_base gb
WHERE 1 = 1
--Functional
AND (
    NULLIF(LTRIM(RTRIM(COALESCE(gb.[GLNAME], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(gb.[GFNAME], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(gb.[PHONE], ''))), '') IS NOT NULL
)

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
