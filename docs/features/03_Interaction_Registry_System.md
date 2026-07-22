# Fitur 03 — Interaction & Registry System

**Ringkasan**: Tulang punggung semua objek interaktif. Menghubungkan raycast player ke `InteractableDriver` manapun (polimorfisme), dan membangun pola **Registry Service** (`NPCService`, `ItemService`, dst.) sesuai `Engine_Design.md` §3.B.4 supaya Service/Controller bisa memanggil Driver spesifik by ID tanpa hardcode node path.

**Dependency**: [02_Player_Controller](02_Player_Controller.md)

---

## Phase (Garis Besar)
1. Lengkapi `InteractionService.gd` — deteksi raycast, trigger `interact()` polymorphic, update UI prompt (prompt UI sendiri detail di fitur 10).
2. Buat `NPCService.gd` & `ItemService.gd` (registry pattern: `register_*`, `unregister_*`, `get_*`, `move_*`).
3. Update `InteractableDriver` turunannya (`NPCDriver`, `ItemDriver` — versi kosong/dummy dulu) agar self-register ke Registry Service terkait di `_ready()`/`_exit_tree()`.
4. Scene test dengan beberapa dummy object interaktif untuk validasi lookup by ID.

## Testing Criteria (Garis Besar)
- Menekan tombol interact di depan objek dummy memicu `interact()` sesuai tipe objek (polimorfisme bekerja).
- `NPCService.get_npc("dummy_id")` mengembalikan instance yang benar setelah scene `_ready()`.
- Registry otomatis bersih (unregister) saat node dihapus dari scene tree.

## Checkpoint (Garis Besar)
- Registry Service pattern terbukti bekerja, siap jadi fondasi fitur NPC & Dialogue (04) dan Item & Evidence (05).
