# Fitur 09 — Psychological Distortion & Supernatural Misdirection System

**Ringkasan**: Ciri khas horor psikologis game: glitch post-processing (VHS/Chromatic Aberration), audio ilusi (langkah kaki, bisikan Mulyono), perubahan teks objective mendadak, dan event misdirection (bau kimia disamarkan jadi suara tangisan via spatial audio).

**Dependency**: [08_Story_Engine_Flags](08_Story_Engine_Flags.md)

---

## Phase (Garis Besar)
1. `DistortionService.gd`: kontrol intensitas efek visual (shader parameter) & audio ilusi, dipicu oleh flag dari Story Engine.
2. Shader post-processing dasar (VHS noise, chromatic aberration, glitch) sebagai `CanvasLayer`/environment effect toggle-able.
3. `AudioTriggerDriver.gd` (di `drivers/environments/`) untuk suara ilusi spasial (langkah di belakang, bisikan).
4. Mekanisme "objective text berubah mendadak" terhubung ke UI objective (detail UI di fitur 10).
5. 1–2 event misdirection contoh (bau kimia → suara tangisan) sebagai proof of concept.

## Testing Criteria (Garis Besar)
- Mengaktifkan flag distorsi dummy memicu efek visual & audio secara bersamaan tanpa lag/stutter.
- Efek bisa dimatikan/direset dengan bersih (tidak ada shader/audio yang "nyangkut" aktif).
- Objective text berubah sesuai flag yang di-set Story Engine.

## Checkpoint (Garis Besar)
- Toolkit distorsi psikologis siap dipakai sebagai "bumbu" di semua chapter, terutama Chapter 1–2.
