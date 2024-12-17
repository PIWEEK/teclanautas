extends TextureRect

@export var current_game = ""
var level_scene: PackedScene = preload("res://level.tscn")
signal level_select(level)
var cb1
var cb2

var max_level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_level = Globals.config.get_value(current_game, "level", 1)
	create_levels()
	level_select.emit(max_level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init(callback1, callback2):
	cb1 = callback1
	cb2 = callback2

func create_levels():
	for i in range(40):
		var level: Node = level_scene.instantiate()
		var locked = i >= max_level
		level.init(i+1, locked)
		level.connect("level_select", _on_level_select)
		if locked:
			level.disabled = true
			level.focus_mode = FOCUS_NONE

		$LevelsContainer.add_child(level)
		level.grab_focus()

func _on_level_select(level):
	level_select.emit(level)


func _on_button_1_pressed() -> void:
	if cb1:
		cb1.call()


func _on_button_2_pressed() -> void:
	if cb2:
		cb2.call()
