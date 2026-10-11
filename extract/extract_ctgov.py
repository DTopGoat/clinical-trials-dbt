"""Extract a reproducible slice of ClinicalTrials.gov (API v2) into flat CSV files.

Slice: COMPLETED, INTERVENTIONAL studies matching condition "cancer",
start date 2015-01-01..2016-12-31, last updated on/before 2026-09-30 (frozen cutoff).
Writes data/raw/{studies,sponsors,conditions,locations,interventions}.csv
"""
import csv, os, sys, time
import requests

API = "https://clinicaltrials.gov/api/v2/studies"
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "raw")
PARAMS = {
    "query.cond": "cancer",
    "filter.overallStatus": "COMPLETED",
    "filter.advanced": "AREA[StudyType]INTERVENTIONAL AND AREA[StartDate]RANGE[2015-01-01,2016-12-31] "
                       "AND AREA[LastUpdatePostDate]RANGE[MIN,2026-09-30]",
    "pageSize": 1000,
    "format": "json",
}

def g(d, *path, default=None):
    for p in path:
        if not isinstance(d, dict) or p not in d:
            return default
        d = d[p]
    return d

def fetch():
    params, token = dict(PARAMS), None
    while True:
        if token:
            params["pageToken"] = token
        for attempt in range(5):
            r = requests.get(API, params=params, timeout=60)
            if r.ok:
                break
            time.sleep(2 ** attempt)
        r.raise_for_status()
        data = r.json()
        yield from data.get("studies", [])
        token = data.get("nextPageToken")
        if not token:
            return

def main():
    os.makedirs(OUT, exist_ok=True)
    rows = {k: [] for k in ["studies", "sponsors", "conditions", "locations", "interventions"]}
    for s in fetch():
        p = s["protocolSection"]
        nct = g(p, "identificationModule", "nctId")
        design = g(p, "designModule", default={})
        rows["studies"].append({
            "nct_id": nct,
            "brief_title": g(p, "identificationModule", "briefTitle"),
            "overall_status": g(p, "statusModule", "overallStatus"),
            "study_type": design.get("studyType"),
            "phases": "|".join(design.get("phases", []) or []),
            "allocation": g(design, "designInfo", "allocation"),
            "intervention_model": g(design, "designInfo", "interventionModel"),
            "primary_purpose": g(design, "designInfo", "primaryPurpose"),
            "masking": g(design, "designInfo", "maskingInfo", "masking"),
            "enrollment_count": g(design, "enrollmentInfo", "count"),
            "enrollment_type": g(design, "enrollmentInfo", "type"),
            "start_date": g(p, "statusModule", "startDateStruct", "date"),
            "primary_completion_date": g(p, "statusModule", "primaryCompletionDateStruct", "date"),
            "completion_date": g(p, "statusModule", "completionDateStruct", "date"),
            "first_posted_date": g(p, "statusModule", "studyFirstPostDateStruct", "date"),
            "results_first_posted_date": g(p, "statusModule", "resultsFirstPostDateStruct", "date"),
            "has_results": s.get("hasResults"),
            "lead_sponsor_name": g(p, "sponsorCollaboratorsModule", "leadSponsor", "name"),
            "lead_sponsor_class": g(p, "sponsorCollaboratorsModule", "leadSponsor", "class"),
        })
        sc = g(p, "sponsorCollaboratorsModule", default={})
        if sc.get("leadSponsor"):
            rows["sponsors"].append({"nct_id": nct, "sponsor_name": sc["leadSponsor"].get("name"),
                                     "sponsor_class": sc["leadSponsor"].get("class"), "sponsor_role": "LEAD"})
        for c in sc.get("collaborators", []) or []:
            rows["sponsors"].append({"nct_id": nct, "sponsor_name": c.get("name"),
                                     "sponsor_class": c.get("class"), "sponsor_role": "COLLABORATOR"})
        for c in g(p, "conditionsModule", "conditions", default=[]) or []:
            rows["conditions"].append({"nct_id": nct, "condition_name": c})
        for l in g(p, "contactsLocationsModule", "locations", default=[]) or []:
            rows["locations"].append({"nct_id": nct, "facility": l.get("facility"), "city": l.get("city"),
                                      "state": l.get("state"), "country": l.get("country")})
        for i in g(p, "armsInterventionsModule", "interventions", default=[]) or []:
            rows["interventions"].append({"nct_id": nct, "intervention_type": i.get("type"),
                                          "intervention_name": i.get("name")})
    for name, data in rows.items():
        path = os.path.join(OUT, f"{name}.csv")
        with open(path, "w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=list(data[0].keys()))
            w.writeheader(); w.writerows(data)
        print(f"{name}: {len(data)} rows -> {path}")

if __name__ == "__main__":
    sys.exit(main())
