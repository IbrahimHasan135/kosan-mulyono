# Fitur 09 — Psychological Distortion & Supernatural Misdirection System

**Ringkasan**: Ciri khas horor psikologis game: glitch post-processing (VHS/Chromatic Aberration), audio ilusi (langkah kaki, bisikan Mulyono), perubahan teks objective mendadak, dan event misdirection (bau kimia disamarkan jadi suara tangisan via spatial audio).

*Catatan arsitektur: **gak ada `DistortionTask` terpisah** — keputusan "kapan efek distorsi mana yang nyala" masuk ke `StoryTask._apply_checkpoint_effect()` (sama kayak checkpoint lain: pindah NPC, munculin item, dst.), karena ini juga cuma konsekuensi dari flag/chapter berubah. `DistortionService` tetap ada sebagai Service (Layer 2) — murni wrapper API ke Driver shader/audio, gak nyimpen keputusan apapun.*

**Dependency**: [08_Story_Engine_Flags](08_Story_Engine_Flags.md)

---

## Phase (Garis Besar)
1. `DistortionService.gd` (Autoload, murni API): method kayak `set_glitch_intensity(value)`, `play_illusion_audio(id)` — di baliknya manggil Driver shader-parameter/audio. Gak ada logic keputusan di sini.
2. Shader post-processing dasar (VHS noise, chromatic aberration, glitch) sebagai `CanvasLayer`/environment effect toggle-able — nempel di `ColorRect` shader yang udah ada dari Fitur 2a, atau layer baru kalau perlu dipisah dari shader atmosfer.
3. `AudioTriggerDriver.gd` (di `drivers/environments/`) untuk suara ilusi spasial (langkah di belakang, bisikan).
4. Di `story_task.gd`, isi `_apply_checkpoint_effect()` buat flag tertentu manggil `DistortionService` (mis. flag `"chapter1_glitch_intro"` → `DistortionService.set_glitch_intensity(0.6)`).
5. Mekanisme "objective text berubah mendadak" — `StoryTask` emit `flag_changed`, `HUDTask` yang dengerin dan update teks (bukan Distortion yang urus UI langsung).
6. 1–2 event misdirection contoh (bau kimia → suara tangisan) sebagai proof of concept.

## Testing Criteria (Garis Besar)
- `story_task.set_flag("distortion_test", true)` memicu efek visual & audio secara bersamaan tanpa lag/stutter, lewat `StoryTask` → `DistortionService` → Driver, bukan dipanggil manual dari tempat lain.
- Efek bisa dimatikan/direset dengan bersih (tidak ada shader/audio yang "nyangkut" aktif).
- Objective text berubah sesuai flag yang di-set `StoryTask`, lewat `HUDTask` yang dengerin `flag_changed` — bukan `DistortionService` yang nyentuh UI.

## Checkpoint (Garis Besar)
- Toolkit distorsi psikologis siap dipakai sebagai "bumbu" di semua chapter, terutama Chapter 1–2, dipicu murni lewat `StoryTask.set_flag()`.
