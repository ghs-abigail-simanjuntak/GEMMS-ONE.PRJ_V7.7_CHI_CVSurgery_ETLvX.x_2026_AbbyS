# CSH_GEMMS_CVSurgery Domain Scope

## Domain Topic

Clinical plus accounting and billing reconstruction for the `files` schema in `GEMMSCV`, limited to the CV Surgery delivery. The objective is to rebuild a patient-centric source model from the serverless Synapse extract surface and align it to the dedicated pool target domains in `etl_customer` and `etl_medical`, with the finance branch now grounded in direct source views rather than boundary-only proxies.

## Scope Constraints

- Source endpoint: `ghs-aetl-workspace-chi-chigemms1-ondemand.sql.azuresynapse.net` / `GEMMSCV`
- Source schema: `files`
- Reference endpoint only: `ghs-aetl-sql-chi-chigemms1.database.windows.net` / `ghs-aetl-adw-chi-chigemms1`
- Reference schemas: `etl_customer`, `etl_medical`
- Documentation used: `Documentation/GEMMS Data Extract Elements.xlsx`
- All findings are read-only and reconstructive only.

## Domain Keywords

`patient`, `pat`, `account`, `demographic`, `registration`, `person`, `appointment`, `schedule`, `book`, `encounter`, `visit`, `note`, `care event`, `allergy`, `reaction`, `insurance`, `claim`, `coverage`, `message`, `email`, `remit`, `document`, `image`, `medication`, `prescription`, `rx`, `order`, `lab order`, `result`, `test result`, `problem`, `procedure`, `charge`, `vital`, `provider`, `doctor`, `credential`, `referring provider`

## Documentation Evidence

The workbook partitions the extract surface into five operational groups:

1. Demographics
2. Documents
3. Clinical Data
4. Charge and Claim Data
5. Appointments

That partitioning supports a hub-and-spoke model rather than a flat extract namespace. The workbook explicitly states that allergy rows link back to the patient account file by patient ID, and the charge extract similarly anchors on patient account identity.

## Confirmed Domain Source Views

### Registration and Person Hub

- `files.PATIENTACCOUNT`
- `files.PATIENTDEMOGRAPHICS`
- `files.GUARANTOR`

### Direct Clinical Domains

- `files.ALLERGY`
- `files.APPOINTMENTS`
- `files.INSURANCE`
- `files.INSURANCEHISTORY`
- `files.LABORDERS`
- `files.LABRESULTS`
- `files.PROBLEMLIST`
- `files.VITALS`
- `files.PATIENTCLINICALITEMS`
- `files.VISITNOTES`
- `files.NURSINGNOTES`

### Direct Accounting and Billing Domains

- `files.CHARGE`
- `files.CLAIM`
- `files.CLAIMHISTORY`
- `files.CLAIMINSURANCE`
- `files.CLAIMSTATEMENTRUNDATES`
- `files.PAYMENT`
- `files.REMITS`
- `files.REMITHISTORY`
- `files.PAYORCODE`
- `files.INSURANCEMASTER`
- `files.INSURANCECODEMASTER`

## Boundary and Supporting Views

- `files.PROVIDERMASTER`
- `files.PROVIDERDOCTORCODEMASTER`
- `files.MASTERPROVIDERCODE`
- `files.MASTERDOCTORCODE`
- `files.PROVIDERCREDENTIALS`
- `files.REFERRINGPROVIDER`
- `files.CHARGENOTES`
- `files.COLLECTIONNOTES`
- `files.PAYMENTEOB`
- `files.EMPLOYER`
- `files.EMPLOYERMASTER`
- `files.EMAILMESSAGELOG`
- `files.REMITMESSAGES`
- `files.REMITMESSAGEHISTORY`

## Target Domain Mapping

