# Engine Design Document (EDD) — Kosan Mulyono (Godot Engine & OOP Architecture)
*Dokumen arsitektur teknis global ini mendefinisikan standar pengembangan berbasis **Object-Oriented Programming (OOP)** dengan pola **Driver-Service-Task/Controller** untuk game "Kosan Mulyono". Business logic & business state HANYA boleh ada di layer Task/Controller — Driver murni fisik, Service murni Registry/API (lihat §1). Dokumen ini wajib dijadikan acuan mutlak agar seluruh implementasi kode memiliki konsistensi kelas, pewarisan, enkapsulasi, dan polimorfisme.*

---

## 1. Filosofi Arsitektur: Driver-Service-Task/Controller (OOP-Based)
Pola ini memisahkan tanggung jawab sistem menjadi tiga lapisan utama berbasis kelas (`class_name`). **Business logic dan business state HANYA boleh ada di Layer 3 (Task/Controller)** — Layer 1 dan 2 murni mekanis, tanpa pengecualian.

1. **Layer 1: Driver (Physical & Node-Level Class)**
   - Berupa kelas turunan node Godot (`class_name [Name]Driver extends [Node3D/CharacterBody3D/ dll]`).
   - Bertanggung jawab penuh atas manipulasi node fisik (transform, animasi, audio, mesh, material shader, teleport, gerakan point-to-point).
   - Tidak memiliki logika bisnis game (tidak tahu quest, skor, atau chapter) dan **tidak boleh memanggil method Service untuk memicu keputusan bisnis apapun**.
   - Interaksi ke atas (melapor kejadian) **wajib lewat Signal**, bukan manggil method Service langsung — kecuali 1 pengecualian sempit: **self-registration** (`XService.register_x(self)` di `_ready()`/`unregister` di `_exit_tree()`), karena itu murni lifecycle handshake, bukan keputusan bisnis.
2. **Layer 2: Service (Registry & API Class — BUKAN Business Logic)**
   - Berupa kelas Singleton / Autoload (`extends Node`, tanpa `class_name`).
   - **Cuma 2 tanggung jawab**: (a) jadi *Registry* — nyimpen mapping `id -> Driver instance` dan expose API generik (`register/unregister/get/move/set_visible`, dst.) yang di baliknya manggil method Driver; (b) *relay sinyal* dari Driver ke atas (connect ke sinyal tiap Driver yang register, lalu re-emit dengan ID-nya) supaya Task gak perlu tau/lacak instance Driver manapun satu-satu.
   - **Dilarang keras** nyimpen business state (skor, counter, flag, progress dialog) atau bikin keputusan bisnis (`if`/`match` yang nentuin konsekuensi gameplay). Kalau ada logic kayak gitu ketemu di Service, itu tandanya harus pindah ke Task.
3. **Layer 3: Controller / Task (Business Logic & Orchestrator)**
   - `MainGameController.gd` adalah root/entry point — nge-instance semua **Task** sebagai child, dan **secara eksplisit nyambungin sinyal antar-Task** di `_ready()`-nya. Ini bikin "siapa dengerin siapa" keliatan di 1 tempat.
   - **Task** (`scripts/controllers/tasks/*.gd`) adalah unit business logic per domain (`StoryTask`, `DialogueTask`, `InteractionTask`, `WorldEnvironmentTask`, `HUDTask`, `SaveTask`) — di sinilah SEMUA state bisnis (counter, flag, progress) dan keputusan gameplay hidup. Task boleh manggil Service manapun (buat baca data via Registry atau ngasih perintah ke Driver lewat Service), dan boleh nyimpen referensi langsung ke Task lain (buat query sinkron, lihat §3.C).
   - Lihat **§3.C** buat detail lengkap pola Task Controller & cara komunikasi antar-Task.

---

