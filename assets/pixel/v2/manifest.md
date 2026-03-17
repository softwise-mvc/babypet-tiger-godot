# Pixel V2 Asset Manifest (2026-03-07)

## 已下載完成

### Characters (8 directions)
- `tigergod_hero_v2`
  - source id: `8f9a1d13-bbe5-40c4-886d-8e4ce87652e5`
  - files: `characters/tigergod_hero_v2/rotations/*.png`
  - metadata: `characters/tigergod_hero_v2/metadata.json`
- `tigerboss_corrupted_v2`
  - source id: `c21bf45f-1748-4eae-a920-78e678f508c5`
  - files: `characters/tigerboss_corrupted_v2/rotations/*.png`
  - metadata: `characters/tigerboss_corrupted_v2/metadata.json`
- `pet_shiba_v2`
  - source id: `f39ccc89-15d1-4713-8074-982f1b5df46c`
  - files: `characters/pet_shiba_v2/rotations/*.png`
  - metadata: `characters/pet_shiba_v2/metadata.json`

### Objects
- `temple_palanquin_mount_v2.png`
  - source id: `7870b785-398d-4908-af40-8c7af57dc08f`
  - path: `objects/temple_palanquin_mount_v2.png`
  - size: `96x64`

### Tilesets
- `sidescroller_ground_temple_v2.png`
  - source id: `2b3aefa2-639e-4822-9472-51cde3f0f7e7`
  - path: `tilesets/sidescroller_ground_temple_v2.png`
  - metadata: `metadata/sidescroller_ground_temple_v2.json`
  - size: `64x64` (16 tiles x 16px)
- `taiwan_topdown_tileset_v1.png`
  - source id: `22b618eb-e2ad-42da-a8ce-50e74dabfcca`
  - path: `tilesets/taiwan_topdown_tileset_v1.png`
  - metadata: `metadata/taiwan_topdown_tileset_v1.json`
  - size: `64x64` (16 tiles x 16px)

## Tiles Pro

- `P0_Obstacle_Item_Set_v2`
  - source id: `60fcef1c-4ed4-4b55-9f5f-e1f935a02976`
  - path: `tiles_pro_60fcef1c/tile_0.png` ... `tile_7.png`
  - usage:
    - `tile_0`~`tile_3`: obstacles
    - `tile_4`~`tile_7`: collectibles

## 任務失敗紀錄

- `sidescroller tileset` failed once:
  - id: `7077c139-230a-4951-a2ea-abd961f42d85`
  - reason: server returned no tiles

## 動畫任務

- queued:
  - character: `8f9a1d13-bbe5-40c4-886d-8e4ce87652e5`
  - animation: `hero_run_v2` (`running-8-frames`)
- note:
  - server reported concurrent job slot limit, other animations需等待此批完成再送。
