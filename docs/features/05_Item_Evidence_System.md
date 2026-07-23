# Fitur 05 — Item & Evidence System

**Ringkasan**: Sistem item generik yang nanganin **4 jenis perilaku** lewat 1 `ItemDriver` + data `ItemData` (bukan subclass per jenis) — Evidence (nambah skor investigasi), Readable (nampilin teks bacaan di layar), Key (kunci buat pintu, disiapin sekarang, integrasi penuh di Fitur 06), dan Equipment (ngasih kemampuan baru ke Player — dipakai buat **Senter**, yang sekarang jadi item yang harus ditemuin, bukan bawaan Player lagi).

**Dependency**: [03_Interaction_Registry_System](03_Interaction_Registry_System.md), [04_NPC_Dialogue_System](04_NPC_Dialogue_System.md) (`PlayerService`, pola lock-movement, dan `dialogue_next` input dipakai ulang di sini)

**Output Akhir**: 5 item bisa diambil dengan efek beda-beda — surat ancaman (dibaca + jadi evidence), foto lama (evidence doang), catatan tembok (dibaca doang, gak nambah skor), kunci gudang (buat pintu nanti), dan **senter** (nempel jadi kemampuan Player, tombol F baru berfungsi setelah ini diambil). Evidence Score & daftar evidence kebukti nambah di `StoryTask`, item non-evidence kebukti gak nambah.

*Pembagian kerja sama seperti fitur sebelumnya: struktur node scene kamu bikin manual di editor sesuai spec Phase 0, script & wiring saya eksekusi.*

---

## Peta Arsitektur (sesuai `Engine_Design.md`)

| Layer | Komponen | Tanggung Jawab |
|---|---|---|
| **Driver** | `ItemDriver` (udah ada, Fitur 03) | Fisik doang: self-register ke `ItemService`, `interact()` → `emit_signal("interacted", item_id)`. **Gak tau** dirinya evidence/readable/key/equipment — itu bukan urusan Driver. |
| **Driver** | `ItemReaderBoxDriver` (baru) | UI nampilin teks bacaan, `show_text()`/`hide_box()` doang, gak ada logic. |
| **Driver** | `PlayerMovementDriver` (update) | Tambah `has_flashlight` + `grant_flashlight()` — ini tetep manipulasi state fisik/kemampuan node Player, bukan business logic. |
| **Service** | `ItemService` (udah ada) | Registry + relay `item_interacted`. Gak berubah. |
| **Service** | `ItemReaderService` (baru) | Registry tipis 1 instance buat `ItemReaderBoxDriver`, pola sama persis `DialogueService`. |
| **Data** | `ItemData` (Resource, baru) | `is_readable`, `read_text`, `is_evidence`, `is_key`, `equipment_grant` — 4 jenis item dibedain lewat kombinasi field ini, **bukan** 4 class Driver berbeda. |
| **Task** | `InteractionTask` (update) | **Satu-satunya tempat keputusan**: baca `ItemData`, mutusin urutan (baca dulu kalau `is_readable` → baru proses evidence/key/equipment), lapor ke `StoryTask` (`item_collected`), atau manggil `PlayerService` buat grant equipment. |
| **Task** | `StoryTask` (gak berubah) | Tetep nyimpen `collected_evidence`/`evidence_score` — `InteractionTask` yang lapor ke sini, `StoryTask` gak tau apa-apa soal `ItemData`. |

---

## Phase 0 — Persiapan Assets & Scene

### Assets (model/texture/audio)
**Opsional.** Kalau ada model 3D buat surat/foto/kunci/senter dari tim art, taruh di `assets/models/props/<nama>/`. Kalau belum, pakai placeholder `BoxMesh` kecil (beda warna per item biar gampang dibedain, sama pola kayak `DummyItem` Fitur 03).

### Scene 1–5: 5 Item Test (buat manual di editor)
Tree-nya **identik** buat kelimanya (sama pola `DummyItem` Fitur 03) — beda nama file & (nanti) `ItemData` yang di-assign di Phase 2.

| Item | Nama file | Lokasi save | `item_id` (di-set Phase 2) | Jenis (Phase 1) |
|---|---|---|---|---|
| Surat Ancaman | `SuratAncaman.tscn` | `res://scenes/entities/items/SuratAncaman.tscn` | `item_surat_ancaman` | Readable **+** Evidence |
| Foto Lama | `FotoLama.tscn` | `res://scenes/entities/items/FotoLama.tscn` | `item_foto_lama` | Evidence doang |
| Catatan Tembok | `CatatanTembok.tscn` | `res://scenes/entities/items/CatatanTembok.tscn` | `item_catatan_tembok` | Readable doang (bukan evidence) |
| Kunci Gudang | `KunciGudang.tscn` | `res://scenes/entities/items/KunciGudang.tscn` | `item_kunci_gudang` | Key |
| Senter | `Flashlight.tscn` | `res://scenes/entities/items/Flashlight.tscn` | `item_flashlight` | Equipment (`equipment_grant = "flashlight"`) |

