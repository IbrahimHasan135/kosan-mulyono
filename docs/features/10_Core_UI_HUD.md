# Fitur 10 — Core UI & HUD

**Ringkasan**: Membungkus semua sistem gameplay dengan UI yang layak: Main Menu, HUD in-game (objective, prompt interaksi), Evidence/Inventory panel (versi final dari draft di fitur 05), Dialogue Box (versi final dari draft di fitur 04), dan Pause/Settings menu.

**Dependency**: [04_NPC_Dialogue_System](04_NPC_Dialogue_System.md), [05_Item_Evidence_System](05_Item_Evidence_System.md), [08_Story_Engine_Flags](08_Story_Engine_Flags.md)

---

## Phase (Garis Besar)
1. Main Menu (New Game, Continue, Settings, Quit).
2. HUD in-game: prompt interaksi kontekstual ("[E] Buka Pintu"), objective text box (reaktif terhadap `StoryEngineService`).
3. Finalisasi Dialogue Box (styling, portrait NPC jika ada, animasi teks).
4. Finalisasi Evidence/Inventory Panel (kategori, detail item saat dipilih).
5. Pause Menu + Settings (audio, sensitivity, subtitle toggle).

## Testing Criteria (Garis Besar)
- Semua UI dari fitur 04/05 versi draft berhasil digantikan versi final tanpa merusak fungsi yang sudah ada.
- Objective text di HUD berubah otomatis saat `StoryEngineService` mengubah flag/chapter (termasuk perubahan mendadak dari fitur 09).
- Pause menu bisa dibuka/ditutup kapan saja tanpa memutus state gameplay.

## Checkpoint (Garis Besar)
- UI/UX lengkap dan terhubung ke seluruh sistem backend, game terasa "utuh" untuk pertama kalinya.
