extends Node

var current_tile_map_bounds: Array[Vector2]
signal tile_map_bounds_changed(bounds: Array[Vector2])

func change_tile_map_bounds(bounds: Array[Vector2]) -> void:
	current_tile_map_bounds = bounds
	tile_map_bounds_changed.emit(bounds)