**Struktur node (tree, sama buat kelimanya)**:
```
<NamaItem>              (StaticBody3D — root, base class InteractableDriver lewat ItemDriver)
├── CollisionShape3D    (CollisionShape3D — shape: BoxShape3D, kecil ~0.3×0.3×0.3, sesuaiin per bentuk)
└── MeshInstance3D      (MeshInstance3D — mesh: BoxMesh placeholder, ATAU model asli kalau ada)
```
Script: **jangan attach manual** — saya tempel `item_driver.gd` (udah ada, ditambah field baru) di Phase 2, sekalian isi `item_id` & `item_data`.

### Scene 6: `ItemReaderBox.tscn` (buat manual di editor)
UI buat nampilin teks pas item `is_readable` dibaca. Beda posisi dari `DialogueBox` (yang di bawah) — ini di **tengah layar**, biar kerasa "lagi fokus baca sesuatu", bukan "lagi diajak ngobrol".

| Detail | Isi |
|---|---|
| Nama file | `ItemReaderBox.tscn` |
| Lokasi save | `res://scenes/ui/ItemReaderBox.tscn` |
| Script | Jangan attach manual — saya tempel `item_reader_box_driver.gd` di Phase 3. |

**Struktur node (tree)**:
```
ItemReaderBox            (Control — root)
└── Panel                (Panel — background box)
    ├── ItemName         (Label — nama item yang lagi dibaca)
    └── ReadText         (RichTextLabel — isi bacaan, autowrap biar teks panjang gak kepotong)
```

**Anchor & posisi `ItemReaderBox` (root Control)**:
- Anchor Preset: **Center** → di Inspector set manual:
  - `anchor_left = 0.5`, `anchor_right = 0.5`, `anchor_top = 0.5`, `anchor_bottom = 0.5`
  - `offset_left = -250`, `offset_right = 250`, `offset_top = -150`, `offset_bottom = 150`
  - Hasilnya: kotak 500×300px pas di tengah layar.
- `mouse_filter` di root & `Panel` → **Ignore** (`= 2`) — biar gak nyerep mouse-look (bug `ColorRect` kemarin).
- `visible = false` di root (default nyembunyi).
- `ReadText` (`RichTextLabel`): centang **Fit Content** / `autowrap_mode` di Inspector biar teks panjang gak keluar box.

### Penempatan
- Drag ke-5 scene item ke `Gameplay.tscn`, taruh di titik-titik beda yang kejangkau dari spawn Player (**Senter taruh agak jauh/tersembunyi dikit**, biar kerasa "ditemuin", bukan langsung nempel di depan muka).
- Drag `ItemReaderBox.tscn` ke dalam `CanvasLayer` yang udah ada (sejajar `ColorRect`/`Crosshair`/`DialogueBox`).

### Testing Phase 0
- [ ] 5 scene item ada, tree-nya sesuai diagram.
- [ ] `ItemReaderBox.tscn` ada, tree sesuai diagram, posisi center 500×300px.
- [ ] Semua 6 scene di atas jadi child `Gameplay.tscn` (5 item di root, `ItemReaderBox` di `CanvasLayer`).
- [ ] `ItemReaderBox` invisible secara default.

---

## Phase 1 — `ItemData` (Custom Resource) + Isi 5 Data Item
Struktur data yang nentuin "jenis" item — murni data, Driver/Service gak tau isinya.

**Langkah**:
1. Buat `resources/items/item_data.gd`: `class_name ItemData extends Resource`. Field: `@export var item_name: String = ""`, `@export var description: String = ""`, `@export var is_readable: bool = false`, `@export var read_text: String = ""`, `@export var is_evidence: bool = false`, `@export var is_key: bool = false`, `@export var equipment_grant: String = ""` (kosong = bukan equipment; isi `"flashlight"` buat senter), **`@export var is_pickupable: bool = true`** (`false` = nempel di tempat — dibaca berkali-kali, gak pernah diambil/ilang dari dunia; dipakai buat item kayak coretan tembok).
2. Buat 5 file `.tres` di `resources/items/`, sesuai tabel Phase 0:
   - `surat_ancaman.tres`: `is_readable=true`, `read_text` isi ancaman singkat, `is_evidence=true`, `is_pickupable=true` (default).
   - `foto_lama.tres`: `is_readable=false`, `is_evidence=true`, `is_pickupable=true` (default).
   - `catatan_tembok.tres`: `is_readable=true`, `read_text` isi coretan random, `is_evidence=false`, **`is_pickupable=false`** — coretan di tembok, bukan barang yang dipungut, tetep di situ selamanya & bisa dibaca ulang kapan aja.
   - `kunci_gudang.tres`: `is_key=true` (`is_evidence` boleh `true` juga, biar kebaca `has_evidence()`), `is_pickupable=true` (default).
   - `flashlight.tres`: `equipment_grant="flashlight"`, `is_evidence=false`, `is_readable` opsional (boleh dikasih flavor text pendek kalau mau), `is_pickupable=true` (default).

