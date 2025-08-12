extends Node2D


@export var fire_rate: float = 0.8
@export var damage: int = 8 
@export var projectile_scene: PackedScene
@export var projectile_container: NodePath

@onready var range = $Range
@onready var fire_timer = $FireRateTimer
# @onready var anim:AnimatedSprite2D = $AnimatedSprite2D

var _targets: Array[Area2D] = []

func _ready() -> void: 
	if not range.area_entered.is_connected(_on_area_entered):
		range.area_entered.connect(_on_area_entered)
	if not range.area_exited.is_connected(_on_area_exited):
		range.area_exited.connect(_on_area_exited)
	if not fire_timer.timeout.is_connected(_on_fire_timeout):
		fire_timer.timeout.connect(_on_fire_timeout)
		
	fire_timer.stop()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.start()
		
func _on_area_entered(area:Area2D) -> void:
	print("enemy has entered in range")
	if area.is_in_group("enemy_hurtbox"):
		print("Hurtbox group evaluation was successful")
		_targets.append(area)
		
func _on_area_exited(area:Area2D) -> void:
	_targets.erase(area)
	
func _on_fire_timeout() -> void: 
	_prune_targets()
	var target := _acquire_target()
	if target == null:
		return 
	_fire_at(target)
	
func _fire_at(target_hurtbox: Area2D) -> void:
	var projectile := projectile_scene.instantiate() as Area2D
	var container := get_node_or_null(projectile_container)
	if container == null: 
		container = get_tree().current_scene
	projectile.global_position = global_position
	container.add_child(projectile)
	
	var enemy := target_hurtbox.get_parent() as PathFollow2D
	var v_tgt: Vector2 = _enemy_velocity(enemy)
	var dir: Vector2 = _lead_direction(projectile.global_position, target_hurtbox.global_position, v_tgt, projectile.speed)
	
	#var dir := (target_hurtbox.global_position - projectile.global_position)
	projectile.call("launch", dir, damage)
	
func _enemy_velocity(enemy:PathFollow2D) -> Vector2: 
	var lane: Path2D = enemy.get_parent()
	var L := lane.curve.get_baked_length()
	var eps := 4.0
	var p0 := lane.curve.sample_baked(clamp(enemy.progress, 0.0, L))
	var p1 := lane.curve.sample_baked(clamp(enemy.progress + eps, 0.0, L))
	var dir := (p1 - p0).normalized()
	return dir * enemy.speed
		
		
func _lead_direction(shooter_pos: Vector2, target_pos: Vector2, target_vel: Vector2, proj_speed: float) -> Vector2:
	var d :Vector2 = target_pos - shooter_pos
	var a :float = target_vel.dot(target_vel) - proj_speed * proj_speed
	var b :float = 2.0 * d.dot(target_vel)
	var c :float = d.dot(d)
	
	var t: float = 0.0
	if abs(a) < 0.001:
		if abs(b) > 0.001:
			t = 0.0
		else: 
			t = -c / b
		
	else: 
		var disc := b*b - 4.0*a*c
		if disc < 0.0:
			return d
		var sqrt_disc :float = sqrt(disc)
		var t1 :float = (-b + sqrt_disc) / (2.0*a)
		var t2 :float = (-b - sqrt_disc) / (2.0*a)
		t = min(t1,t2)
		if t < 0.0: t = max(t1, t2)
		if t < 0.0: return d
	t = max(t, 0.0)
	var aim_point: Vector2 = target_pos + target_vel * t
	return aim_point - shooter_pos
	
func _prune_targets() -> void:
	_targets = _targets.filter(func(a):
		return is_instance_valid(a) and is_instance_valid(a.get_parent()))
	
func _acquire_target() -> Area2D:
	for a in _targets:
		if is_instance_valid(a) and is_instance_valid(a.get_parent()):
			return a 
	return null
