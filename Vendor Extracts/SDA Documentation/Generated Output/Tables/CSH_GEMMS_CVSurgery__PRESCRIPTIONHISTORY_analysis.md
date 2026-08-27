# CSH_GEMMS_CVSurgery PRESCRIPTIONHISTORY Analysis

## Source

- Source view: `files.PRESCRIPTIONHISTORY`
- Domain: `etl_medical.Medication`
- Review scope: second-pass medication-only validation

## Structural Summary

`files.PRESCRIPTIONHISTORY` is the direct medication history source for the GEMMS CV Surgery `files` schema. The view projects one patient-attributed medication event row at a grain finer than the patient level and includes both drug identification and lifecycle status fields.

## Columns Observed

- `PatientID`
- `ACTIVEFLAG`
- `DAYSSUPPLY`
- `DISPENSE`
- `NDC`
- `RXNORM`
- `CSASCHED`
- `IDC9`
- `DRUGNAME`
- `INSTRUCTIO`
- `ORIGDATE`
- `PRESCRIPTI`
- `PROV`
- `REASON`
- `REFILLS`
- `RXDATE`
- `SOURCE`
- `STOPDATE`
- `STOPUSER`

## Profiling Results

- Row count: 121,578
- Distinct patients: 9,646
- Distinct prescription identifiers (`PRESCRIPTI`): 2,873
- Distinct composite medication events (`PatientID`, `PRESCRIPTI`, `RXDATE`, `DRUGNAME`): 117,401
- Distinct NDC values: 4,122
- Distinct RxNorm values: 3,611
- Populated `PROV` rows: 121,436
- Distinct nonblank `PROV` values: 41
- Active rows where `ACTIVEFLAG = 'Y'`: 97,292
- Rows with a populated `STOPDATE`: 24,286
- Rows with populated `RXDATE`: 121,578
- Rows with populated `ORIGDATE`: 121,578

## Key Inference

Recommended inferred primary key:

- (`PatientID`, `PRESCRIPTI`, `RXDATE`, `DRUGNAME`)

Confidence: High

Rationale: the combination is highly distinct, preserves the patient relationship, and matches the apparent event grain of the view better than `PRESCRIPTI` alone.

## Relationship Inference

### Confirmed join

```sql
files.PRESCRIPTIONHISTORY.PatientID = files.PATIENTACCOUNT.PatientID
```

Confidence: High

Basis: 121,578 of 121,578 medication rows matched `PATIENTACCOUNT` on `PatientID`.

### Unresolved join

Potential provider attribution candidates were tested against the current provider master surfaces and did not produce direct matches:

- `files.PROVIDERMASTER.PROV`
- `files.PROVIDERDOCTORCODEMASTER.PROV`
- `files.PROVIDERDOCTORCODEMASTER.DOCTOR`
- `files.MASTERDOCTORCODE.PROV`
- `files.MASTERDOCTORCODE.DOCTOR`
- `files.PROVIDERCREDENTIALS.PROVID`

Confidence: Low for any direct provider join at this time.

Interpretation: `PRESCRIPTIONHISTORY.PROV` appears to hold compact provider-name-like tokens such as `BMOSLEY`, `GTOLLIVER`, and `PHODGE`, not the currently profiled provider key values.

## Domain Fit

This view upgrades the medication domain from inferred to directly supported.

Why it fits:

- Contains medication identity fields: `DRUGNAME`, `NDC`, `RXNORM`
- Contains prescribing and lifecycle fields: `PRESCRIPTI`, `RXDATE`, `ORIGDATE`, `REFILLS`, `ACTIVEFLAG`, `STOPDATE`, `STOPUSER`
- Is fully patient-joinable through `PatientID`
- Has enough row volume to represent the medication history longitudinally rather than as a sparse supplement

## Recommended Join Pattern

```sql
FROM files.PATIENTACCOUNT p
INNER JOIN files.PRESCRIPTIONHISTORY rx
  ON rx.PatientID = p.PatientID
LEFT JOIN files.PATIENTDEMOGRAPHICS d
  ON d.PatientID = p.PatientID
```

## Risks and Gaps

- Provider attribution remains unresolved.
- All columns are surfaced as `varchar(max)` in serverless metadata, so date and numeric typing must be normalized downstream.
- `PRESCRIPTI` alone is not sufficiently distinct to act as a durable single-column key.

## Conclusion

`files.PRESCRIPTIONHISTORY` should be treated as the canonical medication source for the current GEMMS CV Surgery discovery. No further medication-domain expansion is required for this second pass unless the implementation specifically needs provider attribution resolved.