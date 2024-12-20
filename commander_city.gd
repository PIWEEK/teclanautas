extends TextureRect

@export var num = 0

var alive = true
var alive_texture
var ruins_texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func kill():
	print ("killed!")
	if alive:
		$Explosion.visible = true
		await get_tree().create_timer(1.0).timeout
		$Explosion.visible = false
		texture = $Ruins.texture
		alive = false

func reset():
	texture = $City.texture
	alive = true
	$Explosion.visible = false
