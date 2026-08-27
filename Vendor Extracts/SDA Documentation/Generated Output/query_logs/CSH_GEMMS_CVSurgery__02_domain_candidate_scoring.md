# CSH_GEMMS_CVSurgery Domain Candidate Scoring

Date: 2026-08-26
Mode: domain-focused discovery scoping
Domain topic: Clinical EMR files-schema model for CV Surgery

## Stable source prefix

Recommended source prefix: `CSH_GEMMS_CVSurgery`

Reasoning:

- Matches the user-mandated durable filename prefix.
- Stable across serverless source reconstruction and dedicated reference usage.
- Avoids server and database names as requested.

## Domain keywords used

- `patient`, `pat`, `account`, `demographic`, `registration`, `person`
- `appointment`, `schedule`, `book`
- `encounter`, `visit`, `note`, `chief complaint`, `care event`
- `allergy`, `reaction`, `severity`
- `insurance`, `guarantor`, `claim`, `coverage`
- `message`, `email`, `remit`, `communication`
- `document`, `image`, `note`, `filespec`
- `immunization`, `vaccine`, `shot`
- `medication`, `prescription`, `rx`, `clinical item`
- `order`, `lab order`, `result`, `lab result`, `test result`
- `problem`, `problem list`, `diagnosis`
- `procedure`, `charge`, `service`
- `vital`, `vitals`
- `provider`, `referring provider`, `doctor`, `credential`

## Candidate mapping to requested target domains

### Strong mappings

- `etl_customer.Person` <- `PATIENTACCOUNT`, `PATIENTDEMOGRAPHICS`
  - Reason: patient identity, MRN, account, and demographic attributes are explicitly documented in the workbook.
- `etl_medical.Registration` <- `PATIENTACCOUNT`, `PATIENTDEMOGRAPHICS`, `INSURANCE`, `INSURANCEHISTORY`
  - Reason: registration is patient-account-centered and the workbook partitions account, demographics, and insurance as the intake surface.
- `etl_medical.Allergy` <- `ALLERGY`
  - Reason: direct one-to-one topic and workbook-defined columns include allergen, reaction, status, and severity.
- `etl_medical.Appointment` <- `APPOINTMENTS`
  - Reason: direct scheduling surface with date, time, book, comments, and eligibility fields.
- `etl_medical.Insurance` <- `INSURANCE`, `INSURANCEHISTORY`, `CLAIMINSURANCE`
  - Reason: current coverage, coverage history, and downstream claims insurance context are all present.
- `etl_medical.Problem` <- `PROBLEMLIST`
  - Reason: direct problem-list surface.
- `etl_medical.Vital` <- `VITALS`
  - Reason: direct vitals surface.
- `etl_medical.Result` <- `LABRESULTS`, `PATIENTCLINICALITEMS`
  - Reason: lab results are explicit; patient clinical items may carry additional discrete clinical results.
- `etl_medical.TestResult` <- `LABRESULTS`
  - Reason: explicit lab/test result surface.
- `etl_medical.Order` <- `LABORDERS`
  - Reason: direct orders surface, at least for laboratory workflows.
- `etl_medical.Document` <- `VISITNOTES`, `NURSINGNOTES`
  - Reason: note-bearing views are likely the most clinically meaningful document-like source views inside `files`.
- `etl_medical.Visit` <- `VISITNOTES`, `NURSINGNOTES`, `APPOINTMENTS`
  - Reason: visit activity is most likely reconstructed from visit note content with appointment context.
- `etl_medical.Encounter` <- `VISITNOTES`, `NURSINGNOTES`, `APPOINTMENTS`, `CHARGENOTES`
  - Reason: encounter-like activity appears to be distributed across note, scheduling, and charge-event views.
- `etl_medical.CareEvent` <- `VISITNOTES`, `NURSINGNOTES`, `PATIENTCLINICALITEMS`, `LABORDERS`, `LABRESULTS`
  - Reason: care events are likely synthesized from timestamped clinical actions rather than one dedicated source view.

