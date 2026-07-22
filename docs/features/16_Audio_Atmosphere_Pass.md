# Fitur 16 — Audio & Atmosphere Pass

**Ringkasan**: Polish menyeluruh audio ambient horor, spatial sound, VO (jika ada), dan atmosfer visual (lighting mood, VHS post-processing final) di semua scene yang sudah playable dari fitur 07 & 12–15.

**Dependency**: [14_Chapter2_Breakdown_Endings_Content](14_Chapter2_Breakdown_Endings_Content.md), [15_External_Maps](15_External_Maps.md)

---

## Phase (Garis Besar)
1. Ambient loop per room/area (dapur, lorong, halaman, basement) — beda mood tiap chapter jika perlu.
2. Sound effect interaksi (pintu, langkah kaki, item pickup) — pastikan konsisten lewat Driver masing-masing (`AudioStreamPlayer3D` di `DoorDriver`, dll).
3. Horror stinger/jumpscare audio di titik-titik kunci (penemuan jasad Hasan, reveal Dimas, dll).
4. Finalisasi lighting mood per chapter (Prologue lebih "hidup", Chapter 2 lebih suram).
5. VO pass (jika diputuskan pakai voice acting) atau tetap teks-only.

## Testing Criteria (Garis Besar)
- Tidak ada dead air di area yang seharusnya punya ambient.
- Audio 3D/spatial terdengar arah & jaraknya benar (uji headphone).
- Tidak ada audio yang overlap/bertabrakan aneh saat banyak trigger aktif bersamaan.

## Checkpoint (Garis Besar)
- Game terasa "jadi" secara sensory (visual + audio), siap masuk tahap QA akhir.
