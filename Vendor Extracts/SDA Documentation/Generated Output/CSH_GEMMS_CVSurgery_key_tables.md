# CSH_GEMMS_CVSurgery Key Tables

## Ranking Criteria

Ranking emphasizes workflow centrality to the combined patient, clinical, and billing reconstruction, join usefulness, and direct support for the requested dedicated target domains.

## Ranked Source Views

1. `files.PATIENTACCOUNT`
   Global hub for both the clinical and billing branches. Every tested direct domain in this discovery, including finance views, reuses `PatientID` from this surface.

2. `files.PATIENTDEMOGRAPHICS`
   Essential demographic companion to `PATIENTACCOUNT`. Supplies patient enrichment needed for both registration and account reconstruction.

3. `files.CHARGE`
   Strongest direct billing transaction surface. It is fully distinct on `PatientID/CHGID` in live profiling and is the best anchor for charge, payment, statement-run, and note-related finance joins.

4. `files.CLAIM`
   Primary claim-header surface. It promotes the accounting branch from inference to direct support, even though some downstream detail joins remain grain-sensitive.

5. `files.PAYMENT`
   High-value transaction surface with direct patient, charge, payor-code, amount, and status detail. It is the clearest current source for transaction modeling.

6. `files.INSURANCE`
   Core coverage surface with relevance to both registration and billing.

7. `files.CLAIMINSURANCE`
   High-volume claim-payer detail layer that bridges claim activity to insurance lineage.

8. `files.PRESCRIPTIONHISTORY`
   Direct medication history source with 121,578 rows across 9,646 patients. It remains the strongest non-finance event domain outside registration.

9. `files.PATIENTCLINICALITEMS`
   Highest-volume clinical fact source. It likely carries cross-domain value for results, care events, and future boundary expansion.

10. `files.APPOINTMENTS`
    Strongest scheduled encounter precursor. It is the cleanest direct source for the appointment domain and supports inferred encounter and visit modeling.

11. `files.REMITS`
    Lower-volume but strategically important remit surface for billing reconciliation and transaction enrichment.

12. `files.CLAIMSTATEMENTRUNDATES`
    Distinct statement-run bridge that materially improves statement domain support even before the final statement grain is settled.

13. `files.INSURANCEHISTORY`
    Historical complement to `INSURANCE`. The distinct `RECID` provides a durable history grain.

14. `files.LABORDERS`
    Strong order-side event source with near-unique `ID` and clear linkage to results.

15. `files.LABRESULTS`
    Sparse in row count but structurally decisive because it provides the clearest direct order-to-result bridge.

16. `files.PROBLEMLIST`
    Directly supports the clinical problem domain and adds condition history depth.

17. `files.VITALS`
    Directly supports the vitals domain with repeated patient-time measurements.

18. `files.ALLERGY`
    Direct allergy coverage with documented linkage back to the patient account file.

19. `files.NURSINGNOTES`
    High-volume note or event source that supports encounter, visit, document, message-adjacent inference, and some account-note enrichment.

20. `files.VISITNOTES`
    Smaller note or document source that still adds direct clinical narrative context.

## Critical Boundary Context

- `files.PROVIDERMASTER` and `files.PROVIDERDOCTORCODEMASTER` remain the most important person-domain boundary views because they are the likely provider attribution parents.
- `files.PAYORCODE`, `files.INSURANCEMASTER`, and `files.INSURANCECODEMASTER` are now key payer and insurance dimensions for the billing branch.
- `files.CHARGENOTES` and `files.COLLECTIONNOTES` are the most relevant operational-note views for `AccountNote` reconstruction.
- `files.REMITHISTORY`, `files.REMITMESSAGES`, and `files.REMITMESSAGEHISTORY` remain secondary enrichers until a user specifically wants deeper remittance or communication-heavy expansion.

## Expansion Priorities

The next views most likely to change the ranking are `files.CHECK`, `files.CLAIMREMITHISTORY`, `files.CLAIMREMITMESSAGEHISTORY`, `files.CHARGERESPONSIBILITY`, `files.enc`, `files.document`, `files.immunizations`, and `files.globalalertdetails`, because they could either tighten the finance lineage or promote currently weak non-finance domains into direct-support domains.