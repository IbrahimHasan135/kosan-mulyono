# Fitur 01 — Project & Architecture Foundation

**Ringkasan**: Menyiapkan kerangka teknis kosong: struktur folder, base class Driver/Service, dan autoload dasar sesuai `Engine_Design.md`. Tidak ada gameplay di fitur ini — murni pondasi supaya fitur 02 dan seterusnya punya tempat berpijak.

**Dependency**: Tidak ada (fitur pertama).

**Output Akhir**: Project Godot yang bisa di-run (F5) tanpa error, dengan struktur folder lengkap, 1 base class Driver, 1 Service autoload, 1 Controller shell, dan 1 scene kosong (`MainMap.tscn`) sebagai main scene sementara.

---

## Konvensi Pembagian Kerja (berlaku untuk semua fitur ke depan)
- **Script (`.gd`), folder, Project Settings, Autoload** → dieksekusi langsung (file teks, tidak butuh interaksi visual editor).
- **Scene (`.tscn`) — struktur node-nya** → **dibuat manual di Godot editor** oleh kamu, sesuai spesifikasi (tipe root node, nama, child node apa aja) yang dicantumkan di Phase 0.
- **Attach script ke node dalam scene** → tetap dieksekusi (edit isi file `.tscn` langsung), bukan langkah manual kamu.

---

## Phase 0 — Persiapan Assets & Scene
*Semua yang harus sudah ada SEBELUM Phase 1 dimulai, dikumpulkan di sini — bukan dicicil per phase.*

### Assets (model/texture/audio)
**Tidak ada yang dibutuhkan.** Fitur ini murni scaffolding kode & folder — tidak menyentuh `.glb`, texture, atau audio apapun. Model map utama (`assets/models/environment/main_map/`) & kampus baru dipakai mulai Fitur 07/15.

### Scene yang harus dibuat duluan
**Scene: `MainMap.tscn`**

| Detail | Isi |
|---|---|
| Nama file | `MainMap.tscn` |
| Lokasi save | `res://scenes/levels/MainMap.tscn` |
| Tipe root node | `Node3D` |
| Nama root node | `MainMap` |
| Child node | Tidak ada — kosong. Jangan tambah Camera/Mesh/Light apapun, itu urusan Fitur 02 & 07. |
| Script | Belum di-attach di titik ini — baru ditempel otomatis di Phase 5, setelah script controller-nya jadi. |

**Cara bikin**: Godot Editor → New Scene → root node `Node3D` → rename jadi `MainMap` → Save As ke lokasi di atas.

### Testing Phase 0
- [ ] File `res://scenes/levels/MainMap.tscn` ada.
- [ ] Root node bertipe `Node3D`, bernama `MainMap`, tanpa child, tanpa script attached.

---

## Phase 1 — Verifikasi Struktur Direktori
*(Folder fisiknya sudah dibuat di sesi sebelumnya — phase ini murni verifikasi, bukan bikin baru.)*

**Langkah**:
1. Cross-check seluruh folder terhadap diagram `Engine_Design.md` §2: `assets/{models,textures,materials,audio,images,fonts,shaders}/...`, `scenes/{levels,entities/{player,npc,items,doors},ui}/`, `scripts/{controllers,services,drivers/{base,objects,characters,environments}}/`, `resources/{dialogue,items,story}/`, `addons/`.
2. Catat folder yang sudah terisi file vs yang masih kosong (wajar sebagian besar masih kosong di titik ini).

**Testing Phase 1**:
- [ ] Semua folder di diagram §2 ada di filesystem (`find . -type d` mencocokkan diagram).
- [ ] Tidak ada folder nyasar yang menyimpang dari diagram.

---

## Phase 2 — Base Class: `InteractableDriver.gd`
Base class abstrak untuk semua Driver interaktif (Layer 1) sesuai `Engine_Design.md` §3.A.

