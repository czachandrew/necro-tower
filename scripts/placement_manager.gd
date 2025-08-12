extends Node2D

@export var tile_map_layer: TileMapLayer
@export var tower_scene: PackedScene
@export var tower_container: Node2D
@export var starting_gold: int = 100
@export var projectile_container: NodePath
var gold: int

@onready var gold_label: Label = $"CanvasLayer/GoldLabel"
@onready var tower_cost: int = 20
@onready var ghost: Sprite2D = $PlacementGhost
@onready var no_build_layer: TileMapLayer = $NoBuild

var occupied := {} # Dictionary[Vector2i] -> bool

func _ready() -> void: 
	gold = starting_gold
	ghost.self_modulate = Color(1,1,1,0.6)
	_update_gold_ui()
	
func _update_gold_ui() -> void: 
	gold_label.text = "Gold %d" % gold
	
func _can_build(cell: Vector2i) -> bool: 
	if occupied.has(cell):
		return false
	var td := no_build_layer.get_cell_tile_data(cell)
	if td != null: 
		return false
	return gold >= tower_cost

func _process(_dt: float) -> void:
	# Snap ghost to grid
	var world: Vector2   = get_global_mouse_position()
	var local: Vector2   = tile_map_layer.to_local(world)
	var cell:  Vector2i  = tile_map_layer.local_to_map(local)
	var origin_l: Vector2 = tile_map_layer.map_to_local(cell)
	var half:   Vector2   = Vector2(tile_map_layer.tile_set.tile_size) * 0.5
	var pos:    Vector2   = tile_map_layer.to_global(origin_l + half)
	ghost.global_position = pos

	# Validity & tint
	var valid := _can_build(cell)
	if valid:
		ghost.modulate = Color(1,1,1,0.6)
	else:
		ghost.modulate = Color(1,0.3,0.3,0.6)
	#ghost.modulate = valid ? Color(1,1,1,0.6) : Color(1,0.3,0.3,0.6)

	# Place on LMB
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and valid:
		_place_tower(cell, pos)

func _place_tower(cell: Vector2i, pos: Vector2) -> void:
	print("🗡️ Placing tower at cell %s (world %s)" % [cell, pos])
	var tower := tower_scene.instantiate() as Node2D
	tower.projectile_container = projectile_container
	tower.global_position = pos
	tower_container.add_child(tower)
	occupied[cell] = true
