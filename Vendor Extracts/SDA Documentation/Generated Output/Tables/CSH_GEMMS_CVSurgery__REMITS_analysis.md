# CSH_GEMMS_CVSurgery REMITS Analysis

## Source

- Source view: `files.REMITS`
- Requested target candidate: `etl_medical.Transaction` support candidate
- Review scope: billing-domain second-pass validation from local SDA artifacts plus workbook evidence

## Structural Summary

`files.REMITS` appears to be a billing-support remittance surface in the GEMMS ONE `files` schema. Current local evidence places it behind payment and check workflows rather than as a primary patient, charge-line, or claim-header table.

The strongest current interpretation is that `files.REMITS` captures insurer remittance or remit-posting context that downstream payment records may reference through `REMITID`, with broader claim lineage inherited indirectly through `CHARGE` and `PAYMENT`.

## Columns Observed

Live source metadata could not be retrieved in this pass.

Columns directly evidenced from local artifacts:

- `REMITID` - inferred from existing local billing-analysis logic that tests `PAYMENT.REMITID = REMITS.REMITID`

Important caveat:

- The local workbook used for other billing-table analyses does not document a `REMITS` section, so no broader source-side column inventory could be confirmed from documentation alone.

## Profiling Status

Live row-count, distinctness, and sample-row profiling could not be completed in this pass. Direct Azure-token probes against the source serverless endpoint failed with `Login failed for user '<token-identified principal>'`, so this analysis is grounded in workbook-adjacent evidence and nearby SDA billing artifacts rather than observed runtime distributions.

## Key Inference

Recommended inferred business key:

- `REMITID`

Confidence: Medium

Rationale: `REMITID` is the only remit-specific key name currently evidenced in local artifacts, and the neighboring payment scratch logic treats it as the candidate bridge from payment events into the remit branch. If later live profiling shows one-to-many remit detail beneath a single remittance header, the durable reconciliation key may need to expand beyond `REMITID`.

## Relationship Inference

### Strongest current direct join hypothesis

```sql
files.PAYMENT.REMITID = files.REMITS.REMITID
```

Confidence: Medium

Basis: the existing local `files.PAYMENT` analysis logic explicitly tests that join. This is the clearest current source-side relationship clue, but it is not documented in the workbook and has not yet been validated with live referential profiling.

### Check-workflow association

```sql
files.REMITS -> files.CHECK
```

Confidence: Low

Basis: the local workbook documents that `CHECK.DESCRIPTION` stores the insurance check number when a payment was posted from remit. That supports a real operational relationship between remit activity and check issuance or posting, but no explicit shared key was recovered from reviewed local artifacts.

### Indirect billing lineage

```sql
files.CLAIM -> files.CHARGE -> files.PAYMENT -> files.REMITS
```

Confidence: Medium

Basis: current local billing analyses support `CLAIM -> CHARGE` and `PAYMENT -> CHARGE`, and carry `PAYMENT -> REMITS` as the leading remit hypothesis. No reviewed evidence supports a direct `CLAIM -> REMITS` or `PATIENTACCOUNT -> REMITS` key.

### Patient and payor context

Patient and payor context appear more likely to be inherited indirectly:

- patient lineage via `PAYMENT -> CHARGE -> PATIENTACCOUNT`
- payor classification via `PAYMENT -> PAYORCODE`

Confidence: Medium for the indirect context path, Low for any direct `REMITS` key into those dimensions.

## Billing-Domain Relevance

`files.REMITS` is relevant to the billing domain as remittance-support or insurer-payment-posting context, but current evidence does not justify treating it as the primary source for `etl_medical.Transaction`.

Best current fit:

- secondary support to `etl_medical.Transaction`
- supporting lineage for payment posting, remit reconciliation, and insurer-check context

Why it matters:

- it likely explains where certain posted payment or check records originated
- it may be useful for remit reconciliation and payer-posting traceability
- it provides financial workflow context not available from patient-centric clinical tables

## Risks and Caveats

- `files.REMITS` is not documented in the local workbook used for the other GEMMS billing extracts reviewed in this project.
- Live source profiling could not be completed because the current Azure-token principal could not query the source endpoint.
- Only `REMITID` is currently evidenced as a likely join column; broader column semantics, nullability, and uniqueness remain unknown.
- A direct patient join is not evidenced and should not be assumed.
- A direct claim join is not evidenced and should not be assumed.
- The `etl_medical.Transaction` target may still be better rooted in `files.PAYMENT` or another transaction-bearing source, with `REMITS` used only for enrichment or reconciliation context.

## Conclusion

`files.REMITS` should currently be modeled as a billing-support remit surface with probable linkage to payment events through `REMITID`. It is relevant to the billing domain, especially for remit reconciliation and insurer-payment workflow context, but it remains a secondary contributor until direct source metadata and live profiling can confirm its true grain, uniqueness, and strongest joins.