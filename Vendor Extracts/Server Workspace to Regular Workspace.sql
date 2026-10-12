--Customer
--Patient
	SET QUOTED_IDENTIFIER ON;
		TRUNCATE TABLE [etl_customer].[CHIGEMMS1CV_patient];
		COPY INTO [etl_customer].[CHIGEMMS1CV_patient] 
		FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/Patient/*.parquet'
		WITH
		(
			FILE_FORMAT = [ParquetFileFormat],
			CREDENTIAL = (IDENTITY = 'Managed Identity'),
			AUTO_CREATE_TABLE = 'ON'
		);
		DELETE FROM [etl_customer].[patient] WHERE DataSourceCode='CHIGEMMS1CV'; 
		INSERT INTO etl_customer.patient 
		SELECT * FROM etl_customer.CHIGEMMS1CV_patient;


--PatientAddress
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_customer].[CHIGEMMS1CV_patientAddress];
	COPY INTO [etl_customer].[CHIGEMMS1CV_patientAddress]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/PatientAddress/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat],
		CREDENTIAL = (IDENTITY = 'Managed Identity'),
		AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_customer].[patientAddress] WHERE DataSourceCode='CHIGEMMS1CV'; 
	INSERT INTO etl_customer.patientAddress 
	SELECT * FROM etl_customer.CHIGEMMS1CV_patientAddress



--Patientemail
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_customer].[CHIGEMMS1CV_patientEmail];
	COPY INTO [etl_customer].[CHIGEMMS1CV_patientEmail]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/PatientEmail/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat],
		CREDENTIAL = (IDENTITY = 'Managed Identity'),
		AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_customer].[patientEmail] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_customer.patientEmail 
	SELECT * FROM etl_customer.CHIGEMMS1CV_patientEmail



--patientidentifier
	SET QUOTED_IDENTIFIER ON;
	DROP TABLE [etl_customer].[CHIGEMMS1CV_patientIdentifier];
	COPY INTO [etl_customer].[CHIGEMMS1CV_patientIdentifier]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/PatientIdentifier/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat],
		CREDENTIAL = (IDENTITY = 'Managed Identity'),
		AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_customer].[patientIdentifier] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_customer.patientIdentifier 
	SELECT * FROM etl_customer.CHIGEMMS1CV_patientIdentifier
	-- SELECT COUNT(*) FROM etl_customer.patientIdentifier Where DataSourceCode='CHIGEMMS1CV'


--patientphone
	SET QUOTED_IDENTIFIER ON;
	DROP TABLE [etl_customer].[CHIGEMMS1CV_patientPhone];
	COPY INTO [etl_customer].[CHIGEMMS1CV_patientPhone]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/PatientPhone/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat],
		CREDENTIAL = (IDENTITY = 'Managed Identity'),
		AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_customer].[patientPhone] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_customer.patientPhone 
	SELECT * FROM etl_customer.CHIGEMMS1CV_patientPhone
	-- SELECT COUNT(*) FROM etl_customer.patientPhone Where DataSourceCode='CHIGEMMS1CV'

--person
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_customer].[CHIGEMMS1CV_person];
	COPY INTO [etl_customer].[CHIGEMMS1CV_person]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/Person/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat],
		CREDENTIAL = (IDENTITY = 'Managed Identity'),
		AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_customer].[person] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_customer.person 
	SELECT * FROM etl_customer.CHIGEMMS1CV_person

-- Person Address
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_customer].[CHIGEMMS1CV_personAddress];
	COPY INTO [etl_customer].[CHIGEMMS1CV_personAddress]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/PersonAddress/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat],
		CREDENTIAL = (IDENTITY = 'Managed Identity'),
		AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_customer].[personAddress] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_customer.personAddress
	SELECT * FROM etl_customer.CHIGEMMS1CV_personAddress

-- Person Phone
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_customer].[CHIGEMMS1CV_personPhone];
	COPY INTO [etl_customer].[CHIGEMMS1CV_personPhone]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/PersonPhone/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat],
		CREDENTIAL = (IDENTITY = 'Managed Identity'),
		AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_customer].[personPhone] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_customer.personPhone
	SELECT * FROM etl_customer.CHIGEMMS1CV_personPhone

-- Payor
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_customer].[CHIGEMMS1CV_Payor];
	COPY INTO [etl_customer].[CHIGEMMS1CV_Payor]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_customer/Payor/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat],
		CREDENTIAL = (IDENTITY = 'Managed Identity'),
		AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_customer].[Payor] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_customer.Payor
	SELECT * FROM etl_customer.CHIGEMMS1CV_Payor

-- MEDICAL

-- Account

	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_Account];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Account]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Account/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[account] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[account] 
	SELECT * FROM etl_medical.CHIGEMMS1CV_Account

-- Account Note

	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_AccountNote];
	COPY INTO [etl_medical].[CHIGEMMS1CV_AccountNote]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/AccountNote/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[accountNote] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[accountNote] 
	SELECT * FROM etl_medical.CHIGEMMS1CV_AccountNote

-- Allergy

	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_Allergy];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Allergy]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Allergy/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[allergy] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[allergy] 
	SELECT * FROM etl_medical.CHIGEMMS1CV_Allergy

-- Charge

	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_CHarge];
	COPY INTO [etl_medical].[CHIGEMMS1CV_CHarge]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Charge/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[charge] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[charge] 
	SELECT * FROM etl_medical.CHIGEMMS1CV_CHarge

-- Claim

	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_Claim];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Claim]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Claim/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[claim] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[claim]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Claim

-- Claim Charge

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_ClaimCharge];
	COPY INTO [etl_medical].[CHIGEMMS1CV_ClaimCharge]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/ClaimCharge/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[claimCharge] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[claimCharge]
	SELECT * FROM etl_medical.CHIGEMMS1CV_ClaimCharge

-- Document

	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_Document];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Document]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Document/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[document] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[document] SELECT * FROM etl_medical.CHIGEMMS1CV_Document

-- Document Non Discrete

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_DocumentNonDiscrete];
	COPY INTO [etl_medical].[CHIGEMMS1CV_DocumentNonDiscrete]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/DocumentNonDiscrete/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[documentNonDiscrete] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[documentNonDiscrete]
	SELECT count(*) FROM etl_medical.CHIGEMMS1CV_DocumentNonDiscrete

-- Encounter

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Encounter];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Encounter]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Encounter/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[encounter] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[encounter]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Encounter

-- Encounter Insurance

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_EncounterInsurance];
	COPY INTO [etl_medical].[CHIGEMMS1CV_EncounterInsurance]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/EncounterInsurance/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[encounterInsurance] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[encounterInsurance]
	SELECT * FROM etl_medical.CHIGEMMS1CV_EncounterInsurance

-- Insurance

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Insurance];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Insurance]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Insurance/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[insurance] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[insurance]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Insurance

-- Medication

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Medication];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Medication]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Medication/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[medication] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[medication]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Medication


-- Problem

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Problem];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Problem]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Problem/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[problem] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[problem]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Problem

-- Statement

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Statement];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Statement]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Statement/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[statement] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[statement]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Statement
	-- select count(*) from etl_medical.statement where DataSourceCode='CHIGEMMS1CV'
-- Transaction

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Transaction];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Transaction]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Transaction/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[transaction] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[transaction]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Transaction

-- Visit

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Visit];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Visit]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Visit/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[visit] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[visit]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Visit

-- Vital

	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Vital];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Vital]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Vital/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[vital] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[vital]
	SELECT * FROM etl_medical.CHIGEMMS1CV_Vital

-- Order
	SET QUOTED_IDENTIFIER ON;
	drop TABLE [etl_medical].[CHIGEMMS1CV_Order];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Order]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Order/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[order] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[order] 
	SELECT * FROM etl_medical.CHIGEMMS1CV_Order 


-- Registration
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_Registration];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Registration]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Registration/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[Registration] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[Registration] SELECT * FROM etl_medical.CHIGEMMS1CV_Registration




--RegistrationAddress
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_RegistrationAddress];
	COPY INTO [etl_medical].[CHIGEMMS1CV_RegistrationAddress]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/RegistrationAddress/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[RegistrationAddress] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[RegistrationAddress] SELECT * FROM etl_medical.CHIGEMMS1CV_RegistrationAddress



--RegistrationEmail
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_RegistrationEmail];
	COPY INTO [etl_medical].[CHIGEMMS1CV_RegistrationEmail]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/RegistrationEmail/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[RegistrationEmail] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[RegistrationEmail] SELECT * FROM etl_medical.CHIGEMMS1CV_RegistrationEmail 

--RegistrationInsurance
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_RegistrationInsurance];
	COPY INTO [etl_medical].[CHIGEMMS1CV_RegistrationInsurance]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/RegistrationInsurance/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[RegistrationInsurance] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[RegistrationInsurance] SELECT * FROM etl_medical.CHIGEMMS1CV_RegistrationInsurance 
-- select count(*) from etl_medical.RegistrationInsurance where DataSourceCode='CHIGEMMS1CV'
--RegistrationContact
	SET QUOTED_IDENTIFIER ON;
	TRUNCATE TABLE [etl_medical].[CHIGEMMS1CV_RegistrationContact];
	COPY INTO [etl_medical].[CHIGEMMS1CV_RegistrationContact]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/RegistrationContact/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[RegistrationContact] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[RegistrationContact] SELECT * FROM etl_medical.CHIGEMMS1CV_RegistrationContact 

--RegistrationIdentifier
	SET QUOTED_IDENTIFIER ON;
	DROP TABLE [etl_medical].[CHIGEMMS1CV_RegistrationIdentifier];
	COPY INTO [etl_medical].[CHIGEMMS1CV_RegistrationIdentifier]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/RegistrationIdentifier/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[RegistrationIdentifier] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[RegistrationIdentifier] SELECT * FROM etl_medical.CHIGEMMS1CV_RegistrationIdentifier 

--RegistrationPhone
	SET QUOTED_IDENTIFIER ON;
	DROP TABLE [etl_medical].[CHIGEMMS1CV_RegistrationPhone];
	COPY INTO [etl_medical].[CHIGEMMS1CV_RegistrationPhone]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/RegistrationPhone/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[RegistrationPhone] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[RegistrationPhone] SELECT * FROM etl_medical.CHIGEMMS1CV_RegistrationPhone 


--Result
	SET QUOTED_IDENTIFIER ON;
	DROP TABLE [etl_medical].[CHIGEMMS1CV_Result];
	COPY INTO [etl_medical].[CHIGEMMS1CV_Result]
	FROM 'https://ghsaetlvcoimps.dfs.core.windows.net/aetl/chi/chigemms1/extracts/etl/etl_medical/Result/*.parquet'
	WITH
	(
		FILE_FORMAT = [ParquetFileFormat]
		,CREDENTIAL = (IDENTITY = 'Managed Identity')
		,AUTO_CREATE_TABLE = 'ON'
	);
	DELETE FROM [etl_medical].[Result] WHERE DataSourceCode='CHIGEMMS1CV';
	INSERT INTO etl_medical.[Result] SELECT * FROM etl_medical.CHIGEMMS1CV_Result
