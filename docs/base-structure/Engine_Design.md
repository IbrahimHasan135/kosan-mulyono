# Engine Design Document (EDD) — Kosan Mulyono (Godot Engine & OOP Architecture)
*Dokumen arsitektur teknis global ini mendefinisikan standar pengembangan berbasis **Object-Oriented Programming (OOP)** dengan pola **Controller-Service-Driver** untuk game "Kosan Mulyono". Dokumen ini wajib dijadikan acuan mutlak agar seluruh implementasi kode memiliki konsistensi kelas, pewarisan, enkapsulasi, dan polimorfisme.*

---

## 1. Filosofi Arsitektur: Controller-Service-Driver (OOP-Based)
Pola ini memisahkan tanggung jawab sistem menjadi tiga lapisan utama berbasis kelas (`class_name`):

1. **Layer 1: Driver (Physical & Node-Level Class)**
   - Berupa kelas turunan node Godot (`class_name [Name]Driver extends [Node3D/CharacterBody3D/ dll]`).
   - Bertanggung jawab penuh atas manipulasi node fisik (transform, animasi, audio, mesh, material shader, teleport, gerakan point-to-point).
   - Tidak memiliki logika bisnis game (tidak tahu quest, skor, atau chapter).
2. **Layer 2: Service (Business Logic & Autoload Class)**
   - Berupa kelas Singleton / Autoload (`class_name [Name]Service`).
   - Menyediakan fungsi logika bisnis, manajemen data (state, inventory, evidence, dialog), dan bertindak sebagai perantara yang memanggil *Driver* untuk mengeksekusi efek fisik.
3. **Layer 3: Controller (Orchestrator & Flow Methods)**
   - Berupa fungsi/metode biasa yang melekat pada root/scene controller (`MainGameController.gd`).
   - Bertindak sebagai pengatur alur utama game, memantau *state machine*, dan memanggil berbagai *Service* sesuai progress cerita.

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
│   ├── levels/                # Scene utama map (MainMap.tscn = kos+minimarket+jalan, KampusKelas.tscn)
│   ├── entities/               # Prefabs Player, NPC, Pintu, Item
│   │   ├── player/
│   │   ├── npc/
│   │   ├── items/
│   │   └── doors/
│   └── ui/                    # HUD, Evidence Menu, Dialogue Box
│
├── scripts/
│   ├── controllers/     # Fungsi Controller utama alur game
│   ├── services/        # Kelas Service (Autoload / Business Logic)
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

@export var npc_id: String = "npc_yono"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact() -> void:
    # Memanggil service dialog secara OOP
    DialogueService.start_dialogue(npc_id)

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
```gdscript
extends Node

signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)

var yono_interaction_count: int = 0

func start_dialogue(npc_id: String) -> void:
    if npc_id == "npc_yono":
        yono_interaction_count += 1
    
    emit_signal("dialogue_started", npc_id)
    # Memuat data dialog dari file / resource
```

#### 3. `StoryEngineService.gd` (Autoload)
```gdscript
extends Node

var current_chapter: String = "Prologue"
var story_flags: Dictionary = {}

func set_chapter(chapter_name: String) -> void:
    current_chapter = chapter_name

func set_flag(flag_name: String, value: bool) -> void:
    story_flags[flag_name] = value

func check_flag(flag_name: String) -> bool:
    return story_flags.get(flag_name, false)
```

---

#### 4. Registry Service Pattern (`NPCService`, `ItemService`, dll.)
Saat sebuah scene memiliki **banyak instance Driver sejenis** (banyak NPC, banyak Item interaktif), Service bisnis (`StoryEngineService`, dll.) butuh cara untuk memanggil Driver *spesifik* tanpa mengetahui struktur scene tree secara langsung (`get_node(...)` hardcoded dilarang di layer Service/Controller).

Solusinya: setiap kategori entitas fisik yang jumlahnya banyak & dinamis wajib memiliki **Registry Service** — Autoload yang menyimpan *mapping* `id -> Driver instance`, dan menyediakan API tingkat tinggi (`move_npc`, `set_item_visible`, dll.) yang di baliknya memanggil method pada Driver yang cocok. Registry Service **tidak** menyimpan business logic (itu tetap tugas `StoryEngineService`/`DialogueService`); ia murni jembatan lookup + delegasi ke Driver.

