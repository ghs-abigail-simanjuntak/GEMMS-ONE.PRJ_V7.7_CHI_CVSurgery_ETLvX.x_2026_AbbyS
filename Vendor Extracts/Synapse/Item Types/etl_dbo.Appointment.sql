/********************************************************************************
SCRIPT DEPENDENCIES: GEMMSCV.files.APPOINTMENTS, GEMMSCV.files.PATIENTACCOUNT
ITEM TYPE: Appointment
NOTES: Direct appointment reconstruction from APPOINTMENTS with account enrichment from PATIENTACCOUNT.
SCALE:
********************************************************************************/
 
 -- DROP EXTERNAL TABLE etl_dbo.Appointment
CREATE EXTERNAL TABLE etl_dbo.Appointment
WITH (
    LOCATION = 'etl_dbo/Appointment',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS 
SELECT
    NEWID() AS [Id],
    NULL AS [ItemSetId],
    'CHIGEMMS1CV' AS [DataSourceCode],
    CONCAT(a.[PatientID], '|APPT|', COALESCE(a.[ADATE], ''), '|', COALESCE(a.[AKEYTIME], ''), '|', COALESCE(a.[BOOKCODE], ''), '|', COALESCE(a.[REASONCODE], '')) AS [ExternalDataId],
    '1' AS [ExternalDataVersion],
    1 AS [DisplayOrder],
    a.[PatientID] AS [PatientExternalDataId],
    CONCAT(COALESCE(a.[ADATE], ''), CASE WHEN NULLIF(a.[AKEYTIME], '') IS NOT NULL THEN ' ' + a.[AKEYTIME] ELSE '' END) AS [ClinicallyRelevantDttm],
    a.[BOOKCODE] AS [TypeCode],
    COALESCE(NULLIF(a.[REASONFINAL], ''), NULLIF(a.[REASONCODE], ''), a.[BOOKCODE]) AS [TypeName],
    CASE
        WHEN a.[STATUS] IN ('X', 'C') THEN 1
        ELSE 0
    END AS [IsInvalidated],
    NULL AS [InvalidatedDttm],
    NULL AS [InvalidatedByProviderExternalDataId],
    CONCAT(COALESCE(a.[CREATEDATE], ''), CASE WHEN NULLIF(a.[CREATETIME], '') IS NOT NULL THEN ' ' + a.[CREATETIME] ELSE '' END) AS [ExternalDataCreatedDttm],
    NULL AS [ExternalDataUpdatedDttm],
    CASE a.[STATUS]
        WHEN 'A' THEN 'Acknowledged'
        WHEN 'B' THEN 'Bumped'
        WHEN 'C' THEN 'Confirmed'
        WHEN 'F' THEN 'Finished'
        WHEN 'M' THEN 'Med Rec Request'
        WHEN 'N' THEN 'No Show'
        WHEN 'S' THEN 'Scheduled'
        WHEN 'W' THEN 'Wait List'
        WHEN 'X' THEN 'Cancelled'
        ELSE a.[STATUS]
    END AS [Status],
    COALESCE(NULLIF(a.[REASONFINAL], ''), NULLIF(a.[REASONCODE], ''), a.[BOOKCODE]) AS [Title],
    0 AS [IsSecure],
    NULL AS [VcoSetEntries],
    NULL AS [ExtendedProperties],
    CONCAT(COALESCE(a.[ADATE], ''), CASE WHEN NULLIF(a.[SVCTIME], '') IS NOT NULL THEN ' ' + a.[SVCTIME] ELSE CASE WHEN NULLIF(a.[AKEYTIME], '') IS NOT NULL THEN ' ' + a.[AKEYTIME] ELSE '' END END) AS [ServiceDttm],
    CONCAT(COALESCE(a.[CREATEDATE], ''), CASE WHEN NULLIF(a.[CREATETIME], '') IS NOT NULL THEN ' ' + a.[CREATETIME] ELSE '' END) AS [RecordedDttm],
    p.[ACCOUNT] AS [AccountExternalDataId],
    a.[REFERRAL] AS [ReferenceId],
    COALESCE(NULLIF(a.[REASONFINAL], ''), NULLIF(a.[REASONCODE], '')) AS [Reason],
    a.[FACILITY] AS [Location],
    CONCAT(COALESCE(a.[ADATE], ''), CASE WHEN NULLIF(a.[AKEYTIME], '') IS NOT NULL THEN ' ' + a.[AKEYTIME] ELSE '' END) AS [StartDttm],
    CONCAT(COALESCE(a.[ADATE], ''), CASE WHEN NULLIF(a.[FINTIME], '') IS NOT NULL THEN ' ' + a.[FINTIME] ELSE '' END) AS [EndDttm],
    CONCAT(COALESCE(a.[CREATEDATE], ''), CASE WHEN NULLIF(a.[CREATETIME], '') IS NOT NULL THEN ' ' + a.[CREATETIME] ELSE '' END) AS [CreatedByDttm],
    NULL AS [LastUpdateDttm],
    NULL AS [ReferringProviderExternalDataId],
    NULL AS [LastUpdatedByExternalDataId],
    NULLIF(a.[USERCODE], '') AS [CreatedByExternalDataId],
    NULL AS [PrimaryCareProviderExternalDataId],
    NULL AS [ProviderExternalDataId],
    CONCAT(a.[PatientID], '|APPT|', COALESCE(a.[ADATE], ''), '|', COALESCE(a.[AKEYTIME], ''), '|', COALESCE(a.[BOOKCODE], ''), '|', COALESCE(a.[REASONCODE], '')) AS [EncounterExternalDataId]
FROM GEMMSCV.[files].[APPOINTMENTS] a
INNER JOIN GEMMSCV.[files].[PATIENTACCOUNT] p
    ON p.[PatientID] = a.[PatientID]
WHERE 1 = 1
--Functional

--Site specific

-- Testing (Remove this section before final storage of scripts in the Repo)
