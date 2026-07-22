# Fitur 02a — Environment & Time-of-Day System

**Ringkasan**: Sistem buat gonta-ganti preset pencahayaan/atmosfer (sky, fog, warna matahari) secara modular — bisa diganti manual lewat Inspector Godot (buat kamu & temen kamu diskusi art concept, nol kode) ATAU dipanggil programatik lewat `EnvironmentService` (buat gameplay sungguhan nanti, dipicu `MainGameController`/`StoryEngineService`).

**Dependency**: [02_Player_Controller](02_Player_Controller.md) (butuh `Gameplay.tscn` udah ada)

**Kenapa dibutuhin sekarang**: Kamu & temen kamu lagi fokus art concept (model, shader), dan `Game_Design.md` sendiri butuh banyak waktu (siang, sore-maghrib, malam) dalam cerita yang sama — jadi preset environment harus modular dari awal, bukan di-hardcode 1 doang kayak yang kita edit manual sebelumnya di `Gameplay.tscn`.

*Beda dari fitur sebelumnya: dieksekusi flat, gak dipecah Phase — semua langsung jadi sekali jalan, kamu tinggal drag 1 scene ke `Gameplay.tscn` dan tes.*

---

## Yang Dibuat (sudah dieksekusi semua, gak ada yang kamu tulis manual)

| File | Peran |
|---|---|
| `resources/environment/environment_preset_data.gd` | `class_name EnvironmentPresetData extends Resource` — struktur data 1 preset: `environment` (Environment resource), `sun_rotation_degrees`, `sun_color`, `sun_energy`, `sun_visible` (bool), `street_lights_visible` (bool). |
| `resources/environment/siang.tres` | Preset terang tapi diredupin/muted (biar gak "cerah bahagia banget") — `sun_visible = true`, `street_lights_visible = false`. |
| `resources/environment/sore_maghrib.tres` | Preset yang udah kita tuning bareng — langit oranye-emas, matahari rendah tapi masih jelas keliatan — `sun_visible = true`, `street_lights_visible = false`. |
| `resources/environment/malam.tres` | Preset gelap tapi dinaikin dikit biar gak blank total (masih keliatan navigasi) — `sun_visible = false` (matahari disembunyiin, bayangannya bikin feel malem gak natural), `street_lights_visible = true` (lampu jalan nyala, tempat kamu naruh cahaya bulan sendiri). |
| `scripts/drivers/environments/environment_driver.gd` | **Layer 1 (Driver)**, `@tool`, nempel di root `EnvironmentRig`. Method `apply_preset(preset)` — set `WorldEnvironment.environment`, rotasi/warna/energi `DirectionalLight3D`, toggle `Sun.visible` (`sun_visible`), DAN toggle `LightingNight.visible` (`street_lights_visible`) sekaligus. Field `@export var current_preset` muncul sebagai dropdown di Inspector — ganti field ini di editor = preview langsung berubah real-time, nol kode. |
| `scripts/services/environment_service.gd` | **Layer 2 (Autoload)**, daftar 3 preset (`siang`, `sore_maghrib`, `malam`), method `set_time_of_day(nama)` yang nyari `EnvironmentDriver` yang lagi aktif (self-registered) dan manggil `apply_preset`. Ini yang dipanggil programatik pas gameplay jalan. |
| `scenes/entities/environment/EnvironmentRig.tscn` | Scene wadah: `EnvironmentRig` (root, script Driver) → child `WorldEnvironment`, `Sun` (`DirectionalLight3D`), dan `LightingNight` (`Node3D` kosong — wadah lampu jalan). **Ini yang kamu drag ke `Gameplay.tscn`.** |
| `project.godot` | `EnvironmentService` didaftarin sebagai Autoload. |
| `scripts/controllers/main_game_controller.gd` | Ditambah 1 baris: `EnvironmentService.set_time_of_day("sore_maghrib")` di `_ready()` — ini keputusan "waktu apa yang dipakai pas game beneran jalan", lewat kode, bukan manual. |

## Yang Kamu Lakukan (manual)
1. Buka `scenes/Gameplay.tscn` di editor.
2. Drag `scenes/entities/environment/EnvironmentRig.tscn` dari FileSystem dock ke scene tree `Gameplay`, jadi child root (sejajar `MainMap` dan `Player`).
3. Hapus/matiin `WorldEnvironment` lama yang udah ada langsung di `Gameplay.tscn` (yang kita edit manual sebelumnya) — biar gak dobel/bentrok sama `WorldEnvironment` di dalam `EnvironmentRig`.
4. **Isi node `LightingNight`** (di dalam `EnvironmentRig.tscn`) dengan lampu jalan + cahaya bulan beneran — tambahin `OmniLight3D`/`SpotLight3D` sebagai child-nya (lampu jalan di posisi tiang, plus 1 lampu buat cahaya bulan), posisiin sesuai layout map kamu. Node ini otomatis di-nyala/matiin sama Driver berdasarkan preset (`street_lights_visible`), kamu tinggal isi lampunya aja, gak perlu urus toggle-nya. Karena `Sun` otomatis disembunyiin pas preset `malam`, `LightingNight` ini jadi satu-satunya sumber cahaya pas malam — pastiin isi lampu di sini cukup buat bikin scene tetap keliatan.
5. Save scene.