## 2. Struktur Direktori Proyek Godot (OOP Standard)
```text
res://
│
├── assets/                   # Aset MENTAH/sumber (bukan Scene/Script Godot) — semua file
│   │                         # yang dibuat di software eksternal (Blender, Photoshop, dll)
│   │                         # atau diunduh dari asset store WAJIB disalin ke sini dulu
│   │                         # sebelum bisa dirakit jadi Scene/Driver.
│   ├── models/               # File 3D mentah (.glb/.gltf/.fbx/.blend)
│   │   ├── characters/       # Model Raka, Dimas, Hasan, Chika, Pak Yono, Bu Yuni
│   │   ├── props/            # Furniture & benda kecil (kursi, dokumen, kunci, dupa)
│   │   └── environment/      # Modular kit bangunan (dinding, lantai, pintu, tangga)
│   ├── textures/             # Texture map mentah (albedo, normal, roughness, AO)
│   │   ├── characters/
│   │   ├── props/
│   │   └── environment/
│   ├── materials/            # Godot Material resource (.tres) hasil olahan textures/
│   ├── audio/
│   │   ├── music/            # Background score
│   │   ├── ambient/          # Room tone / atmosfer per area
│   │   ├── sfx/               # Efek suara pendek (pintu, langkah, pickup item)
│   │   └── voice/             # VO dialog (opsional, kalau dipakai)
│   ├── images/                # Aset 2D flat (bukan texture 3D)
│   │   ├── ui/                 # Icon, logo, splash screen, background menu
│   │   └── evidence/           # Foto/dokumen bukti yang tampil di Evidence UI
│   ├── fonts/                  # File font (.ttf/.otf)
│   └── shaders/                # File .gdshader (VHS, glitch, chromatic aberration)
│
├── scenes/                   # Hasil RAKITAN dari assets/ — siap pakai di gameplay
│   ├── Gameplay.tscn           # Scene ROOT yang di-run (main_scene): instance level + Player +
│   │                           # MainGameController. Ini satu-satunya tempat level & Player disatukan.
│   ├── levels/                # Peta MURNI, TANPA Player/Controller (MainMap.tscn, KampusKelas.tscn)
│   │                           # — biar bisa dibuka & diedit sebagai map doang, gak kebawa gameplay.
│   ├── entities/               # Prefabs Player, NPC, Pintu, Item
│   │   ├── player/
│   │   ├── npc/
│   │   ├── items/
│   │   └── doors/
│   └── ui/                    # HUD, Evidence Menu, Dialogue Box
│
├── scripts/
│   ├── controllers/     # MainGameController.gd (root, nyambungin sinyal antar-Task)
│   │   └── tasks/       # StoryTask, DialogueTask, InteractionTask, WorldEnvironmentTask,
│   │                    # HUDTask, SaveTask — lihat Engine_Design.md §3.C
│   ├── services/        # Kelas Service (Autoload) — MURNI Registry/API, nol business logic (lihat §1.2)
│   └── drivers/         # Kelas Driver (Node fisik, pewarisan dari Base class)
│       ├── base/        # Base classes (InteractableDriver.gd)
│       ├── objects/     # DoorDriver.gd, ItemDriver.gd
│       ├── characters/  # NPCDriver.gd, PlayerMovementDriver.gd
│       └── environments/# LightFlickerDriver.gd, AudioTriggerDriver.gd
│
├── resources/            # Custom Resources (data, bukan aset visual)
│   ├── dialogue/          # DialogueData .tres per NPC
│   ├── items/             # ItemData .tres per item
│   └── story/             # Story flag / chapter config .tres
│
└── addons/               # Plugin pihak ketiga (opsional)
```

