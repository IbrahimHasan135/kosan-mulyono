# Fitur 13 — Chapter 1 Content (POV: Dimas — Investigasi Awal)

**Ringkasan**: Dimas datang sebagai polisi, memeriksa kamar Raka & Hasan, mewawancarai Chika & Bu Yuni, dan mulai muncul gejala psikologis awal (pintu terbuka sendiri, tahu letak barang tanpa alasan, objective berubah misterius).

**Dependency**: [12_Prologue_Chapter_Content](12_Prologue_Chapter_Content.md)

---

## Phase (Garis Besar)
1. Susun checkpoint Chapter 1 di `StoryEngineService` (transisi dari Prologue → Chapter 1, ganti playable character).
2. Isi dialog wawancara (Chika, Bu Yuni) + reaksi berbeda tergantung evidence yang sudah/belum ditemukan Raka sebelumnya (jika didesain saling terhubung).
3. Rancang & trigger gejala psikologis awal via `DistortionService` (fitur 09) — pintu buka sendiri, objective berubah jadi "hapus jejak".
4. Evidence baru khusus Chapter 1 (dokumen, foto) yang menambah Evidence Score/Truth Unlocked.

## Testing Criteria (Garis Besar)
- Transisi Prologue → Chapter 1 mulus (load state baru, ganti kontrol ke Dimas) tanpa residual state salah (mis. inventory Raka tidak nyangkut ke Dimas kalau memang harus terpisah).
- Semua gejala psikologis Chapter 1 terpicu sesuai checkpoint, teruji tidak infinite-loop atau tumpang tindih efek.
- Wawancara NPC memberi info yang konsisten dengan lore `Game_Design.md`.

## Checkpoint (Garis Besar)
- Chapter 1 playable penuh, siap lanjut ke Chapter 2 (14) yang lebih kompleks (branching ending).
