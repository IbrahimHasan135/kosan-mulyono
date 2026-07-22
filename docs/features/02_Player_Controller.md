# Fitur 02 — Player Controller

**Ringkasan**: Karakter first-person yang bisa jalan, lari, mouse-look, dan menyalakan senter. Fitur ini juga yang memisahkan `MainMap.tscn` (murni map) dari gameplay — `MainGameController` dipindah ke scene komposisi baru (`Gameplay.tscn`) yang menyatukan map + Player.

**Dependency**: [01_Project_Foundation](01_Project_Foundation.md)

**Output Akhir**: `Player.tscn` yang bisa gerak (WASD + sprint), mouse-look halus, kena gravity/collision dengan map, senter bisa toggle, dan `RayCast3D`-nya nyambung ke `InteractionService`. `Gameplay.tscn` jadi main scene baru (gantiin `MainMap.tscn`), isinya instance `MainMap` + `Player` + `MainGameController`. `MainMap.tscn` sendiri balik jadi murni map, gak ada script nempel lagi.

*Pembagian kerja sama seperti Fitur 01: struktur node scene kamu bikin manual di editor sesuai spec Phase 0, script & wiring (attach/lepas script, isi property export, project settings) saya eksekusi.*

---

## Phase 0 — Persiapan Assets & Scene

### Assets (model/texture/audio)
**Tidak ada yang dibutuhkan.** Player belum butuh model 3D karakter (ini first-person, badan gak keliatan) — cukup collision shape primitive. Model karakter NPC baru mulai dipakai di Fitur 04.

### Scene 1: `Player.tscn` (buat manual di editor)
| Detail | Isi |
|---|---|
| Nama file | `Player.tscn` |
| Lokasi save | `res://scenes/entities/player/Player.tscn` |
| Script | Jangan di-attach manual — saya tempel di Phase 2. |

**Struktur node (tree)**:
```
Player                  (CharacterBody3D)
├── CollisionShape3D    (CollisionShape3D — shape: CapsuleShape3D, radius ~0.4, height ~1.8)
└── Head                (Node3D — posisi y ~1.6, ini pivot buat nunduk/nengadah)
    └── Camera3D        (Camera3D — current: On)
        ├── RayCast3D   (RayCast3D — target_position (0, 0, -3), enabled: On)
        └── Flashlight  (SpotLight3D — visible: Off, spot_range ~8, spot_angle ~35)
```
Catatan penting soal tree ini:
- Rotasi horizontal (nengok kiri-kanan) nanti diterapkan ke root `Player`, rotasi vertikal (nunduk-nengadah) ke `Head` — makanya dipisah jadi 2 level, bukan taruh Camera3D langsung di root.
- `RayCast3D` & `Flashlight` sama-sama child dari `Camera3D` supaya arahnya otomatis ikut ke mana pun kamera nengok.

### Scene 2: `Gameplay.tscn` (buat manual di editor)
Scene komposisi baru yang bakal gantiin `MainMap.tscn` sebagai main scene — menyatukan map + Player di satu tempat, tapi `MainMap.tscn` sendiri gak diutak-atik isinya.

| Detail | Isi |
|---|---|
| Nama file | `Gameplay.tscn` |
| Lokasi save | `res://scenes/Gameplay.tscn` |
| Tipe root node | `Node3D` |
| Nama root node | `Gameplay` |
| Child node | 2 instance: `MainMap` (dari `res://scenes/levels/MainMap.tscn`) dan `Player` (dari `res://scenes/entities/player/Player.tscn`, dari Scene 1 di atas). Posisikan `Player` di titik aman di atas permukaan map (misal di area jalan/halaman), biar pas testing gravity jatuh wajar ke tanah. |
| Script | Belum di-attach di titik ini — ditempel di Phase 1 (menggantikan yang ada di `MainMap.tscn`). |

**Cara bikin**: Godot Editor → New Scene → root node `Node3D` → rename jadi `Gameplay` → Save As ke lokasi di atas → drag `MainMap.tscn` dan `Player.tscn` dari FileSystem dock ke dalam tree ini sebagai child root.

### Testing Phase 0
- [ ] `res://scenes/entities/player/Player.tscn` ada, tree-nya cocok diagram di atas.
- [ ] `res://scenes/Gameplay.tscn` ada, root `Node3D` bernama `Gameplay`, punya 2 child: instance `MainMap` dan instance `Player`, keduanya belum ada script tambahan.

---

## Phase 1 — Migrasi Controller: `MainMap.tscn` → `Gameplay.tscn`
Di Fitur 01, `main_game_controller.gd` nempel langsung di `MainMap.tscn` dan itu jadi main scene. Sekarang dipindah: `MainMap.tscn` balik jadi murni map, `Gameplay.tscn` yang pegang controller & jadi main scene.

**Langkah (dieksekusi otomatis)**:
1. Lepas script `main_game_controller.gd` dari root node `MainMap` di `MainMap.tscn` (hapus property `script`-nya).
2. Attach `main_game_controller.gd` ke root node `Gameplay` di `Gameplay.tscn` (dari Phase 0).
3. Ganti Project Settings → Application → Run → Main Scene dari `res://scenes/levels/MainMap.tscn` → `res://scenes/Gameplay.tscn`.

