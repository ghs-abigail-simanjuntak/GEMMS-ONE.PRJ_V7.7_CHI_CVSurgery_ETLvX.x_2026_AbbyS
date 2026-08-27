/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.PAYORCODE, GEMMSCV.files.INSURANCEMASTER, GEMMSCV.files.INSURANCECODEMASTER
ITEM TYPE: Payor
NOTES: Billing payor dimension reconstructed from direct payor and insurance master views.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Payor
CREATE EXTERNAL TABLE etl_dbo.Payor
WITH (
    LOCATION = 'etl_dbo/Payor',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
WITH insurance_code_props AS (
    SELECT
        icm.[INSCODE],
        STRING_AGG(
            CONCAT(
                COALESCE(icm.[IDNAME], ''),
                CASE WHEN NULLIF(icm.[IDVALUE], '') IS NOT NULL THEN ':' + icm.[IDVALUE] ELSE '' END,
                CASE WHEN NULLIF(icm.[STATUS], '') IS NOT NULL THEN ' (' + icm.[STATUS] + ')' ELSE '' END
            ),
            '|'
        ) AS [InsuranceCodeProperties],
        MAX(NULLIF(icm.[ENTERED], '')) AS [LastEntered]
    FROM GEMMSCV.[files].[INSURANCECODEMASTER] icm
    GROUP BY icm.[INSCODE]
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('PAYOR|', pc.[PAYORCODE]) AS [ExternalDataId],
    COALESCE(NULLIF(pc.[PAYDESC], ''), pc.[PAYORCODE]) AS [Name],
    NULL AS [ExtendedProperties],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm]
FROM GEMMSCV.[files].[PAYORCODE] pc

UNION ALL

SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('PAYOR|INS|', im.[CODE]) AS [ExternalDataId],
    COALESCE(NULLIF(im.[NAME], ''), im.[CODE]) AS [Name],
    NULL AS [ExtendedProperties],
    icp.[LastEntered] AS [ExternalDataCreatedDttm],
    icp.[LastEntered] AS [ExternalDataUpdatedDttm]
FROM GEMMSCV.[files].[INSURANCEMASTER] im
LEFT JOIN insurance_code_props icp
    ON icp.[INSCODE] = im.[CODE]
WHERE 1 = 1
--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
