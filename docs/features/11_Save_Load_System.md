# Fitur 11 — Save / Load System

**Ringkasan**: Serialisasi seluruh state penting (chapter aktif, story flags, evidence terkumpul, posisi NPC yang berubah, status pintu) ke file save, dan restore-nya dengan benar.

*Catatan arsitektur: `SaveTask` kerangkanya udah ada (`save_task.gd`, dari sesi refactor Task Controller) — `get_save_data()`/`load_save_data()`/`save_game()`/`load_game()` udah jalan buat `StoryTask`+`DialogueTask`. Ini justru bukti kenapa sentralisasi state di Task itu worth it: `SaveTask` gak perlu nyariin state ke banyak Autoload, cukup query tiap Task lewat `get_save_data()` masing-masing.*

**Dependency**: [08_Story_Engine_Flags](08_Story_Engine_Flags.md), [10_Core_UI_HUD](10_Core_UI_HUD.md)

---

## Phase (Garis Besar)
1. Tiap Task baru yang dibangun (`InteractionTask`, `WorldEnvironmentTask`, dst.) **wajib** expose `get_save_data()`/`load_save_data()` sendiri — lihat pola di `story_task.gd`/`dialogue_task.gd`.
2. Update `save_task.gd`: tambah referensi (di-inject `MainGameController`) ke Task baru yang punya save data, gabungin ke `get_save_data()`.
3. Posisi NPC/status pintu yang berubah lewat `NPCService`/`DoorService` — perlu diputuskan: disimpen di `StoryTask` (sebagai bagian dari flag/state), atau `SaveTask` query langsung ke Registry Service buat dapetin posisi terkini semua NPC.
4. UI Save/Load (slot save, konfirmasi overwrite) — terhubung ke Main Menu & Pause Menu dari fitur 10, manggil `SaveTask.save_game()`/`load_game()`.
5. Auto-save di checkpoint tertentu — panggil dari `StoryTask` lewat referensi `SaveTask` yang di-inject `MainGameController` (query, bukan Signal, karena butuh dipicu langsung).

## Testing Criteria (Garis Besar)
- Save lalu load kembali menghasilkan state dunia identik (posisi NPC, evidence, flag, chapter) dengan sebelum save.
- Load dari slot kosong/corrupt ditangani tanpa crash.
- Auto-save (jika ada) tidak mengganggu gameplay/frame drop signifikan.
- Nambah Task baru gak perlu ubah cara kerja `SaveTask` yang udah ada, cukup daftarin referensinya di `MainGameController._wire_tasks()`.

## Checkpoint (Garis Besar)
- Save/Load teruji stabil di scene test dengan state kompleks, aman dipakai sebagai jaring pengaman development konten chapter berikutnya.
