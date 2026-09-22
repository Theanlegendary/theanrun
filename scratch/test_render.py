import os
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import openpyxl
import pandas as pd
from datetime import datetime
import shipments_tomorrow

src_xlsx = "c:/Users/DELL/Desktop/daily_push/scratch/test_src.xlsx"
today_str = datetime.now().strftime("%d/%m/%Y %H:%M:%S")

df = pd.DataFrame([
    {"ORDER ID": "ORD001", "RECEIVER": "Receiver 1", "ORIGIN BRANCH": "PNP", "ORIGIN POST": "PNP01", "DELIVERY PROVINCE": "BAN", "DELIVERY POST": "BAN01", "CURRENT POST OFFICE": "DVCMEGA1", "ACTION TIME": today_str, "FEE": 10, "COD": 0, "WEIGHT (G)": 803900, "STATUS CODE": 306, "VAS CODE": "", "VAS NAME": "", "SERVICE TYPE": "DVCMEGA1"},
    {"ORDER ID": "ORD002", "RECEIVER": "Receiver 2", "ORIGIN BRANCH": "PNP", "ORIGIN POST": "PNP01", "DELIVERY PROVINCE": "BAT", "DELIVERY POST": "BAT01", "CURRENT POST OFFICE": "DVCMEGA1", "ACTION TIME": today_str, "FEE": 10, "COD": 0, "WEIGHT (G)": 544950, "STATUS CODE": 306, "VAS CODE": "", "VAS NAME": "", "SERVICE TYPE": "DVCMEGA1"},
    {"ORDER ID": "ORD003", "RECEIVER": "Receiver 3", "ORIGIN BRANCH": "PNP", "ORIGIN POST": "PNP01", "DELIVERY PROVINCE": "CHA", "DELIVERY POST": "CHA01", "CURRENT POST OFFICE": "DVCMEGA1", "ACTION TIME": today_str, "FEE": 10, "COD": 0, "WEIGHT (G)": 417000, "STATUS CODE": 306, "VAS CODE": "", "VAS NAME": "", "SERVICE TYPE": "DVCMEGA1"},
    {"ORDER ID": "ORD004", "RECEIVER": "Receiver 4", "ORIGIN BRANCH": "PNP", "ORIGIN POST": "PNP01", "DELIVERY PROVINCE": "CHH", "DELIVERY POST": "CHH01", "CURRENT POST OFFICE": "DVCMEGA1", "ACTION TIME": today_str, "FEE": 10, "COD": 0, "WEIGHT (G)": 690000, "STATUS CODE": 306, "VAS CODE": "", "VAS NAME": "", "SERVICE TYPE": "DVCMEGA1"},
    {"ORDER ID": "ORD005", "RECEIVER": "Receiver 5", "ORIGIN BRANCH": "PNP", "ORIGIN POST": "PNP01", "DELIVERY PROVINCE": "KAM", "DELIVERY POST": "KAM01", "CURRENT POST OFFICE": "DVCMEGA1", "ACTION TIME": today_str, "FEE": 10, "COD": 0, "WEIGHT (G)": 1173300, "STATUS CODE": 306, "VAS CODE": "", "VAS NAME": "", "SERVICE TYPE": "DVCMEGA1"},
] * 10)

df.to_excel(src_xlsx, index=False)

out_xlsx = "c:/Users/DELL/Desktop/daily_push/scratch/test_out.xlsx"
bills, weight = shipments_tomorrow.build_shipments_tomorrow_report(src_xlsx, out_xlsx, target_label="ALL")

img_buf = shipments_tomorrow.render_executive_summary_image(out_xlsx)

artifact_img_path = "C:/Users/DELL/.gemini/antigravity/brain/14092c92-2a48-47a6-bd1d-bc0d7f49be8b/test_rendered_ceo.png"
with open(artifact_img_path, "wb") as f:
    f.write(img_buf.getvalue())

print(f"Bills: {bills}, Weight: {weight}")
print(f"Saved rendered image to {artifact_img_path}")
