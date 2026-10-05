/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: PersonAddress
NOTES: 
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.PersonAddress
-- select top(100)* from etl_dbo.personaddress
CREATE EXTERNAL TABLE etl_dbo.PersonAddress
WITH (
    LOCATION = 'etl_dbo/PersonAddress',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 

WITH provider_address_base AS (
    SELECT
        p.[DOCTOR],
        p.[ADDRESS],
        p.[CITY],
        p.[STATE],
        p.[ZIP]
    FROM [files].[PROVIDERDOCTORCODEMASTER] p
    WHERE NULLIF(LTRIM(RTRIM(COALESCE(p.[DOCTOR], ''))), '') IS NOT NULL
)
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



UNION ALL

SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(
        'PROVIDERADDR|',
        prb.[DOCTOR],
        '|',
        COALESCE(
            NULLIF(prb.[ADDRESS], ''),
            NULLIF(prb.[ZIP], ''),
            NULLIF(prb.[CITY], ''),
            NULLIF(prb.[STATE], '')
        )
    ) AS [ExternalDataId],
    CONCAT('PROVIDER|', prb.[DOCTOR]) AS [ItemExternalDataId],
    prb.[ADDRESS] AS [AddressLine1],
    CAST(NULL AS VARCHAR(255)) AS [AddressLine2],
    prb.[ZIP] AS [PostalCode],
    prb.[CITY] AS [City],
    prb.[STATE] AS [StateCode],
    CAST(NULL AS VARCHAR(10)) AS [CountryCode],
    CAST(1 AS bit) AS [IsPrimary]
FROM provider_address_base prb
WHERE 1 = 1
-- Functional
AND COALESCE(
    NULLIF(prb.[ADDRESS], ''),
    NULLIF(prb.[ZIP], ''),
    NULLIF(prb.[CITY], ''),
    NULLIF(prb.[STATE], '')
) IS NOT NULL