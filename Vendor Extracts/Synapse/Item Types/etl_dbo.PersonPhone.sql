/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: PersonPhone
NOTES: 
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.PersonPhone
CREATE EXTERNAL TABLE etl_dbo.PersonPhone
WITH (
    LOCATION = 'etl_dbo/PersonPhone',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
	NEWID() AS Id,
	1 AS ItemSetId,
	'CHIGEMMS1CV' AS DataSourceCode,
	CONCAT('GUAR|', g.[PatientID], '|', COALESCE(g.[GLNAME], ''), '|', COALESCE(g.[GFNAME], ''), '|Phone') AS ExternalDataId,
	CONCAT('GUAR|', g.[PatientID], '|', COALESCE(g.[GLNAME], ''), '|', COALESCE(g.[GFNAME], '')) AS ItemExternalDataId,
	'Cell' AS Type,
	CAST(g.[PHONE] AS VARCHAR(50)) AS Number,
	1 AS IsPrimary
-- SELECT TOP(100)*
FROM [files].[GUARANTOR] g
WHERE 1 = 1
--Functional
AND (
    NULLIF(LTRIM(RTRIM(COALESCE(g.[GLNAME], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(g.[GFNAME], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(g.[GMNAME], ''))), '') IS NOT NULL
)
AND g.phone IS NOT NULL

UNION

SELECT
	NEWID() AS Id,
	1 AS ItemSetId,
	'CHIGEMMS1CV' AS DataSourceCode,
	CONCAT('EMERGENCY|', pa.[PatientID], '|', COALESCE(pd.[EMERGENCYCONTACT], ''), '|Phone') AS ExternalDataId,
	CONCAT('EMERGENCY|', pa.[PatientID], '|', COALESCE(pd.[EMERGENCYCONTACT], '')) AS ItemExternalDataId,
	'Cell' AS Type,
	CAST(pd.[EMERGENCYPHONE] AS VARCHAR(50)) AS Number,
	1 AS IsPrimary          
-- SELECT TOP(100)*
FROM [files].[PATIENTACCOUNT] pa
LEFT JOIN [files].[PATIENTDEMOGRAPHICS] pd
     ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
--Functional
AND  NULLIF(LTRIM(RTRIM(COALESCE(pd.[EMERGENCYCONTACT], ''))), '') IS NOT NULL
AND NULLIF(LTRIM(RTRIM(COALESCE(pd.[EMERGENCYPHONE], ''))), '') IS NOT NULL