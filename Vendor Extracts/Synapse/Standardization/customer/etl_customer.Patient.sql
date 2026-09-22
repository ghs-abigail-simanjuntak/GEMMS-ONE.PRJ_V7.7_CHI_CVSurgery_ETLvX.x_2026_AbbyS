/********************************************************************************  
SCRIPT DEPENDENCIES: etl_medical.Registration
ITEM TYPE: Patient  
NOTES: 
SCALE:
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[Patient]
CREATE EXTERNAL TABLE [etl_customer].[Patient]
WITH (
		LOCATION = 'etl_customer/Patient',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

SELECT
    CONVERT(UNIQUEIDENTIFIER, NEWID()) AS [Id],
    CONVERT(INT, 1) AS [ItemSetId],
    CONVERT(VARCHAR(50), [reg].[DataSourceCode]) AS [DataSourceCode],
    CONVERT(VARCHAR(255), [reg].[ExternalDataId]) AS [ExternalDataId],
    CONVERT(BIT, 0) AS [HasSecureData],
    CONVERT(DATETIME, [reg].[ExternalDataCreatedDttm]) AS [ExternalDataCreatedDttm],
    CONVERT(DATETIME, [reg].[ExternalDataUpdatedDttm]) AS [ExternalDataUpdatedDttm],
    CONVERT(BIT, [reg].[IsSecure]) AS [IsSecure],
    CONVERT(NVARCHAR(MAX), [reg].[MedicalRecordNumber]) AS [MedicalRecordNumber],
    CONVERT(NVARCHAR(100), [reg].[LastName]) AS [LastName],
    CONVERT(NVARCHAR(20), [reg].[MiddleName]) AS [MiddleName],
    CONVERT(NVARCHAR(100), [reg].[FirstName]) AS [FirstName],
    CONVERT(DATETIME, [reg].[DateOfBirth]) AS [DateOfBirth],
    CONVERT(NVARCHAR(9), [reg].[Ssn]) AS [Ssn],
    CONVERT(NVARCHAR(30), [reg].[Gender]) AS [Gender],
    CONVERT(NVARCHAR(40), [reg].[Ethnicity]) AS [Ethnicity],
    CONVERT(NVARCHAR(50), [reg].[PrimaryLanguage]) AS [PrimaryLanguage],
    CONVERT(NVARCHAR(50), [reg].[SecondaryLanguage]) AS [SecondaryLanguage],
    CONVERT(NVARCHAR(100), [reg].[Race]) AS [Race],
    CONVERT(VARCHAR(255), [reg].[GuarantorExternalDataId]) AS [GuarantorExternalDataId],
    CONVERT(NVARCHAR(MAX), [reg].[GuarantorPatientRelationship]) AS [GuarantorPatientRelationship],
    CONVERT(NVARCHAR(MAX), [reg].[Comment]) AS [Comment],
    CONVERT(BIT, [reg].[IsDeceased]) AS [IsDeceased],
    CONVERT(NVARCHAR(50), [reg].[MaritalStatus]) AS [MaritalStatus],
    CONVERT(NVARCHAR(20), [reg].[Prefix]) AS [Prefix],
    CONVERT(NVARCHAR(20), [reg].[Suffix]) AS [Suffix],
    CONVERT(NVARCHAR(16), [reg].[MedicareId]) AS [MedicareId],
    CONVERT(NVARCHAR(100), [reg].[Religion]) AS [Religion],
    CONVERT(NVARCHAR(MAX), [reg].[Occupation]) AS [Occupation],
    CONVERT(VARCHAR(255), [reg].[PcpExternalDataId]) AS [PcpExternalDataId],
    CONVERT(VARCHAR(255), [reg].[ReferringExternalDataId]) AS [ReferringExternalDataId]

FROM (
    SELECT 
        [r].[ExternalDataId],
        [r].[DataSourceCode],
        MAX([r].[ExternalDataVersion]) AS [edv]
    FROM [etl_dbo].[Registration] AS [r]
    GROUP BY 
        [r].[ExternalDataId],
        [r].[DataSourceCode]
) AS [regx]
INNER JOIN [etl_dbo].[Registration] AS [reg]
    ON [reg].[ExternalDataId] = [regx].[ExternalDataId]
    AND [reg].[DataSourceCode] = [regx].[DataSourceCode]
    AND [reg].[ExternalDataVersion] = [regx].[edv]

WHERE 1 = 1

