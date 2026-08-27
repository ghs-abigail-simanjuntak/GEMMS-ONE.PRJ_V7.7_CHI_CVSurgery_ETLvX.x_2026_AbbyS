# CSH_GEMMS_CVSurgery PAYMENT Analysis

## Source

- Source view: `files.PAYMENT`
- Requested target candidate: `etl_medical.Transaction`
- Review scope: billing-domain second-pass validation from workbook evidence plus project context

## Structural Summary

`files.PAYMENT` appears to be the charge-payment ledger for GEMMS ONE. The workbook defines it as a list of payments applied to a charge for a patient, which places it at a finer grain than patient or account and makes it a strong candidate input for a transaction-style billing domain.

## Columns Observed

Documented in the source workbook:

- `PATID`
- `PAYID`
- `CHGID`
- `PAYDATE`
- `XACDATE`
- `PAYORCODE`
- `DC`
- `XACAMOUNT`
- `STATUS`
- `CHECKID`
- `USERCODE`
- `ENTRYDATE`
- `PLOCATION`

## Profiling Status

Live row-count and distinctness profiling could not be completed in this pass. A direct serverless probe using Azure token authentication failed with `Login failed for user '<token-identified principal>'`, so the current analysis is grounded in the workbook metadata and existing SDA artifacts rather than observed row distributions.

## Key Inference

Recommended inferred primary business key:

- `PAYID`

Confidence: Medium-High

Rationale: the workbook labels `PAYID` as the unique payment identifier and the table description is event-oriented rather than summary-oriented. If later live profiling shows reused `PAYID` values across file partitions or statuses, fall back to `PATID + PAYID` or `CHGID + PAYID`.

## Relationship Inference

### Confirmed-by-documentation joins

```sql
files.PAYMENT.CHGID = files.CHARGE.CHGID
```

Confidence: High

Basis: the workbook explicitly documents `CHGID` in `PAYMENT` as a link to `CHARGE.CSV`.

```sql
files.PAYMENT.PAYORCODE = files.PAYORCODE.PAYORCODE
```

Confidence: High

Basis: the workbook explicitly documents `PAYORCODE` in `PAYMENT` as a link to `PAYORCODE.CSV`, and the `PAYORCODE` file is documented as the payment-code lookup.

```sql
files.PAYMENT.CHECKID = files.CHECK.CHECKID
```

Confidence: High

Basis: the workbook explicitly documents `CHECKID` in `PAYMENT` as a link to `CHECK.CSV`.

```sql
files.PAYMENT.PATID = files.PATIENTACCOUNT.PATID_or_patient_key
```

Confidence: Medium-High

Basis: the workbook explicitly states `PATID` links to `PATIENTACCOUNT.CSV`. Exact key naming on the live `PATIENTACCOUNT` view still needs runtime verification because prior clinical analyses used `PatientID` rather than `PATID`.

### Unresolved or indirect joins

```sql
files.PAYMENT -> files.REMITS
files.PAYMENT -> files.REMITHISTORY
```

Confidence: Low

Basis: no direct remit key is documented on `PAYMENT` in the workbook. The only current remit clue is that `CHECK.DESCRIPTION` stores the insurance check number when the payment was posted from remit, which suggests an operational link through check/remittance workflows rather than a validated direct relational key.

## Domain Fit

`files.PAYMENT` is strongly relevant to the billing domain and is the clearest payment-event source currently documented in the workbook. It aligns best to a transaction-style target because it records monetary activity at the payment event level, preserves charge linkage, and carries payor, amount, posting-date, status, and check context.

Why it fits:

- Represents monetary events rather than static reference data
- Links directly to the parent charge through `CHGID`
- Links to a payor classification lookup through `PAYORCODE`
- Carries temporal and operational posting fields: `PAYDATE`, `XACDATE`, `ENTRYDATE`, `USERCODE`, `PLOCATION`
- Includes lifecycle/state fields such as `STATUS` and `DC`

## Recommended Join Pattern

```sql
FROM GEMMSCV.files.PAYMENT p
INNER JOIN GEMMSCV.files.CHARGE ch
  ON ch.CHGID = p.CHGID
LEFT JOIN GEMMSCV.files.PAYORCODE pc
  ON pc.PAYORCODE = p.PAYORCODE
LEFT JOIN GEMMSCV.files.CHECK ck
  ON ck.CHECKID = p.CHECKID
LEFT JOIN GEMMSCV.files.PATIENTACCOUNT pa
  ON pa.PatientID = p.PATID
```

Implementation note: the patient join column on `PATIENTACCOUNT` should be verified live before production use because the workbook uses `PATID` while current SDA clinical artifacts validated `PatientID` as the patient anchor.

## Risks and Gaps

- Live SQL profiling is still missing because the current token-authenticated principal could not query the source endpoint.
- The existing notebook presence check mapped `etl_medical.Transaction` to `files.edi_invoice`, so `PAYMENT` may be a component of the broader transaction domain rather than the only required source.
- Remit and remit-history linkage is not yet demonstrated with a documented shared key.
- Active-versus-deleted handling matters: `STATUS = 'Y'` is active and `STATUS = 'N'` is deleted.
- Downstream logic may need to distinguish true payments from adjustments or credits using `DC` plus the `PAYORCODE.PAYFLAG` lookup.

## Conclusion

`files.PAYMENT` should be treated as a high-value billing transaction detail source and a strong candidate contributor to `etl_medical.Transaction`. The most defensible immediate model is one row per payment event keyed by `PAYID`, joined first to `CHARGE`, then to `PAYORCODE` and `CHECK`, with patient lineage inherited through `PATID`. Final confirmation of grain, uniqueness, and remit linkage requires live source profiling once source-query permissions are available.