# Development Roadmap — Kosan Mulyono

*Dokumen ini adalah peta urutan eksekusi seluruh fitur game, dari fondasi teknis kosong hingga game selesai. Setiap baris di bawah punya file `.md` sendiri di `docs/features/` berisi garis besar (Phase, Testing Criteria, Checkpoint) sesuai format wajib di `Engine_Design.md` §7. Detail penuh baru diisi saat fitur tersebut mau dieksekusi.*

*Acuan arsitektur: `docs/base-structure/Engine_Design.md` (Controller-Service-Driver) & `docs/base-structure/Game_Design.md` (cerita, dunia, karakter).*

---

## Urutan Eksekusi

| # | Fitur | Kenapa urutan ini | Status |
|---|-------|--------------------|--------|
| 1 | [Project & Architecture Foundation](features/01_Project_Foundation.md) | Semua fitur lain butuh struktur folder, base class Driver/Service, autoload terdaftar. Tanpa ini tidak ada tempat menaruh kode. | Belum dikerjakan |
| 2 | [Player Controller](features/02_Player_Controller.md) | Tidak bisa test fitur apapun (interaksi, NPC, item) tanpa player yang bisa jalan & lihat dunia. | Belum dikerjakan |
| 2a | [Environment & Time-of-Day System](features/02a_Environment_TimeOfDay_System.md) | Dimajuin dari rencana awal karena tim art lagi aktif eksplorasi shader/mood — preset environment modular dibutuhin dari sekarang, bukan nunggu Fitur 16. | Belum dikerjakan |
| 3 | [Interaction & Registry System](features/03_Interaction_Registry_System.md) | Tulang punggung semua objek interaktif (`InteractionService`, `NPCService`, `ItemService` registry). NPC/Item/Door dibangun di atas ini. | Belum dikerjakan |
| 4 | [NPC & Dialogue System](features/04_NPC_Dialogue_System.md) | Karakter (Hasan, Chika, Pak Yono, Bu Yuni, Dimas) & dialog adalah cara utama pemain terima info cerita. | Belum dikerjakan |
| 5 | [Item & Evidence System](features/05_Item_Evidence_System.md) | Investigation System adalah mekanik inti (Evidence Score, Truth Unlocked) — butuh dipakai sejak Chapter 1. | Belum dikerjakan |
| 6 | [Door Management](features/06_Door_Room_Management.md) | Sistem pintu (lock/unlock via evidence) dibutuhin sebelum level digambar penuh. Room management dihapus dari rencana — kos gak banyak ruangan, pindah peta cukup teleport (lihat #15). | Belum dikerjakan |
| 7 | [Level Greybox: Map Utama](features/07_Level_Greybox_MainMap.md) | Setelah semua sistem inti ada, baru masuk akal membangun layout penuh kos + minimarket + jalan penghubung (satu scene) untuk ditempeli sistem-sistem di atas. | Belum dikerjakan |
| 8 | [Story Task & Flag System](features/08_Story_Engine_Flags.md) | Menghubungkan checkpoint cerita ke perubahan dunia nyata (posisi NPC, munculnya item, status pintu, waktu) via registry di #3 dan Task lain. | Belum dikerjakan |
| 9 | [Psychological Distortion & Misdirection System](features/09_Psychological_Distortion_System.md) | Ciri khas horor psikologis game ini; butuh StoryTask (#8) sudah ada supaya efeknya bisa dipicu oleh flag/chapter. | Belum dikerjakan |
| 10 | [Core UI & HUD](features/10_Core_UI_HUD.md) | Setelah gameplay inti jalan, baru dibungkus UI (menu, HUD, prompt, evidence panel, pause/settings). | Belum dikerjakan |
| 11 | [Save / Load System](features/11_Save_Load_System.md) | Butuh semua data state (flags, evidence, posisi NPC) sudah terdefinisi dulu sebelum bisa diserialisasi. | Belum dikerjakan |
| 12 | [Prologue Content (Raka)](features/12_Prologue_Chapter_Content.md) | Konten cerita pertama yang bisa dites end-to-end, memvalidasi semua sistem #1–11 sekaligus. | Belum dikerjakan |
| 13 | [Chapter 1 Content (Dimas — Investigasi)](features/13_Chapter1_Investigation_Content.md) | Lanjutan alur, butuh Evidence System & Distortion System matang. | Belum dikerjakan |
| 14 | [Chapter 2 Content & Branching Endings](features/14_Chapter2_Breakdown_Endings_Content.md) | Fitur paling kompleks (3 ending bercabang) — dikerjakan terakhir dari sisi konten cerita. | Belum dikerjakan |
| 15 | [Peta Kampus (Teleport)](features/15_External_Maps.md) | 1 ruang kelas, di-instance bareng MainMap + teleport posisi Player (bukan scene terpisah), hanya dipakai sekali di awal Prologue — bisa dikerjakan paralel/belakangan tanpa blokir chapter lain. | Belum dikerjakan |
| 16 | [Audio & Atmosphere Pass](features/16_Audio_Atmosphere_Pass.md) | Polish suara ambient/horror/VO — paling efektif dikerjakan setelah semua level & event final. | Belum dikerjakan |
| 17 | [Optimization, QA & Release Prep](features/17_Optimization_QA_Release.md) | Tahap akhir sebelum build rilis. | Belum dikerjakan |

---

## Prinsip Urutan
1. **Fondasi dulu, konten belakangan** — sistem generik (#1–11) harus solid sebelum konten cerita spesifik (#12–15) ditulis, supaya tidak bongkar-pasang arsitektur di tengah jalan.
2. **Setiap fitur harus playtestable sendiri** — setelah tiap file `.md` selesai dieksekusi, harus ada sesuatu yang bisa dicoba langsung di editor/game (lihat Testing Criteria masing-masing file).
3. **Checkpoint = titik aman commit** — checkpoint di tiap file menandai kapan fitur tersebut dianggap stabil dan aman dijadikan dasar fitur berikutnya.
4. Urutan ini boleh direvisi kalau ada kebutuhan baru — update tabel ini setiap kali urutan berubah.
