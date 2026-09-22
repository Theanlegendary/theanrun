import os
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import pandas as pd
import total_pending_report

# Mock summary_df
branches = ['PNP', 'KAN', 'BAN', 'BAT', 'CHA', 'CHH', 'KAM', 'KOH', 'KRA', 'MON', 'ODD', 'PAI', 'PRE', 'PRH', 'PUR', 'ROT', 'SIE', 'SIH', 'SPE', 'STU', 'SVA', 'TAK', 'TBK', 'THO']
rows = []
for b in branches:
    rows.append({
        'Branch': b,
        'Servicepoint': 50 if b == 'PNP' else 10,
        'Showroom': 5 if b == 'PNP' else 1,
        'Agent': 20 if b == 'PNP' else 3,
        '0 Days': 100, '1 Day': 50, '2 Days': 20, '3 Days': 10, '4 Days': 5, '5 Days': 2, '6 Days': 1, '≥ 7 Days': 0,
        'Total >= 3 Days': 18,
        'Total': 188
    })

summary_df = pd.DataFrame(rows)
grand_total = {
    'Branch': 'GRAND TOTAL',
    'Servicepoint': int(summary_df['Servicepoint'].sum()),
    'Showroom': int(summary_df['Showroom'].sum()),
    'Agent': int(summary_df['Agent'].sum()),
    '0 Days': int(summary_df['0 Days'].sum()),
    '1 Day': int(summary_df['1 Day'].sum()),
    '2 Days': int(summary_df['2 Days'].sum()),
    '3 Days': int(summary_df['3 Days'].sum()),
    '4 Days': int(summary_df['4 Days'].sum()),
    '5 Days': int(summary_df['5 Days'].sum()),
    '6 Days': int(summary_df['6 Days'].sum()),
    '≥ 7 Days': int(summary_df['≥ 7 Days'].sum()),
    'Total >= 3 Days': int(summary_df['Total >= 3 Days'].sum()),
    'Total': int(summary_df['Total'].sum())
}

out_xlsx = "c:/Users/DELL/Desktop/daily_push/scratch/test_pending.xlsx"
out_png = "C:/Users/DELL/.gemini/antigravity/brain/14092c92-2a48-47a6-bd1d-bc0d7f49be8b/test_pending_2tables.png"

total_pending_report.export_total_pending_excel(summary_df, grand_total, pd.DataFrame(), out_xlsx)
total_pending_report.render_total_pending_image(summary_df, grand_total, out_png_path=out_png, xlsx_path=out_xlsx)

print(f"Saved 2-table pending report to {out_png}")