**Prinsip self-registration**: setiap Driver mendaftarkan dirinya sendiri ke Registry Service terkait saat `_ready()`, dan melepas diri saat `_exit_tree()`. Dengan begitu menambah NPC/Item baru ke scene tidak memerlukan perubahan kode apa pun di Service atau Controller.

```gdscript
# scripts/services/npc_service.gd
extends Node

var _npcs: Dictionary = {} # npc_id (String) -> NPCDriver

func register_npc(npc_id: String, driver: NPCDriver) -> void:
    _npcs[npc_id] = driver

func unregister_npc(npc_id: String) -> void:
    _npcs.erase(npc_id)

func get_npc(npc_id: String) -> NPCDriver:
    return _npcs.get(npc_id, null)

func move_npc(npc_id: String, target: Vector3) -> void:
    if _npcs.has(npc_id):
        _npcs[npc_id].move_to(target) # Driver yang mengeksekusi transform fisik
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

Dengan pola ini, checkpoint cerita di `StoryEngineService` bisa memicu efek dunia nyata tanpa referensi node manual:

```gdscript
# StoryEngineService.gd
func set_flag(flag_name: String, value: bool) -> void:
    story_flags[flag_name] = value
    if flag_name == "hasan_body_found" and value:
        NPCService.move_npc("bu_yuni", Vector3(12.0, 0.0, -8.0)) # pindah ke halaman belakang
        ItemService.spawn_item("dokumen_lama", Vector3(3.0, 0.0, 5.0))
```

`ItemService` mengikuti pola identik (`register_item`, `unregister_item`, `move_item`, `set_item_visible`, `spawn_item`) terhadap `ItemDriver`. Kategori entitas baru yang butuh manajemen serupa (mis. `DoorService` bila jumlah pintu-terkunci membesar) wajib mengikuti pola Registry Service yang sama, bukan pola ad-hoc baru.

---

### **C. Controller Layer (Main Flow Orchestrator)**
Controller diimplementasikan sebagai fungsi/metode terpusat pada script root scene utama (`MainGameController.gd`), mengatur siklus permainan dengan memanggil Service.

```gdscript
extends Node
# Controller menggunakan metode fungsional terpusat

func _ready() -> void:
    init_game_flow()

func init_game_flow() -> void:
    StoryEngineService.set_chapter("Prologue")
    # Contoh mengatur objektif awal via UI Service atau Story Engine
    print("Game Started: Prologue initialized.")

func trigger_hasan_discovery_event() -> void:
    StoryEngineService.set_flag("hasan_body_found", true)
    # Memanggil Service lain untuk memicu horor ambient
    # AudioService.play_horror_drone()
    print("Event Triggered: Player found Hasan's body.")
```

---

## 4. Standar Penulisan Kode (Coding Guidelines)
- **Typed GDScript**: Wajib menggunakan tipe data eksplisit pada variabel dan fungsi (contoh: `func open_door(speed: float) -> void:`).
- **Enkapsulasi**: Variabel internal node fisik harus dideklarasikan sebagai `@export` privat/terkontrol agar tidak diubah sembarangan oleh modul lain.
- **Pemisahan Tugas Murni**: 
  - *Driver* **tidak boleh** mengakses Service game secara langsung jika bisa dihindari (gunakan *Signal* jika Driver ingin melapor ke Service).
  - *Service* **tidak boleh** mengatur posisi node fisik secara manual; service wajib memanggil method pada *Driver* terkait.
- **Registry Service Wajib untuk Entitas Multi-Instance**: Kategori Driver yang punya banyak instance di satu scene (NPC, Item, dll.) wajib diakses lewat Registry Service (`NPCService`, `ItemService`, dst. — lihat §3.B.4), bukan `get_node(...)` hardcoded dari Controller/Service lain. Driver wajib self-register ke Registry Service terkait pada `_ready()` dan unregister pada `_exit_tree()`.
- **Jangan pakai `class_name` pada script Service yang didaftarkan sebagai Autoload**: Godot melarang `class_name` yang namanya sama persis dengan nama Autoload (`Parse Error: Class "X" hides an autoload singleton`), karena nama Autoload itu sendiri sudah otomatis jadi identifier global. Semua script Service (`InteractionService`, `DialogueService`, `StoryEngineService`, `NPCService`, `ItemService`, dst.) cukup `extends Node` tanpa `class_name` — akses tetap lewat nama Autoload-nya. Aturan ini **tidak berlaku** untuk Driver (Layer 1), yang justru wajib pakai `class_name` karena dipakai untuk type-check (`is InteractableDriver`, dll.) dan bukan Autoload.
