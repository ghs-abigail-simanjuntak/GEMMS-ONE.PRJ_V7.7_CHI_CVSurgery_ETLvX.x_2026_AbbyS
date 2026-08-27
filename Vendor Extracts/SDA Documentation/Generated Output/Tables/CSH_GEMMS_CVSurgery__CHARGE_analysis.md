# CSH_GEMMS_CVSurgery CHARGE Analysis

## Source

- Source view: `files.CHARGE`
- Domain: billing / claims boundary, with `etl_medical.Charge` as the current conceptual target candidate
- Review scope: delegated per-table analysis for charge reconstruction in the GEMMS CV Surgery `files` schema

## Structural Summary

`files.CHARGE` appears to be the active charge-line extract for GEMMS ONE billing activity. The workbook defines one row per generated charge for a patient, with patient, service-date, procedure, billing-status, provider, episode, amount, denial, and claim identifiers carried on the same row.

The available local evidence supports a charge-line transactional grain rather than claim-level or payment-level grain. `CHGID` is documented as the unique charge identifier, while `CLAIMID` and `INCIDENTNO` indicate grouping into larger billing episodes and claims.

## Columns Observed

The charge-and-claim workbook documents these key `files.CHARGE` columns:

- `PATID` - patient key, documented as a link to `PATIENTACCOUNT.CSV`
- `CHGID` - unique charge identifier
- `XACDATE`, `XACDATE2` - service date range
- `BILLDATE`, `BILLDATE2` - billing dates
- `BILLED`, `STATUS` - billing and posting status flags
- `XACCODE` - charge type
- `CPT`, `CPTPRINT`, `MODIFIER`, `PROCDESC` - procedure coding and description
- `ICD9` - diagnosis code for the line item
- `CUNITS` - units
- `PROVIDER`, `RDOC` - provider / rendering doctor codes
- `FACILITY` - facility code
- `INCIDENTNO` - episode / incident number
- `CHGAMOUNT`, `CHGALLOWED` - charge and allowed amounts
- `ERRORCODE`, `DENYCODE`, `DENYDATE` - claims / denial handling fields
- `USERCODE`, `ENTRYDATE` - entry audit fields
- `RESPONSIBLE`, `PTYPE`, `FEETYPE` - financial responsibility and billing context
- `CLAIMID` - claim identifier

## Profiling Status

Live source profiling was attempted during this analysis but could not be completed because both the serverless source endpoint and the dedicated reference endpoint rejected the current Azure token principal with `Login failed for user '<token-identified principal>'`.

Because of that access limitation, the findings below are documentation-grounded and aligned with prior project evidence, but not yet live-validated against row counts, distinct counts, or referential match rates.

## Key Inference

Recommended business key:

- Primary: `CHGID`
- Conservative staging key until live validation is available: (`PATID`, `CHGID`)

Confidence: Medium

Rationale: the extract workbook explicitly labels `CHGID` as the unique charge ID, which is the strongest available key signal. The fallback composite with `PATID` is safer for downstream staging until uniqueness is confirmed in live data.

## Relationship Inference

### Documented joins

```sql
files.CHARGE.PATID = files.PATIENTACCOUNT.PatientID
```

Confidence: Medium

Basis: the workbook states the charge extract anchors on patient account identity by `PATID`, and the broader project has already validated `files.PATIENTACCOUNT.PatientID` as the patient hub.

```sql
files.CHARGE.CLAIMID = files.CLAIM.CLAIMID
```

Confidence: Medium

Basis: `files.CHARGE` carries `CLAIMID`, and the workbook defines `files.CLAIM.CLAIMID` as the claim identifier for the same billing flow.

```sql
files.CHARGE.PATID = files.CLAIM.PATID
AND files.CHARGE.INCIDENTNO = files.CLAIM.INCIDENTNO
```

Confidence: Medium

Basis: the workbook defines `files.CLAIM` as claim information associated to a patient's episode number and explicitly ties `CLAIM.INCIDENTNO` back to `CHARGE.CSV`.

```sql
files.PAYMENT.CHGID = files.CHARGE.CHGID
```

Confidence: Medium

Basis: the workbook defines `files.PAYMENT.CHGID` as a link to `CHARGE.CSV`, which makes `PAYMENT` the clearest downstream financial child of `CHARGE`.

```sql
files.CHARGENOTES.CHGID = files.CHARGE.CHGID
```

Confidence: Medium

Basis: the workbook defines `files.CHARGENOTES.CHGID` as a link to `CHARGE.CSV`.

### Boundary-path joins requiring live validation

