/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.VITALS
ITEM TYPE: Vital
NOTES: Direct vital reconstruction from VITALS with one output row per populated measurement.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Vital
CREATE EXTERNAL TABLE etl_dbo.Vital
WITH (
    LOCATION = 'etl_dbo/Vital',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
WITH vital_source AS (
    SELECT
        v.[PatientID],
        v.[DATETIME],
        v.[VDATE],
        v.[PROV],
        v.[BP],
        v.[BPS],
        v.[BPD],
        v.[BPDESC],
        v.[HEIGHT],
        v.[WEIGHT],
        v.[WAIST],
        v.[HEADSIZE],
        v.[O2SAT],
        v.[PULSE],
        v.[PULSEDESC],
        v.[RESP],
        v.[RESPDESC],
        v.[GLUCOSE],
        v.[TEMPR],
        v.[TEMPRDESC],
        v.[RESULT],
        v.[RECORDEDFLAG],
        v.[MUNIT]
    FROM GEMMSCV.[files].[VITALS] v
    INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] p
        ON p.[PatientID] = v.[PatientID]
)
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(vs.[PatientID], '|VITAL|', COALESCE(vs.[DATETIME], ''), '|', COALESCE(vital_map.[TypeCode], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    vs.[PatientID] AS [PatientExternalDataId],
    COALESCE(NULLIF(vs.[DATETIME], ''), NULLIF(vs.[VDATE], '')) AS [ClinicallyRelevantDttm],
    vital_map.[TypeCode] AS [TypeCode],
    vital_map.[TypeName] AS [TypeName],
    0 AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    COALESCE(NULLIF(vs.[DATETIME], ''), NULLIF(vs.[VDATE], '')) AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    CASE WHEN vs.[RECORDEDFLAG] = 'Y' THEN 'Recorded' ELSE NULL END AS [Status],
    vital_map.[TypeName] AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    NULL AS [ServiceDttm],
    COALESCE(NULLIF(vs.[DATETIME], ''), NULLIF(vs.[VDATE], '')) AS [RecordedDttm],
    COALESCE(NULLIF(vs.[DATETIME], ''), NULLIF(vs.[VDATE], '')) AS [PerformedDttm],
    NULLIF(vs.[PROV], '') AS [PersonExternalDataId],
    vital_map.[ValueText] AS [Value],
    vital_map.[Units] AS [Units],
    NULLIF(vs.[PROV], '') AS [PerformingProviderExternalDataId],
    NULL AS [RecordedByExternalDataId],
    NULLIF(vs.[PROV], '') AS [LastUpdatingProviderExternalDataId],
    NULL AS [OrderExternalDataId],
    NULL AS [EncounterExternalDataId]
FROM vital_source vs
CROSS APPLY (
    VALUES
        ('BP', 'Blood Pressure', NULLIF(vs.[BP], ''), 'mmHg'),
        ('BPS', 'Blood Pressure Systolic', NULLIF(vs.[BPS], ''), 'mmHg'),
        ('BPD', 'Blood Pressure Diastolic', NULLIF(vs.[BPD], ''), 'mmHg'),
        ('Height', 'Height', NULLIF(vs.[HEIGHT], ''), COALESCE(NULLIF(vs.[MUNIT], ''), 'in')),
        ('Weight', 'Weight', NULLIF(vs.[WEIGHT], ''), 'lb'),
        ('Waist', 'Waist Circumference', NULLIF(vs.[WAIST], ''), COALESCE(NULLIF(vs.[MUNIT], ''), 'in')),
        ('HeadSize', 'Head Size', NULLIF(vs.[HEADSIZE], ''), COALESCE(NULLIF(vs.[MUNIT], ''), 'in')),
        ('O2', 'Oxygen Saturation', NULLIF(vs.[O2SAT], ''), '%'),
        ('Pulse', 'Pulse', NULLIF(vs.[PULSE], ''), 'bpm'),
        ('Resp', 'Respiratory Rate', NULLIF(vs.[RESP], ''), '/min'),
        ('Glucose', 'Glucose', NULLIF(vs.[GLUCOSE], ''), NULL),
        ('Temp', 'Temperature', NULLIF(vs.[TEMPR], ''), NULLIF(vs.[TEMPRDESC], '')),
        ('Result', 'Vital Result', NULLIF(vs.[RESULT], ''), NULL)
) vital_map([TypeCode], [TypeName], [ValueText], [Units])
    WHERE 1 = 1
    --Functional
    AND NULLIF(LTRIM(RTRIM(COALESCE(vital_map.[ValueText], ''))), '') IS NOT NULL

    --Site specific

    -- Testing (Remove this section before final storage of scripts in the Repo)