### Kenapa `assets/` Dipisah dari `scenes/`
- **Godot hanya bisa memakai file yang ada di dalam folder project (`res://`).** File 3D yang kamu buat di Blender atau unduh dari asset store, selama masih di luar folder ini (mis. di `~/Downloads`), tidak bisa direferensikan sama sekali — harus disalin ke `assets/models/...` dulu supaya Godot meng-*import*-nya (menghasilkan file `.import`).
- **`assets/` = bahan mentah, `scenes/` = hasil rakitan siap pakai.** Satu file `.glb` karakter di `assets/models/characters/` nantinya dipakai di dalam `scenes/entities/npc/npc_hasan.tscn` yang sudah ditempeli `NPCDriver.gd`, collision shape, dan AnimationPlayer. Ini selaras dengan filosofi Driver: Driver adalah node fisik yang *memakai* model, bukan model itu sendiri.
- **Sub-folder kategori (`characters/props/environment`) sengaja dibuat identik** dengan sub-folder di `scripts/drivers/` dan `scenes/entities/`. Saat menambah NPC baru, polanya selalu sama di 4 tempat: `assets/models/characters/`, `assets/textures/characters/`, `scenes/entities/npc/`, `scripts/drivers/characters/` — predictable dan mudah dicari, sejalan dengan tujuan arsitektur modular.
- **`materials/` dipisah dari `textures/`** karena `materials/` adalah `.tres` Godot (kombinasi texture + shader + parameter) yang bisa dipakai ulang di banyak mesh, sedangkan `textures/` murni file gambar sumbernya.
- **`levels/` vs `Gameplay.tscn` sengaja dipisah**: scene di `levels/` (`MainMap.tscn`, `KampusKelas.tscn`) isinya murni geometri map — gak ada Player, gak ada `MainGameController`. Ini bikin map bisa dibuka & diedit kapan aja (nambah furniture, geser dinding, dll) tanpa kebawa-bawa state gameplay. `Gameplay.tscn` adalah scene komposisi yang nge-instance 1 level dari `levels/` + `Player` dari `entities/player/`, dan di situ juga `MainGameController.gd` ditempel. **`Gameplay.tscn` yang jadi `main_scene` project**, bukan file di `levels/` langsung.

---

## 3. Desain Kelas & Implementasi OOP Detail

### **A. Driver Layer (Inheritance & Polymorphism)**
Semua objek fisik interaktif wajib mewarisi kelas dasar abstrak `InteractableDriver`.

#### Base Class: `InteractableDriver.gd`
```gdscript
class_name InteractableDriver
extends StaticBody3D

@export var prompt_message: String = "Interact"

# Method virtual yang wajib di-override oleh kelas anak (Polimorfisme)
func interact() -> void:
    pass
```

#### Concrete Class: `DoorDriver.gd`
```gdscript
class_name DoorDriver
extends InteractableDriver

@export var is_locked: bool = false
@export var key_id_required: String = ""
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func interact() -> void:
    if is_locked:
        audio_player.play_locked_sound()
        return
    toggle_door()

func toggle_door() -> void:
    animation_player.play("open_door")
    audio_player.play_creak_sound()
```

#### Concrete Class: `NPCDriver.gd`
```gdscript
class_name NPCDriver
extends InteractableDriver

signal interacted(npc_id: String)

@export var npc_id: String = "npc_yono"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact() -> void:
    # BUKAN manggil Service buat keputusan bisnis — cuma lapor kejadian lewat Signal.
    # NPCService yang connect ke sinyal ini pas register, terus relay ke atas (lihat §3.B.4).
    interacted.emit(npc_id)

func look_at_player(player_pos: Vector3) -> void:
    # Driver khusus untuk manipulasi rotasi mesh fisik
    look_at(Vector3(player_pos.x, global_position.y, player_pos.z), Vector3.UP)
```

---

### **B. Service Layer (Autoload Business Logic)**

#### 1. `InteractionService.gd` (Autoload)
```gdscript
extends Node

@export var raycast: RayCast3D
var current_interactable: InteractableDriver = null

func _process(_delta: float) -> void:
    _check_raycast()
    if Input.is_action_just_pressed("interact") and current_interactable:
        current_interactable.interact() # Polimorfisme in action

func _check_raycast() -> void:
    if not raycast.is_colliding():
        current_interactable = null
        return
        
    var collider = raycast.get_collider()
    if collider is InteractableDriver:
        current_interactable = collider
        # Update UI Prompt di sini
    else:
        current_interactable = null
```

