/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: Insurance
NOTES: 
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Insurance
CREATE EXTERNAL TABLE etl_dbo.Insurance
WITH (
    LOCATION = 'etl_dbo/Insurance',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    1 AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(i.[PatientID], '|', COALESCE(i.[INUM], ''), '|', COALESCE(i.[INSCODE], ''), '|', COALESCE(i.[POLICYNO], ''))  AS [ExternalDataId],
    i.[PatientId] AS [PatientExternalDataId],
    NULL AS [PayorExternalDataId],
    im.[Name] AS [Name],
    CONVERT(VARCHAR(8000),
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
            '{
                "lastName":"",
                "firstName":"",
                "middleName":"",
                "address":"",
                "city":"",
                "state":"",
                "zip":"",
                "phone":"",
                "dob":"",
                "sex":"",
                "group":"",
                "policyNumber":"",
                "insuranceCode":"",
                "insurancePlan":"",
                "claim":"",
                "relation":"",
                "otherInsurance":"",
                "coverageFrom":"",
                "coverageTo":"",
                "adjustor":"",
                "adjustorPhone":"",
                "billNote":"",
                "termDate":"",
                "special":"",
                "employer":"",
                "isPrimary":"",
                "secondary":"",
                "coverageType":"",
                "form":"",
                "remark":"",
                "userCode":"",
                "entered":"",
                "suffix":"",
                "country":"",
                "address2":"",
                "insuranceMasterCode":"",
                "insuranceMasterName":"",
                "insuranceMasterAddress1":"",
                "insuranceMasterAddress2":"",
                "insuranceMasterCity":"",
                "insuranceMasterState":"",
                "insuranceMasterZip":"",
                "insuranceMasterForm":"",
                "insuranceMasterAttention":"",
                "insuranceMasterAuthType":"",
                "insuranceMasterBenefitsPhone":"",
                "insuranceMasterPhone":""
            }',
            '$.lastName', COALESCE(CONVERT(VARCHAR(100), i.ILNAME), '')
        ),
            '$.firstName', COALESCE(CONVERT(VARCHAR(100), i.IFNAME), '')
        ),
            '$.middleName', COALESCE(CONVERT(VARCHAR(100), i.IMNAME), '')
        ),
            '$.address', COALESCE(CONVERT(VARCHAR(255), i.ADDRESS), '')
        ),
            '$.city', COALESCE(CONVERT(VARCHAR(100), i.CITY), '')
        ),
            '$.state', COALESCE(CONVERT(VARCHAR(50), i.STATE), '')
        ),
            '$.zip', COALESCE(CONVERT(VARCHAR(25), i.ZIP), '')
        ),
            '$.phone', COALESCE(CONVERT(VARCHAR(50), i.PHONE), '')
        ),
            '$.dob', COALESCE(CONVERT(VARCHAR(23), TRY_CAST(i.DOB AS datetime2), 121), '')
        ),
            '$.sex', COALESCE(CONVERT(VARCHAR(25), i.SEX), '')
        ),
            '$.group', COALESCE(CONVERT(VARCHAR(100), i.IGROUP), '')
        ),
            '$.policyNumber', COALESCE(CONVERT(VARCHAR(100), i.POLICYNO), '')
        ),
            '$.insuranceCode', COALESCE(CONVERT(VARCHAR(100), i.INSCODE), '')
        ),
            '$.insurancePlan', COALESCE(CONVERT(VARCHAR(100), i.INSPLAN), '')
        ),
            '$.claim', COALESCE(CONVERT(VARCHAR(100), i.CLAIM), '')
        ),
            '$.relation', COALESCE(CONVERT(VARCHAR(100), i.RELATION), '')
        ),
            '$.otherInsurance', COALESCE(CONVERT(VARCHAR(100), i.OTHERINS), '')
        ),
            '$.coverageFrom', COALESCE(CONVERT(VARCHAR(23), TRY_CAST(i.COVFROM AS datetime2), 121), '')
        ),
            '$.coverageTo', COALESCE(CONVERT(VARCHAR(23), TRY_CAST(i.COVTO AS datetime2), 121), '')
        ),
            '$.adjustor', COALESCE(CONVERT(VARCHAR(100), i.ADJUSTOR), '')
        ),
            '$.adjustorPhone', COALESCE(CONVERT(VARCHAR(50), i.ADJPHONE), '')
        ),
            '$.billNote', COALESCE(CONVERT(VARCHAR(2000), i.BILLNOTE), '')
        ),
            '$.termDate', COALESCE(CONVERT(VARCHAR(23), TRY_CAST(i.TERMDATE AS datetime2), 121), '')
        ),
            '$.special', COALESCE(CONVERT(VARCHAR(100), i.SPECIAL), '')
        ),
            '$.employer', COALESCE(CONVERT(VARCHAR(255), i.EMPLOYER), '')
        ),
            '$.isPrimary', COALESCE(CONVERT(VARCHAR(25), i.IPRIMARY), '')
        ),
            '$.secondary', COALESCE(CONVERT(VARCHAR(100), i.SECONDARY), '')
        ),
            '$.coverageType', COALESCE(CONVERT(VARCHAR(100), i.COVTYPE), '')
        ),
            '$.form', COALESCE(CONVERT(VARCHAR(100), i.FORM), '')
        ),
            '$.remark', COALESCE(CONVERT(VARCHAR(2000), i.REMARK), '')
        ),
            '$.userCode', COALESCE(CONVERT(VARCHAR(100), i.USERCODE), '')
        ),
            '$.entered', COALESCE(CONVERT(VARCHAR(23), TRY_CAST(i.ENTERED AS datetime2), 121), '')
        ),
            '$.suffix', COALESCE(CONVERT(VARCHAR(50), i.SUFFIX), '')
        ),
            '$.country', COALESCE(CONVERT(VARCHAR(100), i.COUNTRY), '')
        ),
            '$.address2', COALESCE(CONVERT(VARCHAR(255), i.ADDRESS2), '')     
        ),
            '$.insuranceMasterCode', COALESCE(CONVERT(VARCHAR(100), im.[CODE]), '')
        ),
            '$.insuranceMasterName', COALESCE(CONVERT(VARCHAR(255), im.[NAME]), '')
        ),
            '$.insuranceMasterAddress1', COALESCE(CONVERT(VARCHAR(255), im.[ADDRESS1]), '')
        ),
            '$.insuranceMasterAddress2', COALESCE(CONVERT(VARCHAR(255), im.[ADDRESS2]), '')
        ),
            '$.insuranceMasterCity', COALESCE(CONVERT(VARCHAR(100), im.[CITY]), '')
        ),
            '$.insuranceMasterState', COALESCE(CONVERT(VARCHAR(50), im.[STATE]), '')
        ),
            '$.insuranceMasterZip', COALESCE(CONVERT(VARCHAR(25), im.[ZIP]), '')
        ),
            '$.insuranceMasterForm', COALESCE(CONVERT(VARCHAR(50), im.[FORM]), '')
        ),
            '$.insuranceMasterAttention', COALESCE(CONVERT(VARCHAR(100), im.[ATTN]), '')
        ),
            '$.insuranceMasterAuthType', COALESCE(CONVERT(VARCHAR(50), im.[AUTHTYPE]), '')
        ),
            '$.insuranceMasterBenefitsPhone', COALESCE(CONVERT(VARCHAR(50), im.[BENEFITSPHONE]), '')
        ),
            '$.insuranceMasterPhone', COALESCE(CONVERT(VARCHAR(50), im.[PHONE]), '')
    )) AS [ExtendedProperties]
-- SELECT TOP(100)*
FROM [files].[INSURANCE] AS i
LEFT JOIN [files].[INSURANCEMASTER] AS IM
    ON i.[INSCODE] = im.[CODE]
WHERE 1 = 1
--Functional

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)