# Fitur 04 — NPC & Dialogue System

**Ringkasan**: Sistem "Dialogue Mode" — begitu masuk mode ini, gerak & mouse-look Player dikunci total, kamera Player otomatis nengok ke siapapun yang lagi ngomong (NPC atau Player sendiri), dan 1 file `DialogueData` (`.tres`) berisi **percakapan multi-pembicara** (Player + 1 NPC, atau Player + beberapa NPC sekaligus) — bukan cuma monolog 1 NPC. Lanjut baris pakai **klik mouse / Spasi**, bukan `interact` lagi.

*Revisi total dari versi sebelumnya (yang cuma 1 NPC ngomong, player masih bisa gerak bebas). Perubahan ini butuh 1 Service baru (`PlayerService`) dan struktur data `DialogueData` yang beda — lihat breakdown di bawah.*

**Dependency**: [03_Interaction_Registry_System](03_Interaction_Registry_System.md)

**Output Akhir**: Interact ke NPC manapun → Player kekunci gerak+mouse, kepala Player otomatis nengok ke pembicara aktif (gantian kalau lebih dari 1 orang ngomong dalam 1 percakapan, termasuk pas giliran Raka/Player "ngomong"), dialog box nampilin nama+teks sesuai pembicara saat itu, klik kiri/Spasi buat lanjut baris, dan pas percakapan abis, kontrol Player balik normal.

*Pembagian kerja sama seperti fitur sebelumnya: struktur node scene kamu bikin manual di editor (kalau ada yang baru), script & wiring saya eksekusi.*

---

## Ringkasan Perubahan Arsitektur

| Sebelumnya | Sekarang |
|---|---|
| `DialogueData.lines: Array[String]` — semua baris otomatis dianggap punya NPC itu | `DialogueData.lines: Array[DialogueLine]` — tiap baris punya `speaker_id` sendiri (`"player"`, `"npc_hasan"`, `"npc_chika"`, dst.) — 1 file `.tres` = 1 percakapan lengkap multi-pembicara |
| Lanjut baris = tekan `interact` (E) lagi | Lanjut baris = tekan **Spasi** atau **klik kiri mouse** (action baru `dialogue_next`) |
| Player tetap bisa gerak & mouse-look bebas pas dialog kebuka | Player **movement_locked** total (WASD + mouse-look mati) selama dialog aktif |
| Cuma NPC yang di-interact yang `look_at_player()`, 1x di awal | **Setiap ganti baris**, siapapun `speaker_id`-nya (kalau NPC) yang `look_at_player()`, DAN kepala Player (`Head`) otomatis nengok balik ke NPC itu — gantian tiap baris kalau pembicaranya beda-beda |
| Gak ada konsep "Player ngomong" | Baris dengan `speaker_id = "player"` nampilin nama Raka di dialog box; kamera Player gak perlu nengok kemana-mana (gak ada yang dilihat, first-person) |

**Kenapa butuh `PlayerService` baru**: Sebelumnya `DialogueTask` cuma butuh posisi kamera Player (`get_viewport().get_camera_3d().global_position()`) buat `look_at_player()`. Sekarang `DialogueTask` juga perlu **ngasih perintah** ke Player (`kunci gerak`, `nengok ke titik ini`) — itu perintah ke Driver, jadi wajib lewat Service (bukan Task nyolek Driver langsung). `PlayerService` isinya registry tipis (1 instance doang, sama pola kayak `DialogueService` buat `DialogueBoxDriver`) yang wrap `PlayerMovementDriver`.

---

## Phase 0 — Persiapan Assets & Scene
**Status: udah dieksekusi di sesi sebelumnya, gak ada perubahan node/scene baru di revisi ini.** Semua kebutuhan baru (multi-speaker, lock, camera-turn) murni perubahan script + data + Input Map — **gak ada scene baru yang perlu kamu bikin**. 5 scene NPC + `DialogueBox.tscn` yang udah ada tetap dipakai apa adanya.

### Testing Phase 0
- [ ] (Sudah lulus sebelumnya — gak perlu diulang, cuma sanity check) 5 scene NPC + `DialogueBox.tscn` masih ada di `Gameplay.tscn`.

---

## Phase 1 — `DialogueLine` + `DialogueData` (Struktur Baru) + Tulis Ulang 5 Percakapan
Ganti struktur data dari "1 NPC monolog" jadi "percakapan multi-pembicara".