#### 2. `DialogueService.gd` (Autoload)
**Catatan penting**: versi lama Service ini nyimpen `yono_interaction_count` dan logic `start_dialogue` — itu **business state/logic**, sudah dipindah ke `DialogueTask` (lihat §3.C). `DialogueService` sekarang murni registry buat 1 instance `DialogueBoxDriver` (UI dialog), sama polanya kayak Registry Service di §3.B.4 tapi buat entitas tunggal, bukan banyak instance.
```gdscript
extends Node

var _dialogue_box: DialogueBoxDriver = null

func register_dialogue_box(driver: DialogueBoxDriver) -> void:
    _dialogue_box = driver

func unregister_dialogue_box(driver: DialogueBoxDriver) -> void:
    if _dialogue_box == driver:
        _dialogue_box = null

func get_dialogue_box() -> DialogueBoxDriver:
    return _dialogue_box
```

#### 3. Kenapa **Tidak Ada** `StoryService.gd`
Versi sebelumnya sempat ada `StoryEngineService`/`StoryService` yang nyimpen `story_flags`/`current_chapter`. Ini **dihapus** — bukan dipindah ke Service lain, tapi dihapus total, karena Service cuma boleh eksis buat *mewrap Driver*. Flag & chapter itu data abstrak, gak nempel ke node fisik manapun, jadi gak ada Driver yang perlu di-registry-in. **State ini sekarang langsung nempel di `StoryTask`** (lihat §3.C) — gak ada perantara Service sama sekali. Prinsip umumnya: **gak semua Task punya Service pasangan** — Service cuma dibuat kalau ada Driver yang beneran perlu di-registry/di-relay.

---

#### 4. Registry Service Pattern (`NPCService`, `ItemService`, dll.)
Saat sebuah scene memiliki **banyak instance Driver sejenis** (banyak NPC, banyak Item interaktif), Service bisnis (`StoryEngineService`, dll.) butuh cara untuk memanggil Driver *spesifik* tanpa mengetahui struktur scene tree secara langsung (`get_node(...)` hardcoded dilarang di layer Service/Controller).

Solusinya: setiap kategori entitas fisik yang jumlahnya banyak & dinamis wajib memiliki **Registry Service** — Autoload yang menyimpan *mapping* `id -> Driver instance`, dan menyediakan API tingkat tinggi (`move_npc`, `set_item_visible`, dll.) yang di baliknya memanggil method pada Driver yang cocok. Registry Service **tidak** menyimpan business logic (itu tetap tugas `StoryEngineService`/`DialogueService`); ia murni jembatan lookup + delegasi ke Driver.

**Prinsip self-registration**: setiap Driver mendaftarkan dirinya sendiri ke Registry Service terkait saat `_ready()`, dan melepas diri saat `_exit_tree()`. Dengan begitu menambah NPC/Item baru ke scene tidak memerlukan perubahan kode apa pun di Service atau Controller.

```gdscript
# scripts/services/npc_service.gd
extends Node

signal npc_interacted(npc_id: String) # relay — Task subscribe ke sini, bukan ke Driver satu-satu

var _npcs: Dictionary = {} # npc_id (String) -> NPCDriver

func register_npc(npc_id: String, driver: NPCDriver) -> void:
    _npcs[npc_id] = driver
    driver.interacted.connect(_on_npc_interacted) # relay sinyal Driver ke atas

func unregister_npc(npc_id: String) -> void:
    if _npcs.has(npc_id):
        _npcs[npc_id].interacted.disconnect(_on_npc_interacted)
    _npcs.erase(npc_id)

func get_npc(npc_id: String) -> NPCDriver:
    return _npcs.get(npc_id, null)

func move_npc(npc_id: String, target: Vector3) -> void:
    if _npcs.has(npc_id):
        _npcs[npc_id].move_to(target) # Driver yang mengeksekusi transform fisik

func _on_npc_interacted(npc_id: String) -> void:
    npc_interacted.emit(npc_id) # murni relay, TIDAK ada keputusan bisnis di sini
```

