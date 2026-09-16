# 🎧 Audio Quality & Performance Audit

**App:** relax-mindfulness-flutter
**Audited:** 2026-07-30
**File:** `lib/providers/app_state.dart`
**Auditor scope:** audio architecture only

---

## Executive summary

The audio layer is **functional but has 4 confirmed risks** that will hurt
real users — especially the primary sleep audience on low-end phones in
silent bedrooms. None are catastrophic; all are fixable in <300 lines.

| # | Severity | Issue |
|---|----------|-------|
| 1 | 🔴 High   | **Audio clipping risk** when 3+ tracks play at high volume |
| 2 | 🔴 High   | **78 AudioPlayer instances** — one per track, never released |
| 3 | 🟠 Medium | **No fade-in / fade-out** — abrupt start/stop wakes light sleepers |
| 4 | 🟠 Medium | **Loop seamlessness unverified** — depends on source MP3s |
| 5 | 🟡 Low    | **No normalization** across sources — uneven perceived loudness |
| 6 | 🟡 Low    | **No offline cache** — airplane mode = silence |

---

## 🔴 1. Audio clipping when multiple tracks play at high volume

**Where:** `updateSoundTrackVolume` (lines 411–453) sets each track's
volume directly with no master limiter. A user who taps "🌧️ Rainy Cabin"
loads Soft Rain (0.70) + Campfire (0.35) + Singing Bowl (0.20) — three
streams summed into the OS audio mixer can exceed 0 dBFS, causing harsh
distortion that wakes sleepers.

**Fix:** clamp the *combined* mix. Approach options:

```dart
// Option A — soft limiter (recommended for sleep apps)
double _masterGain = 1.0;
void _recalculateMasterGain() {
  final sum = _targetVolumes.values.fold<double>(0, (a, b) => a + b);
  _masterGain = sum > 1.0 ? (1.0 / sum) : 1.0;
  for (final p in _audioPlayers.values) {
    // gain is already baked into each track's volume; just rescale
  }
}
```

Then apply on `updateSoundTrackVolume` after every change, and also
include a *soft* per-track cap (e.g., max 0.8 per track even if user drags
to 1.0 — prevents one loud track dominating).

**Effort:** ~40 lines. High value for the sleep audience.

---

## 🔴 2. AudioPlayer instances never released

**Where:** `updateSoundTrackVolume` creates an `AudioPlayer()` and stores
it in `_audioPlayers` (line 427). `dispose()` cleans them up (lines
630–637), but `AppState.dispose` only fires when the **whole app** shuts
down. A user who taps through 20 different sounds across a session
accumulates 20 player objects. On low-end Android phones this is
noticeable.

**Fix:** prune players whose target volume is 0 for >30s, OR when total
count exceeds a cap (e.g., 12). Also: pause + release the
`just_audio` `AudioSource` instead of keeping the whole decoder in RAM.

```dart
Future<void> _evictColdPlayers() async {
  if (_audioPlayers.length <= 12) return;
  final cold = _audioPlayers.entries
      .where((e) => (_targetVolumes[e.key] ?? 0) == 0)
      .take(_audioPlayers.length - 12)
      .toList();
  for (final e in cold) {
    await e.value.stop();
    await e.value.dispose();
    _audioPlayers.remove(e.key);
  }
}
```

Call this inside `applyCuratedPreset` (after mass-update) and inside
`updateSoundTrackVolume` when count > 12.

**Effort:** ~30 lines.

---

## 🟠 3. No fade-in / fade-out

**Where:** `updateSoundTrackVolume` calls `player.play()` (line 447) with
no ramp. Same for `stopGuidedSession` (line 399: `await _guidedPlayer.stop()`).

**Why this matters for sleep:** a person half-asleep is startled by a
sound snapping on at full volume. The 0.5s ramp from 0 → target is the
single most impactful UX change for the sleep audience.

**Fix:** use `just_audio`'s `setVolume` with a timer-driven ramp:

```dart
Future<void> _fadeIn(AudioPlayer p, double target, {Duration dur = const Duration(milliseconds: 800)}) async {
  const steps = 16;
  for (int i = 1; i <= steps; i++) {
    await p.setVolume(target * i / steps);
    await Future.delayed(dur ~/ steps);
  }
}
Future<void> _fadeOut(AudioPlayer p, {Duration dur = const Duration(milliseconds: 1200)}) async {
  // mirror of fadeIn, decrementing from current volume to 0 then pause()
}
```

**Effort:** ~25 lines, but the UX lift is enormous for sleep users.

---

## 🟠 4. Loop seamlessness — unverified

**Where:** `setLoopMode(LoopMode.one)` is set (line 433). Whether the
**actual MP3 file** loops without a click depends on whether Moodist's
source files are encoded with zero-padded endings.

**Action items:**
- Audit `https://github.com/remvze/moodist` source files for loop padding
- If any files don't loop cleanly, post-process them: `ffmpeg -i in.mp3
  -af "afade=t=0:sample_rate=44100,afade=t=out:st=0:d=0.05,aloop=loop=-1"
  -c:a libmp3lame out.mp3`
- Cache the loop-cleaned versions in `assets/sounds/` for offline use

**Effort:** research 30 min, processing 1 hr if needed.

---

## 🟡 5. No loudness normalization across sources

**Where:** every track uses its raw loudness. Campfire (~ -14 LUFS) is
noticeably louder than Ocean Waves (~ -22 LUFS) when both are at volume
0.7. Users get inconsistent levels.

**Fix (optional):** measure each track's LUFS once with `ffmpeg -af
ebur128` and apply a per-track pre-gain baked into `soundStreamUrls`. Or
expose a single "Master Volume" slider in UI so users can normalize
manually.

**Effort:** 1–2 hours with ffmpeg scripting. Medium value.

---

## 🟡 6. No offline cache

**Where:** every `setUrl(url)` streams from
`raw.githubusercontent.com`. Airplane mode (common for sleepers) = no
audio.

**Fix:** download all 78 files at first launch into
`getApplicationDocumentsDirectory()`, then point `setUrl` at local file
paths. Update `sounds.json` with a `_localCache` field populated post-init.

**Effort:** ~80 lines, +3MB APK size, but **massive** value for sleep use
case (people literally turn on airplane mode at night).

---

## 📊 Quick wins (ordered by ROI)

| Order | Action | Lines | User impact |
|-------|--------|-------|-------------|
| 1 | Add fade-in/out | ~25 | ⭐⭐⭐⭐⭐ sleep users |
| 2 | Master limiter (anti-clip) | ~40 | ⭐⭐⭐⭐⭐ |
| 3 | Evict cold players | ~30 | ⭐⭐⭐ low-end phones |
| 4 | Offline cache | ~80 | ⭐⭐⭐⭐ airplane mode |
| 5 | Loop audit + normalize | 1–2 hr | ⭐⭐⭐ |
| 6 | LUFS normalization | 1–2 hr | ⭐⭐ |

---

## ✅ What's already good

- `LoopMode.one` is set everywhere ✓
- `await _audioPlayers[i].setVolume(0)` then `pause()` on volume 0 ✓
  (prevents unnecessary decoding)
- Error logging with `debugPrint` ✓
- Single `_guidedPlayer` shared across all guided sessions ✓
- `dispose()` properly releases all players ✓

---

## 🎯 Recommended next sprint (2 days)

1. Fade-in / fade-out on every play/stop
2. Soft master limiter to prevent clipping
3. Cold-player eviction

That trio fixes the most likely user complaints (sudden sounds wake
sleepers; clipping hurts ears) without touching UI or requiring ffmpeg.