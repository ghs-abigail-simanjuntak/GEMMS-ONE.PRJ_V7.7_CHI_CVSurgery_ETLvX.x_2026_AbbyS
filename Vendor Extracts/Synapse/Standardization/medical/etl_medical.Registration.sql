/********************************************************************************  
SCRIPT DEPENDENCIES: 
etl_dbo.Registration - Versions.sql
ITEM TYPE: Registration  
NOTES: 
SCALE:
********************************************************************************/



IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_medical')
	EXEC('CREATE SCHEMA [etl_medical]')

--DROP EXTERNAL TABLE [etl_medical].[Registration]
CREATE EXTERNAL TABLE [etl_medical].[Registration]
WITH (
		LOCATION = 'etl_medical/Registration',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
    CONVERT(UNIQUEIDENTIFIER,[Id]) AS [Id],
    CONVERT(INT,[ItemSetId]) AS [ItemSetId],
    CONVERT(VARCHAR(50),[DataSourceCode]) AS [DataSourceCode],
    CONVERT(VARCHAR(255),[ExternalDataId]) AS [ExternalDataId],
    CONVERT(VARCHAR(255),[ExternalDataVersion]) AS [ExternalDataVersion],
    CONVERT(INT,[DisplayOrder]) AS [DisplayOrder],
    CONVERT(VARCHAR(255),[PatientExternalDataId]) AS [PatientExternalDataId],
    CONVERT(DATETIME,[ClinicallyRelevantDttm]) AS [ClinicallyRelevantDttm],
    CONVERT(BIT,[IsInvalidated]) AS [IsInvalidated],
    CONVERT(DATETIME,[InvalidatedDttm]) AS [InvalidatedDttm],
    CONVERT(VARCHAR(255),[InvalidatedByProviderExternalDataId]) AS [InvalidatedByProviderExternalDataId],
    CONVERT(DATETIME,[ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
    CONVERT(DATETIME,[ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
    CONVERT(VARCHAR(100),[Status]) AS [Status],
    CONVERT(VARCHAR(MAX),[Title]) AS [Title],
    CONVERT(BIT,[IsSecure]) AS [IsSecure],
    CONVERT(VARCHAR(MAX),[VcoSetEntries]) AS [VcoSetEntries],
    CONVERT(VARCHAR(MAX),[ExtendedProperties]) AS [ExtendedProperties],
    CONVERT(DATETIME,[ServiceDttm]) AS [ServiceDttm],
    CONVERT(DATETIME,[RecordedDttm]) AS [RecordedDttm],
    CONVERT(VARCHAR(MAX),[MedicalRecordNumber]) AS [MedicalRecordNumber],
    CONVERT(VARCHAR(100),[LastName]) AS [LastName],
    CONVERT(VARCHAR(20),[MiddleName]) AS [MiddleName],
    CONVERT(VARCHAR(100),[FirstName]) AS [FirstName],
    CONVERT(DATETIME,[DateOfBirth]) AS [DateOfBirth],
    CONVERT(VARCHAR(9),[Ssn]) AS [Ssn],
    CONVERT(VARCHAR(30),[Gender]) AS [Gender],
    CONVERT(VARCHAR(40),[Ethnicity]) AS [Ethnicity],
    CONVERT(VARCHAR(50),[PrimaryLanguage]) AS [PrimaryLanguage],
    CONVERT(VARCHAR(50),[SecondaryLanguage]) AS [SecondaryLanguage],
    CONVERT(VARCHAR(100),[Race]) AS [Race],
    CONVERT(VARCHAR(255),[GuarantorExternalDataId]) AS [GuarantorExternalDataId],
    CONVERT(VARCHAR(MAX),[GuarantorPatientRelationship]) AS [GuarantorPatientRelationship],
    CONVERT(VARCHAR(MAX),[Comment]) AS [Comment],
    CONVERT(BIT,[IsDeceased]) AS [IsDeceased],
    CONVERT(VARCHAR(50),[MaritalStatus]) AS [MaritalStatus],
    CONVERT(VARCHAR(20),[Prefix]) AS [Prefix],
    CONVERT(VARCHAR(20),[Suffix]) AS [Suffix],
    CONVERT(VARCHAR(16),[MedicareId]) AS [MedicareId],
    CONVERT(VARCHAR(100),[Religion]) AS [Religion],
    CONVERT(VARCHAR(MAX),[Occupation]) AS [Occupation],
    CONVERT(VARCHAR(255),[PcpExternalDataId]) AS [PcpExternalDataId],
    CONVERT(VARCHAR(255),[ReferringExternalDataId]) AS [ReferringExternalDataId],
    CONVERT(VARCHAR(255),[CreatedByExternalDataId]) AS [CreatedByExternalDataId],
    CONVERT(VARCHAR(255),[LastUpdatedByExternalDataId]) AS [LastUpdatedByExternalDataId]

FROM [etl_dbo].[Registration]
