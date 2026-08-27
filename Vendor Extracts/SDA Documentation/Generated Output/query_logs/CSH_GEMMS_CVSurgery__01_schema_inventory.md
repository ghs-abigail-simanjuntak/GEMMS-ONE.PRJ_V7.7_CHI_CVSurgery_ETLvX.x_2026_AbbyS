# CSH_GEMMS_CVSurgery Schema Inventory

Date: 2026-08-26
Mode: domain-focused discovery scoping

## Scope inputs

- Workspace root: `C:\Users\elaine.folkert\OneDrive - Galen Healthcare Solutions\Data Discovery`
- Artifact root: `C:\Users\elaine.folkert\OneDrive - Galen Healthcare Solutions\Data Discovery\Clients\CSH\CHI\GEMMS\CV Surgery\SDA`
- Source reconstruction endpoint: `ghs-aetl-workspace-chi-chigemms1-ondemand.sql.azuresynapse.net`
- Source database: `GEMMSCV`
- Source schema scope: `files` only
- Reference model endpoint: `ghs-aetl-sql-chi-chigemms1.database.windows.net`
- Reference model database: `ghs-aetl-adw-chi-chigemms1`
- Reference target schemas: `etl_customer`, `etl_medical`

## User-validated environment facts

- Serverless Synapse flavor already validated locally as EngineEdition `11`.
- Dedicated SQL pool flavor already validated locally as EngineEdition `6`.
- Source schemas include `files` plus `etl_*` schemas, but this scoping pass is constrained to `files` for source reconstruction.
- Dedicated target schemas include `etl_customer` and `etl_medical`.
- Dedicated target tables already confirmed locally:
  - `etl_customer.Person`
  - `etl_customer.Message`
  - `etl_medical.Allergy`
  - `etl_medical.Appointment`
  - `etl_medical.CareEvent`
  - `etl_medical.ChartAlert`
  - `etl_medical.Document`
  - `etl_medical.Encounter`
  - `etl_medical.Immunization`
  - `etl_medical.Insurance`
  - `etl_medical.Medication`
  - `etl_medical.Message`
  - `etl_medical.Problem`
  - `etl_medical.Procedure`
  - `etl_medical.Registration`
  - `etl_medical.Result`
  - `etl_medical.TestResult`
  - `etl_medical.Visit`
  - `etl_medical.Vital`

## Files-schema candidate views already identified locally

- `PATIENTACCOUNT`
- `PATIENTDEMOGRAPHICS`
- `ALLERGY`
- `APPOINTMENTS`
- `INSURANCE`
- `INSURANCEHISTORY`
- `LABORDERS`
- `LABRESULTS`
- `PATIENTCLINICALITEMS`
- `PROBLEMLIST`
- `VISITNOTES`
- `NURSINGNOTES`
- `VITALS`
- `PROVIDERMASTER`
- `PROVIDERDOCTORCODEMASTER`
- `MASTERPROVIDERCODE`
- `MASTERDOCTORCODE`
- `PROVIDERCREDENTIALS`
- `REFERRINGPROVIDER`
- `CLAIMINSURANCE`
- `CHARGENOTES`
- `COLLECTIONNOTES`
- `EMAILMESSAGELOG`
- `REMITMESSAGES`
- `REMITMESSAGEHISTORY`

## Documentation inventory

The documentation folder currently contains one workbook:

- `Documentation/GEMMS Data Extract Elements.xlsx`

Workbook sheet partitions observed during this scoping pass:

- `Demographics`
- `Documents`
- `Clinical Data`
- `Charge & Claim Data`
- `Appointments`

Documented extract file sections observed in the workbook:

- Demographics: `Patient Account File`, `Patient Demographic File`, `Guarantor File`, `Insurance File`, `Insurance Master File`, `Referring Provider File`, `Referring Master File`, `Referral Credential File`, `Employer File`, `Employer Master File`
- Documents: `Document Type Master File`, `Image Type Master File`, `Document File`, `Document FileSpec File`, `Image File`, `Image FileSpec File`
- Clinical Data: `Allergy File`, `Clinical Family History File`, `Clinical / Nursing Notes File`, `Lab Results File`, `Orders File`, `Patient Chief Complaint File`, `Prescription History File`, `Problem List File`, `Patient Clinic Item File`, `Vitals File`
- Charge and claim: `CHARGENOTES`
- Appointments: `Appointments`

## Documented relationship clues from the workbook

- `ALLERGY.PATID` links back to the patient account file.
- Charge and claim content references `PATIENTACCOUNT` by `PATID`.
- Appointment content includes scheduling-book context that appears to connect to appointment-book master data.
- The workbook repeatedly partitions patient-centered core files from supporting master files, which supports a hub-and-spoke reconstruction around patient registration and visit activity.

## Inventory status for this scoping pass

- Active files-schema views: not re-counted in-tool during this pass; using the user-validated candidate set above as the working active inventory.
- Empty files-schema views: not established during this pass.
