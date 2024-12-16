extends Node2D

signal destroyed(word)
signal letter_failed

var active = false
var word = ""
var normalized_word

var alive = true

var pos = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func activate():
	active = true

func set_word(new_word):
	word = new_word
	normalized_word = Globals.normalize(word)
	$name/Label.text = "[center]" + word + "[/center]"

func update_label():
	$name/Label.text = "[center]" + "[color=#FF0000]" + word.substr(0, pos) + "[/color]" + word.substr(pos) + "[/center]"

func add_letter(letter):
	if letter == normalized_word[pos]:
		pos += 1
	else:
		pos = 0
		letter_failed.emit()

	update_label()
	if pos == len(word):
		destroy();


func destroy():
	active = false
	alive = false
	$Explosion.visible = true
	destroyed.emit(word)