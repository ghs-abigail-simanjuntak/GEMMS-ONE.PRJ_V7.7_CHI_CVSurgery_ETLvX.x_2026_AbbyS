/********************************************************************************
SCRIPT DEPENDENCIES: None identified.
ITEM TYPE: Visit
NOTES:
SCALE:
********************************************************************************/

DROP EXTERNAL TABLE [etl_dbo].[Visit]
CREATE EXTERNAL TABLE [etl_dbo].[Visit]
WITH
(
    LOCATION = 'etl_dbo/Visit',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS
SELECT
    NEWID() AS [Id]
   ,1 AS [ItemSetId]
   ,'CHIGEMMS1CV' AS [DataSourceCode]
   ,CAST(
        CASE
            WHEN src.[VisitMultiplicity] > 1 THEN CONCAT(src.[BaseExternalDataId], '|', CAST(src.[VisitSequence] AS varchar(10)))
            ELSE src.[BaseExternalDataId]
        END AS varchar(175)
    ) AS [ExternalDataId]
   ,'1' AS [ExternalDataVersion]
   ,1 AS [DisplayOrder]
    ,CAST(src.[PatientID] AS varchar(100)) AS [PatientExternalDataId]
    ,src.[VisitDttm] AS [ClinicallyRelevantDttm]
    ,COALESCE(NULLIF(CAST(src.[BOOKCODE] AS varchar(100)), ''), NULLIF(CAST(src.[REASONCODE] AS varchar(100)), ''), 'Appointment') AS [TypeCode]
    ,COALESCE(NULLIF(CAST(src.[REASONFINAL] AS varchar(250)), ''), NULLIF(CAST(src.[BOOKCODE] AS varchar(100)), ''), NULLIF(CAST(src.[REASONCODE] AS varchar(100)), ''), 'Appointment') AS [TypeName]
   ,CAST(0 AS bit) AS [IsInvalidated]
   ,NULL AS [InvalidatedDttm]
   ,NULL AS [InvalidatedByProviderExternalDataId]
    ,src.[CreatedDttm] AS [ExternalDataCreatedDttm]
    ,COALESCE(src.[ReasonDttm], src.[FinishedDttm], src.[TaggedDttm], src.[CreatedDttm], src.[VisitDttm]) AS [ExternalDataUpdatedDttm]
    ,NULLIF(CAST(src.[STATUS] AS varchar(100)), '') AS [Status]
    ,COALESCE(NULLIF(CAST(src.[REASONFINAL] AS varchar(500)), ''), NULLIF(CAST(src.[ANOTE] AS varchar(500)), '')) AS [Title]
   ,CAST(0 AS bit) AS [IsSecure]
   ,NULL AS [VcoSetEntries]
   ,CAST(
        CONCAT(
            '{',
            '"aKeyTime":"', STRING_ESCAPE(COALESCE(CAST(src.[AKEYTIME] AS varchar(50)), ''), 'json'), '",',
            '"arriveTime":"', STRING_ESCAPE(COALESCE(CAST(src.[ARRIVETIME] AS varchar(50)), ''), 'json'), '",',
            '"tagTime":"', STRING_ESCAPE(COALESCE(CAST(src.[TAGTIME] AS varchar(50)), ''), 'json'), '",',
            '"svcTime":"', STRING_ESCAPE(COALESCE(CAST(src.[SVCTIME] AS varchar(50)), ''), 'json'), '",',
            '"finTime":"', STRING_ESCAPE(COALESCE(CAST(src.[FINTIME] AS varchar(50)), ''), 'json'), '",',
            '"userFlag":"', STRING_ESCAPE(COALESCE(CAST(src.[USERFLAG] AS varchar(100)), ''), 'json'), '",',
            '"lagTime":"', STRING_ESCAPE(COALESCE(CAST(src.[LAGTIME] AS varchar(100)), ''), 'json'), '",',
            '"flagNote":"', STRING_ESCAPE(COALESCE(CAST(src.[FLAGNOTE] AS varchar(1000)), ''), 'json'), '",',
            '"appointmentNote":"', STRING_ESCAPE(COALESCE(CAST(src.[ANOTE] AS varchar(1000)), ''), 'json'), '",',
            '"reasonCode":"', STRING_ESCAPE(COALESCE(CAST(src.[REASONCODE] AS varchar(100)), ''), 'json'), '",',
            '"reasonFinal":"', STRING_ESCAPE(COALESCE(CAST(src.[REASONFINAL] AS varchar(1000)), ''), 'json'), '",',
            '"eligibility":"', STRING_ESCAPE(COALESCE(CAST(src.[ELIGIBILITY] AS varchar(100)), ''), 'json'), '",',
            '"visitSequence":"', STRING_ESCAPE(CAST(src.[VisitSequence] AS varchar(10)), 'json'), '",',
            '"visitNoteDate":"', STRING_ESCAPE(COALESCE(CONVERT(varchar(23), vn.[NoteDttm], 121), ''), 'json'), '",',
            '"visitNoteStatus":"', STRING_ESCAPE(COALESCE(vn.[NoteStatus], ''), 'json'), '",',
            '"visitNoteUser":"', STRING_ESCAPE(COALESCE(vn.[NoteUserCode], ''), 'json'), '",',
            '"visitNoteText":"', STRING_ESCAPE(COALESCE(vn.[NoteText], ''), 'json'), '"',
            '}'
        ) AS varchar(4000)
    ) AS [ExtendedProperties]
   ,src.[ServiceDttm] AS [ServiceDttm]
   ,src.[CreatedDttm] AS [RecordedDttm]
   ,src.[ServiceDttm] AS [PerformedDttm]
    ,CONCAT('account_',pa.[PatientID]) AS [AccountExternalDataId]
   ,NULL AS [WellKnownVisitType]
   ,CAST(
        CASE
            WHEN src.[VisitMultiplicity] > 1 THEN CONCAT(src.[BaseExternalDataId], '|', CAST(src.[VisitSequence] AS varchar(10)))
            ELSE src.[BaseExternalDataId]
        END AS varchar(175)
    ) AS [ReferenceId]
   ,NULLIF(CAST(src.[FACILITY] AS varchar(250)), '') AS [Location]
   ,COALESCE(NULLIF(CAST(src.[BOOKCODE] AS varchar(100)), ''), NULLIF(CAST(src.[REASONCODE] AS varchar(100)), '')) AS [ServiceType]
   ,src.[VisitDttm] AS [VisitDttm]
   ,COALESCE(src.[ReasonDttm], src.[FinishedDttm], src.[TaggedDttm], src.[CreatedDttm], src.[VisitDttm]) AS [LastUpdatedDttm]
   ,src.[CreatedDttm] AS [CreatedDttm]
   ,src.[FinishedDttm] AS [EndDttm]
   ,NULL AS [InsuranceExternalDataId]
   ,CASE
        WHEN NULLIF(CAST(src.[SVCUSER] AS varchar(100)), '') IS NOT NULL THEN CONCAT('USER|', CAST(src.[SVCUSER] AS varchar(100)))
        ELSE NULL
    END AS [AttendingProviderExternalDataId]
   ,CASE
        WHEN created_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(created_user.[USERID] AS varchar(100)))
        ELSE NULL
    END AS [CreatedByExternalDataId]
   ,CASE
        WHEN updated_user.[USERID] IS NOT NULL THEN CONCAT('USER|', CAST(updated_user.[USERID] AS varchar(100)))
        ELSE NULL
    END AS [LastUpdatedByExternalDataId]
   ,NULL AS [PrimaryCareProviderExternalDataId]
   ,NULL AS [ReferringProviderExternalDataId]
   ,NULL AS [SupervisingProviderExternalDataId]
