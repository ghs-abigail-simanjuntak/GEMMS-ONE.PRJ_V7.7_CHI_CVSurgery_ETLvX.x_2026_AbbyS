# CSH_GEMMS_CVSurgery Schema Analysis

## Platform Summary

- Source platform: Azure Synapse serverless SQL pool (`EngineEdition = 11`)
- Reference platform: Azure Synapse dedicated SQL pool (`EngineEdition = 6`)
- Source schema analyzed: `files`
- Reference schemas consulted: `etl_customer`, `etl_medical`

Serverless behavior matters here: the source surface is view-based over parquet-backed extracts, foreign keys are not available, and relationship inference must come from naming, documented layout, and live value overlap.

## Source Inventory Summary

The `files` schema contains 82 views. The domain-focused candidate set was reduced to the clinically relevant subset below.

| Source view | Rows | Distinct `PatientID` | Candidate key signal | Interpretation |
|---|---:|---:|---|---|
| `PATIENTACCOUNT` | 41,273 | 41,273 | `ACCOUNT` and `MRN` also 41,273 distinct | Registration hub; one row per patient in this extract. |
| `PATIENTDEMOGRAPHICS` | 41,271 | 41,271 | `PatientID` unique within observed rowset | Near-1:1 demographic companion to registration. |
| `ALLERGY` | 17,981 | 9,335 | `COMPOSITEALLERGYID` only 1,043 distinct | Patient-level allergy facts; source key likely composite rather than global. |
| `APPOINTMENTS` | 36,380 | 13,187 | 32,808 distinct on `ADATE/AKEYTIME/BOOKCODE/REASONCODE` | Appointment grain is event-like, not patient-like. |
| `INSURANCE` | 25,213 | 16,012 | 25,118 distinct on `INUM/POLICYNO/INSCODE` | Current coverage records. |
| `INSURANCEHISTORY` | 32,069 | 9,937 | `RECID` 32,069 distinct | Historical insurance ledger. |
| `LABORDERS` | 28,656 | 7,969 | `ID` 28,472 distinct | Strong order source, almost unique on order ID. |
| `LABRESULTS` | 9 | 1 | 9 distinct on `ORDER_ID/OBSERVE_ID/TSEQUENCE/TSUBSEQ/TSUBSEQA` | Sparse but structurally clear test-result grain. |
| `PRESCRIPTIONHISTORY` | 121,578 | 9,646 | 117,401 distinct on `PatientID/PRESCRIPTI/RXDATE/DRUGNAME` | Direct medication history source with strong event-level grain. |
| `PROBLEMLIST` | 77,890 | 7,557 | 36,947 distinct on `PROBLEM/ENTRYDATE/PROV` | Problem records require composite event semantics. |
| `VISITNOTES` | 129 | 111 | 129 distinct on `NOTEDATE/USERCODE` | Very small note set; useful for document and visit enrichment. |
| `NURSINGNOTES` | 52,238 | 11,445 | 51,303 distinct on `MDATE/MSGTYPE/VISITDATE` | High-volume event/note surface. |
| `VITALS` | 14,940 | 6,837 | 11,787 distinct on `DATETIME/VDATE/PROV` | Vitals recorded at repeated patient-time grain. |
| `PATIENTCLINICALITEMS` | 1,368,561 | 8,844 | 694,234 distinct on `SECTION/VARCODE/REPORTED` | Broad discrete-clinical fact table; likely crosses several target domains. |

## Accounting Expansion Inventory

The finance pass invalidated the earlier assumption that accounting support would be mostly boundary-only. The `files` schema contains a populated direct billing branch.

| Source view | Rows | Candidate key signal | Join signal | Interpretation |
|---|---:|---|---|---|
| `CHARGE` | 94,202 | 94,202 distinct on `PatientID/CHGID` | 100 percent matched to `PATIENTACCOUNT` on `PatientID` | Direct charge-line transaction surface. |
| `CLAIM` | 94,201 | Header-like grain across `PatientID`, `INCIDENTNO`, `CLAIMID` | Patient key present; exact child linkage still grain-sensitive | Direct claim-header surface. |
| `CLAIMHISTORY` | 578,364 | Run-history style composite over claim plus run metadata | Supports historical claim lifecycle | Claim submission or history ledger. |
| `CLAIMINSURANCE` | 520,768 | 54,779 distinct on `PatientID/INCIDENTNO/INUM/INSCODE` | 100 percent matched to `PATIENTACCOUNT` on `PatientID` | Claim-payer detail layer. |
| `CLAIMSTATEMENTRUNDATES` | 112,599 | Natural grain on `PatientID/CHGID/RUNDATE` | Charge-oriented statement bridge by structure | Statement run bridge. |
| `PAYMENT` | 234,755 | 234,755 distinct on `PatientID/PAYID/CHGID` | 100 percent matched to `PATIENTACCOUNT`; 90,199 distinct patient-charge pairs matched `CHARGE`; 80 distinct codes matched `PAYORCODE` | Direct payment transaction surface. |
| `REMITS` | 13,887 | 13,887 distinct on `PatientID/RECID/CHGID` | 100 percent matched to `PATIENTACCOUNT`; 7,833 distinct patient-charge pairs matched `CHARGE` | Remit or ERA-style transaction support. |
| `REMITHISTORY` | 76,244 | History-style remit grain over `RECID` plus dates | Historical companion to `REMITS` | Remittance history ledger. |
| `PAYORCODE` | 91 | Lookup on `PAYORCODE` | Supports direct `PAYMENT.PAYORCODE` normalization | Payor lookup dimension. |
| `INSURANCEMASTER` | 333 | Lookup on `CODE` | Supports selected insurance-code normalization | Insurance master dimension. |
| `INSURANCECODEMASTER` | 1,607 | Historical code/property lookup | Supports payer and insurance code enrichment | Insurance code history or properties dimension. |

