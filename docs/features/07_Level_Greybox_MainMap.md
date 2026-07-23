# Fitur 07 — Level Greybox: MainMap.tscn

**Ringkasan**: Membangun layout fisik penuh `MainMap.tscn` (masih greybox/blockout, belum art final): Lorong Utama, Kamar Raka (No.7), Kamar Hasan (No.4), Kamar Dimas (No.10), Kamar Kosong/Terlarang, Dapur Bersama, Kamar Mandi Belakang, Halaman Belakang, Ruang Bawah Tanah/Labirin, **Minimarket**, dan **Jalan Penghubung** antara kos dan minimarket — semuanya dalam satu scene (bukan pindah scene). Sumber geometri dasar berasal dari model `.glb` gabungan di `assets/models/environment/main_map/`.

**Dependency**: [06_Door_Room_Management](06_Door_Room_Management.md)

---

## Phase (Garis Besar)
1. Import `.glb` map utama (`assets/models/environment/main_map/`) ke Godot, cek skala/orientasi/collision hasil import.
2. Susun `MainMap.tscn` di `scenes/levels/` dengan model tersebut sebagai base, tambahkan collision manual jika import belum menyediakan (`StaticBody3D`/`CollisionShape3D`).
3. Pasang semua `Area3D` room trigger + `DoorDriver` di posisi asli (kos, minimarket, jalan) — bukan dummy lagi.
4. Pasang NavMesh dasar untuk NPC (jika dibutuhkan pathfinding, bukan sekadar teleport).
5. Placement awal semua NPC & item statis (posisi default sebelum event apapun terjadi), termasuk area minimarket.
6. Basic lighting pass (belum atmosfer horor detail — itu fitur 09/16), termasuk beda mood antara area kos (interior) dan area jalan/minimarket (eksterior).

## Testing Criteria (Garis Besar)
- Player bisa menjelajah seluruh kos, jalan penghubung, hingga minimarket dalam satu sesi tanpa loading/scene-switch, dan tanpa collision bug/stuck.
- Semua pintu berfungsi dengan `DoorService` yang sudah dibangun (lihat `Engine_Design.md` §3.C — gak ada `RoomService`/`RoomTask`, room management disederhanain jadi teleport posisi Player buat pindah peta, lihat Fitur 15).
- Frame rate stabil saat semua area "aktif" sekaligus (uji batas performa Single-Scene Architecture yang sekarang lebih besar karena mencakup minimarket+jalan).

## Checkpoint (Garis Besar)
- Layout MainMap (kos+minimarket+jalan) lengkap & bisa dijelajah, siap ditempeli Story Engine (08) dan konten chapter (12–14).
