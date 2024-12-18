extends Area2D


var rotation_speed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var num = randi_range(1,4)
	var image = Image.load_from_file("res://img/planet" + str(num) +".png")
	$TextureRect.texture = ImageTexture.create_from_image(image)
	rotation_speed = randi_range(-15,15)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TextureRect.rotation_degrees += rotation_speed * delta