**Langkah**:
1. Buat `resources/dialogue/dialogue_line.gd`: `class_name DialogueLine extends Resource`. Field: `@export var speaker_id: String = ""` (isi `npc_id` NPC terkait, ATAU literal `"player"` buat baris Raka), `@export var speaker_display_name: String = ""` (nama yang tampil di dialog box), `@export var text: String = ""`.
2. Update `resources/dialogue/dialogue_data.gd`: ganti `lines: Array[String]` jadi `@export var lines: Array[DialogueLine] = []`.
3. Tulis ulang ke-5 file `.tres` (`hasan.tres`, `chika.tres`, `pakyono.tres`, `buyuni.tres`, `dimas.tres`) — sekarang tiap file isinya percakapan bolak-balik. **Minimal 1 dari 5 file (misal `hasan.tres`) dikasih baris `speaker_id = "player"` di antaranya**, biar kebukti multi-pembicara jalan pas testing. Contoh alur `hasan.tres`:
   - `npc_hasan`: "Eh, lo anak baru ya? Gua Hasan, kamar sebelah."
   - `player`: "Oh iya, gua Raka, baru pindah kos hari ini."
   - `npc_hasan`: "Selamat datang di kos horor, hati-hati kesambet — becanda doang kok... kayaknya."

**Testing Phase 1**:
- [ ] Ke-5 file `.tres` kebuka tanpa error, tiap elemen `lines` punya `speaker_id`/`speaker_display_name`/`text` keisi.
- [ ] Minimal 1 percakapan punya campuran `speaker_id` (`"npc_..."` dan `"player"`).
- [ ] Gak ada parse error di `dialogue_line.gd`/`dialogue_data.gd`.

---

## Phase 2 — `NPCDriver` + Attach ke 5 Karakter
**Status: udah dieksekusi, gak ada perubahan.** `npc_driver.gd` udah punya field `dialogue_data`, ke-5 scene NPC udah di-assign `.tres` masing-masing. Field ini otomatis kepakai lagi walau isi `.tres`-nya berubah struktur (Phase 1) — gak perlu attach ulang apapun.

### Testing Phase 2
- [ ] (Sanity check) Klik salah satu NPC di `Gameplay.tscn`, field `Dialogue Data` masih keisi `.tres` yang bener.

---

## Phase 3 — `PlayerService` + Kunci Gerak/Mouse + Kamera Nengok ke Pembicara
Bagian paling baru: `PlayerMovementDriver` dapet kemampuan "dikendaliin dari luar" (dikunci, dipaksa nengok), lewat `PlayerService`.

**Langkah**:
1. Buat `scripts/services/player_service.gd` (registry tipis, 1 instance — pola sama kayak `DialogueService`): `register_player(driver)`, `unregister_player(driver)`, `get_player() -> PlayerMovementDriver`. Daftarkan sebagai Autoload.
2. Update `scripts/drivers/characters/player_movement_driver.gd`:
   - `_ready()`: tambah `PlayerService.register_player(self)`. `_exit_tree()`: unregister.
   - Tambah `var movement_locked: bool = false`.
   - Tambah `func set_movement_locked(locked: bool) -> void` — set `movement_locked`, kalau `true` langsung nolin `velocity.x`/`velocity.z`.
   - Tambah `var _look_target: Vector3`, `var _has_look_target: bool = false`, `func set_look_target(pos: Vector3) -> void`, `func clear_look_target() -> void`.
   - Tambah `@export var look_turn_speed: float = 4.0` — kecepatan kepala "nengok" (pakai `lerp_angle`, biar halus bukan instan-nyentak).
   - `_unhandled_input()`: mouse motion buat rotasi **cuma diproses kalau `not movement_locked`** (flashlight toggle tetap boleh jalan, gak dikunci).
   - `_physics_process()`: kalau `movement_locked` → skip baca input WASD (redam `velocity.x`/`z` ke 0 pelan), dan panggil method baru `_apply_look_target(delta)` yang muter `rotation.y` (root) & `head.rotation.x` pakai `lerp_angle` menuju arah `_look_target`. Kalau `not movement_locked` → jalan normal kayak sekarang (WASD + gravity + bob), gak ada `_apply_look_target`.
   - Tambah `func get_camera_global_position() -> Vector3` — return `camera.global_position` (ganti cara `DialogueTask` ambil posisi kamera, dari `get_viewport().get_camera_3d()` jadi lewat `PlayerService`).
3. Setup Input Map action baru `dialogue_next` — binding **Spasi** dan **Klik Kiri Mouse** (2 event di action yang sama).

**Testing Phase 3** *(belum kepakai penuh sampai Phase 4, tapi bisa dites parsial)*:
- [ ] `PlayerService` muncul di Autoload Project Settings.
- [ ] Project Settings → Input Map → ada action `dialogue_next` dengan 2 binding (Space + Mouse Left).
- [ ] Gak ada parse error di `player_movement_driver.gd`/`player_service.gd`.
- [ ] (Manual via Remote/debug sementara) manggil `PlayerService.get_player().set_movement_locked(true)` bikin WASD & mouse-look beneran berhenti; `set_look_target(posisi_NPC_tertentu)` bikin kepala Player pelan-pelan nengok ke situ.

---

