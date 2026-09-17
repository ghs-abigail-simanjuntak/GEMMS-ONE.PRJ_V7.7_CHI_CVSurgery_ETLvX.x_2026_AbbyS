/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.PATIENTDEMOGRAPHICS
ITEM TYPE: RegistrationPhone
NOTES: Child registration phone rows linked to Registration by PatientID and version 1.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.RegistrationPhone
CREATE EXTERNAL TABLE etl_dbo.RegistrationPhone
WITH (
    LOCATION = 'etl_dbo/RegistrationPhone',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(pa.[PatientId], '|CELLPHONE|') AS [ExternalDataId],
    pa.[PatientID] AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    pd.[CPhone] AS [Number],
    'Cell' AS [Type],
    1 AS [IsPrimary],
    NULL AS [ExtendedProperties]
-- SELECT TOP(100)*
FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
    ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
AND NULLIF(pd.[CPHONE], '') IS NOT NULL

UNION

SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(pa.[PatientId], '|HOMEPHONE|') AS [ExternalDataId],
    pa.[PatientID] AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    pd.[HPhone] AS [Number],
    'Home' AS [Type],
    1 AS [IsPrimary],
    NULL AS [ExtendedProperties]
-- SELECT TOP(100)*
FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
    ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
AND NULLIF(pd.[HPHONE], '') IS NOT NULL

UNION

SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(pa.[PatientId], '|WORKPHONE|') AS [ExternalDataId],
    pa.[PatientID] AS [ItemExternalDataId],
    '1' AS [ItemExternalDataVersion],
    pd.[WPhone] AS [Number],
    'Work' AS [Type],
    1 AS [IsPrimary],
    NULL AS [ExtendedProperties]
-- SELECT TOP(100)*
FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
    ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
AND NULLIF(pd.[WPHONE], '') IS NOT NULL

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