## High-Confidence Relationships

Every tested child domain below joined back to `PATIENTACCOUNT.PatientID` at 100 percent matched rows in the current dataset:

- `ALLERGY`
- `APPOINTMENTS`
- `CHARGE`
- `CLAIMINSURANCE`
- `INSURANCE`
- `LABORDERS`
- `LABRESULTS`
- `PAYMENT`
- `PROBLEMLIST`
- `REMITS`
- `VITALS`

`PATIENTDEMOGRAPHICS` is a near-complete left-join companion to `PATIENTACCOUNT`, with only two fewer rows in the sampled inventory.

The accounting branch is also patient-anchored, but not all finance views operate at the same business grain. Distinct-pair checks are safer than raw row-count joins when comparing `INCIDENTNO`, `CLAIMID`, and `CHGID` paths.

## Source Definition Signals

View definitions show a consistent extract pattern:

- Most direct clinical views surface `PatientID` as the first projected column.
- `PATIENTACCOUNT` exposes patient identity columns such as `ACCOUNT`, `MRN`, name parts, DOB, sex, and SSN.
- `PATIENTDEMOGRAPHICS` contributes contact and demographic attributes such as address, phones, race, language, ethnicity, religion, and last visit.
- `ALLERGY`, `LABORDERS`, `LABRESULTS`, `PRESCRIPTIONHISTORY`, `PROBLEMLIST`, `VITALS`, `VISITNOTES`, and `NURSINGNOTES` all present direct patient-attributed clinical facts.
- `PRESCRIPTIONHISTORY` adds medication-specific attributes including `DRUGNAME`, `NDC`, `RXNORM`, `RXDATE`, `REFILLS`, `ACTIVEFLAG`, `STOPDATE`, and `STOPUSER`.
- `CHARGE` exposes direct billing-line attributes such as `CHGID`, `XACDATE`, `BILLDATE`, `CPT`, `MODIFIER`, `PROCDESC`, `ICD9`, `CHGAMOUNT`, `CHGALLOWED`, `STATUS`, `INCIDENTNO`, and `CLAIMID`.
- `CLAIM` exposes claim-header and episode context such as `CLAIMID`, `INCIDENTNO`, `ADMDATE`, `PROC1`, `PROC2`, `PSTATUS`, `BILLFLAG`, `PINUM`, `SINUM`, `TINUM`, and `FACCODE`.
- `PAYMENT` and `REMITS` expose downstream financial transaction detail including payment dates, status, payor or insurer references, and amounts tied back to patient plus charge identifiers.

## Reference Target Coverage

The dedicated reference inventory confirmed the following physical target tables:

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

The current accounting request additionally targets the following dedicated domains for source-side alignment: `etl_customer.Payor`, `etl_medical.Account`, `etl_medical.AccountNote`, `etl_medical.Charge`, `etl_medical.Claim`, `etl_medical.Statement`, and `etl_medical.Transaction`.

`etl_medical.Order` was requested by the user but was not returned by the reference inventory query. That mismatch remains an open validation item.

## Schema-Level Risks

- Serverless views do not expose enforced keys or constraints.
- Many source columns are projected as `varchar(max)`, which prevents strong type-based relationship inference.
- Several clinical-event domains depend on composite natural keys rather than durable surrogate IDs.
- Several finance joins are grain-sensitive. In particular, `CLAIMID`, `INCIDENTNO`, and `CHGID` cannot be assumed to be interchangeable parent keys across `CLAIM`, `CHARGE`, statement, and remit surfaces.
- `PATIENTCLINICALITEMS` is structurally important but semantically broad, so any domain mapping from it should be treated as inferential until section and variable code profiling is completed.
- `PRESCRIPTIONHISTORY.PROV` is highly populated but did not directly match the current provider master or credential views, so medication provider attribution remains unresolved.