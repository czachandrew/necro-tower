extends PathFollow2D

signal died(world_pos: Vector2) # this broadcasts the location of where a unit died 


@export var speed: float = 100.0 
@export var max_hp: int = 30

var hp: int
var alive := true
var lane: Path2D

@onready var spr: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Area2D

func _ready() -> void: 
	loop = false
	lane = get_parent()
	hp = max_hp
	spr.flip_h = true
	spr.play("s_walk")
	hurtbox.add_to_group("enemy_hurtbox")
	if not hurtbox.input_event.is_connected(_on_hurtbox_input_event):
		hurtbox.input_event.connect(_on_hurtbox_input_event)
	print("Enemy ready: ", get_instance_id(), " path=", get_path())
	
func _process(delta: float) -> void:
	if !alive: 
		return
	progress += speed * delta
	if progress >= lane.curve.get_baked_length():
		queue_free()
		
func take_damage(damage: int) -> void: 
	print("we are taking some damage", damage)
	if not alive:
		return
	hp -= damage
	if hp <= 0:
		_die()
		
func _die() -> void:
	alive = false
	hurtbox.monitoring = false 
	hurtbox.set_deferred("monitorable", false)
	spr.play("s_death")
	emit_signal("died", global_position)
	await spr.animation_finished
	queue_free()
		
func _on_hurtbox_input_event(_vp, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			take_damage(10)