**Testing Phase 1**:
- [ ] Ke-5 file `.tres` kebuka tanpa error, field-nya keisi sesuai kombinasi di atas.
- [ ] Gak ada parse error di `item_data.gd`.

---

## Phase 2 — `ItemDriver` + Attach ke 5 Item
`ItemDriver` (Fitur 03) udah punya `interact()` yang emit sinyal — tinggal nambah field `item_data`.

**Langkah**:
1. Update `scripts/drivers/objects/item_driver.gd`: tambah `@export var item_data: ItemData`. (`interact()` **gak berubah**, tetap cuma `interacted.emit(item_id)`.)
2. Attach `item_driver.gd` ke root tiap 5 scene item (dari Phase 0).
3. Isi Inspector: `Item Id` sesuai tabel Phase 0, `Item Data` di-drag dari `.tres` yang cocok (Phase 1).

**Testing Phase 2**:
- [ ] Klik tiap 5 scene item, field `Item Id` & `Item Data` keisi bener.
- [ ] Gak ada parse error.

---

## Phase 3 — `ItemReaderService` + `ItemReaderBoxDriver`
UI buat nampilin `read_text`, pola identik `DialogueService`/`DialogueBoxDriver` dari Fitur 04.

**Langkah**:
1. Buat `scripts/services/item_reader_service.gd` (registry tipis, 1 instance): `register_reader_box(driver)`, `unregister_reader_box(driver)`, `get_reader_box() -> ItemReaderBoxDriver`. Daftarkan sebagai Autoload.
2. Buat `scripts/drivers/ui/item_reader_box_driver.gd`: `class_name ItemReaderBoxDriver extends Control`. `@onready var name_label`/`text_label`. `_ready()`: `visible = false`, `ItemReaderService.register_reader_box(self)`. `show_text(name, text)`: isi label, `visible = true`. `hide_box()`: `visible = false`.
3. Attach ke root `ItemReaderBox` (dari Phase 0).

**Testing Phase 3**:
- [ ] `ItemReaderService` muncul di Autoload.
- [ ] Gak ada parse error di kedua script baru.

---

## Phase 4 — Senter Jadi Equipment (`PlayerMovementDriver`)
Cabut status "bawaan" dari senter — cuma bisa dipakai setelah item `Flashlight` diambil.

**Langkah**:
1. Update `scripts/drivers/characters/player_movement_driver.gd`:
   - Tambah `var has_flashlight: bool = false`.
   - Tambah `func grant_flashlight() -> void: has_flashlight = true`.
   - Ubah kondisi di `_unhandled_input()`: `if event.is_action_pressed("flashlight_toggle") and has_flashlight:` (sebelumnya tanpa syarat).
2. Pastiin `FlashLight` node di `Player.tscn` tetep `visible = false` dari awal (udah gitu dari Fitur 02, gak perlu diubah).

**Testing Phase 4**:
- [ ] F5, tekan `F` **sebelum** ambil item Senter — **gak terjadi apa-apa** (senter tetep mati, gak ada visual nyala).
- [ ] Gak ada parse error.

---

## Phase 5 — `InteractionTask` Lengkap: Dispatch 4 Jenis Item
Bagian inti — `InteractionTask` baca `ItemData`, mutusin alur (baca dulu kalau perlu → baru proses konsekuensi), dan gak pernah nyimpen state sendiri soal evidence (itu tetap `StoryTask`).

