/********************************************************************************
SCRIPT DEPENDENCIES:
ITEM TYPE: Payor
NOTES: 
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
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT('PAYOR|', pc.[PAYORCODE]) AS [ExternalDataId],
    COALESCE(NULLIF(pc.[PAYDESC], ''), pc.[PAYORCODE]) AS [Name],
    CONVERT(VARCHAR(8000),
    JSON_MODIFY(
            '{
                "payorCode":""
            }',
        '$."payorCode"',CONVERT(VARCHAR(100), pc.[PAYORCODE]))
    ) AS [ExtendedProperties],
    NULL AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm]
-- SELECT TOP(100)*
FROM GEMMSCV.[files].[PAYORCODE] pc

--Functional

--Site specific
 
-- Testing (Remove this section before final storage of scripts in the Repo)
