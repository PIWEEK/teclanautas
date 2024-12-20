extends Node2D


var target = Vector2()
var target_num
var speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_target(t, num, s):
	target_num = num
	target = t
	look_at(target)
	speed = s