FROM
(
    SELECT
        a.[PatientID]
       ,a.[ADATE]
       ,a.[AKEYTIME]
       ,a.[ARRIVETIME]
       ,a.[TAGTIME]
       ,a.[SVCTIME]
       ,a.[FINTIME]
       ,a.[BOOKCODE]
       ,a.[REASONCODE]
       ,a.[REASONFINAL]
       ,a.[STATUS]
       ,a.[CREATEDATE]
       ,a.[CREATETIME]
       ,a.[USERFLAG]
       ,a.[LAGTIME]
       ,a.[USERCODE]
       ,a.[TAGUSER1]
       ,a.[TAGUSER2]
       ,a.[SVCUSER]
       ,a.[FINUSER]
       ,a.[FACILITY]
       ,a.[ANOTE]
       ,a.[REASONUSER]
       ,a.[REASONDATE]
       ,a.[REFERRAL]
       ,a.[FLAGNOTE]
       ,a.[ELIGIBILITY]
       ,a.[TAGDATE]
       ,dt.[VisitDttm]
       ,dt.[CreatedDttm]
       ,dt.[TaggedDttm]
       ,dt.[ServiceDttm]
       ,dt.[FinishedDttm]
       ,dt.[ReasonDttm]
       ,CAST(
            CONCAT(
                CAST(a.[PatientID] AS varchar(50)), '|',
                COALESCE(CONVERT(varchar(23), dt.[VisitDttm], 121), CAST(a.[ADATE] AS varchar(50))), '|',
                COALESCE(NULLIF(CAST(a.[BOOKCODE] AS varchar(50)), ''), NULLIF(CAST(a.[REASONCODE] AS varchar(50)), ''), 'APPT')
            ) AS varchar(150)
        ) AS [BaseExternalDataId]
       ,ROW_NUMBER() OVER (
            PARTITION BY
                CAST(a.[PatientID] AS varchar(50)),
                COALESCE(CONVERT(varchar(23), dt.[VisitDttm], 121), CAST(a.[ADATE] AS varchar(50))),
                COALESCE(NULLIF(CAST(a.[BOOKCODE] AS varchar(50)), ''), NULLIF(CAST(a.[REASONCODE] AS varchar(50)), ''), 'APPT')
            ORDER BY
                COALESCE(dt.[CreatedDttm], dt.[TaggedDttm], dt.[ServiceDttm], dt.[FinishedDttm], dt.[VisitDttm]),
                COALESCE(dt.[TaggedDttm], dt.[CreatedDttm], dt.[ServiceDttm], dt.[FinishedDttm], dt.[VisitDttm]),
                COALESCE(dt.[ServiceDttm], dt.[VisitDttm]),
                COALESCE(dt.[FinishedDttm], dt.[ServiceDttm], dt.[VisitDttm]),
                COALESCE(NULLIF(CAST(a.[USERCODE] AS varchar(100)), ''), NULLIF(CAST(a.[SVCUSER] AS varchar(100)), ''), NULLIF(CAST(a.[FINUSER] AS varchar(100)), ''), ''),
                COALESCE(NULLIF(CAST(a.[REASONFINAL] AS varchar(500)), ''), NULLIF(CAST(a.[ANOTE] AS varchar(500)), ''), NULLIF(CAST(a.[FLAGNOTE] AS varchar(1000)), ''), ''),
                COALESCE(NULLIF(CAST(a.[REFERRAL] AS varchar(250)), ''), ''),
                COALESCE(NULLIF(CAST(a.[ELIGIBILITY] AS varchar(100)), ''), '')
        ) AS [VisitSequence]
       ,COUNT(*) OVER (
            PARTITION BY
                CAST(a.[PatientID] AS varchar(50)),
                COALESCE(CONVERT(varchar(23), dt.[VisitDttm], 121), CAST(a.[ADATE] AS varchar(50))),
                COALESCE(NULLIF(CAST(a.[BOOKCODE] AS varchar(50)), ''), NULLIF(CAST(a.[REASONCODE] AS varchar(50)), ''), 'APPT')
        ) AS [VisitMultiplicity]
    FROM [files].[APPOINTMENTS] AS a
    CROSS APPLY
    (
        SELECT
             COALESCE(
                 TRY_CAST(CONCAT(CAST(a.[ADATE] AS varchar(50)), ' ', NULLIF(CAST(a.[AKEYTIME] AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(CONCAT(CAST(a.[ADATE] AS varchar(50)), ' ', NULLIF(CAST(a.[ARRIVETIME] AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(CAST(a.[ADATE] AS varchar(50)) AS datetime2)
             ) AS [VisitDttm]
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(a.[CREATEDATE] AS varchar(50)), ' ', NULLIF(CAST(a.[CREATETIME] AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(CAST(a.[CREATEDATE] AS varchar(50)) AS datetime2)
             ) AS [CreatedDttm]
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(a.[TAGDATE] AS varchar(50)), ' ', NULLIF(CAST(a.[TAGTIME] AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(CAST(a.[TAGDATE] AS varchar(50)) AS datetime2)
             ) AS [TaggedDttm]
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(a.[ADATE] AS varchar(50)), ' ', NULLIF(CAST(a.[SVCTIME] AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(CONCAT(CAST(a.[ADATE] AS varchar(50)), ' ', NULLIF(CAST(a.[ARRIVETIME] AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(CAST(a.[ADATE] AS varchar(50)) AS datetime2)
             ) AS [ServiceDttm]
            ,COALESCE(
                 TRY_CAST(CONCAT(CAST(a.[ADATE] AS varchar(50)), ' ', NULLIF(CAST(a.[FINTIME] AS varchar(50)), '')) AS datetime2),
                 TRY_CAST(CAST(a.[ADATE] AS varchar(50)) AS datetime2)
             ) AS [FinishedDttm]
            ,TRY_CAST(CAST(a.[REASONDATE] AS varchar(50)) AS datetime2) AS [ReasonDttm]
    ) AS dt
    WHERE a.[PatientID] IS NOT NULL
) AS src
LEFT JOIN [files].[PATIENTACCOUNT] AS pa
    ON pa.[PatientID] = src.[PatientID]
LEFT JOIN [files].[USERS] AS created_user
    ON created_user.[USERID] = src.[USERCODE]
LEFT JOIN [files].[USERS] AS updated_user
    ON updated_user.[USERID] = COALESCE(
        NULLIF(CAST(src.[FINUSER] AS varchar(100)), ''),
        NULLIF(CAST(src.[REASONUSER] AS varchar(100)), ''),
        NULLIF(CAST(src.[TAGUSER2] AS varchar(100)), ''),
        NULLIF(CAST(src.[TAGUSER1] AS varchar(100)), ''),
        NULLIF(CAST(src.[USERCODE] AS varchar(100)), '')
    )
OUTER APPLY
(
    SELECT TOP 1
         TRY_CAST(vn.[NOTEDATE] AS datetime2) AS [NoteDttm]
        ,CAST(vn.[NOTETEXT] AS varchar(2000)) AS [NoteText]
        ,CAST(vn.[STATUS] AS varchar(100)) AS [NoteStatus]
        ,CAST(vn.[USERCODE] AS varchar(100)) AS [NoteUserCode]
    FROM [files].[VISITNOTES] AS vn
    WHERE vn.[PatientID] = src.[PatientID]
      AND (
            TRY_CAST(vn.[NOTEDATE] AS date) = TRY_CAST(src.[ADATE] AS date)
         OR TRY_CAST(vn.[NOTEDATE] AS datetime2) = src.[VisitDttm]
      )
    ORDER BY TRY_CAST(vn.[NOTEDATE] AS datetime2) DESC
) AS vn
WHERE src.[PatientID] IS NOT NULL;