**Langkah**:
1. Buat `scripts/drivers/base/interactable_driver.gd`: `class_name InteractableDriver extends StaticBody3D`, `@export var prompt_message: String`, method virtual `interact() -> void`.
2. Buka di Godot editor, pastikan tidak ada parse error (ikon script hijau, bukan merah).

**Testing Phase 2**:
- [ ] Tidak ada parse error pada script (cek Script Editor / Errors panel).
- [ ] `InteractableDriver` muncul sebagai custom type yang bisa dipilih saat "New Script" → Inherits.

---

## Phase 3 — Service Layer: `InteractionService.gd` (Autoload)
Service pusat yang mendeteksi objek interaktif via raycast (Layer 2), sesuai `Engine_Design.md` §3.B.1.

**Langkah**:
1. Buat `scripts/services/interaction_service.gd` sesuai contoh di EDD §3.B.1.
2. **Penting**: tambahkan null-guard di `_check_raycast()` (`if raycast == null: return`) — karena `RayCast3D` milik Player **belum ada** sampai Fitur 02 selesai, tanpa guard ini autoload akan error setiap frame begitu project di-run.
3. Daftarkan sebagai Autoload: Project Settings → Autoload → Path `res://scripts/services/interaction_service.gd`, Name `InteractionService`.

**Testing Phase 3**:
- [ ] `InteractionService` muncul di daftar Autoload Project Settings.
- [ ] Menjalankan project (setelah Phase 5 kelar) tidak memunculkan error di console meski `raycast` belum di-assign.

---

## Phase 4 — Controller Shell: `MainGameController.gd`
Kerangka kosong untuk root controller (Layer 3) — **belum** memanggil `StoryEngineService` apapun, karena Service itu baru dibangun di Fitur 08.

**Langkah**:
1. Buat `scripts/controllers/main_game_controller.gd`: `extends Node`, `func _ready() -> void: print("MainGameController: Foundation OK")`.
2. Jangan tambahkan pemanggilan `StoryEngineService`/Service lain — itu baru masuk saat Fitur 08 dieksekusi.

**Testing Phase 4**:
- [ ] Script tidak ada parse error.
- [ ] Siap di-attach ke root node scene `MainMap.tscn` (dari Phase 0) di Phase 5.

---

## Phase 5 — Wiring Scene ke Script & Project Settings
Menempel script ke `MainMap.tscn` yang sudah dibuat di Phase 0, set sebagai main scene, dan setup Input Map dasar.

**Langkah (dieksekusi otomatis)**:
1. Attach `scripts/controllers/main_game_controller.gd` ke root node `MainMap` di `MainMap.tscn`.
2. Set Project Settings → Application → Run → Main Scene → `res://scenes/levels/MainMap.tscn`.
3. Setup Input Map dasar (disiapkan sekarang supaya Fitur 02 tinggal pakai): `interact`, `move_forward`, `move_back`, `move_left`, `move_right`, `sprint`, `flashlight_toggle`.
4. Verifikasi rendering method tetap `gl_compatibility` (sudah di `project.godot`, untuk gaya visual retro/PS1 — detail shader menyusul di Fitur 16).

**Testing Phase 5**:
- [ ] Project di-run (F5) tanpa error/crash, console menampilkan `"MainGameController: Foundation OK"`.
- [ ] Semua Input Map action di atas terdaftar tanpa konflik binding.
- [ ] Tidak ada warning/error dari `InteractionService` di console meski belum ada Player/RayCast3D di scene.

---

## Checkpoint Akhir Fitur 01
- Semua Phase (0–5) di atas lulus testing masing-masing.
- Project bisa dibuka & di-run (F5) tanpa error dari awal.
- Struktur folder, `InteractableDriver`, `InteractionService` (autoload), `MainGameController` (shell), dan `MainMap.tscn` sudah ada — siap ditumpangi **Fitur 02 (Player Controller)**, yang akan mengisi `RayCast3D` ke `InteractionService` dan menaruh Player di dalam `MainMap.tscn` ini.
