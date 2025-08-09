extends PathFollow2D


@export var speed: float = 100.0 

var lane: Path2D

func _ready() -> void: 
	lane = get_parent()
	
func _process(delta: float) -> void:
	progress += speed * delta
	if progress >= lane.curve.get_baked_length():
		queue_free()
