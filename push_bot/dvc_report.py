"""
dvc_report.py
Module for generating Executive DVC Hub By Zone Pivot reports and detailed Excel workbooks.

Zone Groups:
  Zone 1 (DVCZ1): PNP, KAN, PRE, SVA
  Zone 2 (DVCZ2): SIH, SPE, KOH, TAK, KAM
  Zone 3 (DVCZ3): BAT, BAN, CHH, PUR
  Zone 4 (DVCZ4): SIE, THO, ODD, PRH
  Zone 5 (DVCZ5): KRA, CHA, TBK, MON, ROT, STU
"""

import os
from datetime import datetime, timedelta
from collections import defaultdict

import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

# Column indexes in raw export file (0-based)
COL_CREATED_DATE   = 1
COL_ORDER_ID       = 2
COL_SENDER         = 3
COL_RECEIVER       = 4
COL_SERVICE        = 5
COL_DELIVERY_PROV  = 12
COL_DELIVERY_PO    = 13
COL_CURRENT_PO     = 15
COL_TOTAL_FEE      = 19
COL_COD            = 20
COL_CURRENT_STATUS = 23
COL_CURRENT_TIME   = 24
COL_ACTION_USER    = 25

ZONE_ORDER = [
    "Zone 1 (DVCZ1)",
    "Zone 2 (DVCZ2)",
    "Zone 3 (DVCZ3)",
    "Zone 4 (DVCZ4)",
    "Zone 5 (DVCZ5)",
]

ZONE_PROVINCES = {
    "Zone 1 (DVCZ1)": ["PNP", "KAN", "PRE", "SVA"],
    "Zone 2 (DVCZ2)": ["SIH", "SPE", "KOH", "TAK", "KAM"],
    "Zone 3 (DVCZ3)": ["BAT", "BAN", "CHH", "PUR"],
    "Zone 4 (DVCZ4)": ["SIE", "THO", "ODD", "PRH"],
    "Zone 5 (DVCZ5)": ["KRA", "CHA", "TBK", "MON", "ROT", "STU"],
}

PROV_TO_ZONE = {}
for z_label, provs in ZONE_PROVINCES.items():
    for p in provs:
        PROV_TO_ZONE[p] = z_label


def read_source(path):
    """Fast Excel reader using calamine engine with openpyxl fallback."""
    try:
        import pandas as pd
        df = pd.read_excel(path, engine='calamine')
        df = df.where(pd.notnull(df), None)
        return [tuple(x) for x in df.itertuples(index=False)]
    except Exception:
        import pivot
        return pivot.read_source(path)


def _status_code(value):
    if value is None:
        return ""
    s = str(value).strip()
    if " - " in s:
        s = s.split(" - ", 1)[0]
    return s.split()[0].strip() if s else ""


def _parse_ts(row):
    for col in (COL_CURRENT_TIME, COL_CREATED_DATE):
        val = row[col] if len(row) > col else None
        if val is None:
            continue
        if isinstance(val, datetime):
            return val
        s = str(val).strip()
        for fmt in ("%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M", "%d/%m/%Y",
                    "%Y-%m-%d %H:%M:%S", "%Y-%m-%d"):
            try:
                return datetime.strptime(s, fmt)
            except ValueError:
                continue
    return datetime.min