### Moderate mappings

- `etl_medical.Medication` <- `PATIENTCLINICALITEMS`
  - Reason: this is the best named candidate in the current files-schema list, but the workbook also documents a `Prescription History File` that should be checked for a matching view name.
- `etl_medical.Procedure` <- `LABORDERS`, `CHARGENOTES`
  - Reason: orders and billed service context may be the closest available reconstruction surfaces, but this remains weaker than direct procedure extracts.
- `etl_medical.Message` <- `EMAILMESSAGELOG`
  - Reason: explicit communication surface exists, though it may skew operational rather than clinical.
- `etl_customer.Message` <- `EMAILMESSAGELOG`, `REMITMESSAGES`, `REMITMESSAGEHISTORY`
  - Reason: customer-facing or operational message constructs may exist here, but remit traffic is likely financial rather than EMR messaging.

### Weak or gap-prone mappings

- `etl_medical.ChartAlert` <- `PATIENTCLINICALITEMS`
  - Reason: possible if alerts are encoded as generic clinical items, but no dedicated alert-like files view is currently evident.
- `etl_medical.Immunization` <- `PATIENTCLINICALITEMS`
  - Reason: no dedicated immunization or vaccine view is currently evident in the validated candidate list.

## Boundary and source-supporting views to retain

- `PROVIDERMASTER`
- `PROVIDERDOCTORCODEMASTER`
- `MASTERPROVIDERCODE`
- `MASTERDOCTORCODE`
- `PROVIDERCREDENTIALS`
- `REFERRINGPROVIDER`
- `INSURANCEHISTORY`
- `CLAIMINSURANCE`
- `CHARGENOTES`
- `COLLECTIONNOTES`
- `EMAILMESSAGELOG`
- `REMITMESSAGES`
- `REMITMESSAGEHISTORY`

These views should stay in context because they provide provider attribution, insurance lineage, billing/financial event linkage, or communication context that can clarify person, registration, encounter, visit, and document reconstruction.

## Immediate gaps to confirm early

- No clearly evidenced dedicated files-schema view yet for `ChartAlert`.
- No clearly evidenced dedicated files-schema view yet for `Immunization`.
- The requested target core domains include `etl_medical.Order`, but that table was not included in the user-validated dedicated target-table list for this pass; confirm whether the reference model has an `Order` table under a different name or whether orders fold into another target domain.
- Medication coverage is plausible but not yet well anchored unless the documented `Prescription History File` has a corresponding files view not included in the initial candidate list.
- Procedure coverage is still indirect unless a stronger procedure or charge extract view exists beyond `CHARGENOTES`.
- Message coverage may split between operational email/remit artifacts and true clinical messaging; that distinction needs early validation.

## Suggested initial analysis order anchored on Registration

1. `PATIENTACCOUNT`
2. `PATIENTDEMOGRAPHICS`
3. `INSURANCE`
4. `INSURANCEHISTORY`
5. `APPOINTMENTS`
6. `VISITNOTES`
7. `NURSINGNOTES`
8. `PATIENTCLINICALITEMS`
9. `ALLERGY`
10. `PROBLEMLIST`
11. `VITALS`
12. `LABORDERS`
13. `LABRESULTS`
14. Provider and referring-provider master views
15. Charge, claim, and message-supporting views

This order starts with the patient-registration hub, then attaches scheduling and visit evidence, then expands into discrete clinical domains and finally boundary context.

## Workbook partition note

The workbook appears to partition the extract surface into five practical layers:

1. Demographics and registration identity files
2. Document and image payload files
3. Core clinical activity files
4. Charge and claim support files
5. Appointment scheduling files

That partition strongly suggests reconstructing the model from a patient/account hub outward into visits, notes, results, insurance, and provider attribution rather than treating the files schema as one flat extract surface.
