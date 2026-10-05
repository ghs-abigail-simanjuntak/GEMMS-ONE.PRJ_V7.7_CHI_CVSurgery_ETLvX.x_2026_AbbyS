/********************************************************************************
SCRIPT DEPENDENCIES: etl_dbo.Registration
ITEM TYPE: Patient
NOTES: Patient item sourced from etl_dbo.Registration. Keeps one row per patient/DataSourceCode by taking the highest DisplayOrder.
SCALE:
********************************************************************************/

-- DROP EXTERNAL TABLE etl_dbo.Patient
CREATE EXTERNAL TABLE etl_dbo.Patient
WITH (
    LOCATION = 'etl_dbo/Patient',
    DATA_SOURCE = [EtlExtractStorage],
    FILE_FORMAT = ParquetFileFormat
)
AS
SELECT
    r.[Id] AS [Id],
    r.[ItemSetId] AS [ItemSetId],
    r.[DataSourceCode] AS [DataSourceCode],
    r.[ExternalDataId] AS [ExternalDataId],
    0 AS [HasSecureData],
    r.[ExternalDataCreatedDttm] AS [ExternalDataCreatedDttm],
    r.[ExternalDataUpdatedDttm] AS [ExternalDataUpdatedDttm],
    r.[IsSecure] AS [IsSecure],
    r.[MedicalRecordNumber] AS [MedicalRecordNumber],
    r.[LastName] AS [LastName],
    r.[MiddleName] AS [MiddleName],
    r.[FirstName] AS [FirstName],
    r.[DateOfBirth] AS [DateOfBirth],
    r.[Ssn] AS [Ssn],
    r.[Gender] AS [Gender],
    r.[Ethnicity] AS [Ethnicity],
    r.[PrimaryLanguage] AS [PrimaryLanguage],
    r.[SecondaryLanguage] AS [SecondaryLanguage],
    r.[Race] AS [Race],
    r.[GuarantorExternalDataId] AS [GuarantorExternalDataId],
    r.[GuarantorPatientRelationship] AS [GuarantorPatientRelationship],
    r.[Comment] AS [Comment],
    r.[IsDeceased] AS [IsDeceased],
    r.[MaritalStatus] AS [MaritalStatus],
    r.[Prefix] AS [Prefix],
    r.[Suffix] AS [Suffix],
    r.[MedicareId] AS [MedicareId],
    r.[Religion] AS [Religion],
    r.[Occupation] AS [Occupation],
    r.[PcpExternalDataId] AS [PcpExternalDataId],
    r.[ReferringExternalDataId] AS [ReferringExternalDataId]
FROM [etl_dbo].[Registration] r
WHERE 1 = 1
