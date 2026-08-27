/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PATIENTACCOUNT, GEMMSCV.files.PATIENTDEMOGRAPHICS
ITEM TYPE: RegistrationAddress
NOTES: Child registration address rows linked to Registration by PatientID and version 1.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.RegistrationAddress
CREATE EXTERNAL TABLE etl_dbo.RegistrationAddress
WITH (
    LOCATION = 'etl_dbo/RegistrationAddress',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
WITH registration_base AS (
    SELECT
        pa.[PatientID] AS [ExternalDataId],
        '1' AS [ExternalDataVersion],
        pd.[ADDRESS],
        pd.[CITY],
        pd.[STATE],
        pd.[ZIP]
    FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
    LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
        ON pd.[PatientID] = pa.[PatientID]
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(rb.[ExternalDataId], '|ADDRESS|PRIMARY') AS [ExternalDataId],
    rb.[ExternalDataId] AS [ItemExternalDataId],
    rb.[ExternalDataVersion] AS [ItemExternalDataVersion],
    rb.[ADDRESS] AS [AddressLine1],
    NULL AS [AddressLine2],
    rb.[ZIP] AS [PostalCode],
    rb.[CITY] AS [City],
    rb.[STATE] AS [StateCode],
    'US' AS [CountryCode],
    1 AS [IsPrimary],
    NULL AS [ExtendedProperties]
FROM registration_base rb
WHERE 1 = 1
--Functional
AND NULLIF(LTRIM(RTRIM(COALESCE(rb.[ADDRESS], ''))), '') IS NOT NULL

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
