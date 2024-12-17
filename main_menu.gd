extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mission_selected(name: Variant) -> void:
	get_tree().change_scene_to_file(name)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()
			if event.keycode == KEY_2:
				get_tree().change_scene_to_file("res://invaders.tscn")
