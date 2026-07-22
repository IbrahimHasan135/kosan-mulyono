# Fitur 17 — Optimization, QA & Release Prep

**Ringkasan**: Tahap akhir sebelum rilis — optimasi performa, playtesting menyeluruh, bug fixing, dan persiapan build untuk platform target (Windows/Linux/Mac).

**Dependency**: [16_Audio_Atmosphere_Pass](16_Audio_Atmosphere_Pass.md)

---

## Phase (Garis Besar)
1. Profiling performa (frame time, draw calls, memory) terutama di `MainMap.tscn` karena arsitektur single-scene rawan menumpuk node aktif, apalagi sekarang mencakup kos+minimarket+jalan sekaligus.
2. Full playtest pass: semua chapter, semua ending, semua external map, dari New Game murni.
3. Bug bash & fix list (prioritaskan blocking bug > cosmetic).
4. Build export per platform (Windows/Linux/Mac) + smoke test tiap build.
5. Checklist rilis (versi, changelog, packaging).

## Testing Criteria (Garis Besar)
- Frame rate stabil di target minimum (tentukan angka target saat eksekusi fitur ini) di semua area.
- Semua 3 ending + 2 external map + save/load lolos playtest tanpa blocking bug.
- Build berjalan normal di tiap platform target tanpa missing asset/crash saat start.

## Checkpoint (Garis Besar)
- Build rilis siap didistribusikan — **Release Milestone**.