def build_dvc_zone_pivot(rows, target_zone=None, exclude_test=True, test_keywords=None):
    """
    Builds a hierarchical pivot tree:
      zone -> province -> (month, day) -> count
    Also tracks:
      fee_tree[zone][prov]
      cod_tree[zone][prov]
      urgent_tree[zone][prov]
    """
    if test_keywords is None:
        test_keywords = ["test"]

    # Keep latest scan per order ID for DVC rows
    latest_row_by_order = {}
    exclude_statuses = {"201", "520", "99", "100", "-99"}

    for row in rows:
        if not row or len(row) <= COL_CURRENT_PO:
            continue
        if row[COL_ORDER_ID] in (None, ""):
            continue
        
        status_code = _status_code(row[COL_CURRENT_STATUS])
        if status_code in exclude_statuses:
            continue

        po = str(row[COL_CURRENT_PO] or "").strip().upper()
        # Must be DVC post office (DVCMEGA1, DVCZ1..5, etc.)
        if not po.startswith("DVC") and "DVCMEGA" not in po and "DVMEGA" not in po:
            continue

        if exclude_test:
            blob = " ".join(str(row[c] or "") for c in (COL_SENDER, COL_RECEIVER) if len(row) > c).lower()
            if any(k.lower() in blob for k in test_keywords):
                continue

        oid = str(row[COL_ORDER_ID]).strip()
        ts = _parse_ts(row)
        existing = latest_row_by_order.get(oid)
        if existing is None or ts > _parse_ts(existing):
            latest_row_by_order[oid] = row

    # Tree structures
    tree = defaultdict(lambda: defaultdict(lambda: defaultdict(int)))
    fee_tree = defaultdict(lambda: defaultdict(float))
    cod_tree = defaultdict(lambda: defaultdict(float))
    urgent_tree = defaultdict(lambda: defaultdict(int))
    dvc_rows = []

    today = datetime.now().date()
    day_keys_seen = set()
    day_keys_seen.add((today.month, today.day))

    for row in latest_row_by_order.values():
        prov = str(row[COL_DELIVERY_PROV] if len(row) > COL_DELIVERY_PROV and row[COL_DELIVERY_PROV] else "").strip().upper()
        if not prov:
            prov = "KHAC"

        zone_label = PROV_TO_ZONE.get(prov, "Other")

        if target_zone:
            tz_norm = str(target_zone).strip().lower()
            if tz_norm in ("zone1", "dvcz1", "1", "z1") and "Zone 1" not in zone_label:
                continue
            elif tz_norm in ("zone2", "dvcz2", "2", "z2") and "Zone 2" not in zone_label:
                continue
            elif tz_norm in ("zone3", "dvcz3", "3", "z3") and "Zone 3" not in zone_label:
                continue
            elif tz_norm in ("zone4", "dvcz4", "4", "z4") and "Zone 4" not in zone_label:
                continue
            elif tz_norm in ("zone5", "dvcz5", "5", "z5") and "Zone 5" not in zone_label:
                continue

        dvc_rows.append(row)

        # Determine Action Date (Col 24 CURRENT TIME or Col 1 CREATED DATE)
        act_val = row[COL_CURRENT_TIME] if len(row) > COL_CURRENT_TIME and row[COL_CURRENT_TIME] else row[COL_CREATED_DATE]
        act_date = None
        if isinstance(act_val, datetime):
            act_date = act_val.date()
        elif act_val:
            s = str(act_val).strip().split(" ")[0]
            for fmt in ("%d/%m/%Y", "%Y-%m-%d", "%m/%d/%Y", "%d-%m-%Y"):
                try:
                    act_date = datetime.strptime(s, fmt).date()
                    break
                except ValueError:
                    continue
        if not act_date:
            act_date = today

        # 14-day cutoff: clamp older bills into the earliest cutoff date so no bills are dropped from the pivot table
        cutoff_date = today - timedelta(days=14)
        if act_date < cutoff_date:
            act_date = cutoff_date

        key = (act_date.month, act_date.day)
        tree[zone_label][prov][key] += 1
        day_keys_seen.add(key)

        try:
            fee_tree[zone_label][prov] += float(row[COL_TOTAL_FEE] or 0)
        except (ValueError, TypeError):
            pass

        try:
            cod_tree[zone_label][prov] += float(row[COL_COD] or 0)
        except (ValueError, TypeError):
            pass

        if (today - act_date).days >= 1:
            urgent_tree[zone_label][prov] += 1

    day_keys = sorted(day_keys_seen)
    return tree, day_keys, (fee_tree, cod_tree, urgent_tree), dvc_rows