```gdscript
# NPCDriver.gd (tambahan wajib untuk mendukung Registry Service)
func _ready() -> void:
    NPCService.register_npc(npc_id, self)

func _exit_tree() -> void:
    NPCService.unregister_npc(npc_id)

func move_to(target: Vector3) -> void:
    global_position = target # atau NavigationAgent3D untuk gerakan halus
```

Dengan pola ini, `Task` (Layer 3 — **bukan** Service lain) yang manggil `NPCService.move_npc(...)`/`ItemService.spawn_item(...)` buat mewujudkan efek dunia nyata, tanpa referensi node manual dan tanpa Service saling manggil. Karena `story_flags` sekarang nempel langsung di `StoryTask` (§3.B.3), gak perlu sinyal eksternal lagi — `StoryTask.set_flag()` bisa langsung eksekusi efeknya di method yang sama:

```gdscript
# scripts/controllers/tasks/story_task.gd — lihat §3.C untuk penjelasan lengkap
func set_flag(flag_name: String, value: bool) -> void:
    story_flags[flag_name] = value
    flag_changed.emit(flag_name, value) # Task lain (WorldEnvironmentTask, HUDTask, dst.) boleh dengerin ini

    if flag_name == "hasan_body_found" and value:
        NPCService.move_npc("bu_yuni", Vector3(12.0, 0.0, -8.0)) # pindah ke halaman belakang
        ItemService.spawn_item("dokumen_lama", Vector3(3.0, 0.0, 5.0))
```

`ItemService` mengikuti pola identik (`register_item`, `unregister_item`, `move_item`, `set_item_visible`, `spawn_item`, plus relay `item_interacted`) terhadap `ItemDriver`. `DoorService` juga sama (`register_door`, `unregister_door`, `open_door`, `lock_door`, plus relay `door_interacted`) terhadap `DoorDriver`. Kategori entitas baru yang butuh manajemen serupa wajib mengikuti pola Registry Service + relay yang sama, bukan pola ad-hoc baru.

---

### **C. Task Controller Layer (Business Logic & Orkestrasi)**
Ini layer tempat **semua business logic & business state game hidup**. Dipecah jadi banyak file kecil (`Task`) per domain, bukan 1 file `MainGameController.gd` raksasa.

#### Struktur
- `scripts/controllers/main_game_controller.gd` — root, attached ke `Gameplay.tscn`. Nge-instance semua Task sebagai child Node, dan **secara eksplisit nyambungin sinyal antar-Task** di `_ready()`. Ini bikin peta "siapa bereaksi ke siapa" keliatan di 1 file, bukan tersebar.
- `scripts/controllers/tasks/*.gd` — 1 file per domain business logic (`dialogue_task.gd`, `evidence_task.gd`, `story_task.gd`, dst.). Tiap Task `extends Node`, nyimpen state bisnis domain-nya sendiri (counter, index, flag lokal), dan boleh manggil Service manapun (Registry buat baca/perintah Driver).

#### Aturan Task
1. **Task boleh manggil Service manapun** — itu tugasnya (baca data via Registry, kasih perintah eksekusi ke Driver lewat Service).
2. **Task DILARANG saling manggil method secara implisit/tersembunyi** — semua sambungan antar-Task harus lewat salah satu dari 2 cara berikut, dan **wiring-nya wajib ada di `MainGameController`**, bukan di dalam Task itu sendiri:
   - **Notifikasi (1-ke-banyak, gak butuh jawaban)** → pakai **Signal**. Task A `emit` sinyal kejadian, `MainGameController` connect sinyal itu ke handler di Task B.
   - **Query sinkron (butuh jawaban langsung, mis. "apakah player punya kunci ini?")** → Task boleh pegang **referensi langsung** ke Task lain, di-inject oleh `MainGameController` setelah semua Task ke-instance. Ini beda dari larangan "hardcode node path" di Driver/Service — Task itu jumlahnya tetap & sedikit (bukan multi-instance dinamis kayak NPC/Item), jadi referensi langsung antar-Task aman dan gak ngelanggar prinsip modularitas.
