# Fitur 03 — Interaction & Registry System

**Ringkasan**: Tulang punggung semua objek interaktif. Menyambungkan raycast Player (Fitur 02) ke `InteractableDriver` manapun lewat polimorfisme, dan membangun pola **Registry Service** (`NPCService`, `ItemService`) sesuai `Engine_Design.md` §3.B.4 — supaya Service/Controller bisa manggil Driver spesifik by ID tanpa hardcode node path.

**Dependency**: [02_Player_Controller](02_Player_Controller.md) (butuh raycast Player udah nyambung ke `InteractionService`)

**Output Akhir**: 2 Registry Service baru (`NPCService`, `ItemService`) sebagai Autoload, 2 Driver konkret dummy (`NPCDriver`, `ItemDriver`) yang self-register, dan 2 objek dummy di `Gameplay.tscn` yang bisa diajak `interact()` beneran lewat raycast Player — membuktikan seluruh rantai **Raycast → InteractionService → Driver.interact() → Registry** jalan end-to-end. Ditambah: **titik crosshair di tengah layar** yang membesar begitu raycast lagi nunjuk ke objek interaktif — indikator visual paling minimal buat "ini bisa diinteraksi", sebelum prompt UI beneran dibikin di Fitur 10.

*Pembagian kerja sama seperti fitur sebelumnya: struktur node scene kamu bikin manual di editor sesuai spec Phase 0, script & wiring saya eksekusi.*

---

## Phase 0 — Persiapan Assets & Scene

### Assets (model/texture/audio)
**Tidak ada yang dibutuhkan.** Dummy NPC & Item cukup pakai primitive mesh Godot (`CapsuleMesh`/`BoxMesh`) sebagai penanda visual sementara — model asli baru masuk di Fitur 04 (NPC) & Fitur 05 (Item).

### Scene 1: `DummyNPC.tscn` (buat manual di editor)
| Detail | Isi |
|---|---|
| Nama file | `DummyNPC.tscn` |
| Lokasi save | `res://scenes/entities/npc/DummyNPC.tscn` |
| Script | Jangan di-attach manual — saya tempel `NPCDriver.gd` di Phase 2. |

**Struktur node (tree)**:
```
DummyNPC                (StaticBody3D — base class InteractableDriver extend ini, lihat Engine_Design.md §3.A)
├── CollisionShape3D    (CollisionShape3D — shape: CapsuleShape3D, radius ~0.4, height ~1.8)
└── MeshInstance3D      (MeshInstance3D — mesh: CapsuleMesh, ukuran sama; placeholder visual doang, model asli nunggu Fitur 04)
```

### Scene 2: `DummyItem.tscn` (buat manual di editor)
| Detail | Isi |
|---|---|
| Nama file | `DummyItem.tscn` |
| Lokasi save | `res://scenes/entities/items/DummyItem.tscn` |
| Script | Jangan di-attach manual — saya tempel `ItemDriver.gd` di Phase 2. |

**Struktur node (tree)**:
```
DummyItem               (StaticBody3D — base class InteractableDriver)
├── CollisionShape3D    (CollisionShape3D — shape: BoxShape3D, kecil, ~0.3×0.3×0.3)
└── MeshInstance3D      (MeshInstance3D — mesh: BoxMesh, ukuran sama; placeholder visual doang, model asli nunggu Fitur 05)
```

### Penempatan ke `Gameplay.tscn`
- Drag `DummyNPC.tscn` dan `DummyItem.tscn` ke scene tree `Gameplay.tscn` (dari Fitur 02), jadi child root sejajar `MainMap`/`Player`/`EnvironmentRig`.
- Posisiin keduanya di titik yang gampang dijangkau dari titik spawn Player — biar gampang jalan dikit terus langsung tes interact, gak perlu muter-muter cari.

### Tambahan Node: `Crosshair` — di `Gameplay.tscn`, di dalam `CanvasLayer` yang udah ada
Ini **bukan scene baru**, cuma 1 node `Control` yang kamu tambahin manual ke `CanvasLayer` yang udah ada di `Gameplay.tscn` (yang sekarang isinya `ColorRect` buat shader post-processing). Taruh sejajar `ColorRect` itu, sebagai child kedua di `CanvasLayer`.