def export_dvc_zone_pivot(tree, day_keys, out_path, extra_data=None):
    """
    Renders an Executive DVC Hub By Zone Dashboard matching /total mega executive styling:
      - Premium Dark Obsidian (#0F172A) Top Banner
      - Sleek Slate Header Bar (#1E293B)
      - Zone Section Header Banners (#1E3A8A)
      - Province Rows with date columns
      - Zone Subtotal Rows (#EFF6FF / Soft Royal Blue)
      - Emerald Green Fee/COD & Red Urgent indicators
      - Grand Total Footer (#0F172A)
    """
    fee_tree    = extra_data[0] if extra_data and len(extra_data) > 0 else defaultdict(lambda: defaultdict(float))
    cod_tree    = extra_data[1] if extra_data and len(extra_data) > 1 else defaultdict(lambda: defaultdict(float))
    urgent_tree = extra_data[2] if extra_data and len(extra_data) > 2 else defaultdict(lambda: defaultdict(int))

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "DVC ZONE PIVOT"

    fn = "Segoe UI"
    _CENTER = Alignment(horizontal="center", vertical="center")
    _LEFT   = Alignment(horizontal="left", vertical="center", indent=1)
    _RIGHT  = Alignment(horizontal="right", vertical="center")

    banner_font  = Font(name=fn, size=11, bold=True, color="FFFFFF")
    hdr_font     = Font(name=fn, size=10, bold=True, color="FFFFFF")
    zone_hdr_fnt = Font(name=fn, size=13, bold=True, color="FFFFFF")
    handle_font  = Font(name=fn, size=10, bold=True, color="0F172A")
    data_font    = Font(name=fn, size=10, color="0F172A")
    blue_font    = Font(name=fn, size=10, color="1E40AF", bold=True)
    fee_font     = Font(name=fn, size=10, color="047857", bold=True)
    urg_font     = Font(name=fn, size=10, color="DC2626", bold=True)
    subtot_font  = Font(name=fn, size=10, bold=True, color="1E3A8A")
    gt_font      = Font(name=fn, size=10, bold=True, color="FFFFFF")
    gt_urg_font  = Font(name=fn, size=10, bold=True, color="FCA5A5")

    # Fills
    banner_fill   = PatternFill("solid", fgColor="0F172A") # Dark Obsidian
    hdr_slate     = PatternFill("solid", fgColor="1E293B") # Slate Header
    zone_hdr_fill = PatternFill("solid", fgColor="1E3A8A") # Navy Blue for Zone Title
    tot_hdr_fill  = PatternFill("solid", fgColor="1E40AF") # Royal Blue
    fee_hdr_fill  = PatternFill("solid", fgColor="065F46") # Deep Emerald
    urg_hdr_fill  = PatternFill("solid", fgColor="991B1B") # Deep Crimson

    fee_cell_fill = PatternFill("solid", fgColor="ECFDF5") # Soft Emerald Tint
    urg_cell_fill = PatternFill("solid", fgColor="FEE2E2") # Soft Coral Tint
    tot_cell_fill = PatternFill("solid", fgColor="EFF6FF") # Soft Blue Tint
    subtot_fill   = PatternFill("solid", fgColor="E0E7FF") # Indigo 100
    gt_row_fill   = PatternFill("solid", fgColor="0F172A") # Executive Dark Footer

    thin_border = Side(style="thin", color="CBD5E1")
    cell_border = Border(left=thin_border, right=thin_border, top=thin_border, bottom=thin_border)
    bold_top_border = Border(left=thin_border, right=thin_border, top=Side(style="medium", color="1E3A8A"), bottom=thin_border)

    # Filter day_keys to only active days across tree
    active_days = [
        dk for dk in day_keys
        if any(tree[z][p].get(dk, 0) > 0 for z in tree for p in tree[z])
    ]
    if active_days:
        day_keys = active_days

    tot_col = 2 + len(day_keys)
    fee_col = tot_col + 1
    cod_col = fee_col + 1
    urg_col = cod_col + 1

    # 1. Top Banner Row 1
    stamp_str = datetime.now().strftime("%d/%m/%Y %H:%M")
    ws.merge_cells(start_row=1, start_column=1, end_row=1, end_column=urg_col)
    top_cell = ws.cell(1, 1, f"📊 EXECUTIVE DVC HUB BY ZONE REPORT  |  {stamp_str}")
    top_cell.font = banner_font
    top_cell.fill = banner_fill
    top_cell.alignment = _LEFT
    ws.row_dimensions[1].height = 28

    # 2. Row 2: Headers
    h_cell = ws.cell(2, 1, "ZONE / PROVINCE")
    h_cell.font = hdr_font
    h_cell.fill = hdr_slate
    h_cell.border = cell_border
    h_cell.alignment = _CENTER

    col_idx_map = {}
    for idx, dk in enumerate(day_keys):
        col_num = 2 + idx
        col_idx_map[dk] = col_num
        cell = ws.cell(2, col_num, f"{dk[1]:02d}/{dk[0]:02d}")
        cell.font = hdr_font
        cell.fill = hdr_slate
        cell.border = cell_border
        cell.alignment = _CENTER

    c_tot_hdr = ws.cell(2, tot_col, "TOTAL")
    c_tot_hdr.font = hdr_font
    c_tot_hdr.fill = tot_hdr_fill
    c_tot_hdr.border = cell_border
    c_tot_hdr.alignment = _CENTER

    c_fee_hdr = ws.cell(2, fee_col, "Fee ($)")
    c_fee_hdr.font = hdr_font
    c_fee_hdr.fill = fee_hdr_fill
    c_fee_hdr.border = cell_border
    c_fee_hdr.alignment = _CENTER

    c_cod_hdr = ws.cell(2, cod_col, "COD ($)")
    c_cod_hdr.font = hdr_font
    c_cod_hdr.fill = fee_hdr_fill
    c_cod_hdr.border = cell_border
    c_cod_hdr.alignment = _CENTER

    c_urg_hdr = ws.cell(2, urg_col, "URGENT")
    c_urg_hdr.font = hdr_font
    c_urg_hdr.fill = urg_hdr_fill
    c_urg_hdr.border = cell_border
    c_urg_hdr.alignment = _CENTER

    for c in range(1, urg_col + 1):
        ws.cell(1, c).fill = banner_fill

    ws.row_dimensions[2].height = 26

    # Determine zones to render
    present_zones = [z for z in ZONE_ORDER if z in tree and tree[z]]
    other_zones = [z for z in sorted(tree.keys()) if z not in ZONE_ORDER and tree[z]]
    all_render_zones = present_zones + other_zones

    r = 3
    grand_col_totals = defaultdict(int)
    grand_overall_orders = 0
    grand_overall_fee = 0.0
    grand_overall_cod = 0.0
    grand_overall_urgent = 0

    row_bg_even = PatternFill("solid", fgColor="F8FAFC")
    row_bg_odd  = PatternFill("solid", fgColor="FFFFFF")

    for z_label in all_render_zones:
        prov_dict = tree[z_label]
        if not prov_dict:
            continue

        # Zone Section Header
        ws.merge_cells(start_row=r, start_column=1, end_row=r, end_column=urg_col)
        z_cell = ws.cell(r, 1, f"🔷 {z_label.upper()}")
        z_cell.font = zone_hdr_fnt
        z_cell.fill = zone_hdr_fill
        z_cell.alignment = _LEFT
        for c in range(1, urg_col + 1):
            ws.cell(r, c).fill = zone_hdr_fill
            ws.cell(r, c).border = cell_border
        ws.row_dimensions[r].height = 28
        r += 1

        zone_col_totals = defaultdict(int)
        zone_total_orders = 0
        zone_total_fee = 0.0
        zone_total_cod = 0.0
        zone_total_urgent = 0

        # Sort provinces according to predefined order, then any extras
        target_provs = ZONE_PROVINCES.get(z_label, [])
        known_provs = [p for p in target_provs if p in prov_dict]
        extra_provs = [p for p in sorted(prov_dict.keys()) if p not in known_provs]
        render_provs = known_provs + extra_provs

        for prov_idx, prov in enumerate(render_provs):
            row_bg = row_bg_even if prov_idx % 2 == 0 else row_bg_odd
            ws.row_dimensions[r].height = 22

            c_prov = ws.cell(r, 1, f"   {prov}")
            c_prov.font = handle_font
            c_prov.fill = row_bg
            c_prov.border = cell_border
            c_prov.alignment = _LEFT

            row_sum = 0
            for idx, dk in enumerate(day_keys):
                col_num = col_idx_map[dk]
                val = prov_dict[prov].get(dk, 0)
                cell = ws.cell(r, col_num)
                cell.fill = row_bg
                cell.border = cell_border
                cell.font = blue_font if val > 0 else data_font
                cell.alignment = _CENTER
                if val > 0:
                    cell.value = val
                    row_sum += val
                    zone_col_totals[dk] += val
                    grand_col_totals[dk] += val

            # Total
            c_tot = ws.cell(r, tot_col, row_sum)
            c_tot.font = blue_font
            c_tot.fill = tot_cell_fill
            c_tot.border = cell_border
            c_tot.alignment = _CENTER
            zone_total_orders += row_sum
            grand_overall_orders += row_sum

            # Fee
            f_val = fee_tree[z_label].get(prov, 0.0)
            c_fee = ws.cell(r, fee_col, f"${f_val:.2f}" if f_val > 0 else "$0.00")
            c_fee.font = fee_font
            c_fee.fill = fee_cell_fill
            c_fee.border = cell_border
            c_fee.alignment = _RIGHT
            zone_total_fee += f_val
            grand_overall_fee += f_val

            # COD
            c_val = cod_tree[z_label].get(prov, 0.0)
            c_cod = ws.cell(r, cod_col, f"${c_val:.2f}" if c_val > 0 else "$0.00")
            c_cod.font = fee_font
            c_cod.fill = fee_cell_fill
            c_cod.border = cell_border
            c_cod.alignment = _RIGHT
            zone_total_cod += c_val
            grand_overall_cod += c_val

            # Urgent
            u_val = urgent_tree[z_label].get(prov, 0)
            c_urg = ws.cell(r, urg_col, u_val if u_val > 0 else "")
            c_urg.font = urg_font
            c_urg.fill = urg_cell_fill if u_val > 0 else row_bg
            c_urg.border = cell_border
            c_urg.alignment = _CENTER
            zone_total_urgent += u_val
            grand_overall_urgent += u_val

            r += 1

        # Zone Subtotal Row
        ws.row_dimensions[r].height = 23
        c_sub_label = ws.cell(r, 1, f"SUBTOTAL {z_label.upper()}")
        c_sub_label.font = subtot_font
        c_sub_label.fill = subtot_fill
        c_sub_label.border = bold_top_border
        c_sub_label.alignment = _LEFT

        for idx, dk in enumerate(day_keys):
            col_num = col_idx_map[dk]
            val = zone_col_totals.get(dk, 0)
            cell = ws.cell(r, col_num, val if val > 0 else "")
            cell.font = subtot_font
            cell.fill = subtot_fill
            cell.border = bold_top_border
            cell.alignment = _CENTER

        c_sub_tot = ws.cell(r, tot_col, zone_total_orders)
        c_sub_tot.font = subtot_font
        c_sub_tot.fill = subtot_fill
        c_sub_tot.border = bold_top_border
        c_sub_tot.alignment = _CENTER

        c_sub_fee = ws.cell(r, fee_col, f"${zone_total_fee:.2f}")
        c_sub_fee.font = subtot_font
        c_sub_fee.fill = subtot_fill
        c_sub_fee.border = bold_top_border
        c_sub_fee.alignment = _RIGHT

        c_sub_cod = ws.cell(r, cod_col, f"${zone_total_cod:.2f}")
        c_sub_cod.font = subtot_font
        c_sub_cod.fill = subtot_fill
        c_sub_cod.border = bold_top_border
        c_sub_cod.alignment = _RIGHT

        c_sub_urg = ws.cell(r, urg_col, zone_total_urgent if zone_total_urgent > 0 else "")
        c_sub_urg.font = urg_font if zone_total_urgent > 0 else subtot_font
        c_sub_urg.fill = subtot_fill
        c_sub_urg.border = bold_top_border
        c_sub_urg.alignment = _CENTER

        r += 1

    # Grand Total Row
    ws.row_dimensions[r].height = 26
    c_gt_label = ws.cell(r, 1, "GRAND TOTAL")
    c_gt_label.font = gt_font
    c_gt_label.fill = gt_row_fill
    c_gt_label.border = cell_border
    c_gt_label.alignment = _CENTER

    for idx, dk in enumerate(day_keys):
        col_num = col_idx_map[dk]
        val = grand_col_totals.get(dk, 0)
        cell = ws.cell(r, col_num, val if val > 0 else "")
        cell.font = gt_font
        cell.fill = gt_row_fill
        cell.border = cell_border
        cell.alignment = _CENTER

    c_gt_tot = ws.cell(r, tot_col, grand_overall_orders)
    c_gt_tot.font = gt_font
    c_gt_tot.fill = gt_row_fill
    c_gt_tot.border = cell_border
    c_gt_tot.alignment = _CENTER

    c_gt_fee = ws.cell(r, fee_col, f"${grand_overall_fee:.2f}")
    c_gt_fee.font = gt_font
    c_gt_fee.fill = gt_row_fill
    c_gt_fee.border = cell_border
    c_gt_fee.alignment = _RIGHT

    c_gt_cod = ws.cell(r, cod_col, f"${grand_overall_cod:.2f}")
    c_gt_cod.font = gt_font
    c_gt_cod.fill = gt_row_fill
    c_gt_cod.border = cell_border
    c_gt_cod.alignment = _RIGHT

    c_gt_urg = ws.cell(r, urg_col, grand_overall_urgent if grand_overall_urgent > 0 else "")
    c_gt_urg.font = gt_urg_font
    c_gt_urg.fill = gt_row_fill
    c_gt_urg.border = cell_border
    c_gt_urg.alignment = _CENTER

    # Auto Column Widths
    ws.column_dimensions["A"].width = 28
    for idx, dk in enumerate(day_keys):
        ws.column_dimensions[get_column_letter(2 + idx)].width = 7.5
    ws.column_dimensions[get_column_letter(tot_col)].width = 9.5
    ws.column_dimensions[get_column_letter(fee_col)].width = 11.5
    ws.column_dimensions[get_column_letter(cod_col)].width = 11.5
    ws.column_dimensions[get_column_letter(urg_col)].width = 9.0

    ws.views.sheetView[0].showGridLines = True
    wb.save(out_path)
    return grand_overall_orders, grand_overall_urgent


