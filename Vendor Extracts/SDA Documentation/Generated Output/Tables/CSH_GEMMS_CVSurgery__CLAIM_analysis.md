# CSH_GEMMS_CVSurgery CLAIM Analysis

## Source

- Source view: `files.CLAIM`
- Primary target domain: `etl_medical.Claim`
- Requested billing context: `PATIENTACCOUNT`, `CHARGE`, `CLAIMINSURANCE`, `CLAIMSTATEMENTRUNDATES`, `REMITS`

## Structural Summary

`files.CLAIM` appears to be the GEMMS ONE claim-header or episode-billing source for the `files` schema. The workbook describes it as the claim information associated to a patient's episode number, and the documented columns emphasize episode dates, referral/preauthorization data, primary and secondary procedures, billing flags, and claim-frequency fields rather than charge-line detail.

That makes `files.CLAIM` the strongest current source candidate for `etl_medical.Claim`, with `files.CHARGE` acting as line-level financial detail beneath it and `files.CLAIMINSURANCE` acting as downstream coverage/claim lineage context.

## Columns Observed

Columns confirmed from the local workbook evidence:

- `PATID`
- `CLAIMID`
- `INCIDENTNO`
- `ADMDATE`
- `INCDATE1`
- `PREAUT`
- `REFERRAL`
- `PROC1`
- `PROC2`
- `HOSPDATE1`
- `HOSPDATE2`
- `ADMTYPE`
- `FACCODE`
- `REMARK`
- `BILLFLAG`
- `PINUM`
- `EPSDT`
- `CERTIFICATE1`
- `CERTIFICATE2`
- `SYMPTOMDATE`
- `ACCIDENTSTATE`

Columns of interest:

- `CLAIMID`: strongest documented claim-level identifier.
- `PATID`: patient anchor back to the registration hub.
- `INCIDENTNO`: episode number and likely the best operational link back to episode-based billing activity.
- `PROC1`, `PROC2`: procedure summary fields that reinforce claim-header grain rather than line grain.
- `PINUM`: primary insurance ordinal, useful for insurance-context alignment but not sufficient alone for claim identity.
- `CERTIFICATE1`, `CERTIFICATE2`, `BILLFLAG`: signs that rebills or frequency-code-driven resubmissions may exist.

## Estimated Grain

Estimated grain: one row per claim header for a patient's episode of care.

Confidence: Medium-High

Rationale: the source description is explicitly episode-oriented, and the observed columns cluster around claim-level dates, claim submission metadata, and summarized procedure/insurance context rather than charge-line repetition.

## Key Inference

Recommended business key:

- `CLAIMID`

Recommended reconciliation composite when validating extracts downstream:

- (`PATID`, `INCIDENTNO`, `CLAIMID`)

Confidence: Medium

Rationale: `CLAIMID` is the only directly documented non-null claim identifier. `INCIDENTNO` clearly expresses episode grain, but the presence of claim-frequency-related fields means one episode could plausibly generate multiple claim records over time. Pairing `CLAIMID` with patient and episode context is the safest current recommendation until live distinct-count profiling is available.

## Relationship Inference

### Strongest documented join

```sql
files.CLAIM.PATID = files.PATIENTACCOUNT.PatientID
```

Confidence: High

Basis: the workbook explicitly links charge and claim content back to `PATIENTACCOUNT` by `PATID`, and the broader project already treats `PATIENTACCOUNT.PatientID` as the canonical patient hub.

### Strong non-patient billing join

```sql
files.CLAIM.CLAIMID = files.CHARGE.CLAIMID
```

Confidence: Medium-High

Basis: both billing files carry `CLAIMID`, and the workbook documents `CHARGE` as the charge-line extract generated for a patient while `CLAIM` carries the claim header associated to that episode.

Recommended robust pattern:

```sql
FROM files.CLAIM cl
INNER JOIN files.CHARGE ch
  ON ch.CLAIMID = cl.CLAIMID
 AND ch.PATID = cl.PATID
```

### Episode-alignment join

```sql
files.CLAIM.INCIDENTNO = files.CHARGE.INCIDENTNO
```

Confidence: Medium-High

Basis: `INCIDENTNO` is documented as the episode number in both billing contexts and is explicitly linked from the claim file back to charge activity.

Use: best as a secondary consistency key or fallback episode join, not as the sole durable identifier.

### Insurance lineage join

```sql
files.CLAIM -> files.CLAIMINSURANCE
```

Most likely candidate keys: `CLAIMID` first, then patient-plus-insurance context if needed.

Confidence: Low-Medium

Basis: local domain artifacts place `CLAIMINSURANCE` squarely in the insurance/claim boundary layer, but the reviewed workbook and scratch files did not surface a verified shared key for this specific join.

### Remit lineage join

```sql
files.CLAIM -> files.CHARGE -> files.PAYMENT -> files.REMITS
```

Confidence: Medium for the indirect path

Basis: existing local payment-analysis logic explicitly tests `PAYMENT.CHARGEID -> CHARGE.CHARGEID` and `PAYMENT.REMITID -> REMITS.REMITID`. No reviewed local evidence established a direct `CLAIM -> REMITS` key.

### Statement-run lineage

`files.CLAIMSTATEMENTRUNDATES` could not be validated from reviewed local artifacts.

Confidence: Low / unresolved

Basis: the object was not evidenced in the workbook extract or the current SDA scratch/report files reviewed in this pass.

## Billing-Domain Relevance

`files.CLAIM` is highly relevant to the billing domain and should be treated as the primary claim-header source for this GEMMS CV Surgery discovery. It fills a gap that `files.CLAIMINSURANCE` and `files.CHARGENOTES` cannot fill on their own because it carries episode-level claim context, procedure summary fields, preauthorization/referral elements, and claim-submission metadata.

Best-fit mappings:

- Primary: `etl_medical.Claim`
- Secondary support: `etl_medical.Insurance`, `etl_medical.Encounter`, and `etl_medical.Procedure` boundary context

## Risks and Caveats

- No live profiling was possible in this pass because direct source access failed for the current Azure token principal with login error `18456`.
- `CLAIMID` is the best documented identifier, but uniqueness could not be verified.
- `INCIDENTNO` should not be assumed unique because claim-frequency fields imply possible rebills or replacement claims for the same episode.
- `CLAIMINSURANCE` relevance is strong at the domain level, but the exact join key back to `CLAIM` remains unverified from local evidence.
- `CLAIMSTATEMENTRUNDATES` remains unresolved and should not be used in canonical join guidance until source metadata or profiling is available.

## Conclusion

`files.CLAIM` should be modeled as a claim-header table at episode grain and is the best available source candidate for `etl_medical.Claim` in the current GEMMS CV Surgery discovery. The most defensible immediate join pattern is patient anchoring through `PATIENTACCOUNT` plus claim/episode alignment to `CHARGE`, while remit and statement-run linkage should remain explicitly caveated until direct profiling access is restored.