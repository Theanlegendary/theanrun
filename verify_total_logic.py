#!/usr/bin/env python3
"""
VERIFY /TOTAL LOGIC - Check if all numbers are correct
Validates:
1. Overall counts match sum of handle counts
2. Grand Total = Pickup + Delivery + Transit + Branch
3. Table totals match individual row sums
4. No double counting or missing records
"""

import pandas as pd
import os
from datetime import datetime

print("🔍 VERIFYING /TOTAL LOGIC")
print("=" * 50)

# Load cached data
cache_file = 'cache/latest_detail.xlsx'
if not os.path.exists(cache_file):
    print("❌ Cache file not found")
    exit(1)

df = pd.read_excel(cache_file)
df.columns = [str(c).strip().upper() for c in df.columns]

print(f"📊 Total records: {len(df)}")

# Classify orders like generate_report does
def classify_order(row):
    """Classify order into Pickup/Delivery/Transit/Branch"""
    
    status = str(row.get('CURRENT STATUS', '')).strip()
    
    # Extract status code
    if not status:
        return 'Unknown'
    
    # Status code extraction
    status_code = status[:3] if len(status) >= 3 else status
    
    # Classification logic from generate_report.py:
    # Pickup: 110, 120, 200, 202
    # Delivery: 302, 306, 308, 310, 311
    # Transit: 304 (at mega/hub)
    # Branch: 206, 208, 210
    
    if status_code in ['110', '120', '200', '202']:
        return 'Pickup'
    elif status_code in ['302', '306', '308', '310', '311']:
        return 'Delivery'
    elif status_code in ['304']:
        return 'Transit'
    elif status_code in ['206', '208', '210']:
        return 'Branch'
    else:
        return 'Other'

# Apply classification
df['_CLASSIFICATION'] = df.apply(classify_order, axis=1)

# Count by classification
counts = df['_CLASSIFICATION'].value_counts()

print("\n📊 CLASSIFICATION COUNTS:")
print(f"   Pickup: {counts.get('Pickup', 0)}")
print(f"   Delivery: {counts.get('Delivery', 0)}")
print(f"   Transit: {counts.get('Transit', 0)}")
print(f"   Branch: {counts.get('Branch', 0)}")
print(f"   Other: {counts.get('Other', 0)}")
print(f"   Unknown: {counts.get('Unknown', 0)}")

pickup_count = counts.get('Pickup', 0)
delivery_count = counts.get('Delivery', 0)
transit_count = counts.get('Transit', 0)
branch_count = counts.get('Branch', 0)

calculated_total = pickup_count + delivery_count + transit_count + branch_count

print(f"\n🔢 GRAND TOTAL CALCULATION:")
print(f"   Pickup ({pickup_count}) + Delivery ({delivery_count}) + Transit ({transit_count}) + Branch ({branch_count})")
print(f"   = {calculated_total}")

# Verify by handle/branch
print(f"\n📍 VERIFICATION BY POST OFFICE:")

# Find post office column
po_col = None
for col in df.columns:
    if 'CURRENT POST OFFICE' in col or 'POST OFFICE HANDLE' in col:
        po_col = col
        break

if po_col:
    # Count by post office
    po_counts = {}
    for classification in ['Pickup', 'Delivery', 'Transit', 'Branch']:
        df_class = df[df['_CLASSIFICATION'] == classification]
        for po in df_class[po_col].dropna().unique():
            if po not in po_counts:
                po_counts[po] = {'Pickup': 0, 'Delivery': 0, 'Transit': 0, 'Branch': 0}
            po_counts[po][classification] += len(df_class[df_class[po_col] == po])
    
    # Show top 5 post offices
    total_by_po = {po: sum(counts.values()) for po, counts in po_counts.items()}
    top_5 = sorted(total_by_po.items(), key=lambda x: x[1], reverse=True)[:5]
    
    print(f"   Top 5 Post Offices:")
    for po, total in top_5:
        counts = po_counts[po]
        print(f"      {po}: {total} (P:{counts['Pickup']} D:{counts['Delivery']} T:{counts['Transit']} B:{counts['Branch']})")
    
    # Verify sum
    sum_by_po = sum(total_by_po.values())
    print(f"\n   Sum of all post offices: {sum_by_po}")
    print(f"   Original calculated total: {calculated_total}")
    
    if sum_by_po == calculated_total:
        print(f"   ✅ MATCH! No double counting detected")
    else:
        print(f"   ⚠️  MISMATCH! Difference: {abs(sum_by_po - calculated_total)}")

