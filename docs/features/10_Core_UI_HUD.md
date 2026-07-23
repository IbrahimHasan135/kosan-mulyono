# Fitur 10 — Core UI & HUD

**Ringkasan**: Membungkus semua sistem gameplay dengan UI yang layak: Main Menu, HUD in-game (objective, prompt interaksi), Evidence/Inventory panel (versi final dari draft di fitur 05), Dialogue Box (versi final dari draft di fitur 04), dan Pause/Settings menu.

*Catatan arsitektur: HUD digerakin oleh `HUDTask` (Layer 3) yang dengerin `StoryTask.flag_changed` (udah disambungin dari sesi refactor Task Controller, tinggal diisi logic-nya di `hud_task.gd`) — bukan HUD langsung baca `StoryTask`/Service manapun sendiri. `HUDService` (kalau dibutuhin) cuma registry buat nyimpen referensi node HUD, sama pola kayak `DialogueService` buat `DialogueBoxDriver`.*

**Dependency**: [04_NPC_Dialogue_System](04_NPC_Dialogue_System.md), [05_Item_Evidence_System](05_Item_Evidence_System.md), [08_Story_Engine_Flags](08_Story_Engine_Flags.md)

---

## Phase (Garis Besar)
1. Main Menu (New Game, Continue, Settings, Quit).
2. HUD in-game: prompt interaksi kontekstual ("[E] Buka Pintu"), objective text box — isi `hud_task.gd`'s `on_flag_changed()` (kerangkanya udah ada) buat update teksnya lewat `HUDService`.
3. Finalisasi Dialogue Box (styling, portrait NPC jika ada, animasi teks) — tetap dikontrol `DialogueTask`, cuma visualnya yang di-final-in di sini.
4. Finalisasi Evidence/Inventory Panel (kategori, detail item saat dipilih) — datanya dari `StoryTask` (`collected_evidence`, `evidence_score`).
5. Pause Menu + Settings (audio, sensitivity, subtitle toggle).

## Testing Criteria (Garis Besar)
- Semua UI dari fitur 04/05 versi draft berhasil digantikan versi final tanpa merusak fungsi yang sudah ada.
- Objective text di HUD berubah otomatis saat `StoryTask` mengubah flag/chapter (termasuk perubahan mendadak dari fitur 09), lewat `HUDTask` yang dengerin `flag_changed` — bukan HUD nge-poll `StoryTask` sendiri.
- Pause menu bisa dibuka/ditutup kapan saja tanpa memutus state gameplay.

## Checkpoint (Garis Besar)
- UI/UX lengkap dan terhubung ke seluruh sistem backend lewat `HUDTask`, game terasa "utuh" untuk pertama kalinya.
