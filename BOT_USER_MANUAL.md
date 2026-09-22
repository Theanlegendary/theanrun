# 📖 Telegram Bot Complete Commands & Operations Manual

Welcome to the **Daily Push & Branch Operations Bot** manual. This guide covers all Telegram commands, zone filters, branch targets, and options available in `bot.py` and `push_bot/bot.py`.

---

## 1. 🚀 Push Commands (`push`)

Use `push` commands to forward reports to branch Telegram groups or run targeted pushes.

| Command | Description | Example |
| :--- | :--- | :--- |
| `push` | Standard push to all registered branch groups (23 groups). | `push` |
| `push all` | Full push to all 23 branch groups **AND** 5 zone summary groups. | `push all` |
| `push zone` | Send summary reports to the 5 Zone groups only (Zone 1-5). | `push zone` |
| `push branch` | Send reports to **all Provincial Branches** (excludes PNP 1-14). | `push branch` |
| `push zone1` | Push to **Zone 1** groups (PNP Area & nearby). | `push zone1` |
| `push zone2` | Push to **Zone 2** groups (Kampot, Koh Kong, Sihanoukville, etc.). | `push zone2` |
| `push zone3` | Push to **Zone 3** groups (Banteay Meanchey, Battambang, Chhnang, Pursat). | `push zone3` |
| `push zone4` | Push to **Zone 4** groups (Oddar Meanchey, Preah Vihear, Siem Reap, Tboung Khmum). | `push zone4` |
| `push zone5` | Push to **Zone 5** groups (Kampong Cham, Kratie, Ratanakiri, Stung Treng, etc.). | `push zone5` |
| `push [branch1] [branch2] ...` | Push to **specific handles only**. | `push banp001 batp001 purp001` |
| `push remark: [text]` | Attach a custom note/remark to all pushed reports. | `push remark: Please clean all 10h urgent items today` |

---

## 2. 📊 Summary & KPI Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| `/total` | Generates overall summary dashboard image + Excel file for all handles. | `/total` |
| `/total [handle]` | Generates total report for a single branch. | `/total batp001` |
| `/total mega` | Generates detailed report for **MEGA / HUB / DVC** warehouse orders. | `/total mega` |
| `/tomorrow` or `/tomorrow all` | Generates **Tomorrow Delivery & 10H KPI** priority dashboard. | `/tomorrow all` |
| `/tomorrow [handle]` | Generates tomorrow priority report for a specific branch. | `/tomorrow batp001` |
| `/speed` or `/speed all` | Generates **Delivery Speed & Commission KPI** dashboard + Excel file. | `/speed all` |
| `/speed [branch1] [branch2]` | Generates speed report for **selected branches**. | `/speed banp001 batp001 purp001` |
| `/penalty` or `/penalty all` | Generates **Penalty & Late Delivery** report across branches. | `/penalty all` |
| `/penalty [handle]` | Generates penalty report for a specific branch. | `/penalty batp001` |

---

## 3. 🔍 Search & Export Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| `/find [bill_no]` | Search complete tracking details for a bill or tracking number. | `/find TB5001234` |
| `/export` | Export raw Excel data file currently stored in cache. | `/export` |
| `/status` | Check current bot status, system uptime, and cache timestamp. | `/status` |
| `/help` | Show Telegram interactive help menu. | `/help` |

---

## 4. ⚙️ Bot Control & Scheduling

| Command | Description | Example |
| :--- | :--- | :--- |
| `/schedule on` | Enable background auto-push of pending reports to designated groups. | `/schedule on` |
| `/schedule off` | Pause the background auto-scheduler. | `/schedule off` |
| `/schedule` | View auto-schedule status, target groups, and time slots. | `/schedule` |
| `/pause` | Temporarily halt automatic report forwarding. | `/pause` |
| `/resume` | Resume automatic report forwarding. | `/resume` |
| `/register` | Register the current group to receive daily report forwards. | `/register` |
| `/unregister` | Remove the current group from report forwards. | `/unregister` |

---

## 5. 🗺️ Zone & Branch Handle Quick Reference

* **Zone 1 (PNP Area & Nearby)**: `PNPP001` $\rightarrow$ `PNPP014`, `KANP001`, `PREP001`, `SVAP001`
* **Zone 2 (South & Coast)**: `KAMP001`, `KOHP001`, `SIHP001`, `SPEP001`, `TAKP001`
* **Zone 3 (West & Northwest)**: `BANP001`, `BATP001`, `CHHP001`, `PURP001`
* **Zone 4 (North & North-Central)**: `ODDP001`, `PRHP001`, `SIEP001`, `THOP001`
* **Zone 5 (East & Northeast)**: `CHAP001`, `KRAP001`, `TBKP001`, `ROTP001`, `MONP001`, `STUP001`

---

## 💡 Pro Tips:
* **Combine Commands**: You can combine multiple zone keys or handle names, e.g.:
  `push zone3 zone5` or `/speed banp001 batp001 purp001`
* **Add Remarks**: Append `remark: Your message` to any push command to notify branch managers.
