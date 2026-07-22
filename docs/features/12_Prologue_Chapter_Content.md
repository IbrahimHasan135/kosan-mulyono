# Fitur 12 — Prologue Chapter Content (POV: Raka)

**Ringkasan**: Mengisi alur cerita Prologue sesungguhnya di atas semua sistem yang sudah dibangun (fitur 01–11): check-in ke Bu Yuni, ketemu Hasan & Chika, perjalanan ke kampus/supermarket, ritual Bu Yuni, ketemu Dimas, insiden malam menemukan jasad Hasan, dan penculikan Raka.

**Dependency**: [09_Psychological_Distortion_System](09_Psychological_Distortion_System.md), [10_Core_UI_HUD](10_Core_UI_HUD.md), [11_Save_Load_System](11_Save_Load_System.md)

---

## Phase (Garis Besar)
1. Susun urutan event Prologue sebagai daftar checkpoint konkret di `StoryEngineService` (sesuai alur `Game_Design.md` §5).
2. Isi dialog asli (bukan placeholder) untuk Bu Yuni, Hasan, Chika, Pak Yono, Dimas sepanjang Prologue.
3. Setup event "lorong ditutup plastik hitam" (perubahan visual/room state via `RoomService`).
4. Setup event penemuan jasad Hasan + jumpscare sosok mirip hantu + transisi "layar gelap" (akhir Prologue).
5. Playtest alur penuh dari awal sampai akhir Prologue tanpa terputus.

## Testing Criteria (Garis Besar)
- Prologue bisa dimainkan end-to-end dari New Game sampai layar gelap (Raka diculik) tanpa bug blocking.
- Semua dialog & event checkpoint terpicu di urutan yang benar, termasuk yang bergantung pada exploration bebas pemain (non-linear sebagian).
- Save/Load berfungsi normal di tengah-tengah Prologue.

## Checkpoint (Garis Besar)
- Prologue dianggap "vertical slice" pertama yang playable penuh — validasi bahwa seluruh arsitektur (01–11) bekerja sebagai satu kesatuan.
