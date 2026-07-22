# Fitur 08 — Story Engine & Flag System

**Ringkasan**: `StoryEngineService` penuh — manajemen chapter (`Prologue`/`Chapter 1`/`Chapter 2`), story flags, dan checkpoint yang memicu perubahan dunia nyata (posisi NPC, munculnya item, status pintu) lewat Registry Service dari fitur 03.

**Dependency**: [04_NPC_Dialogue_System](04_NPC_Dialogue_System.md), [05_Item_Evidence_System](05_Item_Evidence_System.md), [06_Door_Room_Management](06_Door_Room_Management.md), [07_Level_Greybox_MainMap](07_Level_Greybox_MainMap.md)

---

## Phase (Garis Besar)
1. Lengkapi `StoryEngineService.gd`: `set_chapter`, `set_flag`, `check_flag`, signal `chapter_changed`/`flag_changed`.
2. Definisikan skema checkpoint: mapping flag → aksi dunia (`NPCService.move_npc`, `ItemService.spawn_item`, `RoomService`/`DoorService` lock-unlock).
3. `MainGameController.gd`: fungsi orchestrator per checkpoint besar (mengikuti pola `trigger_hasan_discovery_event()` di `Engine_Design.md`).
4. Sistem trigger checkpoint (Area3D masuk ruangan tertentu, selesai dialog tertentu, item tertentu didapat, dll).

## Testing Criteria (Garis Besar)
- Checkpoint dummy (mis. "hasan_body_found") memicu efek berantai: NPC pindah + item muncul + pintu berubah status, semua tanpa hardcode node reference di Story Engine.
- Chapter bisa berpindah (`Prologue` → `Chapter 1`) dan flag lama tetap tersimpan dengan benar.
- Bisa cek state flag kapan saja tanpa memicu efek samping (`check_flag` murni read-only).

## Checkpoint (Garis Besar)
- Story Engine terbukti bisa mengorkestrasi seluruh sistem via checkpoint dummy, siap dipakai isi konten cerita asli (12–14).
