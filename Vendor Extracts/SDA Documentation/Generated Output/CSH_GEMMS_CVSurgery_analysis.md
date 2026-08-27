# CSH_GEMMS_CVSurgery Technical Analysis

## Data Model Overview

The `GEMMSCV.files` source behaves as a patient-centric extract model. The central registration entity is not a dedicated `Registration` view; instead it is reconstructed from two near-1:1 source views:

- `files.PATIENTACCOUNT` for master patient identity
- `files.PATIENTDEMOGRAPHICS` for contact, demographic, and supplementary registration attributes

All currently validated clinical domains radiate outward from this patient hub through `PatientID`. The strongest non-clinical branch is now the direct billing model, where `files.CHARGE`, `files.CLAIM`, `files.CLAIMINSURANCE`, `files.PAYMENT`, `files.REMITS`, and `files.CLAIMSTATEMENTRUNDATES` expose a parallel patient-anchored finance spine inside the same source schema. The strongest secondary clinical event chain remains laboratory data, where `files.LABRESULTS.ORDER_ID` aligns to `files.LABORDERS.ID`.

## Core Domain Alignment

### High-confidence domains

- `Registration`: `PATIENTACCOUNT` + `PATIENTDEMOGRAPHICS`
- `Account`: `PATIENTACCOUNT` + `PATIENTDEMOGRAPHICS` + `GUARANTOR` + insurance context
- `Appointment`: `APPOINTMENTS`
- `Allergy`: `ALLERGY`
- `Charge`: `CHARGE`
- `Claim`: `CLAIM` + `CLAIMHISTORY` + `CLAIMINSURANCE`
- `Insurance`: `INSURANCE` + `INSURANCEHISTORY`
- `Medication`: `PRESCRIPTIONHISTORY`
- `Order`: `LABORDERS`
- `Payor`: `PAYORCODE` + insurance master views, with patient coverage context from `INSURANCE`
- `Result`: `LABRESULTS` plus selective `PATIENTCLINICALITEMS`
- `TestResult`: `LABRESULTS`
- `Problem`: `PROBLEMLIST`
- `Vital`: `VITALS`

### Medium-confidence reconstructed domains

- `AccountNote`: `CHARGENOTES` and `COLLECTIONNOTES`
- `Encounter`: `APPOINTMENTS`, `VISITNOTES`, `NURSINGNOTES`, and charge context
- `Visit`: `VISITNOTES`, `NURSINGNOTES`, and appointment timing
- `CareEvent`: `PATIENTCLINICALITEMS`, lab activity, and note activity
- `Document`: `VISITNOTES` and `NURSINGNOTES`
- `Person`: provider master and doctor-code views for non-patient persons, plus patient hub for person identity patterns
- `Statement`: `CLAIMSTATEMENTRUNDATES` with charge and claim context
- `Transaction`: `PAYMENT` with remit, payor, and charge enrichment

### Low-confidence or unsupported domains

- `Procedure`: indirect via `LABORDERS` or `CHARGENOTES`
- `Message`: mixed clinical/operational semantics across note, email, and remit views
- `ChartAlert`: no validated direct source yet
- `Immunization`: no validated direct source yet

## Inferred Primary Keys

