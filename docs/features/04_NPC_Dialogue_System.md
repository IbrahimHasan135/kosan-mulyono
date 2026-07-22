# Fitur 04 — NPC & Dialogue System

**Ringkasan**: Menghidupkan karakter (Hasan, Chika, Pak Yono, Bu Yuni, Dimas) lewat `NPCDriver` konkret + sistem dialog (`DialogueService`) dan UI dialog dasar. Termasuk counter interaksi (mis. `yono_interaction_count`) untuk syarat Absurd Ending nanti.

**Dependency**: [03_Interaction_Registry_System](03_Interaction_Registry_System.md)

---

## Phase (Garis Besar)
1. `NPCDriver.gd` konkret: `interact()` → panggil `DialogueService`, `look_at_player()`, `move_to()` (dipakai Story Engine nanti).
2. `DialogueService.gd`: state dialog aktif, signal `dialogue_started`/`dialogue_ended`, counter interaksi per NPC.
3. Custom Resource `DialogueData` (baris dialog per NPC, sederhana dulu — belum branching kompleks).
4. UI Dialog Box dasar (teks + nama NPC) — versi minimal, detail styling di fitur 10.
5. Populate 5 NPC dummy (Hasan, Chika, Pak Yono, Bu Yuni, Dimas) dengan 1–2 baris dialog placeholder masing-masing.

## Testing Criteria (Garis Besar)
- Interact ke tiap NPC memunculkan dialog box dengan teks yang sesuai NPC-nya.
- Counter interaksi Pak Yono bertambah tiap kali dialog dimulai, bisa dicek lewat debug print.
- NPC bisa dipindah posisi via `NPCService.move_npc(id, target)` dan tetap bisa diajak bicara di posisi baru.

## Checkpoint (Garis Besar)
- Semua 5 karakter utama bisa diajak interaksi dasar di scene test, siap dipakai isi konten Prologue (12) nanti.
