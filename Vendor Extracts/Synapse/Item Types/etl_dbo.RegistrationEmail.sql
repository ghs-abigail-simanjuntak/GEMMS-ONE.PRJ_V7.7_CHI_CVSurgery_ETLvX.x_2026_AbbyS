/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.PATIENTDEMOGRAPHICS
ITEM TYPE: RegistrationEmail
NOTES: Child registration email rows linked to Registration by PatientID and version 1.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.RegistrationEmail
CREATE EXTERNAL TABLE etl_dbo.RegistrationEmail
WITH (
    LOCATION = 'etl_dbo/RegistrationEmail',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(pa.[PatientID], '|EMAIL|PRIMARY') AS [ExternalDataId],
    pa.[PatientID] AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    pd.[EMAIL] AS [Address],
    1 AS [IsPrimary],
    NULL AS [ExtendedProperties]
FROM [files].[PATIENTACCOUNT] pa
LEFT JOIN [files].[PATIENTDEMOGRAPHICS] pd
    ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
--Functional
AND NULLIF(LTRIM(RTRIM(COALESCE(pd.[EMAIL], ''))), '') IS NOT NULL

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