| Source view | Recommended primary key | Confidence | Rationale |
|---|---|---|---|
| `PATIENTACCOUNT` | `PatientID` | High | Fully distinct in observed data; `ACCOUNT` and `MRN` are also distinct alternates. |
| `PATIENTDEMOGRAPHICS` | `PatientID` | High | Near-1:1 patient dimension. |
| `ALLERGY` | `PatientID`, `COMPOSITEALLERGYID` | Medium | `COMPOSITEALLERGYID` alone is not globally distinct. |
| `APPOINTMENTS` | `PatientID`, `ADATE`, `AKEYTIME`, `BOOKCODE`, `REASONCODE` | Medium | Best event-grain composite currently available. |
| `INSURANCE` | `PatientID`, `INUM`, `POLICYNO`, `INSCODE` | Medium | High distinctness but not perfectly unique on the non-patient subset alone. |
| `INSURANCEHISTORY` | `RECID` | High | Fully distinct in observed data. |
| `LABORDERS` | `ID` | High | Almost perfectly distinct and event-oriented. |
| `LABRESULTS` | `ORDER_ID`, `OBSERVE_ID`, `TSEQUENCE`, `TSUBSEQ`, `TSUBSEQA` | High | Fully distinct in observed sample and structurally event-like. |
| `PRESCRIPTIONHISTORY` | `PatientID`, `PRESCRIPTI`, `RXDATE`, `DRUGNAME` | High | High-cardinality composite key with direct medication semantics and full patient coverage. |
| `PROBLEMLIST` | `PatientID`, `PROBLEM`, `ENTRYDATE`, `PROV` | Medium | Problem facts recur per patient across time and provider. |
| `VISITNOTES` | `PatientID`, `NOTEDATE`, `USERCODE` | Medium | Distinct in current sample. |
| `NURSINGNOTES` | `PatientID`, `MDATE`, `MSGTYPE`, `VISITDATE` | Medium | Strong event distinctness, but likely not source-enforced. |
| `VITALS` | `PatientID`, `DATETIME`, `VDATE`, `PROV` | Medium | Best available visit-time composite. |
| `PATIENTCLINICALITEMS` | `PatientID`, `SECTION`, `VARCODE`, `REPORTED` | Medium | High-cardinality discrete fact grain. |
| `CHARGE` | `PatientID`, `CHGID` | High | Fully distinct in the observed finance profile and directly aligned to charge-line grain. |
| `CLAIM` | `PatientID`, `INCIDENTNO`, `CLAIMID` | Medium | Best current header-grain composite; do not assume `CLAIMID` alone safely joins to all child finance rows. |
| `CLAIMHISTORY` | `PatientID`, `RUNDATE`, `RUNID`, `CHGID`, `CLAIMID` | Medium | Historical claim-run grain with repeated lifecycle entries. |
| `CLAIMINSURANCE` | `PatientID`, `INCIDENTNO`, `INUM`, `INSCODE` | Medium | High distinctness and clear claim-payer semantics. |
| `CLAIMSTATEMENTRUNDATES` | `PatientID`, `CHGID`, `RUNDATE` | Medium | Natural statement-run bridge keyed by patient-charge-date. |
| `PAYMENT` | `PatientID`, `PAYID`, `CHGID` | High | Fully distinct in the observed finance profile and directly tied to charge activity. |
| `REMITS` | `PatientID`, `RECID`, `CHGID` | High | Fully distinct in the observed remit profile. |
| `REMITHISTORY` | `PatientID`, `RECID`, `CHGID`, `PAYDATE` | Medium | Historical remittance ledger with repeated lifecycle entries. |
| `PAYORCODE` | `PAYORCODE` | High | Lookup-style payer dimension. |
| `INSURANCEMASTER` | `CODE` | High | Lookup-style insurance master dimension. |
| `INSURANCECODEMASTER` | `INSCODE`, `IDNAME`, `ENTERED` | Medium | Historical or property-style insurance code grain. |

## Inferred Foreign Keys and Relationships