```sql
files.CLAIMSTATEMENTRUNDATES.CLAIMID = files.CHARGE.CLAIMID
```

Confidence: Low

Basis: plausible billing lineage through `CLAIMID`, but no local workbook or prior report evidence in this project confirmed the table shape or key on `CLAIMSTATEMENTRUNDATES`.

```sql
files.CHARGE.CHGID = files.PAYMENT.CHGID
AND files.PAYMENT.REMITID = files.REMITS.REMITID
```

Confidence: Low

Basis: an existing local `files.PAYMENT` scratch script already treats `REMITS` as a likely downstream join off `PAYMENT.REMITID`, but this analysis could not validate the match rates live.

## Domain Fit

`files.CHARGE` is highly relevant to the requested billing domain and is the strongest available source-side candidate for a charge-line fact table.

Why it fits:

- Carries the documented unique charge identifier (`CHGID`)
- Includes charge coding and financial amount fields (`CPT`, `MODIFIER`, `PROCDESC`, `CHGAMOUNT`, `CHGALLOWED`)
- Includes billing workflow flags (`BILLED`, `STATUS`, `RESPONSIBLE`, `PTYPE`)
- Connects upstream to patient identity (`PATID`) and downstream to claims (`CLAIMID`) and payments (`CHGID`)

Current target mapping position:

- `etl_medical.Charge` remains a reasonable conceptual mapping candidate for this source, if that target exists in the intended downstream model.
- The current project artifacts do not independently confirm a dedicated-side `etl_medical.Charge` table because the reference endpoint was not accessible in this session.
- If `etl_medical.Charge` does not exist, this source may instead feed a more generic financial transaction surface, but that remains unconfirmed here.

## Recommended Join Pattern

```sql
FROM files.CHARGE c
INNER JOIN files.PATIENTACCOUNT pa
  ON pa.PatientID = c.PATID
LEFT JOIN files.CLAIM cl
  ON cl.CLAIMID = c.CLAIMID
LEFT JOIN files.PAYMENT p
  ON p.CHGID = c.CHGID
LEFT JOIN files.CHARGENOTES cn
  ON cn.CHGID = c.CHGID
```

For episode-sensitive claim reconstruction, test the stronger predicate:

```sql
LEFT JOIN files.CLAIM cl
  ON cl.PATID = c.PATID
 AND cl.INCIDENTNO = c.INCIDENTNO
```

## Risks and Gaps

- No live profiling was possible in this session because both Azure SQL endpoints rejected the current principal.
- `CHGID` is documented as unique, but that uniqueness has not been empirically validated on the live source.
- `CLAIMID` and `INCIDENTNO` likely represent higher-level billing groupings, so they should not be used as charge-grain keys.
- Statement-run and remit lineage remain boundary-path hypotheses until `CLAIMSTATEMENTRUNDATES` and `REMITS` can be profiled.
- Like the other serverless `files` views in this project, downstream typing may need normalization even when workbook metadata advertises numeric and datetime types.
- The workbook also documents a separate `CHARGEDELETE` extract, so `files.CHARGE` should be treated as the active-charge surface rather than a full charge history including deletions.

## Evidence

Primary evidence used in this analysis:

- `Documentation/GEMMS Data Extract Elements.xlsx`, `Charge & Claim Data` sheet
- Existing project findings that establish `files.PATIENTACCOUNT.PatientID` as the patient hub
- Existing local scratch script for `files.PAYMENT`, which already encodes candidate joins from `PAYMENT` to `CHARGE`, `REMITS`, and `REMITHISTORY`

Live validation status:

- Attempted against `ghs-aetl-workspace-chi-chigemms1-ondemand.sql.azuresynapse.net / GEMMSCV`
- Attempted against `ghs-aetl-sql-chi-chigemms1.database.windows.net / ghs-aetl-adw-chi-chigemms1`
- Both attempts failed with Azure SQL login rejection for the current token principal

## Conclusion

`files.CHARGE` should be treated as the primary source-side charge-line table for the current GEMMS CV Surgery billing analysis. The table is strongly relevant to the requested billing domain, with the best-documented joins running from `PATID` to `PATIENTACCOUNT`, from `CLAIMID` or (`PATID`, `INCIDENTNO`) to `CLAIM`, and from `CHGID` to `PAYMENT` and `CHARGENOTES`.

The main remaining work is live validation: confirm the actual uniqueness of `CHGID`, measure claim and payment match rates, and verify whether `CLAIMSTATEMENTRUNDATES` and `REMITS` participate through `CLAIMID` or only through downstream payment/remit artifacts.