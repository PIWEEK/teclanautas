extends TextureRect

var star_full = preload("res://img/star.png")
var star_empty = preload("res://img/star2.png")

var cb1
var cb2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init(title, you, best, stars, callback1, callback2):
	if stars == 0:
		$Star1.texture = star_empty
		$Star2.texture = star_empty
		$Star3.texture = star_empty
	if stars == 1:
		$Star1.texture = star_full
		$Star2.texture = star_empty
		$Star3.texture = star_empty
	elif stars == 2:
		$Star1.texture = star_full
		$Star2.texture = star_full
		$Star3.texture = star_empty
	elif stars == 3:
		$Star1.texture = star_full
		$Star2.texture = star_full
		$Star3.texture = star_full

	$Title.text = title
	$You.text = you
	$Best.text = best

	cb1 = callback1
	cb2 = callback2


func _on_button_1_pressed() -> void:
	if cb1:
		cb1.call()


func _on_button_2_pressed() -> void:
	if cb2:
		cb2.call()
