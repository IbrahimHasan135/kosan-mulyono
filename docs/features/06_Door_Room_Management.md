# Fitur 06 — Door Management System

**Ringkasan**: `DoorDriver` (buka/tutup/terkunci) + `DoorService` (registry, pola sama kayak `NPCService`/`ItemService`) + `InteractionTask` yang mutusin lock/unlock berdasar evidence yang dipegang `StoryTask`.

*Revisi arsitektur & scope: **Nama fitur berubah dari "Door & Room Management" jadi "Door Management" doang** — `RoomService`/`RoomTask` **dihapus dari rencana**. Alasannya: kos di game ini gak banyak ruangan, dan tiap ruangan udah termodelin fisik di map (gak butuh sistem visibility/portal terpisah). Pindah ke peta Kampus juga gak pakai `change_scene_to_file` lagi — cukup teleport posisi Player, karena `MainMap` & `KampusKelas` sama-sama di-instance bareng di `Gameplay.tscn` (lihat Fitur 15 & `Engine_Design.md` §3.C).*

**Dependency**: [03_Interaction_Registry_System](03_Interaction_Registry_System.md)

---

## Phase (Garis Besar)
1. `DoorDriver.gd` konkret: `class_name DoorDriver extends InteractableDriver`, `@export var is_locked`, `@export var key_id_required`, signal `interacted(door_id)`. `interact()` **cuma** cek `is_locked` milik sendiri (physical state, bukan keputusan lintas-domain) — kalau locked, mainin `locked_sound` + `interacted.emit(door_id)`; kalau enggak, `toggle_door()` + `interacted.emit(door_id)`.
2. `DoorService.gd` (registry pattern sama seperti NPC/Item): `register_door`, `unregister_door`, `get_door`, `unlock_door(door_id)` (set `is_locked = false` di Driver), plus relay sinyal `door_interacted`.
3. Isi `interaction_task.gd`'s `_on_door_interacted()` (kerangka udah ada, isinya masih placeholder) — pola: kalau item kunci ke-collect (dengerin `story_task.has_evidence(key_id)`), langsung commands `DoorService.unlock_door(door_id)`. Ini bisa proaktif (pas item diambil) ATAU reaktif (pas coba buka pintu) — pilih salah satu, proaktif lebih simpel karena `DoorDriver.interact()` gak perlu tau apa-apa soal evidence.
4. Scene test dengan 2–3 pintu dummy (1 terkunci butuh kunci, 1 bebas) buat validasi.

## Testing Criteria (Garis Besar)
- Pintu terkunci menolak dibuka tanpa key_id yang sesuai (`DoorDriver` mainin `locked_sound` sendiri, gak butuh tanya siapa-siapa).
- Setelah item kunci yang sesuai di-collect (integrasi Fitur 05 → `InteractionTask` → `StoryTask.has_evidence()`), `DoorService.unlock_door()` kepanggil otomatis, pintu bisa dibuka.
- `DoorService` bisa dipanggil dari `StoryTask` (lewat `_apply_checkpoint_effect`) buat paksa buka/kunci pintu tertentu sebagai bagian checkpoint cerita — bukan `DoorService` manggil `StoryTask` (arah sebaliknya dilarang).

## Checkpoint (Garis Besar)
- Sistem pintu terbukti stabil di scene test (termasuk integrasi ke `InteractionTask`/`StoryTask`), siap dipakai membangun layout penuh Map Utama (07).
