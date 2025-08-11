extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var lanes: Node2D = $Lanes

func _ready() -> void:
	# Ensure timer is configured and running
	spawn_timer.stop()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false

	# Nuke any existing connections (editor or hot-reload) then connect once
	for c in spawn_timer.timeout.get_connections():
		spawn_timer.timeout.disconnect(c.callable)
	spawn_timer.timeout.connect(_on_spawn_timeout)

	spawn_timer.start()

	add_to_group("spawners")
	_log_timer_state("ready")

func _on_spawn_timeout() -> void:
	var before := _count_followers(0)
	_log_timer_state("timeout")
	_spawn_enemy_in_lane(0)
	var after := _count_followers(0)
	print("followers this tick: +", after - before, " (total=", after, ")")
	
func _count_followers(lane_index:int) -> int:
	var lane := $Lanes.get_child(lane_index) as Path2D
	var n := 0
	for c in lane.get_children():
		if c is PathFollow2D:
			n += 1
	return n 


func _spawn_enemy_in_lane(lane_index: int) -> void:
	var lane: Path2D = lanes.get_child(lane_index) as Path2D
	var enemy: PathFollow2D = enemy_scene.instantiate() as PathFollow2D
	enemy.progress = 0.0
	enemy.add_to_group("enemies")
	lane.add_child(enemy)

func _log_timer_state(tag: String) -> void:
	if !is_instance_valid(spawn_timer):
		print("[%s] spawn_timer is invalid" % tag)
		return

	var conns := spawn_timer.timeout.get_connections()
	

func _count_timers_named(name_wanted: String) -> int:
	var count := 0
	_walk(get_tree().root, func(n):
		if n is Timer and n.name == name_wanted:
			count += 1
	)
	return count

func _walk(n: Node, f: Callable) -> void:
	f.call(n)
	for c in n.get_children():
		_walk(c, f)
