extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
var spawn_timer:float = 4.0 

@onready var lanes: Node2D = $Lanes
@onready var enemy_container: Node2D = $EnemyContainer

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_enemy_in_lane(0)
		
func _spawn_enemy_in_lane(lane_index: int) -> void:
	var lane_node: Path2D = lanes.get_child(lane_index) as Path2D
	var enemy: PathFollow2D = enemy_scene.instantiate() as PathFollow2D
	
	enemy.progress = 0
	lane_node.add_child(enemy)
	enemy_container.add_child(enemy)
	
