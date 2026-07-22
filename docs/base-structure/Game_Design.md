# Game Design Document (GDD) — Kosan Mulyono
*Dokumen ini adalah referensi utama end-to-end (Single Source of Truth) untuk pengembangan game "Kosan Mulyono" menggunakan Godot Engine. Dokumen ini dirancang agar AI atau developer baru dapat langsung memahami konteks proyek secara utuh tanpa penjelasan ulang.*

---

## 1. Project Overview & Meta Information
- **Judul Game**: Kosan Mulyono
- **Genre**: First-Person, Psychological Horror, Mystery, Crime, Dark Humor
- **Platform**: PC (Windows/Linux/Mac)
- **Game Engine**: Godot Engine (GDScript)
- **Perspective**: First-Person (`CharacterBody3D`)
- **Visual Style**: Retro Horror / Low Poly / PS1-style / VHS-like Atmosphere & Post-Processing
- **Development Philosophy**:
  - **Single-Map Bounded Architecture**: Area kos, minimarket, dan jalan penghubung di antara keduanya berada dalam satu scene utama (`MainMap.tscn`) untuk menghindari *scene-switching* yang tidak perlu. Transisi ruangan/area dikelola secara lokal via pintu interaktif, *Area3D*, dan visibilitas node/pencahayaan dinamik.
  - **Modular Markdown Workflow**: GDD ini berpasangan dengan `Engine_Design.md` (arsitektur teknis global). Implementasi fitur spesifik akan dipecah ke file Markdown terpisah yang memuat *Phase*, *Testing Criteria*, dan *Checkpoint*.

---

## 2. Core Concept & Premise
- **Premise Utama**: 
  > *"Pemain mengira sedang menghadapi hantu, tetapi kebenaran yang lebih mengerikan adalah manusia."*
- **Bedah Premise**: Game dibangun di atas ilusi horor supernatural (arwah Pak Mulyono, ritual, suara tangisan). Seiring cerita berjalan, seluruh elemen mistis tersebut terungkap sebagai sisa-sisa operasi kejahatan manusia: **jaringan penculikan dan jual organ ilegal**.
- **Dual Perspective & Unreliable Narrator**: 
  - *Chapter Awal (Raka)*: Pemain melihat kos melalui kacamata korban yang ketakutan oleh fenomena mistis.
  - *Chapter Lanjutan (Dimas)*: Pemain beralih menjadi polisi penyelidik, yang perlahan mengalami *psychological breakdown* hingga terungkap bahwa dirinya adalah pelaku utama (pembunuh Mulyono & pelindung sindikat) yang mengalami amnesia disosiatif / penolakan diri.
- **Dark Humor Integration**: Humor tidak merusak ketegangan, melainkan menjadi kontras (comic relief) di Chapter 1 lewat interaksi keseharian mahasiswa di kos, sebelum akhirnya dibanting ke horor psikologis yang gelap.

---

## 3. World & Setting: Kosan Mulyono
Sebuah kos tua murah di pinggir kota yang sempit, lembap, dan dihindari warga sekitar.
- **Layout & Area di dalam 1 Scene Utama (`MainMap.tscn`)**:
  - Lorong Utama (menghubungkan kamar-kamar).
  - Kamar Raka (Kamar No. 7).
  - Kamar Hasan (Kamar No. 4).
  - Kamar Dimas (Kamar No. 10).
  - Kamar Kosong / Kamar Terlarang.
  - Dapur Bersama & Kamar Mandi Belakang.
  - Halaman Belakang / Area Ritual Bu Yuni.
  - Ruang Bawah Tanah Tersembunyi (Hidden Basement / Labirin).
  - Minimarket (dapat dijangkau jalan kaki langsung dari area kos, bukan pindah scene).
  - Jalan Penghubung (area luar/jalan yang menghubungkan kos dan minimarket).
- **External Map (Scene Terpisah)**: Area kampus — hanya satu ruang kelas (`KampusKelas.tscn`), diakses via `get_tree().change_scene_to_file` pada sekuens spesifik awal.

---

## 4. Character Profiles & Complete Roles
1. **Raka (Protagonis Chapter Prolog)**:
   - Mahasiswa baru, pindah karena ekonomi dan dekat kampus.
   - Berperan sebagai orang luar yang polos, pemicu awal investigasi, dan korban penculikan yang mengira dirinya diserang hantu.
2. **Hasan**:
   - Mahasiswa penghuni kos, santai, banyak bicara, sumber humor utama (comic relief).
   - Menjadi **korban pertama yang tewas** di area belakang kos, memicu kepanikan Raka.
3. **Chika**:
   - Mahasiswa penghuni kos, ceplas-ceplos, skeptis terhadap ritual Bu Yuni.
   - Saksi mata di Chapter 1, dan kunci penyelamatan di *Absurd Ending*.
4. **Pak Yono**:
   - Pria tua mirip gembel/dukun keliling yang sering nongkrong di depan kos.
   - Sering bicara ngawur tapi menyimpan clue. Interaksi berlebihan dengannya membuka *Absurd Ending*.
5. **Bu Yuni**:
   - Istri almarhum Pak Mulyono yang mengurus kos. Melakukan ritual dupa terus-menerus karena percaya suaminya dikutuk, tanpa sadar menutupi jejak kriminal masa lalu.
