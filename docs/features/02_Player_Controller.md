# Fitur 02 — Player Controller

**Ringkasan**: Karakter first-person yang bisa jalan, lari, lihat sekitar, dan menyalakan senter. Ini prasyarat untuk menguji semua fitur interaktif berikutnya.

**Dependency**: [01_Project_Foundation](01_Project_Foundation.md)

---

## Phase (Garis Besar)
1. `PlayerMovementDriver.gd` di atas `CharacterBody3D` — gerak jalan/lari, gravity, mouse-look kamera.
2. Setup `SpotLight3D` di tangan player sebagai senter (toggle on/off).
3. `RayCast3D` dari kamera untuk deteksi interaksi (dipakai `InteractionService` di fitur 03).
4. Scene test kosong (grey room) untuk uji coba gerak & collision.

## Testing Criteria (Garis Besar)
- Player bisa jalan, lari, lompat (jika ada), dan mouse-look terasa halus tanpa jitter.
- Senter bisa dinyalakan/dimatikan.
- Raycast interaksi terdeteksi di console/debug saat mengarah ke objek dummy.

## Checkpoint (Garis Besar)
- Player controller stabil di grey room, siap dipakai fitur Interaction & Registry System (03).