def build_dvc_zone_detail(dvc_rows, out_xlsx, cfg=None):
    """
    Builds a structured Excel workbook with raw DVC orders:
      Columns: NO, ZONE, PROVINCE, ORDER ID, CURRENT POST OFFICE, CURRENT STATUS,
               CURRENT TIME, SENDER, RECEIVER, FEE (USD), COD (USD), ACTION USER
    """
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "DVC Order Details"

    fn = "Segoe UI"
    hdr_font = Font(name=fn, size=10, bold=True, color="FFFFFF")
    hdr_fill = PatternFill("solid", fgColor="1E293B")
    thin_border = Side(style="thin", color="E2E8F0")
    border = Border(left=thin_border, right=thin_border, top=thin_border, bottom=thin_border)

    headers = [
        "NO", "ZONE", "DELIVERY PROVINCE", "ORDER ID", "CURRENT POST OFFICE",
        "CURRENT STATUS", "CURRENT TIME", "SENDER", "RECEIVER",
        "FEE ($)", "COD ($)", "ACTION USER"
    ]

    for col_idx, h in enumerate(headers, 1):
        cell = ws.cell(1, col_idx, h)
        cell.font = hdr_font
        cell.fill = hdr_fill
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border
    ws.row_dimensions[1].height = 24

    r = 2
    row_even = PatternFill("solid", fgColor="F8FAFC")
    row_odd  = PatternFill("solid", fgColor="FFFFFF")

    urgent_count = 0
    today = datetime.now().date()

    for idx, row in enumerate(dvc_rows, 1):
        prov = str(row[COL_DELIVERY_PROV] if len(row) > COL_DELIVERY_PROV and row[COL_DELIVERY_PROV] else "").strip().upper()
        zone = PROV_TO_ZONE.get(prov, "Other")
        oid = str(row[COL_ORDER_ID] or "").strip()
        po = str(row[COL_CURRENT_PO] or "").strip()
        status = str(row[COL_CURRENT_STATUS] or "").strip()
        cur_time = str(row[COL_CURRENT_TIME] or "").strip()
        sender = str(row[COL_SENDER] or "").strip() if len(row) > COL_SENDER else ""
        receiver = str(row[COL_RECEIVER] or "").strip() if len(row) > COL_RECEIVER else ""
        action_user = str(row[COL_ACTION_USER] or "").strip() if len(row) > COL_ACTION_USER else ""

        fee = float(row[COL_TOTAL_FEE] or 0) if len(row) > COL_TOTAL_FEE and row[COL_TOTAL_FEE] is not None else 0.0
        cod = float(row[COL_COD] or 0) if len(row) > COL_COD and row[COL_COD] is not None else 0.0

        ts = _parse_ts(row)
        if ts != datetime.min and (today - ts.date()).days >= 1:
            urgent_count += 1

        bg = row_even if idx % 2 == 0 else row_odd
        vals = [idx, zone, prov, oid, po, status, cur_time, sender, receiver, fee, cod, action_user]

        for c_idx, v in enumerate(vals, 1):
            c = ws.cell(r, c_idx, v)
            c.fill = bg
            c.border = border
            if c_idx in (1, 2, 3, 4, 5, 7):
                c.alignment = Alignment(horizontal="center", vertical="center")
            elif c_idx in (10, 11):
                c.alignment = Alignment(horizontal="right", vertical="center")
                c.number_format = "$#,##0.00"
            else:
                c.alignment = Alignment(horizontal="left", vertical="center")
        r += 1

    # Auto widths
    for col in ws.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws.column_dimensions[col_letter].width = max(max_len + 3, 10)

    ws.views.sheetView[0].showGridLines = True
    wb.save(out_xlsx)
    return len(dvc_rows), urgent_count
