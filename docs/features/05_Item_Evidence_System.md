# Fitur 05 — Item & Evidence System

**Ringkasan**: Sistem investigasi inti — `ItemDriver` untuk objek yang bisa diambil/diperiksa (udah ada dari Fitur 03, tinggal dikembangin dari versi dummy), `ItemService` sebagai registry (udah ada), dan `InteractionTask` yang mutusin konsekuensi pickup (evidence score, Truth Unlocked) lewat `StoryTask`.

*Revisi arsitektur: **gak ada `EvidenceManager`**. Evidence score/daftar evidence/Truth Unlocked itu business state, jadi nempel di `StoryTask` (field `collected_evidence`, `evidence_score`, `truth_unlocked` — udah ada kerangkanya). `InteractionTask` (udah ada, dengerin `ItemService.item_interacted`) yang mutusin "item ini nambah evidence apa gak", terus lapor ke `StoryTask` lewat sinyal `item_collected` (udah disambungin `MainGameController`). Lihat `Engine_Design.md` §3.C.*

**Dependency**: [03_Interaction_Registry_System](03_Interaction_Registry_System.md)

---

## Phase (Garis Besar)
1. `ItemDriver.gd`: udah emit sinyal `interacted(item_id)` dari Fitur 03 — tinggal tambah data spesifik per item kalau perlu (mis. `@export var item_data: ItemData`).
2. `ItemService.gd`: udah lengkap (`register/unregister/get/move/set_item_visible` + relay `item_interacted`) — cek apa masih butuh `spawn_item` buat checkpoint cerita nanti (Fitur 08).
3. Isi `interaction_task.gd`'s `_on_item_interacted()` (kerangka print doang saat ini) — bedain item biasa vs evidence (via `ItemData.type`), baru `item_collected.emit(item_id)` kalau emang evidence.
4. Custom Resource `ItemData` (nama, deskripsi, tipe: kunci/dokumen/foto/benda biasa).
5. UI Evidence/Inventory dasar (list item terkumpul, baca dari `StoryTask.collected_evidence`) — versi minimal, detail styling di fitur 10.

## Testing Criteria (Garis Besar)
- Item bisa diambil via interact, `InteractionTask` mutusin itu evidence, lapor ke `StoryTask` (cek `collected_evidence`/`evidence_score` lewat Debugger → Remote), dan Evidence Score bertambah.
- Item non-evidence (misal benda biasa) diambil TAPI gak nambah `evidence_score` — bukti `InteractionTask` beneran mutusin, bukan asal nambah semua item.
- UI evidence menampilkan daftar item yang sudah diambil (baca dari `StoryTask`).

## Checkpoint (Garis Besar)
- Alur pickup → `ItemDriver` emit → `ItemService` relay → `InteractionTask` mutusin → `StoryTask` nyimpen evidence → score bertambah, terbukti bekerja end-to-end tanpa Service manggil Service.