**Langkah**:
1. Update `scripts/controllers/tasks/interaction_task.gd`:
   - State baru: `var _reading_item_id: String = ""`.
   - `_unhandled_input(event)`: kalau `_reading_item_id != ""` dan `event.is_action_pressed("dialogue_next")` (dipakai ulang dari Fitur 04 — "next/dismiss" itu konsep yang sama) → `_finish_reading()`.
   - `_on_item_interacted(item_id)`: kalau lagi baca sesuatu (`_reading_item_id != ""`), abaikan. Ambil `ItemDriver` via `ItemService.get_item(item_id)`, validasi `item_data` ada. Kalau `item_data.is_readable == true` → set `_reading_item_id = item_id`, kunci Player (`PlayerService.get_player().set_movement_locked(true)`), sembunyiin crosshair (`InteractionService.set_crosshair_visible(false)`), tampilin teks (`ItemReaderService.get_reader_box().show_text(...)`). Kalau **enggak** readable → langsung `_resolve_item(item_id, item_data)`.
   - `_finish_reading()`: sembunyiin reader box, buka kunci Player, tampilin crosshair lagi, reset `_reading_item_id`, baru panggil `_resolve_item(...)` buat item yang barusan dibaca.
   - `_resolve_item(item_id, data)`: kalau `data.is_evidence` **atau** `data.is_key` → `item_collected.emit(item_id)` (StoryTask yang nyimpen). Kalau `data.equipment_grant != ""` → panggil `_grant_equipment(item_id, data.equipment_grant)`. Di akhir, **kalau `data.is_pickupable`** → `ItemService.remove_item(item_id)` (**beneran `queue_free()` node-nya**, bukan `set_item_visible(false)` — kalau cuma di-hide, `CollisionShape3D`-nya tetep aktif dan masih bisa kena raycast/interact lagi walau invisible). Kalau `is_pickupable == false`, item dibiarin tetep ada di dunia.
   - `_grant_equipment(item_id, grant_name)`: `match grant_name: "flashlight": PlayerService.get_player().grant_flashlight()`.
2. Gak ada perubahan di `MainGameController` — wiring `interaction_task.item_collected.connect(story_task.on_item_collected)` udah ada dari sebelumnya.

**Testing Phase 5** *(full test, F5 langsung)*:
- [ ] Ambil **Foto Lama** (evidence doang, gak readable) — langsung ilang dari dunia, `Tasks/StoryTask` → `collected_evidence` nambah `"item_foto_lama"`, `evidence_score` naik.
- [ ] Ambil **Catatan Tembok** (readable, `is_pickupable=false`) — reader box muncul, klik/Spasi nutup → **item TETEP ada di dunia** (gak ilang, gak ke-`queue_free`), `collected_evidence` gak nambah. Interact lagi → reader box muncul ulang, bisa dibaca berkali-kali.
- [ ] **Cek collision item yang udah diambil**: abis ambil Foto Lama/Surat Ancaman/Kunci Gudang/Senter, coba arahin crosshair ke posisi bekas item itu & tekan interact — **gak ada reaksi apapun** (bukan cuma invisible, tapi beneran gak ada node/collision di situ lagi). Bandingin sama versi lama yang cuma `set_item_visible(false)` — sekarang harusnya beda.
- [ ] Ambil **Surat Ancaman** (readable + evidence) — reader box muncul dulu, abis ditutup baru `evidence_score` nambah — bukti urutannya "baca dulu, baru dicatat", bukan kebalik.
- [ ] Ambil **Kunci Gudang** — masuk `collected_evidence` (`has_evidence("item_kunci_gudang")` true lewat Remote), siap dipakai Fitur 06.
- [ ] Ambil **Senter** — item ilang, gak masuk `collected_evidence` (equipment beda kategori). Tekan `F` **sekarang** — senter nyala normal.
- [ ] Gak ada error console soal `ItemData`, `ItemReaderService`, `PlayerService`, atau null reference.
- [ ] Mouse-look & WASD balik normal abis nutup reader box, sama kayak abis dialog kelar.

---

## Checkpoint Akhir Fitur 05
- 4 jenis perilaku item (Evidence, Readable, Key, Equipment) terbukti jalan dari **1 `ItemDriver` + `ItemData` data-driven**, tanpa perlu subclass Driver baru per jenis.
- Urutan "baca dulu → baru dicatat evidence" kebukti bener di item yang dua-duanya (`is_readable` + `is_evidence`).
- Senter resmi jadi item — Player mulai game **tanpa** kemampuan nyalain senter, baru bisa dipakai setelah ketemu & diambil. `PlayerService.grant_flashlight()` jadi pola pertama "item ngasih kemampuan ke Player", siap dipakai ulang buat equipment lain nanti (kamera foto evidence, dsb — tinggal tambah `match` case baru di `_grant_equipment()`).
- `StoryTask` tetap satu-satunya pemilik data evidence — `InteractionTask` cuma lapor, gak pernah nyimpen sendiri, sesuai `Engine_Design.md` §1.3.
- Siap lanjut ke **Fitur 06 (Door Management)** — `kunci_gudang` yang udah ada di `collected_evidence` tinggal dicocokin ke `DoorDriver.key_id_required` pas `InteractionTask` diperluas nanganin `door_interacted`.
