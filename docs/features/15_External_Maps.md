# Fitur 15 — External Map (Kampus)

**Ringkasan**: Satu scene terpisah (bukan bagian dari `MainMap.tscn`) berisi ruang kelas kampus (hanya 1 ruangan), diakses lewat `get_tree().change_scene_to_file` pada sekuens spesifik di awal Prologue (perjalanan siang Raka). Sumber geometri dari `assets/models/environment/kampus_kelas/`.

*Catatan: minimarket TIDAK lagi termasuk external map — sudah digabung ke `MainMap.tscn` sebagai bagian dari peta utama (lihat fitur 07).*

**Dependency**: [12_Prologue_Chapter_Content](12_Prologue_Chapter_Content.md) (bisa dikerjakan paralel dengan fitur 13/14 karena tidak saling blocking)

---

## Phase (Garis Besar)
1. Import `.glb` ruang kelas kampus (`assets/models/environment/kampus_kelas/`) dan susun `KampusKelas.tscn` di `scenes/levels/`.
2. Setup transisi scene (`change_scene_to_file`) dari `MainMap.tscn` ke `KampusKelas.tscn` dan sebaliknya, dengan state carry-over (posisi kembali ke MainMap, inventory tetap).
3. Isi dialog & event spesifik area ini (sekuens singkat di kelas kampus sesuai alur Prologue).

## Testing Criteria (Garis Besar)
- Transisi keluar-masuk `KampusKelas.tscn` tidak menghilangkan state penting (evidence, flag) dari `MainMap`.
- Player kembali ke posisi yang benar di `MainMap.tscn` setelah keluar dari scene kampus.
- Tidak ada memory leak/orphan node saat berpindah scene bolak-balik.

## Checkpoint (Garis Besar)
- Scene kampus playable dan terintegrasi mulus ke alur Prologue.
