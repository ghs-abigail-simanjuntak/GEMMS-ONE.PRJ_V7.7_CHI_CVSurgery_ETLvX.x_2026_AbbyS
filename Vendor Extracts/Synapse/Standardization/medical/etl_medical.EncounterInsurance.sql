/********************************************************************************  
SCRIPT DEPENDENCIES: 
    etl_ctas.GHS_VISITS, 
    etl_ctas.GHS_PAT_ADM, 
    etl_ctas.GHS_LatestVisits,
    etl_ctas.Encounter
ITEM TYPE: EncounterInsurance  
NOTES: 
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[EncounterInsurance]
CREATE EXTERNAL TABLE [etl_medical].[EncounterInsurance]
WITH (
		LOCATION = 'etl_medical/EncounterInsurance',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
	CONVERT(uniqueidentifier, NEWID()) AS [Id],
	CONVERT(int, 1) AS [ItemSetId],
	CONVERT(varchar(50), '1') AS [DataSourceCode],
	CONVERT(varchar(255), CONCAT(CONCAT([gv].[medicalrecord], '_', [ad].[insurance], '_', [ad].[insuredpolicynumber], '_', [o].[InsSeqNo], '_', [ad].[insuredsubscriber], '_', [lv].[externaldataid]), '|', [gv].[ExternalDataid])) AS [ExternalDataId],
	CONVERT(varchar(255), [gv].[MedicalRecord]) AS [PatientExternalDataId],
	CONVERT(varchar(255), [enc].[ExternalDataId]) AS [ItemExternalDataId],
	CONVERT(varchar(255), [enc].[ExternalDataVersion]) AS [ItemExternalDataVersion],
	CONVERT(varchar(255), CONCAT([gv].[medicalrecord], '_', [ad].[insurance], '_', [ad].[InsuredName], '_', [ad].[InsuredRelationship], '_', [ad].[InsuredDeductible], '_', [ad].[insuredpolicynumber], '_', [ad].[InsuredGroupName], '_', [ad].[InsuredGroupNumber], '_', [ad].[InsuranceCovNo], '_', [o].[InsSeqNo], '_', [ad].[insuredsubscriber], '_', CONVERT(VARCHAR, [ad].[InsuranceEffDate], 121), '_', [lv].[externaldataid])) AS [InsuranceExternalDataId],
	CONVERT(nvarchar(50), ISNULL([o].[InsSeqNo], 0) + 1) AS [Priority],
	CONVERT(nvarchar(MAX), NULL) AS [ExtendedProperties]

--SELECT COUNT(*)
FROM [MRI].[MriPatVisits] AS [v]
    INNER JOIN [etl_ctas].[GHS_VISITS] AS [gv] on [gv].[ExternalDataId] = CONCAT([v].[MedicalRecord], '|', [v].[VisitSubscript])
    --LEFT JOIN [ABS].[AbspatMain] AS [abspat] on [abspat].[accountnumber] = [gv].[accountnumber]
    --LEFT JOIN [ABS].[AbsPatDischarges] AS [disc] on [disc].[urn] = [abspat].[urn]
    INNER JOIN [etl_ctas].[GHS_PAT_ADM] AS [adm] on [adm].[AccountNumber] = [gv].[AccountNumber] and [adm].[MedicalRecord] = [gv].[MedicalRecord]
    INNER JOIN [ADM].[AdmPatInsureData] AS [ad] on [ad].[urn] = [adm].[adm_urn]
    LEFT JOIN [etl_ctas].[GHS_LatestVisits] AS [lv] on [lv].[MedicalRecord] = [adm].[medicalrecord] and [lv].[AccountNumber] = [adm].[accountnumber]
    LEFT JOIN [ADM].[AdmPatInsureOrder] AS [o] on [o].[urn] = [ad].[urn] and [o].[InsuranceMnemonic] = [ad].[Insurance]
    LEFT JOIN [BAR].[BarPatAdmDemographics] AS [baradm] on [baradm].[number] = [gv].[accountnumber]
    CROSS APPLY (
    	SELECT TOP 1
    		[enc0].[ExternalDataId],
    		[enc0].[ExternalDataVersion]
    	FROM [etl_ctas].[Encounter] AS [enc0]
    	WHERE [enc0].[AccountExternalDataId] = [baradm].[account] + '_' + [gv].[MedicalRecord]
    	ORDER BY [enc0].[ClinicallyRelevantDttm]
    ) AS [enc]

GROUP BY 
    [adm].[medicalrecord], 
    [ad].[insurance], 
    [ad].[insuredpolicynumber], 
    [o].[InsSeqNo], 
    [ad].[insuredsubscriber], 
    [lv].[externaldataid], 
    [gv].[VisitType], 
    [gv].[MedicalRecord], 
    [gv].[DTTM], 
    [gv].[ExternalDataid], 
    [enc].[ExternalDataId], 
    [enc].[ExternalDataVersion], 
    [ad].[insuredname], 
    [ad].[insuredrelationship], 
    [ad].[insureddeductible], 
    [ad].[insuredgroupname], 
    [ad].[insurancecovno], 
    [ad].[insuranceeffdate], 
    [ad].[insuredgroupnumber]

 