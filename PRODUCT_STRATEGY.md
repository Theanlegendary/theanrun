# 🛌 Product Strategy — Relax Mindfulness

**App Name:** Relax Mindfulness (Flutter)
**Last updated:** 2026-07-30
**Status:** v2.0.0 sound library

---

## 🎯 Mission

Help people who struggle to fall asleep (or stay asleep) build a personal
sound environment they actually control — without paying a subscription,
without surrendering privacy, and without being lectured about "wellness."

---

## 👥 Primary Audience

**People with sleep struggles.**

- Adults 22–55 who regularly have trouble winding down, falling asleep,
  or returning to sleep after waking.
- Have *tried* Calm / Headspace / Spotify sleep playlists and either:
  - Don't want to pay $14/month,
  - Felt the content was too long / too "spiritual",
  - Couldn't find the *exact* sound combo that works for them.
- Use their phone in bed — so the app has to be smooth, dark-themed,
  and never accidentally wake them with notifications.

**Secondary audiences:** stressed casual users, knowledge workers wanting
ambient focus sounds. Same product serves them — but positioning, copy,
and feature priorities center on sleep.

---

## 💎 Unique Value Proposition

> **The only free, open-source sleep app that lets you mix your own
> ambient soundscape — no subscription, no ads, no content gate.**

Three words: **Free. Yours. Mixable.**

---

## ⚔️ Competitive Positioning

| App | Free? | Mixable? | Open Source? | Theme-able? | Privacy |
|-----|-------|----------|--------------|-------------|---------|
| **Relax Mindfulness** | ✅ 100% | ✅ Multi-track | ✅ CC0 | ✅ 4 themes | ✅ No tracking |
| Calm | ❌ $14/mo | ❌ Single loops | ❌ | ⚠️ Limited | ⚠️ Account required |
| Headspace | ❌ $13/mo | ❌ | ❌ | ⚠️ Limited | ⚠️ |
| Spotify | ⚠️ Limited | ❌ | ❌ | ❌ | ⚠️ Account |
| Insight Timer | ⚠️ Mostly | ❌ | ❌ | ❌ | ⚠️ |

**Tagline variants:**
- *"Your soundscape. Your sleep. No subscription."*
- *"Mix rain, ocean, and a Tibetan bowl. Free."*
- *"Open-source calm."*

---

## 🌟 Strongest Differentiators (priority order)

1. **Multi-sound mixing** — Already shipping. Calm and Headspace don't let
   you blend Ocean Waves (40%) + Soft Rain (60%) + Brown Noise (20%) and
   save it as "My Stormy Beach." This is the **headline feature.**
2. **100% free, no paywalls** — Calm gates 80% of guided content.
   Everything is unlocked from first launch.
3. **Open-source + CC0 sources** — Every sound URL is in `sounds.json`,
   visible, replaceable. Users can audit, fork, and self-host.
4. **Visual polish / theme-able** — 4 themes (Midnight Navy, Forest Dusk,
   Twilight Lavender, Claymorphism). Designed for dark rooms.

---

## 🧠 What NOT To Compete On

- ❌ Celebrity narrators (we don't have Morgan Freeman)
- ❌ 30-day meditation programs (Headspace owns this)
- ❌ Live coach sessions (Calm owns this)
- ❌ AI-generated personalized meditations (commodity, low margin)

---

## 🪜 Roadmap Themes

| Theme | What it means | Why |
|-------|---------------|-----|
| **Sleep first** | Every new feature asks: "does this help someone fall asleep?" | Primary audience |
| **Own your data** | Export sounds.json, export presets, no lock-in | Open-source pillar |
| **Less is more** | Resist adding features. Polish what exists. | 9/10 UI already |
| **Audio quality > feature count** | Seamless loops, smooth mixing, no clipping | Differentiator + retention |

---

## 📊 Success Metrics (proposed)

Not vanity installs. Look at:

| Metric | Target | Why |
|--------|--------|-----|
| **7-day return rate** | > 30% | People who come back a week later actually use it to sleep |
| **Avg sounds per mix** | 2.5+ | Proves mixing is the value, not single tracks |
| **Time-to-sleep delta** | Self-reported | Are users actually falling asleep faster? |
| **GitHub stars / forks** | Trend up | Validates open-source positioning |
| **Play Store rating** | > 4.5 | Quality signal |

---

## 🛡️ Non-Goals (anti-roadmap)

To stay focused:

- ❌ No social features (friends, sharing)
- ❌ No AI chatbot for mental health
- ❌ No "premium tier" — paid features would betray the 100% free promise
- ❌ No 30+ guided meditation courses (we curate, not produce)
- ❌ No account creation — installs only

---

## 📝 One-liner for app store

> *"Mix rain, ocean, and a singing bowl. Save the combo. Fall asleep.
> No subscription, no ads, no account. 100% free and open source."*

---

## 📂 Source / Provenance

- **Code:** MIT (or your preferred license)
- **All sounds:** CC0 from Moodist + Google Actions Sound Library
- **All images:** Unsplash (free use)
- **No tracking, no analytics, no ads SDKs**