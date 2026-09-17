/********************************************************************************
SCRIPT DEPENDENCIES:
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
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('address_',pa.[PatientID]) AS [ExternalDataId],
    pa.[PatientID] AS [ItemExternalDataId],
    '1'  AS [ItemExternalDataVersion],
    pd.[ADDRESS] AS [AddressLine1],
    NULL AS [AddressLine2],
    pd.[ZIP] AS [PostalCode],
    pd.[CITY] AS [City],
    pd.[STATE] AS [StateCode],
    'US' AS [CountryCode],
    1 AS [IsPrimary],
    NULL AS [ExtendedProperties]
-- SELECT TOP(100)*
FROM [files].[PATIENTACCOUNT] pa
LEFT JOIN [files].[PATIENTDEMOGRAPHICS] pd
     ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
--Functional
AND NULLIF(LTRIM(RTRIM(COALESCE(pd.[ADDRESS], ''))), '') IS NOT NULL

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
