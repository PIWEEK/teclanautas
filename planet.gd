extends Area2D


var rotation_speed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var planet = [$P1, $P2, $P3, $P4].pick_random()
	$TextureRect.texture = planet.texture
	rotation_speed = randi_range(-15,15)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TextureRect.rotation_degrees += rotation_speed * delta
