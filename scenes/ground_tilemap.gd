extends TileMapLayer

@export var wall_tilemap: TileMapLayer

# Delete navigation for tiles which have a tile in the above fence tilemap.

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return coords in wall_tilemap.get_used_cells_by_id(0)
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in wall_tilemap.get_used_cells_by_id(0):
		tile_data.set_navigation_polygon(0, null)
