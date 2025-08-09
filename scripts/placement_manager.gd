extends Node2D

@export var tile_map_layer: TileMapLayer
@export var tower_container: Node2D
@export var starting_gold: int = 100
var gold: int

@onready var gold_label: Label = $"CanvasLayer/GoldLabel"
@onready var tower_cost: int = 20

func _ready() -> void: 
	gold = starting_gold
	_update_gold_ui()
	
func _update_gold_ui() -> void: 
	gold_label.text = "Gold %d" % gold

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		
		if gold < tower_cost: 
			# flash the label 
			gold_label.add_theme_color_override("font_color", Color.RED)
			return
		gold_label.remove_theme_color_override("font_color")
		
		var world_pos: Vector2 = get_global_mouse_position()
		var local_pos: Vector2 = tile_map_layer.to_local(world_pos)
		var cell: Vector2i = tile_map_layer.local_to_map(local_pos)
		var cell_origin_local:Vector2 = tile_map_layer.map_to_local(cell)
		var tile_size: Vector2i = tile_map_layer.tile_set.tile_size
		var half_tile: Vector2 = Vector2(tile_size) * 0.5
		var cell_center_local: Vector2 = cell_origin_local + half_tile
		var cell_center_global: Vector2 = tile_map_layer.to_global(cell_center_local)
		
		gold -= tower_cost
		_update_gold_ui()
		place_tower(cell, cell_center_global)

func place_tower(cell: Vector2i, pos: Vector2) -> void:
	print("🗡️ Placing tower at cell %s (world %s)" % [cell, pos])
	var tower = Sprite2D.new()
	tower.texture  = preload("res://assets/towers/PlaceForTower1.png")
	tower.position = pos
	tower_container.add_child(tower)
