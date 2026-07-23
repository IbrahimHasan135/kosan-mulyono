# Fitur 15 — Peta Kampus (Teleport, Bukan Scene Terpisah)

**Ringkasan**: Ruang kelas kampus (cuma 1 ruangan) di-instance **bareng** `MainMap` di `Gameplay.tscn` — pindah ke sana cukup **teleport posisi Player**, bukan `change_scene_to_file`. Sumber geometri dari `assets/models/environment/kampus_kelas/`.

*Revisi arsitektur: rencana lama pakai `get_tree().change_scene_to_file()` buat pindah scene. Direvisi karena kampus cuma 1 ruangan kecil, dan `KampusKelas` gak butuh dipisah scene — cukup diinstance sebagai node lain di `Gameplay.tscn` (sejajar `MainMap`), diposisiin jauh dari `MainMap` (atau di ketinggian/koordinat berbeda) biar gak numpuk collision, terus Player di-teleport (`global_position = ...`) ke titik spawn di area kampus. Ini juga yang bikin `RoomTask` gak perlu ada (lihat Fitur 06) — gak ada state "scene mana yang lagi aktif" yang perlu dikelola, cuma posisi Player yang pindah.*

**Dependency**: [12_Prologue_Chapter_Content](12_Prologue_Chapter_Content.md) (bisa dikerjakan paralel dengan fitur 13/14 karena tidak saling blocking)

---

## Phase (Garis Besar)
1. Import `.glb` ruang kelas kampus (`assets/models/environment/kampus_kelas/`) dan susun jadi scene `KampusKelas.tscn` di `scenes/levels/` (murni geometri, sama pola kayak `MainMap.tscn` — gak ada Player/Controller di dalamnya).
2. Instance `KampusKelas.tscn` sebagai child `Gameplay.tscn`, posisiin di koordinat yang jauh dari `MainMap` (biar collision-nya gak numpuk/ketuker).
3. Bikin trigger teleport: `InteractableDriver` khusus (mis. `TeleportDriver.gd`, atau pintu kampus pakai `DoorDriver` yang di-extend) yang manggil `player.global_position = target_position` pas di-interact — logic "kapan boleh teleport ke kampus" (misal cuma di sekuens tertentu Prologue) dicek lewat `story_task.check_flag(...)` di `InteractionTask`.
4. Isi dialog & event spesifik area ini (sekuens singkat di kelas kampus sesuai alur Prologue).

## Testing Criteria (Garis Besar)
- Interact ke trigger kampus → Player ke-teleport ke titik spawn `KampusKelas`, tanpa loading screen/jeda (karena emang gak ganti scene).
- State penting (evidence, flag di `StoryTask`) gak berubah/hilang sama sekali karena emang gak ada scene yang di-unload.
- Interact ke trigger pulang → Player balik ke posisi yang bener di `MainMap`.
- Gak ada collision `KampusKelas` yang "bocor" ke area `MainMap` (posisinya harus cukup jauh terpisah).

## Checkpoint (Garis Besar)
- Area kampus playable dan terintegrasi mulus ke alur Prologue lewat teleport, tanpa kompleksitas scene-switching.
