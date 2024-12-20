extends Node2D

const max_width = 800

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_progress(percent):
	$Progress.size.x = percent * max_width
	$Ship.position.x = percent * max_width - 25