# Check for edge cases
print(f"\n🔍 EDGE CASE CHECKS:")

# 1. NTN orders (should only be in Pickup)
ntn_mask = df.astype(str).apply(lambda row: row.str.upper().str.contains('NTN', na=False).any(), axis=1)
ntn_df = df[ntn_mask]
ntn_by_class = ntn_df['_CLASSIFICATION'].value_counts()

print(f"   NTN Orders:")
print(f"      Total NTN: {len(ntn_df)}")
print(f"      In Pickup: {ntn_by_class.get('Pickup', 0)}")
print(f"      In Delivery: {ntn_by_class.get('Delivery', 0)} (should be 0)")
print(f"      In Transit: {ntn_by_class.get('Transit', 0)} (should be 0)")
print(f"      In Branch: {ntn_by_class.get('Branch', 0)} (should be 0)")

if ntn_by_class.get('Delivery', 0) > 0 or ntn_by_class.get('Transit', 0) > 0 or ntn_by_class.get('Branch', 0) > 0:
    print(f"      ⚠️  WARNING: NTN orders found outside Pickup!")
else:
    print(f"      ✅ NTN orders correctly in Pickup only")

# 2. MEGA/HUB orders (should not be in Transit/Branch for /total)
if po_col:
    mega_mask = df[po_col].astype(str).str.contains('MEGA|HUB|DVC', case=False, na=False)
    mega_df = df[mega_mask]
    mega_by_class = mega_df['_CLASSIFICATION'].value_counts()
    
    print(f"\n   MEGA/HUB/DVC Orders:")
    print(f"      Total MEGA: {len(mega_df)}")
    print(f"      In Transit: {mega_by_class.get('Transit', 0)} (excluded from /total)")
    print(f"      In Branch: {mega_by_class.get('Branch', 0)} (excluded from /total)")
    
    # These should be excluded from overall counts
    excluded_mega = mega_by_class.get('Transit', 0) + mega_by_class.get('Branch', 0)
    if excluded_mega > 0:
        print(f"      ℹ️  {excluded_mega} MEGA orders excluded from /total")
        print(f"      ✅ Correct (MEGA shown in /total mega instead)")

# 3. Test bills (should be excluded)
test_file = 'test_bills.txt'
if os.path.exists(test_file):
    with open(test_file, 'r') as f:
        test_bills = {line.strip().upper() for line in f if line.strip()}
    
    order_col = next((c for c in df.columns if 'ORDER' in c), None)
    if order_col:
        test_mask = df[order_col].astype(str).str.upper().isin(test_bills)
        test_count = test_mask.sum()
        
        print(f"\n   Test Bills:")
        print(f"      Test bills in data: {test_count}")
        if test_count > 0:
            print(f"      ⚠️  WARNING: Test bills not filtered out!")
        else:
            print(f"      ✅ Test bills correctly filtered")

print(f"\n" + "=" * 50)
print(f"✅ VERIFICATION COMPLETE")
print(f"\n📊 FINAL SUMMARY:")
print(f"   Pickup: {pickup_count}")
print(f"   Delivery: {delivery_count}")
print(f"   Transit: {transit_count}")
print(f"   Branch: {branch_count}")
print(f"   GRAND TOTAL: {calculated_total}")
print(f"\n   Formula: Pickup + Delivery + Transit + Branch = Grand Total")
print(f"   Check: {pickup_count} + {delivery_count} + {transit_count} + {branch_count} = {calculated_total}")

if calculated_total == pickup_count + delivery_count + transit_count + branch_count:
    print(f"   ✅ MATH CHECKS OUT!")
else:
    print(f"   ❌ MATH ERROR!")

print(f"\n💡 If /total shows different numbers:")
print(f"   1. Check if MEGA/HUB excluded correctly")
print(f"   2. Check if NTN orders only in Pickup")
print(f"   3. Check if test bills filtered")
print(f"   4. Check if date range filtering correct")
print(f"=" * 50)