| Child view | Parent view | Join | Confidence | Basis |
|---|---|---|---|---|
| `PATIENTDEMOGRAPHICS` | `PATIENTACCOUNT` | `d.PatientID = p.PatientID` | High | Near-1:1 patient dimension. |
| `ALLERGY` | `PATIENTACCOUNT` | `a.PatientID = p.PatientID` | High | 100% live match and workbook support. |
| `APPOINTMENTS` | `PATIENTACCOUNT` | `appt.PatientID = p.PatientID` | High | 100% live match. |
| `INSURANCE` | `PATIENTACCOUNT` | `ins.PatientID = p.PatientID` | High | 100% live match. |
| `INSURANCEHISTORY` | `PATIENTACCOUNT` | `ih.PatientID = p.PatientID` | High | Shared patient key and historical ledger shape. |
| `LABORDERS` | `PATIENTACCOUNT` | `lo.PatientID = p.PatientID` | High | 100% live match. |
| `LABRESULTS` | `PATIENTACCOUNT` | `lr.PatientID = p.PatientID` | High | 100% live match. |
| `LABRESULTS` | `LABORDERS` | `lr.ORDER_ID = lo.ID` | High | Strongest non-patient event linkage in the current source. |
| `PRESCRIPTIONHISTORY` | `PATIENTACCOUNT` | `rx.PatientID = p.PatientID` | High | 100% live match across 121,578 medication rows. |
| `PROBLEMLIST` | `PATIENTACCOUNT` | `pr.PatientID = p.PatientID` | High | 100% live match. |
| `VITALS` | `PATIENTACCOUNT` | `v.PatientID = p.PatientID` | High | 100% live match. |
| `PATIENTCLINICALITEMS` | `PATIENTACCOUNT` | `pci.PatientID = p.PatientID` | High | Shared leading patient identifier and extract design. |
| `VISITNOTES` | `PATIENTACCOUNT` | `vn.PatientID = p.PatientID` | Medium | Same patient key, but note set is sparse. |
| `NURSINGNOTES` | `PATIENTACCOUNT` | `nn.PatientID = p.PatientID` | High | Same patient key and event volume. |
| `CHARGE` | `PATIENTACCOUNT` | `c.PatientID = p.PatientID` | High | 100 percent live match across 94,202 charge rows. |
| `CLAIM` | `PATIENTACCOUNT` | `cl.PatientID = p.PatientID` | High | Direct patient key present on the header-style claim source. |
| `CLAIMINSURANCE` | `PATIENTACCOUNT` | `ci.PatientID = p.PatientID` | High | 100 percent live match across 520,768 claim-insurance rows. |
| `PAYMENT` | `PATIENTACCOUNT` | `pay.PatientID = p.PatientID` | High | 100 percent live match across 234,755 payment rows. |
| `REMITS` | `PATIENTACCOUNT` | `r.PatientID = p.PatientID` | High | 100 percent live match across 13,887 remit rows. |
| `PAYMENT` | `CHARGE` | `pay.PatientID = c.PatientID AND pay.CHGID = c.CHGID` | High | 90,199 distinct patient-charge pairs matched in live profiling. |
| `REMITS` | `CHARGE` | `r.PatientID = c.PatientID AND r.CHGID = c.CHGID` | Medium | 7,833 distinct patient-charge pairs matched in live profiling. |
| `PAYMENT` | `PAYORCODE` | `pay.PAYORCODE = pc.PAYORCODE` | High | Direct code-based join with 80 observed matched payor codes. |
| `CLAIMSTATEMENTRUNDATES` | `CHARGE` | `csrd.PatientID = c.PatientID AND csrd.CHGID = c.CHGID` | Medium | Strong structural fit for statement-run lineage, but downstream statement identity remains inferred. |
| `ALLERGY` | `PROVIDERMASTER` | `a.PROV = pm.PROV` | Medium | Provider code naming pattern only; value profiling pending. |
| `LABORDERS` | `PROVIDERMASTER` | `lo.PROV = pm.PROV` | Medium | Direct provider-code pattern. |
| `PROBLEMLIST` | `PROVIDERMASTER` | `pr.PROV = pm.PROV` | Medium | Direct provider-code pattern. |
| `VITALS` | `PROVIDERMASTER` | `v.PROV = pm.PROV` | Medium | Direct provider-code pattern. |

The direct `CLAIM` to `CHARGE` and `CLAIM` to remit lineage remains grain-sensitive. The source exposes overlapping `INCIDENTNO`, `CLAIMID`, and `CHGID` identifiers, but current live checks do not yet support treating those as a single uniform parent-child key.

## Join Definitions

### Patient-centric EMR spine