3. Task **tidak boleh** tau soal node/scene tree secara langsung (gak ada `get_node("../../SomeNode")`) — semua akses fisik tetap lewat Service/Driver.

#### Daftar Task (6 Task, Final)
Disengaja **jumlahnya sedikit tapi tiap file isinya banyak fungsi handle** — 1 Task = 1 domain besar, bukan 1 Task per fitur kecil. Kalau 1 domain butuh banyak logic, ya taruh semua di 1 file itu (banyak `func` di dalamnya), bukan dipecah jadi Task baru.

| Task | Domain / State yang dipegang | Akses (Service) | Dengerin / Query |
|---|---|---|---|
| `StoryTask` | **Pusat state game**: `story_flags`, `current_chapter`, evidence score, daftar evidence terkumpul, `truth_unlocked`. Juga eksekusi efek checkpoint (pindah NPC, munculin item, dst.) | `NPCService`, `ItemService`, `DoorService`, `EnvironmentService` | Dengerin `InteractionTask.item_collected`/`door_unlocked`; Dengerin `DialogueTask.dialogue_finished` (buat cek syarat ending) |
| `DialogueTask` | Progress dialog NPC aktif, `yono_interaction_count` | `NPCService`, `DialogueService` | Dengerin `NPCService.npc_interacted`. Emit `dialogue_finished` → `StoryTask` dengerin |
| `InteractionTask` | Konsekuensi bisnis dari interaksi **Item & Door** (pickup, evidence, lock/unlock) — bukan raycast detection (itu tetap `InteractionService`, beda layer) | `ItemService`, `DoorService` | Dengerin `ItemService.item_interacted`, `DoorService.door_interacted`. Query → `StoryTask` (punya evidence/kunci ini?). Emit `item_collected`/`door_unlocked` → `StoryTask` dengerin |
| `WorldEnvironmentTask` | Keputusan preset waktu/atmosfer mana yang aktif, kapan berubah | `EnvironmentService` | Query/Dengerin → `StoryTask` (`flag_changed`, `current_chapter`) buat nentuin preset yang sesuai progress cerita |
| `HUDTask` | Teks objective aktif, tampilan skor evidence di HUD | `HUDService` (registry UI, pola sama kayak `DialogueService`) | Dengerin `StoryTask.flag_changed` |
| `SaveTask` | Serialize/deserialize seluruh save data | — (baca lewat method `get_save_data()` Task lain) | Query → **semua Task lain** (masing-masing wajib expose `get_save_data()`/`load_save_data()`) |

**Catatan soal Room**: gak ada `RoomTask` — kos di game ini gak banyak ruangan, dan pindah ke peta Kampus cukup lewat **teleport posisi Player** (`MainMap` & `KampusKelas` sama-sama di-instance di `Gameplay.tscn`, tinggal geser posisi Player, bukan `change_scene_to_file`). Logic teleport ini kecil, cukup nempel sebagai 1 fungsi handle di `InteractionTask` (dipicu pintu/trigger khusus), gak perlu Task sendiri.