## Phase 4 — `DialogueTask` Multi-Pembicara + Wiring Lengkap
Ganti logic `DialogueTask` total: mulai dialog → kunci Player → loop ganti baris (pembicara bisa beda-beda tiap baris, kamera ngikut) → `dialogue_next` buat lanjut → selesai → buka kunci Player.

**Langkah**:
1. Update `scripts/controllers/tasks/dialogue_task.gd`:
   - State baru: `_current_data: DialogueData`, hapus asumsi lama "npc_id yang lagi diajak ngomong = pembicara".
   - `_on_npc_interacted(npc_id)`: **kalau lagi ada dialog aktif (`_current_data != null`), abaikan** (E gak lagi dipakai buat lanjut). Kalau belum ada dialog aktif: validasi `dialogue_data` NPC itu ada & gak kosong → set state awal, `yono_interaction_count` naik kalau `npc_id == "npc_yono"`, panggil `PlayerService.get_player().set_movement_locked(true)`, lalu `_show_current_line()`.
   - `_unhandled_input(event)`: kalau `_current_data != null` dan `event.is_action_pressed("dialogue_next")` → `_advance()`.
   - `_show_current_line()`: ambil `DialogueLine` di index sekarang. Kalau `speaker_id != "player"` → cari drivernya (`NPCService.get_npc(speaker_id)`), panggil `.look_at_player(PlayerService.get_player().get_camera_global_position())`, dan `PlayerService.get_player().set_look_target(npc.global_position)`. Kalau `speaker_id == "player"` → **jangan** panggil `set_look_target` (biar kamera diem, gak ada yang perlu dilihat first-person). Tampilin `speaker_display_name` + `text` ke `DialogueService.get_dialogue_box()`.
   - `_advance()`: naik index; abis baris terakhir → panggil `_end_dialogue()`; belum → `_show_current_line()` lagi (otomatis ganti target kamera kalau pembicara baris berikutnya beda).
   - `_end_dialogue()`: sembunyiin dialog box, `PlayerService.get_player().set_movement_locked(false)` + `.clear_look_target()`, emit `dialogue_finished`, reset state.
2. `DialogueBoxDriver`/`dialogue_service.gd` — **gak ada perubahan**, tetap dipanggil `show_line(name, text)`/`hide_box()` yang sama.

**Testing Phase 4** *(full test, F5 langsung — pakai `hasan.tres` yang udah dikasih baris `"player"` di Phase 1)*:
- [ ] Interact Hasan — WASD & mouse-look **langsung mati total**, gak bisa gerak/nengok sendiri sama sekali.
- [ ] Baris pertama (Hasan ngomong) — kepala Player **pelan-pelan nengok** ke Hasan, Hasan juga noleh ke Player, dialog box nampilin "Hasan".
- [ ] Klik kiri mouse (ATAU pencet Spasi) — lanjut ke baris ke-2 (baris Raka) — dialog box ganti nama jadi "Raka"/nama Player, **kamera gak ikut muter** (diem aja, karena speaker-nya Player).
- [ ] Lanjut lagi — balik ke baris Hasan (kalau ada) — kamera nengok balik ke Hasan lagi.
- [ ] Abis baris terakhir, klik/Spasi sekali lagi — dialog box **hilang**, WASD & mouse-look **balik normal**, bisa gerak & nengok bebas lagi.
- [ ] Pencet `interact` (E) pas lagi di tengah dialog — **gak ngapa-ngapain** (bukan lanjut baris, bukan mulai dialog baru).
- [ ] Ulangi ke NPC lain (Chika/Pak Yono/Bu Yuni/Dimas) — behaviour sama, dialog beda-beda sesuai `.tres` masing-masing.
- [ ] Interact Pak Yono 2-3x (dialog baru tiap kali, bukan pas lagi ngobrol) — `yono_interaction_count` di `Tasks/DialogueTask` tetep naik bener.
- [ ] Gak ada error console soal `PlayerService`, `movement_locked`, atau null reference `_look_target`.

---

## Checkpoint Akhir Fitur 04
- Mode Dialog beneran "ngunci" pengalaman — Player gak bisa ngapa-ngapain selain baca & lanjut dialog selama percakapan aktif.
- 1 percakapan bisa nampilin lebih dari 1 pembicara (NPC + Raka, bahkan NPC lain kalau mau), kebukti lewat `hasan.tres` yang punya baris `"player"`.
- Kamera Player otomatis gantian nengok ke pembicara aktif tiap baris, NPC yang lagi ngomong juga noleh balik — dua-duanya saling ngadep pas ngobrol.
- `PlayerService` jadi pola baru buat "Task ngasih perintah ke Player Driver" — bakal dipakai ulang nanti (misal Fitur 09 Distortion buat maksa kamera/gerakan pas momen horor).
- Siap lanjut ke **Fitur 05 (Item & Evidence System)** — pola sinyal Driver → relay Service → keputusan Task tetap sama, `InteractionTask` tinggal disusul sama pola serupa.
