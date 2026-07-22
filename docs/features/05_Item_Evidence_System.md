# Fitur 05 — Item & Evidence System

**Ringkasan**: Sistem investigasi inti — `ItemDriver` untuk objek yang bisa diambil/diperiksa, `ItemService` sebagai registry, dan `EvidenceManager` (autoload) untuk menyimpan clue/dokumen/foto yang mempengaruhi Evidence Score & Truth Unlocked.

**Dependency**: [03_Interaction_Registry_System](03_Interaction_Registry_System.md)

---

## Phase (Garis Besar)
1. `ItemDriver.gd` konkret: `interact()` → pickup/inspect, self-register ke `ItemService`.
2. `ItemService.gd`: lengkapi `spawn_item`, `move_item`, `set_item_visible`, `remove_item`.
3. `EvidenceManager.gd` (autoload): daftar evidence terkumpul, Evidence Score, flag Truth Unlocked.
4. Custom Resource `ItemData` (nama, deskripsi, tipe: kunci/dokumen/foto/benda biasa).
5. UI Evidence/Inventory dasar (list item terkumpul) — versi minimal, detail styling di fitur 10.

## Testing Criteria (Garis Besar)
- Item bisa diambil via interact, masuk ke `EvidenceManager`, dan Evidence Score bertambah.
- Item bisa di-spawn/dihilangkan secara dinamis lewat `ItemService` (dites manual via checkpoint dummy).
- UI evidence menampilkan daftar item yang sudah diambil.

## Checkpoint (Garis Besar)
- Alur pickup → evidence tercatat → score bertambah terbukti bekerja end-to-end di scene test.