#### Contoh: `MainGameController.gd`
```gdscript
extends Node

@onready var story_task: StoryTask = $StoryTask
@onready var dialogue_task: DialogueTask = $DialogueTask
@onready var interaction_task: InteractionTask = $InteractionTask
@onready var world_environment_task: WorldEnvironmentTask = $WorldEnvironmentTask
@onready var hud_task: HUDTask = $HUDTask
@onready var save_task: SaveTask = $SaveTask

func _ready() -> void:
    # Query sinkron: siapa butuh nanya StoryTask langsung
    interaction_task.story_task = story_task
    world_environment_task.story_task = story_task
    hud_task.story_task = story_task
    save_task.story_task = story_task
    save_task.dialogue_task = dialogue_task

    # Notifikasi: StoryTask bereaksi ke kejadian dari Task lain
    dialogue_task.dialogue_finished.connect(story_task.on_dialogue_finished)
    interaction_task.item_collected.connect(story_task.on_item_collected)
    interaction_task.door_unlocked.connect(story_task.on_door_unlocked)

    story_task.set_chapter("Prologue")
    print("Game Started: Prologue initialized.")
```

#### Contoh: `story_task.gd` (pusat state — gabungan flag, chapter, evidence)
```gdscript
class_name StoryTask
extends Node

signal flag_changed(flag_name: String, value: bool)

var current_chapter: String = "Prologue"
var story_flags: Dictionary = {}
var evidence_score: int = 0
var collected_evidence: Array[String] = []
var truth_unlocked: bool = false

func set_chapter(chapter_name: String) -> void:
    current_chapter = chapter_name

func set_flag(flag_name: String, value: bool) -> void:
    story_flags[flag_name] = value
    flag_changed.emit(flag_name, value)
    _apply_checkpoint_effect(flag_name, value)

func check_flag(flag_name: String) -> bool:
    return story_flags.get(flag_name, false)

func has_evidence(item_id: String) -> bool:
    return item_id in collected_evidence

func on_item_collected(item_id: String) -> void:
    if item_id in collected_evidence:
        return
    collected_evidence.append(item_id)
    evidence_score += 1

func on_door_unlocked(door_id: String) -> void:
    set_flag("door_%s_unlocked" % door_id, true)

func on_dialogue_finished(npc_id: String) -> void:
    pass # cek syarat ending, dst.

func _apply_checkpoint_effect(flag_name: String, value: bool) -> void:
    if flag_name == "hasan_body_found" and value:
        NPCService.move_npc("bu_yuni", Vector3(12.0, 0.0, -8.0))
        ItemService.spawn_item("dokumen_lama", Vector3(3.0, 0.0, 5.0))

func get_save_data() -> Dictionary:
    return {"chapter": current_chapter, "flags": story_flags, "evidence": collected_evidence}
```

#### Contoh: `interaction_task.gd` (konsekuensi Item & Door)
```gdscript
class_name InteractionTask
extends Node

signal item_collected(item_id: String)
signal door_unlocked(door_id: String)

var story_task: StoryTask # di-inject MainGameController (query)

func _ready() -> void:
    ItemService.item_interacted.connect(_on_item_interacted)
    DoorService.door_interacted.connect(_on_door_interacted)

func _on_item_interacted(item_id: String) -> void:
    item_collected.emit(item_id) # StoryTask yang nyimpen datanya
    ItemService.set_item_visible(item_id, false)

func _on_door_interacted(door_id: String) -> void:
    var door := DoorService.get_door(door_id)
    if not door.is_locked:
        return
    if story_task.has_evidence(door.key_id_required):
        DoorService.unlock_door(door_id)
        door_unlocked.emit(door_id)
    # kalau gak punya kunci, DoorDriver.interact() sendiri udah mainin locked_sound (lihat §3.A)
```

`DialogueTask` isinya sama persis kayak contoh sebelumnya (dengerin `NPCService.npc_interacted`, nyimpen `yono_interaction_count` + progress baris). `WorldEnvironmentTask`, `HUDTask`, `SaveTask` ngikutin pola yang sama: `extends Node`, nyimpen state kecil kalau perlu, dengerin `story_task.flag_changed`, dan manggil Service masing-masing (`EnvironmentService`/`HUDService`) buat eksekusi efeknya.

---

