import csv
import os

csv_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'machhunt_49_companies_master_cleaned.csv')
with open(csv_path, mode='r', encoding='utf-8') as f:
    rows = list(csv.DictReader(f))

rows.sort(key=lambda x: x['company_id'])

print(f"Total companies: {len(rows)}")
for i, r in enumerate(rows, 1):
    print(f"{i:02d}: {r['company_id']} - {r['city']} - {r['industry']} - {r['company_name']} - ({r['latitude']}, {r['longitude']})")