```sql
FROM files.PATIENTACCOUNT p
LEFT JOIN files.PATIENTDEMOGRAPHICS d
  ON d.PatientID = p.PatientID
LEFT JOIN files.INSURANCE ins
  ON ins.PatientID = p.PatientID
LEFT JOIN files.INSURANCEHISTORY ih
  ON ih.PatientID = p.PatientID
LEFT JOIN files.ALLERGY a
  ON a.PatientID = p.PatientID
LEFT JOIN files.APPOINTMENTS appt
  ON appt.PatientID = p.PatientID
LEFT JOIN files.PROBLEMLIST pr
  ON pr.PatientID = p.PatientID
LEFT JOIN files.VITALS v
  ON v.PatientID = p.PatientID
LEFT JOIN files.LABORDERS lo
  ON lo.PatientID = p.PatientID
LEFT JOIN files.LABRESULTS lr
  ON lr.PatientID = p.PatientID
LEFT JOIN files.PRESCRIPTIONHISTORY rx
  ON rx.PatientID = p.PatientID
LEFT JOIN files.PATIENTCLINICALITEMS pci
  ON pci.PatientID = p.PatientID
LEFT JOIN files.VISITNOTES vn
  ON vn.PatientID = p.PatientID
LEFT JOIN files.NURSINGNOTES nn
  ON nn.PatientID = p.PatientID
```

### Clinical-event enrichment around orders and results

```sql
FROM files.PATIENTACCOUNT p
LEFT JOIN files.PRESCRIPTIONHISTORY rx
  ON rx.PatientID = p.PatientID
LEFT JOIN files.PATIENTDEMOGRAPHICS d
  ON d.PatientID = p.PatientID
```

### Medication-focused reconstruction

```sql
FROM files.PATIENTACCOUNT p
INNER JOIN files.PRESCRIPTIONHISTORY rx
  ON rx.PatientID = p.PatientID
LEFT JOIN files.PATIENTDEMOGRAPHICS d
  ON d.PatientID = p.PatientID
```

Recommended medication grain in the current source:

- `PatientID`
- `PRESCRIPTI`
- `RXDATE`
- `DRUGNAME`

Medication attributes immediately available from the source include `ACTIVEFLAG`, `DAYSSUPPLY`, `DISPENSE`, `NDC`, `RXNORM`, `IDC9`, `INSTRUCTIO`, `PROV`, `REASON`, `REFILLS`, `SOURCE`, `STOPDATE`, and `STOPUSER`.

Medication provider attribution is not yet safe to join because `PRESCRIPTIONHISTORY.PROV` values did not directly match the current provider master surfaces.

```sql
FROM files.PATIENTACCOUNT p
INNER JOIN files.LABORDERS lo
  ON lo.PatientID = p.PatientID
LEFT JOIN files.LABRESULTS lr
  ON lr.PatientID = lo.PatientID
 AND lr.ORDER_ID = lo.ID
LEFT JOIN files.PROVIDERMASTER pm
  ON pm.PROV = lo.PROV
LEFT JOIN files.PROVIDERMASTER rpm
  ON rpm.PROV = lo.REVIEWPROV
LEFT JOIN files.PROVIDERMASTER dpm
  ON dpm.PROV = lo.DRAWPROV
```

### Note-driven visit or encounter reconstruction

```sql
FROM files.PATIENTACCOUNT p
LEFT JOIN files.APPOINTMENTS appt
  ON appt.PatientID = p.PatientID
LEFT JOIN files.NURSINGNOTES nn
  ON nn.PatientID = p.PatientID
 AND nn.VISITDATE = appt.ADATE
LEFT JOIN files.VISITNOTES vn
  ON vn.PatientID = p.PatientID
 AND vn.NOTEDATE = appt.ADATE
LEFT JOIN files.PROVIDERMASTER pm
  ON pm.PROV = appt.SVCUSER
```

The final join in that encounter-style pattern is low confidence because `SVCUSER` may represent an application user rather than a provider code.

### Billing-focused reconstruction