## 4. Standar Penulisan Kode (Coding Guidelines)
- **Typed GDScript**: Wajib menggunakan tipe data eksplisit pada variabel dan fungsi (contoh: `func open_door(speed: float) -> void:`).
- **Enkapsulasi**: Variabel internal node fisik harus dideklarasikan sebagai `@export` privat/terkontrol agar tidak diubah sembarangan oleh modul lain.
- **Pemisahan Tugas Murni**: 
  - *Driver* **tidak boleh** mengakses Service game secara langsung jika bisa dihindari (gunakan *Signal* jika Driver ingin melapor ke Service). Pengecualian sempit: self-registration (`register_x`/`unregister_x`) di `_ready()`/`_exit_tree()`.
  - *Service* **tidak boleh** mengatur posisi node fisik secara manual; service wajib memanggil method pada *Driver* terkait.
- **Service Dilarang Punya Business Logic/State**: Service (Layer 2) cuma boleh berisi Registry (`register/unregister/get/move`, dst.) dan relay sinyal dari Driver ke atas. **Dilarang** nyimpen counter/flag/progress atau bikin keputusan `if`/`match` yang nentuin konsekuensi gameplay — itu wajib pindah ke Task (Layer 3, lihat §3.C). Kalau nemu Service yang mulai nyimpen state kayak gitu, itu tanda harus di-refactor jadi Task.
- **Service Dilarang Manggil Service Lain**: Koordinasi antar-domain (mis. "flag cerita berubah → pindahin NPC + munculin item") wajib lewat Task yang subscribe ke sinyal Service-Service terkait, **bukan** satu Service manggil Service lain secara langsung.
- **Task Controller Wajib untuk Business Logic**: Semua logic & state bisnis (dialog progress, evidence score, story flag consequence, dst.) wajib tinggal di `scripts/controllers/tasks/*.gd`, 1 file per domain. `MainGameController.gd` jadi satu-satunya tempat yang nyambungin sinyal antar-Task (lihat §3.C) — kalau butuh tau "Task A pengaruhin Task B lewat apa", jawabannya harus bisa ditemuin di `main_game_controller.gd`, bukan nyebar/nyembunyi di dalam Task itu sendiri.
- **Registry Service Wajib untuk Entitas Multi-Instance**: Kategori Driver yang punya banyak instance di satu scene (NPC, Item, dll.) wajib diakses lewat Registry Service (`NPCService`, `ItemService`, dst. — lihat §3.B.4), bukan `get_node(...)` hardcoded dari Controller/Service lain. Driver wajib self-register ke Registry Service terkait pada `_ready()` dan unregister pada `_exit_tree()`.
- **Jangan pakai `class_name` pada script Service yang didaftarkan sebagai Autoload**: Godot melarang `class_name` yang namanya sama persis dengan nama Autoload (`Parse Error: Class "X" hides an autoload singleton`), karena nama Autoload itu sendiri sudah otomatis jadi identifier global. Semua script Service (`InteractionService`, `DialogueService`, `NPCService`, `ItemService`, `DoorService`, `EnvironmentService`, `HUDService`, dst.) cukup `extends Node` tanpa `class_name` — akses tetap lewat nama Autoload-nya. Aturan ini **tidak berlaku** untuk Driver (Layer 1), yang justru wajib pakai `class_name` karena dipakai untuk type-check (`is InteractableDriver`, dll.) dan bukan Autoload.
- **Script `@tool` (dipakai buat live-preview di editor, misal `EnvironmentDriver`) tidak boleh mengakses Autoload lewat nama global langsung** (`NamaService.method()`). Autoload cuma diinstansiasi saat game benar-benar berjalan (Play) — kalau script `@tool` merujuk nama Autoload secara langsung, editor bakal gagal compile script itu dengan error `Identifier not found` begitu dibuka di editor (bukan Play), walau referensinya dibungkus `if not Engine.is_editor_hint()`. Wajib akses lewat path: `get_node_or_null("/root/NamaService")`, baru panggil method-nya kalau hasilnya gak null.
