# Fitur 11 — Save / Load System

**Ringkasan**: Serialisasi seluruh state penting (chapter aktif, story flags, evidence terkumpul, posisi NPC yang berubah, status pintu) ke file save, dan restore-nya dengan benar.

**Dependency**: [08_Story_Engine_Flags](08_Story_Engine_Flags.md), [10_Core_UI_HUD](10_Core_UI_HUD.md)

---

## Phase (Garis Besar)
1. `SaveService.gd`: definisikan struktur data save (dictionary/resource) yang menggabungkan state dari `StoryEngineService`, `EvidenceManager`, `NPCService`, `ItemService`, `RoomService`.
2. Fungsi `save_game()` / `load_game()` ke file lokal (`user://`).
3. UI Save/Load (slot save, konfirmasi overwrite) — terhubung ke Main Menu & Pause Menu dari fitur 10.
4. Auto-save di checkpoint tertentu (opsional, tentukan titiknya bareng Story Engine).

## Testing Criteria (Garis Besar)
- Save lalu load kembali menghasilkan state dunia identik (posisi NPC, evidence, flag, chapter) dengan sebelum save.
- Load dari slot kosong/corrupt ditangani tanpa crash.
- Auto-save (jika ada) tidak mengganggu gameplay/frame drop signifikan.

## Checkpoint (Garis Besar)
- Save/Load teruji stabil di scene test dengan state kompleks, aman dipakai sebagai jaring pengaman development konten chapter berikutnya.
