# Fitur 06 — Door & Room Management System

**Ringkasan**: `DoorDriver` (buka/tutup/terkunci) + sistem manajemen visibilitas ruangan (`Room/Portal` atau script `Visible` per kamar) supaya arsitektur Single-Map Bounded (`MainMap.tscn`) tetap efisien tanpa scene-switching.

**Dependency**: [03_Interaction_Registry_System](03_Interaction_Registry_System.md)

---

## Phase (Garis Besar)
1. `DoorDriver.gd` konkret: toggle open/close, cek `is_locked` + `key_id_required` (integrasi dengan Evidence/Item untuk kunci).
2. `RoomService.gd` (registry pattern sama seperti NPC/Item): daftar room by ID, kontrol visibilitas + lighting per room.
3. Area3D trigger per pintu/lorong untuk deteksi player masuk/keluar room → panggil `RoomService`.
4. Scene test dengan 2–3 room dummy terhubung pintu untuk validasi transisi.

## Testing Criteria (Garis Besar)
- Pintu terkunci menolak dibuka tanpa key_id yang sesuai, dan bisa dibuka setelah item kunci didapat (integrasi fitur 05).
- Berpindah antar room dummy mengubah visibilitas node dengan mulus, tanpa drop FPS signifikan.
- `RoomService` bisa dipanggil dari Service lain (mis. Story Engine) untuk paksa buka/kunci pintu tertentu.

## Checkpoint (Garis Besar)
- Sistem pintu + visibilitas room terbukti stabil di scene test, siap dipakai membangun layout penuh Map Utama (07).
