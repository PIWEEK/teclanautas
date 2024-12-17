extends Button

signal level_select(level)
var _level
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init(level, locked):
	_level = level
	$Label.text = str(level)
	$Label.visible = not locked
	$Lock.visible = locked

func _on_pressed() -> void:
	level_select.emit(_level)
