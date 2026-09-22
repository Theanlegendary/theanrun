# 📊 Cache Behavior - REPLACE vs ADD

## Your Question:
> "when i calculate or generate or running do it store new data or it replace new data? i want replace rather than keep"

---

## ✅ ANSWER: It REPLACES (Not Adds)

The cache file `cache/latest_detail.xlsx` is **OVERWRITTEN** every time fresh data is downloaded.

**No appending, no accumulation** - just a single file that gets replaced.

---

## 📋 How Cache Works

### Before (cache_minutes = 5):

```
Run 1 (/push at 10:00 AM):
  ↓ Download fresh data from API
  ↓ Save to cache/latest_detail.xlsx (NEW FILE)
  ↓ Generate reports
  ✅ Cache file: 10:00 AM data

Run 2 (/push at 10:02 AM - 2 minutes later):
  ↓ Check cache age: 2 minutes < 5 minutes
  ↓ USE OLD CACHE (doesn't download) ❌
  ↓ Generate reports from 10:00 AM data
  ❌ Stale data - bill 3304648355 still shows as 402 (pending)
      even though it's now 410 (delivered)!

Run 3 (/push at 10:06 AM - 6 minutes later):
  ↓ Check cache age: 6 minutes > 5 minutes
  ↓ Download fresh data from API
  ↓ REPLACE cache/latest_detail.xlsx (OVERWRITES old file)
  ↓ Generate reports
  ✅ Fresh data - bill 3304648355 now shows correct status 410
```

### After (cache_minutes = 0):

```
Run 1 (/push at 10:00 AM):
  ↓ Download fresh data from API
  ↓ Save to cache/latest_detail.xlsx
  ↓ Generate reports
  ✅ Fresh data

Run 2 (/push at 10:02 AM):
  ↓ cache_minutes = 0 → Always refresh
  ↓ Download fresh data from API
  ↓ REPLACE cache/latest_detail.xlsx
  ↓ Generate reports
  ✅ Fresh data - always current!

Run 3 (/push at 10:06 AM):
  ↓ cache_minutes = 0 → Always refresh
  ↓ Download fresh data from API
  ↓ REPLACE cache/latest_detail.xlsx
  ↓ Generate reports
  ✅ Fresh data - always current!
```

---

## 🔧 What Changed

### config.json:
```json
"cache_minutes": 0  // Changed from 5 to 0
```

**Effect:**
- ✅ Every `/push` downloads FRESH data
- ✅ No reusing old cache
- ✅ Cache file still gets REPLACED (not added to)
- ✅ Always shows current bill statuses
- ✅ Fixes the 3304648355 bug (402 → 410)

---

## 📁 Cache File Location

```
daily_push/
├── cache/
│   ├── latest_detail.xlsx      ← Main cache (REPLACED on each run)
│   └── latest_revenue.xlsx     ← Revenue cache (REPLACED on each run)
```

**Single file per data type** - gets overwritten, never grows.

---

## 🎯 Commands Behavior

| Command | Behavior (cache_minutes = 0) |
|---------|------------------------------|
| `/push` | Downloads fresh data, REPLACES cache |
| `/push new` | Downloads fresh data, REPLACES cache |
| `/push force` | Downloads fresh data, REPLACES cache |
| `/push refresh` | Downloads fresh data, REPLACES cache |

**All do the same now** - always fresh data!

---

## 💡 Why This Fixes Your Bug

**Problem:** Bill 3304648355 showed status 402 in report but was 410 in reality

**Root Cause:** Old cached data from when bill was 402

**Solution:** cache_minutes = 0 means:
1. Never reuse old cache
2. Always download current data
3. Always see real-time statuses
4. Enhanced filtering catches any shipped bills

---

## ⚙️ Technical Details

### Cache Logic (downloader.py line 175):
```python
if is_default_range and cache_minutes > 0 and not force_refresh:
    if os.path.exists(cache_file):
        mtime = os.path.getmtime(cache_file)
        age_seconds = time.time() - mtime
        if age_seconds < (cache_minutes * 60):
            # USE OLD CACHE
            shutil.copy2(cache_file, out_path)
            return out_path
```

When `cache_minutes = 0`:
- The condition `cache_minutes > 0` is FALSE
- Never enters the "use old cache" branch
- Always downloads fresh data
- Always REPLACES cache file with new data

---

## ✅ Result

**REPLACE behavior confirmed:**
- ✅ Cache file is OVERWRITTEN (not appended)
- ✅ Fresh data on every run (cache_minutes = 0)
- ✅ No stale data issues
- ✅ Bill statuses always current
- ✅ Single cache file (doesn't accumulate)

---

## 🔄 Rollback

If you want to re-enable caching (reuse data for 5 minutes):
```json
"cache_minutes": 5
```

But this may cause stale data issues again!

---

**Done! Cache now REPLACES fresh data on every run!** 🎉