---

## Cara Milih-Milih Preset

**Manual lewat UI (buat diskusi sama temen, gak ngoding)**:
- Klik node `EnvironmentRig` di scene tree (`Gameplay.tscn` atau `EnvironmentRig.tscn` langsung).
- Di Inspector, field **Current Preset** — drag salah satu dari `siang.tres` / `sore_maghrib.tres` / `malam.tres` (di `resources/environment/`) ke situ.
- **Langsung keliatan perubahannya di viewport editor**, gak perlu run game, gak perlu sentuh kode.

**Lewat kode (pas gameplay beneran jalan)**:
- `main_game_controller.gd` manggil `EnvironmentService.set_time_of_day("sore_maghrib")` pas `_ready()`.
- Ini **override** apapun yang kepilih manual di Inspector — begitu F5, yang dipakai adalah preset yang ditentuin lewat kode ini, bukan preview manual kamu.
- Mau ganti waktu yang dipakai pas gameplay? Ganti nama string di baris itu ke `"siang"` / `"sore_maghrib"` / `"malam"`.

---

## Testing (kamu jalanin sendiri)
- [ ] `EnvironmentRig.tscn` berhasil di-drag ke `Gameplay.tscn` tanpa error merah.
- [ ] Klik node `EnvironmentRig` di Inspector, field `Current Preset` kelihatan, isinya `sore_maghrib.tres` secara default.
- [ ] **Test manual/UI**: ganti `Current Preset` ke `malam.tres` di Inspector (masih di editor, belum run) — viewport 3D editor langsung berubah gelap (tapi masih keliatan detailnya, gak blank total) tanpa run game. Ganti lagi ke `siang.tres` — langsung berubah terang tapi muted/gak vibrant. Ini bukti fitur "diskusi tanpa kode" jalan.
- [ ] **Test lampu jalan**: begitu ganti ke `malam.tres`, node `LightingNight` (dan isi lampu di dalamnya) harus keliatan/nyala. Ganti ke `siang.tres`/`sore_maghrib.tres`, `LightingNight` harus invisible.
- [ ] **Test Sun mati pas malam**: ganti `Current Preset` ke `malam.tres` — node `Sun` (`DirectionalLight3D`) harus invisible (gak ada bayangan matahari sama sekali). Ganti ke `siang.tres`/`sore_maghrib.tres`, `Sun` harus muncul lagi.
- [ ] Balikin `Current Preset` ke `sore_maghrib.tres` lagi (atau biarin apa aja, gak ngaruh ke hasil run — lihat poin berikutnya).
- [ ] **Test kode**: tekan F5 — walaupun tadi Inspector-nya di-set ke preset lain, begitu game jalan harus balik ke preset `"sore_maghrib"` (sesuai kode di `main_game_controller.gd`), soalnya kode yang menang pas runtime. Lampu jalan otomatis ikutan mati juga (karena preset `sore_maghrib` = `street_lights_visible: false`).
- [ ] Gak ada error di console soal `EnvironmentService`, `EnvironmentDriver`, atau `null` reference.

## Catatan Teknis (gotcha Godot yang kejadian pas eksekusi ini)
- Setter `current_preset` sempat gak jalan di editor (cuma jalan pas Play) gara-gara gate `is_node_ready()` — sudah dihapus, `apply_preset()` sekarang selalu jalan begitu preset diganti.
- Script `@tool` **gak boleh** manggil Autoload lewat nama global langsung (`EnvironmentService.xxx`) — itu bikin compile error `Identifier not found` pas dipakai di editor murni (autoload cuma ada pas Play). Fix: akses lewat `get_node_or_null("/root/EnvironmentService")`. Aturan ini juga udah dicatat di `Engine_Design.md` §4 biar gak kejadian lagi di driver `@tool` lain ke depannya.

## Checkpoint
- Preset environment udah modular — nambah waktu baru = tinggal bikin 1 file `.tres` baru + 1 baris di `PRESETS` dictionary `environment_service.gd`, gak perlu ubah scene/driver apapun.
- Lampu jalan (`LightingNight`) otomatis nyala/mati ngikutin preset, tanpa kode tambahan tiap ganti preset.
- Kamu & temen kamu bisa preview cepat lewat Inspector buat diskusi art concept.
- Gameplay sungguhan tetap dikontrol lewat kode (`Controller → Service`), siap dipanggil `StoryEngineService` pas checkpoint cerita di Fitur 08 nanti.
