/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: PersonAddress
NOTES: 
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.PersonAddress
CREATE EXTERNAL TABLE etl_dbo.PersonAddress
WITH (
    LOCATION = 'etl_dbo/PersonAddress',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
-- GUARANTOR
SELECT
	NEWID() AS Id,
	1 AS ItemSetId,
	'CHIGEMMS1CV' AS DataSourceCode,
	CONCAT('GUAR|', g.[PatientID], '|', COALESCE(g.[GLNAME], ''), '|', COALESCE(g.[GFNAME], ''), '|Address') AS ExternalDataId,
	CONCAT('GUAR|', g.[PatientID], '|', COALESCE(g.[GLNAME], ''), '|', COALESCE(g.[GFNAME], '')) AS ItemExternalDataId,
	LTRIM(RTRIM(g.[ADDRESS])) AS AddressLine1,
	NULL AS AddressLine2,
	g.[ZIP] AS PostalCode,
	g.[CITY] AS City,
	g.[STATE] AS StateCode,
	NULL AS CountryCode,
	1 AS IsPrimary
--SELECT TOP(100)*
FROM files.guarantor g
WHERE 1 = 1
AND NULLIF(LTRIM(RTRIM(g.[ADDRESS])), '') IS NOT NULL