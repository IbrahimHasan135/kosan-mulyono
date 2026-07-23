# Fitur 08 — Story Task & Flag System

**Ringkasan**: `StoryTask` penuh — manajemen chapter (`Prologue`/`Chapter 1`/`Chapter 2`), story flags, evidence score, dan checkpoint yang memicu perubahan dunia nyata (posisi NPC, munculnya item, status pintu, preset waktu) lewat Registry Service dari fitur 03 dan Task lain (`InteractionTask`, `WorldEnvironmentTask`).

*Revisi arsitektur: dulu ini dirancang sebagai `StoryEngineService` (Autoload) yang manggil `NPCService`/`ItemService` langsung. Sekarang jadi `StoryTask` (Layer 3, bukan Autoload) — udah ada kerangkanya dari sesi refactor Task Controller, tinggal diisi logic checkpoint asli di sini. Lihat `Engine_Design.md` §3.C.*

**Dependency**: [04_NPC_Dialogue_System](04_NPC_Dialogue_System.md), [05_Item_Evidence_System](05_Item_Evidence_System.md), [06_Door_Room_Management](06_Door_Room_Management.md), [07_Level_Greybox_MainMap](07_Level_Greybox_MainMap.md)

---

## Phase (Garis Besar)
1. Isi `_apply_checkpoint_effect(flag_name, value)` di `story_task.gd` (kerangkanya udah ada, isinya masih `pass`) — mapping flag → aksi dunia (`NPCService.move_npc`, `ItemService.spawn_item`, `DoorService` lock-unlock, `WorldEnvironmentTask.set_time_of_day`).
2. Isi `on_dialogue_finished(npc_id)` (kerangka udah ada) — cek syarat ending berdasar dialog yang udah selesai.
3. Sistem trigger checkpoint tambahan (Area3D masuk area tertentu → panggil `story_task.set_flag(...)` lewat `MainGameController`, bukan hardcode di scene).

## Testing Criteria (Garis Besar)
- Checkpoint dummy (mis. `set_flag("hasan_body_found", true)`) memicu efek berantai: NPC pindah + item muncul + preset waktu berubah, semua tanpa hardcode node reference di `StoryTask`.
- Chapter bisa berpindah (`Prologue` → `Chapter 1`) dan flag lama tetap tersimpan dengan benar.
- Bisa cek state flag kapan saja tanpa memicu efek samping (`check_flag` murni read-only).
- `StoryTask` gak pernah manggil Task lain secara langsung buat notifikasi — semua koneksi tetap lewat wiring di `main_game_controller.gd` (`_wire_tasks()`).

## Checkpoint (Garis Besar)
- `StoryTask` terbukti bisa mengorkestrasi seluruh sistem via checkpoint dummy, siap dipakai isi konten cerita asli (12–14).
