extends TextureRect

@export var num_shadow=0
var word = "."
var pos = 0
var alive = true

signal finished(num)
signal letter_failed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_word(new_word):
	word = new_word
	pos = 0
	$Label.text = "[center]" + word + "[/center]"

func update_label():
	$Label.text = "[center]" + "[color=#FF0000]" + word.substr(0, pos) + "[/color]" + word.substr(pos) + "[/center]"

func add_letter(letter):
	if letter == word[pos]:
		pos += 1
	else:
		pos = 0
		letter_failed.emit()

	update_label()
	if pos == len(word):
		finished.emit(num_shadow)