| Detail | Isi |
|---|---|
| Parent | `CanvasLayer` (child root `Gameplay.tscn`, yang udah ada dari sesi shader kemarin) |
| Nama node | `Crosshair` |
| Tipe node | `Control` |
| Anchor (Layout) | Klik kanan → Anchor Preset → **Center** (ini bikin `anchor_left/top/right/bottom` semua jadi `0.5`) |
| Offset (di Inspector, setelah anchor di-set Center) | `offset_left = -10`, `offset_top = -10`, `offset_right = 10`, `offset_bottom = 10` — hasilnya kotak invisible 20×20 px pas di tengah layar, posisinya gak berubah walau resolusi window beda-beda. |
| Mouse Filter | **Ignore** — biar gak nyerep mouse kayak kejadian di `ColorRect` kemarin (lihat catatan bug shader sebelumnya). |
| Script | Jangan attach manual — saya tempel `crosshair_driver.gd` di Phase 3. Node ini gambar titik-nya sendiri lewat kode (`_draw()`), jadi **gak butuh gambar/texture apapun**. |

**Ukuran titik yang bakal digambar** (buat referensi, ini dikontrol lewat kode di Phase 3, bukan properti node): radius **3px** pas idle (gak nunjuk apa-apa), membesar ke radius **9px** pas raycast kena objek interaktif.

### Testing Phase 0
- [ ] `DummyNPC.tscn` & `DummyItem.tscn` ada, tree-nya sesuai diagram di atas.
- [ ] Keduanya udah jadi child `Gameplay.tscn`, keliatan di viewport deket titik spawn Player.
- [ ] Node `Crosshair` ada di dalam `CanvasLayer`, posisinya di tengah (bisa dicek: pas resize jendela editor, kotaknya tetep di tengah, gak geser).

---

## Phase 1 — Registry Service: `NPCService` & `ItemService`
Layer 2 (Autoload) — nyimpen mapping `id -> Driver instance`, disediain API tingkat tinggi (`move_npc`, `set_item_visible`, dll.) tanpa nyimpen business logic apapun (itu tugas Service lain kayak `DialogueService`/`EvidenceManager` di Fitur 04/05).

**Langkah**:
1. Buat `scripts/services/npc_service.gd` — `extends Node` (**jangan** pakai `class_name`, dia bakal jadi Autoload — lihat `Engine_Design.md` §4). Isi: `register_npc(id, driver)`, `unregister_npc(id)`, `get_npc(id)`, `move_npc(id, target: Vector3)`.
2. Buat `scripts/services/item_service.gd` — pola sama: `register_item(id, driver)`, `unregister_item(id)`, `get_item(id)`, `move_item(id, target)`, `set_item_visible(id, visible)`.
3. Daftarkan keduanya sebagai Autoload di `project.godot`.

**Testing Phase 1**:
- [ ] `NPCService` & `ItemService` muncul di daftar Autoload Project Settings.
- [ ] Gak ada parse error di kedua script (cek Script Editor).
- [ ] Project masih bisa di-run (F5) tanpa error baru — wajar karena belum ada Driver yang manggil registry ini.

---

## Phase 2 — Dummy Driver (`NPCDriver`, `ItemDriver`) + Wiring End-to-End
Driver konkret pertama yang beneran self-register ke Registry Service, dan membuktikan `interact()` polymorphic jalan lewat raycast Player.

**Langkah**:
1. Buat `scripts/drivers/characters/npc_driver.gd`: `class_name NPCDriver extends InteractableDriver`. `@export var npc_id: String = "npc_dummy_01"`. `_ready()`: self-register ke `NPCService.register_npc(npc_id, self)`. `_exit_tree()`: `NPCService.unregister_npc(npc_id)`. `interact()`: `print("[NPC] %s diajak bicara (dummy — dialog asli nunggu Fitur 04)" % npc_id)`.
2. Buat `scripts/drivers/objects/item_driver.gd`: `class_name ItemDriver extends InteractableDriver`. `@export var item_id: String = "item_dummy_01"`. `_ready()`/`_exit_tree()` self-register/unregister ke `ItemService` sama polanya. `interact()`: `print("[Item] %s diambil (dummy — evidence asli nunggu Fitur 05)" % item_id)` lalu `queue_free()` — item dummy hilang dari scene setelah diambil, sekaligus jadi bukti registry otomatis bersih pas node dihapus.
3. Attach `npc_driver.gd` ke root `DummyNPC` (di `DummyNPC.tscn`), dan `item_driver.gd` ke root `DummyItem` (di `DummyItem.tscn`) — scene yang udah dibuat di Phase 0.