| Dedicated target domain | Primary files view(s) | Support level | Notes |
|---|---|---|---|
| `etl_customer.Person` | `PATIENTACCOUNT`, `PATIENTDEMOGRAPHICS`, provider master views | Medium | Strong patient identity coverage; non-patient person normalization remains partial. |
| `etl_customer.Payor` | `PAYORCODE`, `INSURANCEMASTER`, `INSURANCECODEMASTER`, `INSURANCE` | Medium | Direct payer and insurance master surfaces exist, but no single validated crosswalk covers every `INSCODE` and `PAYORID` path yet. |
| `etl_medical.Registration` | `PATIENTACCOUNT`, `PATIENTDEMOGRAPHICS`, `INSURANCE`, `INSURANCEHISTORY` | High | Best-supported hub in the current source surface. |
| `etl_medical.Account` | `PATIENTACCOUNT`, `PATIENTDEMOGRAPHICS`, `GUARANTOR`, `INSURANCE`, `INSURANCEHISTORY` | High | Strong patient-account hub with direct guarantor and coverage context. |
| `etl_medical.AccountNote` | `CHARGENOTES`, `COLLECTIONNOTES` | Medium | Operational note coverage is direct, but note lineage to downstream account-note semantics is still inferred. |
| `etl_medical.Appointment` | `APPOINTMENTS` | High | Direct scheduling source. |
| `etl_medical.Charge` | `CHARGE` | High | Direct charge-line source with stable patient plus charge grain and billing attributes. |
| `etl_medical.Claim` | `CLAIM`, `CLAIMHISTORY`, `CLAIMINSURANCE` | High | Direct claim-header plus claim-history and payer-line support. |
| `etl_medical.Encounter` | `APPOINTMENTS`, `VISITNOTES`, `NURSINGNOTES`, `CHARGENOTES` | Medium | Event identity is inferred, not explicit. |
| `etl_medical.Insurance` | `INSURANCE`, `INSURANCEHISTORY`, `CLAIMINSURANCE` | High | Current and historical coverage both present. |
| `etl_medical.Message` | `EMAILMESSAGELOG`, `NURSINGNOTES`, `REMITMESSAGES`, `REMITMESSAGEHISTORY` | Low | Mixed clinical and operational semantics. |
| `etl_medical.Statement` | `CLAIMSTATEMENTRUNDATES`, `CLAIM`, `CHARGE` | Medium | Direct statement-run dates are present, but the final statement grain still needs one more lineage pass. |
| `etl_medical.Transaction` | `PAYMENT`, `REMITS`, `REMITHISTORY`, `REMITMESSAGES`, `REMITMESSAGEHISTORY` | Medium | Payment facts are direct and strong; remit linkage is supportive but not yet fully normalized. |
| `etl_medical.Visit` | `VISITNOTES`, `NURSINGNOTES`, `APPOINTMENTS` | Medium | Patient and date links are strong; visit keys are inferred. |
| `etl_medical.Allergy` | `ALLERGY` | High | Direct source with patient linkage and allergy detail. |
| `etl_medical.CareEvent` | `PATIENTCLINICALITEMS`, `LABORDERS`, `LABRESULTS`, `NURSINGNOTES` | Medium | Reconstructed from dated patient activity. |
| `etl_medical.ChartAlert` | none confirmed | Low | Requires second-pass alert-specific boundary search. |
| `etl_medical.Document` | `VISITNOTES`, `NURSINGNOTES` | Medium | Clinically useful note content exists; document master/image extracts need follow-up. |
| `etl_medical.Immunization` | none confirmed, possible `PATIENTCLINICALITEMS` placeholder | Low | No direct immunization view validated yet. |
| `etl_medical.Medication` | `PRESCRIPTIONHISTORY` | High | Direct medication history source with drug identifiers, dispense detail, fill dates, refills, active flag, and stop-state fields. |
| `etl_medical.Order` | `LABORDERS` | High | Strong order-like surface for lab workflows. |
| `etl_medical.Problem` | `PROBLEMLIST` | High | Direct source. |
| `etl_medical.Procedure` | `LABORDERS`, `CHARGENOTES` | Low | Procedure identity still indirect. |
| `etl_medical.Result` | `LABRESULTS`, `PATIENTCLINICALITEMS` | High | Best covered by lab result plus generic clinical item surface. |
| `etl_medical.TestResult` | `LABRESULTS` | High | Direct source. |
| `etl_medical.Vital` | `VITALS` | High | Direct source. |

## Immediate Gaps

- No validated direct source yet for chart alerts.
- No validated direct source yet for immunizations.
- Procedure and encounter identity remain event-inferred rather than source-enforced.
- Exact header-detail linkage among `CLAIM`, `CHARGE`, and statement or remit surfaces is not yet source-enforced and should be treated as grain-sensitive.
- `PAYORCODE`, `INSURANCEMASTER`, and `INSURANCECODEMASTER` are clearly relevant, but the final payer normalization path for every finance branch is not yet fully resolved.
- The dedicated reference inventory did not return a table named `etl_medical.Order`; that target requires separate confirmation.

## Scope Expansion Queue

Recommended next boundary pulls:

- `files.patients`
- `files.enc`
- `files.document`
- `files.immunizations`
- `files.globalalertdetails`
- `files.labdata*`

## Suggested Analysis Order

1. `files.PATIENTACCOUNT`
2. `files.PATIENTDEMOGRAPHICS`
3. `files.INSURANCE`
4. `files.INSURANCEHISTORY`
5. `files.APPOINTMENTS`
6. `files.VISITNOTES`
7. `files.NURSINGNOTES`
8. `files.PATIENTCLINICALITEMS`
9. `files.ALLERGY`
10. `files.PROBLEMLIST`
11. `files.VITALS`
12. `files.LABORDERS`
13. `files.LABRESULTS`
14. Provider master and credential views
15. `files.CHARGE`
16. `files.CLAIM`
17. `files.CLAIMINSURANCE`
18. `files.PAYMENT`
19. `files.REMITS`
20. `files.CLAIMSTATEMENTRUNDATES`
21. Charge, claim, and remit-support boundary views

## Scope Change Log

- Initial scope established from the user-requested clinical domains and confirmed `files` views.
- Provider, claim, and remit surfaces retained as boundary context.
- Event, document, immunization, and alert reinforcement deferred to a later boundary validation.
- Medication was upgraded in the second pass after direct profiling of `files.PRESCRIPTIONHISTORY`.
- Accounting and billing were expanded after direct profiling confirmed populated `CHARGE`, `CLAIM`, `PAYMENT`, `REMITS`, and `CLAIMSTATEMENTRUNDATES` source views in the same `files` schema.