**Testing Phase 1**:
- [ ] Buka `MainMap.tscn` langsung — root node `MainMap` **tanpa** script apapun.
- [ ] Buka `Gameplay.tscn` — root node `Gameplay` punya script `main_game_controller.gd`.
- [ ] Project Settings → Main Scene sekarang `res://scenes/Gameplay.tscn`.
- [ ] Tekan F5 — yang jalan adalah `Gameplay.tscn`, console tetap muncul `"MainGameController: Foundation OK"`.

---

## Phase 2 — Movement, Gravity & Mouse-Look
`PlayerMovementDriver.gd` (Layer 1 — Driver) nempel di root `Player`. Gerak WASD, sprint, gravity, dan mouse-look (yaw di root, pitch di `Head`).

**Langkah**:
1. Buat `scripts/drivers/characters/player_movement_driver.gd`: `class_name PlayerMovementDriver extends CharacterBody3D`.
2. `_ready()`: set `Input.mouse_mode = Input.MOUSE_MODE_CAPTURED`.
3. Input mouse motion (`_unhandled_input`): rotasi root `Player` di sumbu Y (yaw) pakai `event.relative.x`; rotasi `$Head` di sumbu X (pitch) pakai `event.relative.y`, **clamp** supaya gak bisa muter 360° (misal -80°..80°).
4. `_physics_process(delta)`: tambah gravity ke `velocity.y` tiap frame kalau `not is_on_floor()`, hitung arah gerak dari input `move_forward/back/left/right` relatif ke rotasi `Player`, kalikan `speed` (atau `sprint_speed` kalau `sprint` ditahan), lalu `move_and_slide()`.
5. Attach script ini ke root node `Player` (baik di `Player.tscn` sendiri, otomatis kepakai juga di instance-nya dalam `Gameplay.tscn`).

**Testing Phase 2** *(tekan F5, kamu cek langsung di game)*:
- [ ] Begitu game jalan, cursor mouse ketangkep/ilang (captured mode aktif).
- [ ] WASD gerakin player ke 4 arah, gak nembus lantai/dinding map.
- [ ] Tahan tombol `sprint` (Shift), kecepatan jalan kerasa lebih cepat.
- [ ] Gerakin mouse: nengok kiri-kanan (badan) & nunduk-nengadah (kepala) mulus, gak ada jitter atau kebalik-balik aneh, dan gak bisa muter sampai jungkir balik (pitch ke-clamp).
- [ ] Player yang di-spawn agak melayang di atas tanah jatuh natural kena gravity dan berhenti di permukaan map (gak tembus ke bawah).

---

## Phase 3 — Senter (`Flashlight` Toggle)
Toggle nyala/mati `SpotLight3D` pakai action `flashlight_toggle` (udah didaftarkan di Input Map sejak Fitur 01).

**Langkah**:
1. Di `player_movement_driver.gd`, tambah `@onready var flashlight: SpotLight3D = $Head/Camera3D/Flashlight`, set `flashlight.visible = false` di `_ready()`.
2. Di `_unhandled_input` atau `_process`, cek `Input.is_action_just_pressed("flashlight_toggle")` → toggle `flashlight.visible`.

**Testing Phase 3**:
- [ ] Pas game baru mulai, senter dalam kondisi mati (area depan player gelap).
- [ ] Tekan `F`, senter nyala, dan arah sorotnya ikut ke mana kamera nengok.
- [ ] Tekan `F` lagi, senter mati.

---

## Phase 4 — Wiring `RayCast3D` ke `InteractionService`
`InteractionService` (Fitur 01) sekarang punya `raycast`-nya beneran diisi, bukan `null` lagi.

**Langkah**:
1. Di `player_movement_driver.gd`, tambah di `_ready()`: `InteractionService.raycast = $Head/Camera3D/RayCast3D`.

**Testing Phase 4** *(pakai Debugger → Remote scene tree Godot, bukan nambah print manual)*:
- [ ] Jalanin game, buka tab **Debugger → Remote** di editor, cari node Autoload `InteractionService`, cek property `raycast` — harus keisi path ke RayCast3D-nya, bukan `<null>`.
- [ ] Arahin pandangan deket ke dinding/lantai map — gak ada error di console (raycast berhasil ngecek collision map walau belum ada `InteractableDriver` apapun buat ditemuin — itu baru masuk Fitur 03/04).
- [ ] Sama sekali gak ada error null-reference soal `raycast` di console.

---

## Checkpoint Akhir Fitur 02
- Semua Phase (0–4) di atas lulus testing masing-masing.
- `MainMap.tscn` murni map lagi (gak ada script), `Gameplay.tscn` jadi main scene baru berisi `MainMap` + `Player` + `MainGameController`.
- Player bisa jalan, sprint, mouse-look, kena gravity/collision dengan map, toggle senter, dan raycast-nya udah nyambung ke `InteractionService` tanpa error.
- Siap lanjut ke **Fitur 03 (Interaction & Registry System)**, yang akan bikin objek dummy pertama buat dites polimorfisme `interact()` lewat raycast ini.
