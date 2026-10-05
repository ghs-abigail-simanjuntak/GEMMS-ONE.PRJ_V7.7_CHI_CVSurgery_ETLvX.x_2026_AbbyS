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

WITH 
provider_credential_rollup AS (
    SELECT
        pc.[DOCTOR],
        STRING_AGG(NULLIF(LTRIM(RTRIM(pc.[CREDENTCODE])), ''), ', ') AS [Credentials],
        MAX(TRY_CAST(pc.[ENTRYDATE] AS datetime2)) AS [LastCredentialEntryDttm]
    FROM [files].[PROVIDERCREDENTIALS] pc
    WHERE NULLIF(LTRIM(RTRIM(COALESCE(pc.[DOCTOR], ''))), '') IS NOT NULL
    GROUP BY pc.[DOCTOR]
),
provider_base AS (
    SELECT
        p.[DOCTOR],
        p.[NAME1],
        p.[NAME2],
        p.[NAME3],
        p.[ADDRESS],
        p.[CITY],
        p.[STATE],
        p.[ZIP],
        p.[PHONE],
        p.[GROUPCODE],
        p.[RENDERING],
        p.[PROV],
        p.[FACILITY],
        p.[EMAIL],
        p.[USERCODE],
        p.[ENTRYDATE],
        cred.[Credentials],
        cred.[LastCredentialEntryDttm]
    FROM [files].[PROVIDERDOCTORCODEMASTER] p
    LEFT JOIN provider_credential_rollup cred
        ON cred.[DOCTOR] = p.[DOCTOR]
    WHERE NULLIF(LTRIM(RTRIM(COALESCE(p.[DOCTOR], ''))), '') IS NOT NULL
),
user_base AS (
    SELECT
        u.[USERID],
        u.[MAILNAME],
        u.[WORKGROUP],
        u.[ACTIVE],
        u.[FNAME],
        u.[LNAME]
    FROM [files].[USERS] u
    WHERE NULLIF(LTRIM(RTRIM(COALESCE(u.[USERID], ''))), '') IS NOT NULL
)
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

UNION ALL

SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('PROVIDER|', pr.[DOCTOR]) AS [ExternalDataId],
    CASE
        WHEN CHARINDEX(',', COALESCE(pr.[NAME2], '')) > 0 THEN LTRIM(RTRIM(SUBSTRING(pr.[NAME2], CHARINDEX(',', pr.[NAME2]) + 1, 4000)))
        WHEN CHARINDEX(' ', COALESCE(pr.[NAME3], '')) > 0 THEN LEFT(LTRIM(RTRIM(pr.[NAME3])), CHARINDEX(' ', LTRIM(RTRIM(pr.[NAME3]))) - 1)
        ELSE pr.[NAME3]
    END AS [FirstName],
    CASE
        WHEN CHARINDEX(',', COALESCE(pr.[NAME2], '')) > 0 THEN LTRIM(RTRIM(LEFT(pr.[NAME2], CHARINDEX(',', pr.[NAME2]) - 1)))
        WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(COALESCE(pr.[NAME3], ''))))) > 0 THEN RIGHT(LTRIM(RTRIM(pr.[NAME3])), CHARINDEX(' ', REVERSE(LTRIM(RTRIM(pr.[NAME3])))) - 1)
        ELSE pr.[NAME1]
    END AS [LastName],
    CAST(NULL AS VARCHAR(100)) AS [MiddleName],
    CAST(NULL AS VARCHAR(50)) AS [Prefix],
    CAST(NULL AS VARCHAR(50)) AS [Suffix],
    pr.[DOCTOR] AS [SourceSystemUserIdentifier],
    CAST(0 AS bit) AS [IsSourceSystemUser],
    pr.[Credentials] AS [Credentials],
    CAST(NULL AS VARCHAR(50)) AS [Npi],
    TRY_CAST(pr.[ENTRYDATE] AS datetime2) AS [ExternalDataCreatedDttm],
    COALESCE(pr.[LastCredentialEntryDttm], TRY_CAST(pr.[ENTRYDATE] AS datetime2)) AS [ExternalDataUpdatedDttm],
    CAST(NULL AS VARCHAR(4000)) AS [SignatureFilePath],
    CAST(NULL AS VARBINARY(MAX)) AS [SignatureBinaryContent],
    CONVERT(VARCHAR(8000),
        CONCAT(
            '{',
            '"recordType":"Provider",',
            '"providerDisplayName":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), pr.[NAME3]), CONVERT(VARCHAR(255), pr.[NAME2]), CONVERT(VARCHAR(255), pr.[NAME1]), ''), 'json'), '",',
            '"organization":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), pr.[NAME1]), ''), 'json'), '",',
            '"providerCode":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pr.[PROV]), ''), 'json'), '",',
            '"groupCode":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pr.[GROUPCODE]), ''), 'json'), '",',
            '"facility":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pr.[FACILITY]), ''), 'json'), '",',
            '"rendering":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(25), pr.[RENDERING]), ''), 'json'), '",',
            '"phone":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(50), pr.[PHONE]), ''), 'json'), '",',
            '"email":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), pr.[EMAIL]), ''), 'json'), '",',
            '"userCode":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pr.[USERCODE]), ''), 'json'), '",',
            '"address":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), pr.[ADDRESS]), ''), 'json'), '",',
            '"city":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pr.[CITY]), ''), 'json'), '",',
            '"state":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(50), pr.[STATE]), ''), 'json'), '",',
            '"zip":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(25), pr.[ZIP]), ''), 'json'), '"',
            '}'
        )
    ) AS [ExtendedProperties]
FROM provider_base pr
WHERE 1 = 1
--Functional
AND NULLIF(LTRIM(RTRIM(COALESCE(pr.[NAME1], pr.[NAME2], pr.[NAME3], ''))), '') IS NOT NULL

UNION ALL

SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('USER|', ub.[USERID]) AS [ExternalDataId],
    ub.[FNAME] AS [FirstName],
    ub.[LNAME] AS [LastName],
    CAST(NULL AS VARCHAR(100)) AS [MiddleName],
    CAST(NULL AS VARCHAR(50)) AS [Prefix],
    CAST(NULL AS VARCHAR(50)) AS [Suffix],
    ub.[USERID] AS [SourceSystemUserIdentifier],
    CAST(1 AS bit) AS [IsSourceSystemUser],
    CAST(NULL AS VARCHAR(255)) AS [Credentials],
    CAST(NULL AS VARCHAR(50)) AS [Npi],
    CAST(NULL AS datetime2) AS [ExternalDataCreatedDttm],
    CAST(NULL AS datetime2) AS [ExternalDataUpdatedDttm],
    CAST(NULL AS VARCHAR(4000)) AS [SignatureFilePath],
    CAST(NULL AS VARBINARY(MAX)) AS [SignatureBinaryContent],
    CONVERT(VARCHAR(8000),
        CONCAT(
            '{',
            '"recordType":"User",',
            '"mailName":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), ub.[MAILNAME]), ''), 'json'), '",',
            '"workgroup":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), ub.[WORKGROUP]), ''), 'json'), '",',
            '"active":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(10), ub.[ACTIVE]), ''), 'json'), '"',
            '}'
        )
    ) AS [ExtendedProperties]
FROM user_base ub
WHERE 1 = 1
--Functional
AND NULLIF(LTRIM(RTRIM(COALESCE(ub.[FNAME], ub.[LNAME], ub.[MAILNAME], ''))), '') IS NOT NULL

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)