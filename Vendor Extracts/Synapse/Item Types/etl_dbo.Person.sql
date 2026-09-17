/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: Person
NOTES: 
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Person
CREATE EXTERNAL TABLE etl_dbo.Person
WITH (
    LOCATION = 'etl_dbo/Person',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
-- GUARANTOR
SELECT
	NEWID() AS Id,
	1 AS ItemSetId,
	'CHIGEMMS1CV' AS DataSourceCode,
	CONCAT('GUAR|', g.[PatientID], '|', COALESCE(g.[GLNAME], ''), '|', COALESCE(g.[GFNAME], '')) AS ExternalDataId,
    g.[GFNAME] AS FirstName,
	g.[GLNAME] AS LastName,
	g.[GMNAME] AS MiddleName,
	NULL AS Prefix,
	NULL AS Suffix,
	NULL AS SourceSystemUserIdentifier,
	NULL AS IsSourceSystemUser,
	NULL AS Credentials,
	NULL AS Npi,
	NULL AS ExternalDataCreatedDttm,
	NULL AS ExternalDataUpdatedDttm,
	NULL AS SignatureFilePath,
	NULL AS SignatureBinaryContent,
	NULL AS ExtendedProperties
--SELECT *
--SELECT TOP(100) * 
FROM [files].[GUARANTOR] g
WHERE 1 = 1
--Functional
AND (
    NULLIF(LTRIM(RTRIM(COALESCE(g.[GLNAME], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(g.[GFNAME], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(g.[GMNAME], ''))), '') IS NOT NULL
)

UNION

-- EMERGENCY
SELECT
	NEWID() AS Id,
	1 AS ItemSetId,
	'CHIGEMMS1CV' AS DataSourceCode,
	CONCAT('EMERGENCY|', pa.[PatientID], '|', COALESCE(pd.[EMERGENCYCONTACT], '')) AS ExternalDataId,
    pd.[EMERGENCYCONTACT] AS FirstName,
	NULL AS LastName,
	NULL AS MiddleName,
	NULL AS Prefix,
	NULL AS Suffix,
	NULL AS SourceSystemUserIdentifier,
	NULL AS IsSourceSystemUser,
	NULL AS Credentials,
	NULL AS Npi,
	NULL AS ExternalDataCreatedDttm,
	NULL AS ExternalDataUpdatedDttm,
	NULL AS SignatureFilePath,
	NULL AS SignatureBinaryContent,
	NULL AS ExtendedProperties
--SELECT *
--SELECT TOP(100) * 
FROM [files].[PATIENTACCOUNT] pa
LEFT JOIN [files].[PATIENTDEMOGRAPHICS] pd
     ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
--Functional
AND (
    NULLIF(LTRIM(RTRIM(COALESCE(pd.[EMERGENCYCONTACT], ''))), '') IS NOT NULL
    OR NULLIF(LTRIM(RTRIM(COALESCE(pd.[EMERGENCYPHONE], ''))), '') IS NOT NULL
)
