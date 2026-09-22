/********************************************************************************  
SCRIPT DEPENDENCIES: 
2 - etl_dbo.Person_Contact.sql, 
3 - etl_dbo.Person_Docs.sql, 
4 - etl_dbo.Person_Docs2.sql,
5 - etl_dbo.Person_MTUsers.sql, etl_dbo.Person_AuthPerson.sql, etl_dbo.Person_UNK.sql,
etl_dbo.Document.sql, 
UDP SplitDelimitedStringBuilder.sql
ITEM TYPE: PersonType  
NOTES: 
SCALE:
********************************************************************************/


IF NOT EXISTS ( SELECT * FROM SYS.SCHEMAS WHERE NAME = 'etl_customer')
	EXEC('CREATE SCHEMA [etl_customer]')

--DROP EXTERNAL TABLE [etl_customer].[PersonType]
CREATE EXTERNAL TABLE [etl_customer].[PersonType]
WITH (
		LOCATION = 'etl_customer/PersonType',
		DATA_SOURCE = [EtlExtractStorage],
		FILE_FORMAT = ParquetFileFormat
	)
	AS

WITH [PersonSource] AS (
	SELECT [DataSourceCode], [ExternalDataId], [Misc1] FROM [etl_dbo].[Person_Contact]
	UNION ALL
	SELECT [DataSourceCode], [ExternalDataId], [Misc1] FROM [etl_dbo].[Person_Docs]
	UNION ALL
	SELECT [DataSourceCode], [ExternalDataId], [Misc1] FROM [etl_dbo].[Person_Docs2]
	UNION ALL
	SELECT [DataSourceCode], [ExternalDataId], [Misc1] FROM [etl_dbo].[Person_MTUsers]
	UNION ALL
	SELECT [DataSourceCode], [ExternalDataId], [Misc1] FROM [etl_dbo].[Person_AuthPerson]
	UNION ALL
	SELECT [DataSourceCode], [ExternalDataId], [Misc1] FROM [etl_dbo].[Person_UNK]
)

SELECT
	CONVERT(UNIQUEIDENTIFIER, NEWID()) AS [Id],
	CONVERT(INT, 34) AS [ItemSetId],
	CONVERT(VARCHAR(50), [p].[DataSourceCode]) AS [DataSourceCode],
	CONVERT(VARCHAR(255), ('PT_' + [p].[ExternalDataId])) AS [ExternalDataId],
	CONVERT(VARCHAR(255), [p].[ExternalDataID]) AS [ItemExternalDataId],
	CONVERT(NVARCHAR(50), CASE
		WHEN [p].[Misc1] = 'MisDoctors' AND [d].[AuthoringProviderExternalDataId] IS NOT NULL THEN 5
		WHEN [p].[Misc1] = 'MriDoctors' AND [d].[AuthoringProviderExternalDataId] IS NOT NULL THEN 5
		WHEN [p].[Misc1] = 'MisDoctors' THEN 1
		WHEN [p].[Misc1] = 'MisUsers' AND [d].[AuthoringProviderExternalDataId] IS NOT NULL THEN 5
		WHEN [p].[Misc1] = 'MisUsers' OR [p].[Misc1] = 'GalenCreatedUser' THEN 2
		ELSE 4
	END) AS [WellKnownPersonType],
	CONVERT(NVARCHAR(50), CASE 
		WHEN [p].[Misc1] = 'MisUsers' THEN 'MisUsers'
		WHEN [p].[Misc1] = 'MisDoctors' THEN 'MisDoctors'
		WHEN [p].[Misc1] = 'MriDoctors' THEN 'MriDoctors'
		WHEN [p].[Externaldataid] LIKE 'Guar%' OR [p].[Externaldataid] LIKE 'NOK%' OR [p].[Externaldataid] LIKE 'PTN%' THEN [personTypeCode].[value]
		ELSE NULL 
	END) AS [Code],
	CONVERT(NVARCHAR(255), CASE 
		WHEN [p].[Misc1] = 'MisUsers' THEN 'MisUsers'
		WHEN [p].[Misc1] = 'MisDoctors' THEN 'MisDoctors'
		WHEN [p].[Misc1] = 'MriDoctors' THEN 'MriDoctors'
		WHEN [p].[Externaldataid] LIKE 'Guar%' OR [p].[Externaldataid] LIKE 'NOK%' OR [p].[Externaldataid] LIKE 'PTN%' THEN [personTypeCode].[value]
		ELSE NULL 
	END) AS [Name],
	CONVERT(NVARCHAR(512), NULL) AS [Title],
	CONVERT(NVARCHAR(MAX), NULL) AS [ExtendedProperties]

FROM [PersonSource] AS [p]
LEFT JOIN [etl_medical].[Document] AS [d]
	ON [d].[AuthoringProviderExternalDataId] = [p].[externaldataid]
	AND [p].[datasourcecode] = [d].[datasourcecode]
OUTER APPLY [dbo].[SplitDelimitedString]([p].[externaldataid], '_', 2) AS [personTypeCode]

GROUP BY [p].[ExternalDataID], [p].[Misc1], [d].[AuthoringProviderExternalDataId], [p].[DataSourceCode], [personTypeCode].[value];
