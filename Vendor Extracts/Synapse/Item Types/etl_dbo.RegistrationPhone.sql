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
WITH registration_base AS (
    SELECT
        pa.[PatientID] AS [ExternalDataId],
        '1' AS [ExternalDataVersion],
        pd.[HPHONE],
        pd.[CPHONE],
        pd.[WPHONE]
    FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
    LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
        ON pd.[PatientID] = pa.[PatientID]
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(rb.[ExternalDataId], '|PHONE|', UPPER(ph.[PhoneType])) AS [ExternalDataId],
    rb.[ExternalDataId] AS [ItemExternalDataId],
    rb.[ExternalDataVersion] AS [ItemExternalDataVersion],
    ph.[PhoneNumber] AS [Number],
    ph.[PhoneType] AS [Type],
    ph.[IsPrimary] AS [IsPrimary],
    NULL AS [ExtendedProperties]
FROM registration_base rb
CROSS APPLY (
    VALUES
        ('Home', rb.[HPHONE], CASE WHEN NULLIF(rb.[HPHONE], '') IS NOT NULL THEN 1 ELSE 0 END),
        ('Cell', rb.[CPHONE], CASE WHEN NULLIF(rb.[HPHONE], '') IS NULL AND NULLIF(rb.[CPHONE], '') IS NOT NULL THEN 1 ELSE 0 END),
        ('Work', rb.[WPHONE], CASE WHEN NULLIF(rb.[HPHONE], '') IS NULL AND NULLIF(rb.[CPHONE], '') IS NULL AND NULLIF(rb.[WPHONE], '') IS NOT NULL THEN 1 ELSE 0 END)
) ph([PhoneType], [PhoneNumber], [IsPrimary])
WHERE 1 = 1
--Functional
AND NULLIF(LTRIM(RTRIM(COALESCE(ph.[PhoneNumber], ''))), '') IS NOT NULL

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
