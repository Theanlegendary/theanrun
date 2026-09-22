#!/usr/bin/env python3
"""
Quick check to verify:
1. Which bot.py you should be running
2. If generate_report.py has the filtering code
3. If bot is using fresh data (cache_minutes = 0)
"""

import os
import json

print("\n" + "="*60)
print("🔍 BOT STATUS CHECK")
print("="*60 + "\n")

# Check which directory we're in
cwd = os.getcwd()
print(f"📁 Current directory: {cwd}")

# Check if generate_report.py exists
gen_report_path = os.path.join(cwd, "generate_report.py")
if os.path.exists(gen_report_path):
    print(f"✅ generate_report.py found")
    
    # Check if filtering code exists
    with open(gen_report_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    if '[FILTER] Removed' in content:
        print(f"✅ Filtering code IS PRESENT in generate_report.py")
        
        if '[FINAL VERIFICATION]' in content:
            print(f"✅ Final verification layer IS PRESENT")
        else:
            print(f"⚠️  Final verification layer MISSING")
    else:
        print(f"❌ Filtering code NOT FOUND in generate_report.py!")
else:
    print(f"❌ generate_report.py NOT FOUND")

print()

# Check config.json
config_path = os.path.join(cwd, "config.json")
if os.path.exists(config_path):
    print(f"✅ config.json found")
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            cfg = json.load(f)
        
        cache_min = cfg.get('api', {}).get('cache_minutes', 'NOT SET')
        print(f"   cache_minutes: {cache_min}")
        
        if cache_min == 0:
            print(f"   ✅ Fresh data every run (cache disabled)")
        elif cache_min == 5:
            print(f"   ⚠️  Using cache (may have stale data)")
        else:
            print(f"   ⚠️  Unknown cache setting")
    except Exception as e:
        print(f"❌ Error reading config.json: {e}")
else:
    print(f"❌ config.json NOT FOUND")

print()

# Check bot files
bot_files = []
for root, dirs, files in os.walk(cwd):
    for f in files:
        if f == 'bot.py':
            bot_files.append(os.path.join(root, f))

print(f"📋 Found {len(bot_files)} bot.py files:")
for bf in bot_files:
    rel_path = os.path.relpath(bf, cwd)
    print(f"   • {rel_path}")

print()

# Determine which bot to run
main_bot = os.path.join(cwd, "bot.py")
if os.path.exists(main_bot):
    print(f"✅ Main bot.py exists in root directory")
    print(f"👉 YOU SHOULD RUN: python bot.py")
else:
    print(f"⚠️  No bot.py in root directory")
    if bot_files:
        print(f"👉 Available bots:")
        for bf in bot_files:
            print(f"   python {os.path.relpath(bf, cwd)}")

print()
print("="*60)
print("🔧 ACTION REQUIRED:")
print("="*60)
print()
print("1. STOP the currently running bot (Ctrl+C)")
print("2. Make sure you're in the right directory:")
print(f"   cd {cwd}")
print("3. Run the main bot:")
print("   python bot.py")
print("4. Run /push in Telegram")
print("5. Check terminal logs for [FILTER] messages")
print()
print("Expected logs:")
print("  [FILTER] Removed X bills by STATUS_CODE filter")
print("  [FILTER] Removed Y bills by CURRENT STATUS code prefix")
print("  [FILTER] Removed Z bills by CURRENT STATUS keywords")
print("  [FINAL VERIFICATION] ✅ No shipped bills found")
print()
print("="*60 + "\n")