```sql
FROM files.PATIENTACCOUNT p
LEFT JOIN files.PATIENTDEMOGRAPHICS d
  ON d.PatientID = p.PatientID
LEFT JOIN files.GUARANTOR g
  ON g.PatientID = p.PatientID
LEFT JOIN files.INSURANCE ins
  ON ins.PatientID = p.PatientID
LEFT JOIN files.INSURANCEHISTORY ih
  ON ih.PatientID = p.PatientID
LEFT JOIN files.CHARGE c
  ON c.PatientID = p.PatientID
LEFT JOIN files.CLAIM cl
  ON cl.PatientID = p.PatientID
LEFT JOIN files.CLAIMINSURANCE ci
  ON ci.PatientID = p.PatientID
LEFT JOIN files.PAYMENT pay
  ON pay.PatientID = p.PatientID
LEFT JOIN files.REMITS r
  ON r.PatientID = p.PatientID
LEFT JOIN files.REMITHISTORY rh
  ON rh.PatientID = p.PatientID
LEFT JOIN files.CLAIMSTATEMENTRUNDATES csrd
  ON csrd.PatientID = p.PatientID
```

### Billing detail with strongest validated joins

```sql
FROM files.PATIENTACCOUNT p
INNER JOIN files.CHARGE c
  ON c.PatientID = p.PatientID
LEFT JOIN files.PAYMENT pay
  ON pay.PatientID = c.PatientID
 AND pay.CHGID = c.CHGID
LEFT JOIN files.REMITS r
  ON r.PatientID = c.PatientID
 AND r.CHGID = c.CHGID
LEFT JOIN files.CLAIMSTATEMENTRUNDATES csrd
  ON csrd.PatientID = c.PatientID
 AND csrd.CHGID = c.CHGID
LEFT JOIN files.PAYORCODE pc
  ON pc.PAYORCODE = pay.PAYORCODE
LEFT JOIN files.CHARGENOTES cn
  ON cn.PatientID = c.PatientID
 AND cn.CHGID = c.CHGID
LEFT JOIN files.COLLECTIONNOTES coln
  ON coln.PatientID = c.PatientID
```

That pattern is the safest current finance reconstruction because it uses the joins that were directly supported in live profiling. It intentionally does not force `CHARGE.CLAIMID = CLAIM.CLAIMID`.

## Assumptions and Gaps

- `PATIENTACCOUNT` is treated as the `Registration` root because it is the only fully unique patient identity surface in the current source set.
- `PATIENTDEMOGRAPHICS` is treated as optional enrichment because it is nearly but not perfectly 1:1 with `PATIENTACCOUNT`.
- Provider joins are still inferential until direct value-overlap profiling is completed across `PROV`, `DOCTOR`, `PROVID`, and `USERCODE`.
- Event keys for appointments, notes, vitals, and problems are composite and likely not source-enforced.
- Finance keys are also grain-sensitive. `CHARGE`, `CLAIM`, `CLAIMINSURANCE`, `CLAIMSTATEMENTRUNDATES`, `PAYMENT`, and remit views all participate in the same billing branch, but they do not yet resolve to a single validated universal parent-child key.
- `PAYORCODE`, `INSURANCEMASTER`, and `INSURANCECODEMASTER` provide strong payer and insurance dimension signals, but the final normalized payor crosswalk is still partial.
- `PRESCRIPTIONHISTORY` materially upgrades the medication domain, but provider attribution within that domain remains unresolved.
- `PATIENTCLINICALITEMS` is still too broad to map safely to immunization or chart-alert domains without code-level profiling.
- The current result surface is still laboratory-heavy outside the now-confirmed medication coverage. Broader document, immunization, and alert coverage likely exists in additional boundary views not yet profiled.

## Confidence Summary

- High: patient-to-domain joins on `PatientID`; `PATIENTACCOUNT` as registration hub; `LABRESULTS.ORDER_ID = LABORDERS.ID`; `CHARGE` and `PAYMENT` finance joins; direct billing source availability
- Medium: provider attribution joins, appointment event keys, visit and encounter reconstruction, payor normalization, statement modeling, and claim-header lineage beyond the patient key
- Low: chart alert, immunization, generalized procedure mapping, and universal claim-to-remit parentage from the current in-scope views