# Fitur 14 — Chapter 2 Content & Branching Endings

**Ringkasan**: Fitur konten paling kompleks — eksplorasi labirin bawah tanah, pengungkapan identitas asli Dimas, dan 3 ending bercabang (Bad, Cliffhanger, Absurd/Secret) berdasarkan kelengkapan clue & interaksi `yono_interaction_count`.

**Dependency**: [13_Chapter1_Investigation_Content](13_Chapter1_Investigation_Content.md)

---

## Phase (Garis Besar)
1. Bangun area labirin bawah tanah (extend layout dari fitur 07 jika belum lengkap).
2. Susun checkpoint penemuan dokumen lama, foto bersama Mulyono, dan reveal "Dimas = pembunuh Mulyono".
3. Implementasi logika penentuan ending: evaluasi Evidence Score/flag lengkap → Bad vs Cliffhanger; evaluasi `yono_interaction_count` → Absurd Ending (override).
4. Isi konten & cutscene/sequence untuk masing-masing dari 3 ending.
5. Playtest ketiga jalur ending secara terpisah untuk memastikan branching logic benar.

## Testing Criteria (Garis Besar)
- Kondisi clue tidak lengkap secara konsisten mengarah ke Bad Ending, clue lengkap ke Cliffhanger Ending.
- Threshold `yono_interaction_count` yang cukup tinggi secara konsisten membuka Absurd Ending, override 2 ending lain.
- Ketiga ending bisa dicapai dan dites ulang dari save point berbeda tanpa harus main dari awal tiap kali (manfaat Save/Load di fitur 11).

## Checkpoint (Garis Besar)
- Seluruh alur cerita utama (Prologue → Chapter 1 → Chapter 2 + 3 ending) selesai dan playable — ini adalah **Story Complete Milestone**.
