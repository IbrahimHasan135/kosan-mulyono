# Fitur 01 — Project & Architecture Foundation

**Ringkasan**: Menyiapkan kerangka teknis kosong: struktur folder, base class Driver/Service, dan autoload dasar sesuai `Engine_Design.md`. Tidak ada gameplay di fitur ini — murni pondasi supaya fitur 02 dan seterusnya punya tempat berpijak.

**Dependency**: Tidak ada (fitur pertama).

---

## Phase (Garis Besar)
1. Buat struktur direktori sesuai §2 `Engine_Design.md` (`scenes/`, `scripts/controllers|services|drivers`, `resources/`).
2. Buat base class `InteractableDriver.gd` (abstrak).
3. Buat `InteractionService.gd` dan daftarkan sebagai Autoload.
4. Buat shell `MainGameController.gd` kosong (belum ada logic chapter, cuma `_ready()`).
5. Setup project settings dasar Godot (input map: `interact`, `move_*`, `sprint`, dll; render pipeline untuk gaya visual retro/PS1).

## Testing Criteria (Garis Besar)
- Project bisa di-run tanpa error dengan scene kosong.
- Autoload `InteractionService` terdaftar dan tidak crash saat `_ready()`.
- Struktur folder cocok 1:1 dengan diagram di `Engine_Design.md` §2.

## Checkpoint (Garis Besar)
- Struktur folder + base class committed, siap ditumpangi fitur Player Controller (02).
