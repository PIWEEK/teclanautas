extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Globals.clear_config()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_mission_selected(scene: Variant) -> void:
	$Sound.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(scene)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()
			if event.keycode == KEY_1:
				_on_mission_selected("res://commander.tscn")
			if event.keycode == KEY_2:
				$Sound.play()
				_on_mission_selected("res://invaders.tscn")
			if event.keycode == KEY_3:
				$Sound.play()
				_on_mission_selected("res://scroller.tscn")
