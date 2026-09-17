/********************************************************************************
SCRIPT DEPENDENCIES:
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
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(pa.[PatientID], '|CONTACT|EMERGENCY') AS [ExternalDataId],
    pa.[PatientID] AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    CONCAT('EMERGENCY|', pa.[PatientID], '|', COALESCE(pd.[EMERGENCYCONTACT], '')) AS [PersonExternalDataId],
    'Emergency' AS [Type],
    NULL AS [ExtendedProperties]
-- SELECT TOP(100)*
FROM [files].[PATIENTACCOUNT] pa
LEFT JOIN [files].[PATIENTDEMOGRAPHICS] pd
     ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
--Functional
AND (
    NULLIF(LTRIM(RTRIM(COALESCE(pd.[EMERGENCYCONTACT], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(pd.[EMERGENCYPHONE], ''))), '') IS NOT NULL
)

UNION ALL

SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(pa.[PatientID], '|CONTACT|GUARANTOR') AS [ExternalDataId],
    pa.[PatientID] AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    CONCAT('GUAR|', pa.[PatientID], '|', COALESCE(g.[GLNAME], ''), '|', COALESCE(g.[GFNAME], '')) AS [PersonExternalDataId],
    'Guarantor' AS [Type],
    NULL AS [ExtendedProperties]
-- SELECT TOP(100)*
FROM [files].[PATIENTACCOUNT] pa
INNER JOIN [files].[GUARANTOR] g
    ON g.[PatientID] = pa.[PatientID]
WHERE 1 = 1
--Functional
AND (
    NULLIF(LTRIM(RTRIM(COALESCE(g.[GLNAME], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(g.[GFNAME], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(g.[GMNAME], ''))), '') IS NOT NULL
)

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
