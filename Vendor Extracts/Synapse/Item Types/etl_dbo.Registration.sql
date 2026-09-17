/********************************************************************************
SCRIPT DEPENDENCIES: 
ITEM TYPE: Registration
NOTES: Parent registration item sourced from PATIENTACCOUNT with PATIENTDEMOGRAPHICS enrichment.
SCALE:      
********************************************************************************/
 
-- DROP EXTERNAL TABLE etl_dbo.Registration
CREATE EXTERNAL TABLE etl_dbo.Registration
WITH (
    LOCATION = 'etl_dbo/Registration',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    pa.[PatientID] AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    pa.[PatientID] AS [PatientExternalDataId],
    NULLIF(pa.[DOB], '') AS [ClinicallyRelevantDttm],
    0 AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    CASE
        WHEN NULLIF(LTRIM(RTRIM(pd.[DECEASED])), '') IS NOT NULL AND LTRIM(RTRIM(pd.[DECEASED])) NOT IN ('0', 'N', 'No') THEN 'Deceased'
        ELSE NULL
    END AS [Status],
    NULL AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    CONVERT(VARCHAR(8000),
        CONCAT(
            '{',
            '"patientAccountNumber":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pa.ACCOUNT), ''), 'json'), '",',
            '"nickname":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pd.NICKNAME), ''), 'json'), '",',
            '"salutation":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pd.SALUTATION), ''), 'json'), '",',
            '"patientType":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pd.PTYPE), ''), 'json'), '",',
            '"feeType":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(100), pd.FEETYPE), ''), 'json'), '",',
            '"birthTime":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(50), pd.BIRTHTIME), ''), 'json'), '",',
            '"emergencyContact":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(255), pd.EMERGENCYCONTACT), ''), 'json'), '",',
            '"emergencyPhone":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(50), pd.EMERGENCYPHONE), ''), 'json'), '",',
            '"dateOfDeath":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(23), TRY_CAST(pd.DECEASED AS datetime2), 121), ''), 'json'), '",',
            '"causeOfDeath":"', STRING_ESCAPE(COALESCE(CONVERT(VARCHAR(2000), pd.DEATHREASON), ''), 'json'), '"',
            '}'
        )
    ) AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    NULLIF(pd.[LASTVISIT], '') AS [RecordedDttm],
    pa.[MRN] AS [MedicalRecordNumber],
    pa.[PLNAME] AS [LastName],
    pa.[PMNAME] AS [MiddleName],
    pa.[PFNAME] AS [FirstName],
    NULLIF(pa.[DOB], '') AS [DateOfBirth],
    pa.[SSN] AS [Ssn],
    pa.[SEX] AS [Gender],
    pd.[ETHNIC] AS [Ethnicity],
    pd.[LANGUAGE] AS [PrimaryLanguage],
    NULL AS [SecondaryLanguage],
    pd.[RACE] AS [Race],
    NULL AS [GuarantorExternalDataId],
    NULL AS [GuarantorPatientRelationship],
    NULL AS [Comment],
    CASE
        WHEN NULLIF(LTRIM(RTRIM(pd.[DECEASED])), '') IS NOT NULL AND LTRIM(RTRIM(pd.[DECEASED])) NOT IN ('0', 'N', 'No') THEN 1
        ELSE 0
    END AS [IsDeceased],
    CASE pd.[MARITAL]
        WHEN 'M' THEN 'Married'
        WHEN 'S' THEN 'Single'
        WHEN 'D' THEN 'Divorced'
        WHEN 'X' THEN 'Separated'
        WHEN 'W' THEN 'Widowed'
        WHEN 'U' THEN 'Unknown'
        ELSE pd.[MARITAL]
    END AS [MaritalStatus],
    pd.[SALUTATION] AS [Prefix],
    NULL AS [Suffix],
    NULL AS [MedicareId],
    pd.[RELIGION] AS [Religion],
    NULL AS [Occupation],
    NULL AS [PcpExternalDataId],
    NULL AS [ReferringExternalDataId],
    NULL AS [CreatedByExternalDataId],
    NULL AS [LastUpdatedByExternalDataId]
FROM GEMMSCV.[files].[PATIENTACCOUNT] pa
LEFT JOIN GEMMSCV.[files].[PATIENTDEMOGRAPHICS] pd
    ON pd.[PatientID] = pa.[PatientID]
WHERE 1 = 1
--Functional

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
