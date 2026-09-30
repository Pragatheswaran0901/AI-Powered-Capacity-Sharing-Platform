import csv
import json
import os
import uuid

csv_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'machhunt_49_companies_master_cleaned.csv')
with open(csv_path, encoding='utf-8') as f:
    rows = list(csv.DictReader(f))

rows.sort(key=lambda x: x['company_id'])

# Providers:
# 1-13 (13) -> Janika
# 14-25 (12) -> Pragatheswaran
# 26-37 (12) -> Jayanth
# 38-49 (12) -> Reethika
assignments = {}
for i, r in enumerate(rows):
    if i < 13:
        p = "Janika"
    elif i < 25:
        p = "Pragatheswaran"
    elif i < 37:
        p = "Jayanth"
    else:
        p = "Reethika"
    assignments[r['company_id']] = p

counts = {}
for p in assignments.values():
    counts[p] = counts.get(p, 0) + 1

print("Distribution counts:", counts)
assert counts["Janika"] == 13
assert counts["Pragatheswaran"] == 12
assert counts["Jayanth"] == 12
assert counts["Reethika"] == 12
assert sum(counts.values()) == 49
print("Assignment validation passed successfully!")
