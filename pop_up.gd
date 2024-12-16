extends TextureRect


var cb1
var cb2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func init(title, text, button1, button2, callback1, callback2):
	$Title.text = title
	$Text.text = text
	$HFlowContainer/Button1/Label.text = button1
	$HFlowContainer/Button2/Label.text = button2
	cb1 = callback1
	cb2 = callback2


func _on_button_1_pressed() -> void:
	if cb1:
		cb1.call()


func _on_button_2_pressed() -> void:
	if cb2:
		cb2.call()
