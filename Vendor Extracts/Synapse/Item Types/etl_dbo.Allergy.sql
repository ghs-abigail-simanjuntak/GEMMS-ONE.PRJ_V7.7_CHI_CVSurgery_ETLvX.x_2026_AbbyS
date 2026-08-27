/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.ALLERGY
ITEM TYPE: Allergy
NOTES: Direct allergy reconstruction from the GEMMS ALLERGY source view.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Allergy
CREATE EXTERNAL TABLE etl_dbo.Allergy
WITH (
    LOCATION = 'etl_dbo/Allergy',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(a.[PatientID], '|ALLERGY|', COALESCE(a.[COMPOSITEALLERGYID], ''), '|', COALESCE(a.[ALLERGY], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    a.[PatientID] AS [PatientExternalDataId],
    COALESCE(NULLIF(a.[REPORTED], ''), NULLIF(a.[DELDATE], '')) AS [ClinicallyRelevantDttm],
    a.[ConceptType] AS [TypeCode],
    COALESCE(NULLIF(a.[COMPOSITEDESCRIPTION], ''), NULLIF(a.[ALLERGYSTATED], ''), a.[ALLERGY]) AS [TypeName],
    CASE
        WHEN NULLIF(a.[DELDATE], '') IS NOT NULL THEN 1
        WHEN NULLIF(a.[ASTATUS], '') IS NOT NULL AND a.[ASTATUS] NOT IN ('Y', 'A', 'Active') THEN 1
        ELSE 0
    END AS [IsInvalidated],
    NULLIF(a.[DELDATE], '') AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    NULLIF(a.[REPORTED], '') AS [ExternalDataCreatedDttm],
    NULLIF(a.[DELDATE], '') AS [ExternalDataUpdatedDttm],
    CASE a.[ASTATUS]
        WHEN 'Y' THEN 'Active'
        WHEN 'N' THEN 'Inactive'
        WHEN 'D' THEN 'Deleted'
        ELSE a.[ASTATUS]
    END AS [Status],
    a.[ALLERGY] AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    NULLIF(a.[REPORTED], '') AS [RecordedDttm],
    CASE
        WHEN UPPER(COALESCE(a.[ALLERGY], '')) LIKE '%DRUG%'
          OR UPPER(COALESCE(a.[ALLERGYSTATED], '')) LIKE '%DRUG%'
          OR UPPER(COALESCE(a.[ALLERGY], '')) LIKE '%MED%'
          OR UPPER(COALESCE(a.[ALLERGYSTATED], '')) LIKE '%MED%'
        THEN 1
        ELSE 0
    END AS [IsMedication],
    COALESCE(NULLIF(a.[SEVERITY], ''), NULLIF(a.[SOURCE], ''), NULLIF(a.[ConceptType], '')) AS [Classification],
    a.[REACTION] AS [ReactionDescription],
    NULLIF(a.[PROV], '') AS [PerformingProviderExternalDataId],
    NULL AS [RecordedByExternalDataId],
    NULLIF(a.[PROV], '') AS [LastUpdatingProviderExternalDataId],
    NULL AS [EncounterExternalDataId]
FROM GEMMSCV.[files].[ALLERGY] a
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] p
    ON p.[PatientID] = a.[PatientID]
WHERE 1 = 1
--Functional

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