6. **Dimas (Protagonis Chapter 1, 2, & 3)**:
   - Polisi penyidik yang awalnya rasional. 
   - Seiring waktu mengalami halusinasi, mendengar suara Mulyono di kepala, dan akhirnya terungkap sebagai *the killer / mastermind* yang menyembunyikan identitas aslinya lewat mekanisme pertahanan psikologis.

---

## 5. Detailed Story Structure & Chapters

### **Prologue (POV: Raka)**
- **Fokus**: Atmosfer horor supernatural, pengenalan lingkungan kos, humor ringan mahasiswa.
- **Alur**:
  1. Raka check-in ke Bu Yuni, mendapat kamar No. 7.
  2. Bertemu Hasan dan Chika di lorong; ngobrol santai dan mendengar rumor kos angker.
  3. Perjalanan siang ke kampus & supermarket; bertemu Pak Yono yang memberi peringatan absurd ("kuburan, jangan keluar malam").
  4. Malam hari: Raka terbangun oleh suara aneh, memergoki Bu Yuni ritual dupa di lorong, lalu bertemu Dimas di depan kamar No. 10 yang memberi nasihat singkat.
  5. Insiden Malam Hari: Raka ketiduran di kelas sampai malam, pulang ke kos dan mendapati lorong ditutup plastik hitam. Memutar lewat pintu belakang.
  6. Menemukan jasad Hasan yang berlumuran darah di dekat ruang bawah tanah. Sosok mirip hantu menyerang Raka. Layar gelap (Raka diculik).

### **Chapter 1 (POV: Dimas - Investigasi Awal)**
- **Fokus**: Investigasi kriminal, penelusuran hilangnya Raka dan Hasan.
- **Alur**:
  1. Dimas datang sebagai polisi untuk membuka kembali kasus kos.
  2. Memeriksa kamar Raka & Hasan, mewawancarai Chika dan Bu Yuni.
  3. Mulai muncul gejala psikologis: pintu terbuka sendiri, Dimas tahu letak barang tanpa alasan, bayangan cermin tidak sinkron, objective berubah secara misterius menjadi "hapus jejak".

### **Chapter 2 (POV: Dimas - Psychological Breakdown & Twist)**
- **Fokus**: Eksplorasi labirin bawah tanah, pecahnya kewarasan, pengungkapan identitas asli.
- **Alur**:
  - Dimas menemukan dokumen lama, foto bersama Mulyono, dan bukti bahwa dirinyalah yang menutup kasus ini dulu.
  - Terungkap bahwa Dimas membunuh Mulyono karena perebutan kekuasaan sindikat, lalu menciptakan persona "polisi baik" untuk menutupi rasa bersalahnya.
- **Cabang Ending**:
  - **Bad Ending**: Clue kurang lengkap. Dimas bingung, tertangkap polisi di ruang bawah tanah, mengalami glitch psikologis, dan tewas ditembak polisi dalam kebingungan.
  - **Cliffhanger Ending**: Clue lengkap. Dimas sadar penuh, melarikan diri dari kejaran polisi di labirin bawah tanah, kabur sebagai buron (kasus menggantung).
  - **Absurd Ending (Secret / Non-Canon)**: Dipicu terlalu sering ngobrol dengan Pak Yono sejak Chapter 1. Menemukan Raka hidup, berkelahi konyol melawan Mulyono, diselamatkan Chika yang naksir Dimas, dan Bu Yuni kembali ke Pak Yono.

---

## 6. Core Game Systems & Mechanics
1. **First-Person Controller**: Gerakan jalan, lari, senter (`SpotLight3D` di tangan player), interaksi raycast (`RayCast3D`).
2. **Investigation & Evidence System**: Sistem penyimpanan catatan/clue (`EvidenceManager` autoload). Mengumpulkan dokumen/foto memperbarui *Evidence Score* dan *Truth Unlocked*.
3. **Psychological Distortion System**: Script runtime untuk mengubah environment:
   - Glitch post-processing (VHS shader / Chromatic Aberration).
   - Audio trigger ilusi (suara langkah di belakang, bisikan Mulyono).
   - Perubahan teks objective secara mendadak.
4. **Supernatural Misdirection System**: Event di mana kejadian kriminal disamarkan sebagai misteri mistis (misal: bau bahan kimia diubah suaranya menjadi suara tangisan lewat audio spatial).
5. **NPC Interaction & Counter System**: Interaksi teks sederhana, pencatatan variabel `yono_interaction_count` untuk syarat *Absurd Ending*.
6. **Single-Scene Room Management**: Sistem manajemen visibilitas ruangan (`Room / Portal` atau script pengatur `Visible` node kamar) untuk efisiensi performa di Godot tanpa pindah scene.

---

## 7. Development & System Rules for AI Handover
- **Aturan Perubahan File**: GDD ini (`Game_Design.md`) dan `Engine_Design.md` adalah dokumen permanen. Jangan mengubah core lore atau struktur dasar tanpa instruksi eksplisit.
- **Eksekusi Fitur**: Setiap pembuatan fitur baru wajib dibuatkan file .MD terpisah dengan format: **Phase** (tahapan pengerjaan), **Testing Criteria** (syarat lulus uji), dan **Checkpoint** (titik simpan progress).
- **Integrasi Godot**: Selalu gunakan node bawaan Godot yang optimal (`CharacterBody3D`, `Area3D`, `RayCast3D`, `Control` untuk UI) dan tulis script bersih berbasis GDScript bertipe data eksplisit (`typed GDScript`).
