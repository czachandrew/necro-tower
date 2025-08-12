extends Area2D

class_name Projectile

@export var speed: float = 300.0
@export var lifetime: float = 2.0

var _vel: Vector2 = Vector2.ZERO
var _damage: int = 5

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func launch(dir: Vector2, dmg: int) -> void:
	_vel = dir.normalized() * speed
	_damage = dmg
	rotation = dir.angle()
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()
		
func _physics_process(delta: float) -> void:
	position += _vel * delta

func _on_area_entered(area: Area2D) -> void: 
	if area.is_in_group("enemy_hurtbox"):
		var enemy := area.get_parent()
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.take_damage(_damage)
		queue_free()
