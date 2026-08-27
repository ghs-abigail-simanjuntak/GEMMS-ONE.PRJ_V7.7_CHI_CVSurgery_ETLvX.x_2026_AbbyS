# SDA TODO

## Scope
- Server: ghs-aetl-workspace-chi-chigemms1-ondemand.sql.azuresynapse.net
- Database: GEMMSCV
- Schema: files
- Discovery mode: domain
- Output root: CSH_GEMMS_CVSurgery under this SDA root
- Status: initial clinical synthesis completed; medication second-pass completed; accounting and billing expansion completed; targeted edge validation remains for selected finance joins

## CSH_GEMMS_CVSurgery

### Completed
- Scaffolded and reused artifact root under the CV Surgery client folder.
- Validated source engine as Azure Synapse serverless (EngineEdition 11).
- Validated reference target engine as Azure Synapse dedicated pool (EngineEdition 6).
- Confirmed the source `files` schema and the reference `etl_customer` / `etl_medical` schemas.
- Confirmed a patient-centric hub anchored on `files.PATIENTACCOUNT` with `files.PATIENTDEMOGRAPHICS` as the companion demographic dimension.
- Completed a medication second-pass and confirmed `files.PRESCRIPTIONHISTORY` as the primary medication source view.
- Validated direct accounting and billing source views in the `files` schema, including `CHARGE`, `CLAIM`, `CLAIMHISTORY`, `CLAIMINSURANCE`, `CLAIMSTATEMENTRUNDATES`, `PAYMENT`, `REMITS`, `REMITHISTORY`, `PAYORCODE`, `INSURANCEMASTER`, and `INSURANCECODEMASTER`.
- Confirmed strong patient-hub reuse across the finance branch, including 100 percent `PatientID` match coverage for tested `CHARGE`, `CLAIMINSURANCE`, `PAYMENT`, `REMITS`, `INSURANCE`, and `CHARGENOTES` joins back to `PATIENTACCOUNT`.
- Published focused per-view finance analyses for `files.CHARGE`, `files.CLAIM`, `files.PAYMENT`, and `files.REMITS`.
- Published domain-scoped artifacts: domain, schema analysis, technical analysis, and key-table ranking.
- Published a focused per-view analysis for `files.PRESCRIPTIONHISTORY`.

### In Progress
- Tighten exact lineage among `CLAIM`, `CHARGE`, `CLAIMINSURANCE`, `CLAIMSTATEMENTRUNDATES`, `REMITS`, and `REMITHISTORY` where the source uses different business grains.
- Strengthen provider and payer normalization around `PROV`, `DOCTOR`, `PROVID`, `USERCODE`, `PAYORID`, and `INSCODE` crosswalks.

### Remaining
- Review `files.patients`, `files.enc`, `files.document`, `files.immunizations`, `files.globalalertdetails`, and the `files.labdata*` family.
- Review whether `files.CHECK`, `files.CLAIMREMITHISTORY`, `files.CLAIMREMITMESSAGEHISTORY`, `files.UNDERPAYMENT`, and `files.CHARGERESPONSIBILITY` should be elevated in a third finance pass.
- Confirm whether statement output should be modeled solely from `files.CLAIMSTATEMENTRUNDATES` or whether additional statement-oriented boundary views are required.
- Confirm whether the dedicated target for orders is `etl_medical.Order` under a different physical name or folded into another domain.
- Publish additional per-view canonical analyses if a second-pass expansion is requested.

## Tables
- Registration hub: `files.PATIENTACCOUNT`, `files.PATIENTDEMOGRAPHICS`
- Direct clinical children: `files.ALLERGY`, `files.APPOINTMENTS`, `files.INSURANCE`, `files.INSURANCEHISTORY`, `files.LABORDERS`, `files.LABRESULTS`, `files.PRESCRIPTIONHISTORY`, `files.PROBLEMLIST`, `files.VITALS`, `files.PATIENTCLINICALITEMS`, `files.VISITNOTES`, `files.NURSINGNOTES`
- Direct accounting and billing views: `files.CHARGE`, `files.CLAIM`, `files.CLAIMHISTORY`, `files.CLAIMINSURANCE`, `files.CLAIMSTATEMENTRUNDATES`, `files.PAYMENT`, `files.REMITS`, `files.REMITHISTORY`, `files.PAYORCODE`, `files.INSURANCEMASTER`, `files.INSURANCECODEMASTER`
- Boundary/provider/supporting views: `files.PROVIDERMASTER`, `files.PROVIDERDOCTORCODEMASTER`, `files.MASTERPROVIDERCODE`, `files.MASTERDOCTORCODE`, `files.PROVIDERCREDENTIALS`, `files.REFERRINGPROVIDER`, `files.GUARANTOR`, `files.CHARGENOTES`, `files.COLLECTIONNOTES`, `files.PAYMENTEOB`, `files.REMITMESSAGES`, `files.REMITMESSAGEHISTORY`, `files.EMAILMESSAGELOG`, `files.EMPLOYER`, `files.EMPLOYERMASTER`