**Testing Phase 2**:
- [ ] F5, jalan ke deket `DummyNPC`, arahin pandangan ke situ, tekan `interact` (E) — console muncul `"[NPC] npc_dummy_01 diajak bicara..."`.
- [ ] Jalan ke deket `DummyItem`, arahin, tekan `interact` — console muncul `"[Item] item_dummy_01 diambil..."`, dan objeknya **hilang** dari scene (visual & collision-nya ilang, gak bisa diinteraksi lagi).
- [ ] Buka Debugger → Remote, klik autoload `NPCService`, cek property `_npcs` — harus ada entry `"npc_dummy_01"` nunjuk ke instance `DummyNPC`.
- [ ] Buka Debugger → Remote, klik autoload `ItemService`, cek `_items` — **sebelum** interact ada entry `"item_dummy_01"`; **setelah** interact (item ke-`queue_free()`), entry itu ilang sendiri dari dictionary (bukti unregister via `_exit_tree()` jalan).
- [ ] Gak ada error console soal null reference atau `InteractableDriver` type-check gagal.

---

## Phase 3 — Crosshair Interaction Indicator
Titik kecil di tengah layar yang membesar begitu raycast Player nunjuk ke `InteractableDriver` manapun — indikator visual paling minimal, belum prompt teks (itu baru Fitur 10).

**Langkah**:
1. Buat `scripts/drivers/ui/crosshair_driver.gd` (folder baru `drivers/ui/`, khusus Driver yang manipulasi elemen HUD/`Control`) — `class_name CrosshairDriver extends Control`.
   - `@export var idle_radius: float = 3.0`, `@export var hover_radius: float = 9.0`.
   - `var is_hovering: bool = false`.
   - `_draw()`: `draw_circle(size / 2.0, hover_radius if is_hovering else idle_radius, Color(1, 1, 1, 1.0 if is_hovering else 0.75))`.
   - `func set_hovering(value: bool) -> void`: kalau `value != is_hovering`, update `is_hovering = value` lalu panggil `queue_redraw()` (biar cuma redraw pas statusnya beneran berubah, gak tiap frame).
2. Attach script ini ke node `Crosshair` (di `Gameplay.tscn`, dari Phase 0).
3. Update `scripts/services/interaction_service.gd`: tambah `@export var crosshair: CrosshairDriver`. Di `_check_raycast()` (fungsi yang udah ada dari Fitur 01), setelah `current_interactable` ke-update, panggil `if crosshair: crosshair.set_hovering(current_interactable != null)`.
4. Di `player_movement_driver.gd`, di baris yang sama tempat `InteractionService.raycast` di-assign (`_ready()`), tambah juga: `InteractionService.crosshair = get_tree().current_scene.get_node("CanvasLayer/Crosshair")` — atau cara lebih rapi: assign lewat Inspector `@export` di `InteractionService` langsung dari editor kalau lebih gampang buat kamu (tinggal drag node `Crosshair` ke field `Crosshair` di Inspector autoload-nya lewat Remote saat Play, atau saya wire lewat kode saat eksekusi).

**Testing Phase 3**:
- [ ] F5, lihat tengah layar — ada titik putih kecil (radius ~3px) nempel di crosshair area, walau belum lihat objek apapun.
- [ ] Arahin pandangan ke `DummyNPC` atau `DummyItem` — titiknya **membesar** (radius ~9px) begitu raycast kena collision-nya.
- [ ] Alihin pandangan ke tembok kosong — titiknya **mengecil lagi** ke ukuran idle.
- [ ] Gak ada error console soal `CrosshairDriver`, `queue_redraw`, atau null reference.

---

## Checkpoint Akhir Fitur 03
- Registry Service pattern (`NPCService`, `ItemService`) terbukti bekerja: self-registration, lookup by ID, dan auto-cleanup pas node dihapus, semua jalan tanpa `get_node(...)` hardcoded.
- Rantai penuh **Raycast (Fitur 02) → InteractionService (Fitur 01) → Driver.interact() (polymorphic) → Registry** terbukti nyambung end-to-end lewat 2 dummy object.
- Crosshair kasih feedback visual real-time (membesar/mengecil) sesuai status raycast — bukti `InteractionService` udah "hidup", bukan cuma logic diem di background.
- Siap jadi fondasi **Fitur 04 (NPC & Dialogue System)** dan **Fitur 05 (Item & Evidence System)** — tinggal ganti isi `interact()` dummy ini dengan panggilan ke `DialogueService`/`EvidenceManager` beneran, dan ganti mesh placeholder dengan model asli. Crosshair ini juga jadi basis visual buat prompt teks di Fitur 10 (tinggal nambah `Label` di sebelah titik yang sama).
