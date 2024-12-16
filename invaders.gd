extends Node2D

var ufo_scene: PackedScene = preload("res://ufo.tscn")
var ufos = []
var ufos_by_word = Dictionary()
var writing_to_ufo
var moving_ufo
var moving_ufo_row = 0
var playing = false

var current_level

const ROW_SIZE = 250
const UFO_WIDTH = 250
const UFO_HEIGTH = 288
const LEFT = 0
const RIGHT = 2560 - UFO_WIDTH
var ufo_speed = 500


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart()

func restart():
	current_level = 0
	next_level()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				exit_to_menu()
				#get_tree().quit()
			elif playing:
				var character = Globals.remove_accents(char(event.unicode))
				if writing_to_ufo != null and writing_to_ufo.alive:
					writing_to_ufo.add_letter(character)
				else:
					for ufo in ufos:
						if ufo.alive and ufo.normalized_word[0] == character:
							ufo.add_letter(character)
							writing_to_ufo = ufo
							break


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		move_ufo(delta)

func move_ufo(delta):
	var target = Vector2(moving_ufo.position.x, moving_ufo.position.y)
	if playing and moving_ufo != null and moving_ufo.active:
		if moving_ufo_row % 2 == 0: #move left
			if moving_ufo.position.x <= LEFT: #move down
				target.y = (moving_ufo_row + 1) * ROW_SIZE
				if moving_ufo.position.y >= target.y: #advance_row
					moving_ufo_row += 1
			else:
				target.x = 0
		else: #move right
			if moving_ufo.position.x >= RIGHT: #move down
				target.y = (moving_ufo_row + 1) * ROW_SIZE
				if moving_ufo.position.y >= target.y: #advance_row
					moving_ufo_row += 1
			else:
				target.x = RIGHT

		if (moving_ufo.position.x > target.x):
			moving_ufo.position.x = max(LEFT, moving_ufo.position.x - delta * ufo_speed)
		elif (moving_ufo.position.x < target.x):
			moving_ufo.position.x = min(RIGHT, moving_ufo.position.x + delta * ufo_speed)

		if (moving_ufo.position.y < target.y):
			moving_ufo.position.y = min(target.y, moving_ufo.position.y + delta * ufo_speed)

		check_end()


func check_end():
	if moving_ufo_row == 4 and moving_ufo.position.x < $City.position.x + $City.size.x / 2:
		playing = false
		$Explosion.visible = true

		for ufo in ufos:
			delete_ufo(ufo)

		$PopUp.init("Has perdido", "[center][b]¿Quieres volver a jugar?[/b][/center]", "Salir", "Jugar", exit_to_menu, restart)
		$PopUp.visible = true


func create_ufos():
	var x = 10
	var y = 10
	var num_ufos
	var word_size
	match current_level:
		1:
			num_ufos = 3
			word_size = 2
			ufo_speed = 250
		2:
			num_ufos = 4
			word_size = 2
			ufo_speed = 250
		3:
			num_ufos = 6
			word_size = 2
			ufo_speed = 250
		4:
			num_ufos = 8
			word_size = 2
			ufo_speed = 250
		5:
			num_ufos = 3
			word_size = 3
			ufo_speed = 300
		6:
			num_ufos = 4
			word_size = 3
			ufo_speed = 350
		6:
			num_ufos = 6
			word_size = 3
			ufo_speed = 400
		6:
			num_ufos = 8
			word_size = 3
			ufo_speed = 500
		7:
			num_ufos = 3
			word_size = 4
			ufo_speed = 500
		8:
			num_ufos = 4
			word_size = 4
			ufo_speed = 600
		9:
			num_ufos = 6
			word_size = 4
			ufo_speed = 600
		10:
			num_ufos = 8
			word_size = 4
			ufo_speed = 700
		11:
			num_ufos = 3
			word_size = 5
			ufo_speed = 700
		12:
			num_ufos = 4
			word_size = 5
			ufo_speed = 750
		13:
			num_ufos = 6
			word_size = 5
			ufo_speed = 800
		14:
			num_ufos = 8
			word_size = 5
			ufo_speed = 850

	for i in range(num_ufos):
		create_ufo(Vector2(x + i * 300, y), word_size)

func create_ufo(position, word_size):
	var word = Globals.next_word(word_size)
	var ufo: Node = ufo_scene.instantiate()
	ufo.set_word(word)
	ufo.position = position

	ufos.append(ufo)
	ufos_by_word[word] = ufo

	ufo.connect("destroyed", _on_ufo_destroyed)
	ufo.connect("letter_failed", _on_letter_failed)

	add_child(ufo)

func _on_ufo_destroyed(word):
	var ufo = ufos_by_word[word]
	if ufo == writing_to_ufo:
		writing_to_ufo = null

	$LaserBeam2D.target_position.x = ufo.position.x + UFO_WIDTH / 2 - $LaserBeam2D.position.x
	$LaserBeam2D.target_position.y = ufo.position.y + UFO_HEIGTH / 2 - $LaserBeam2D.position.y
	$LaserBeam2D.set_is_casting(true)

	await get_tree().create_timer(1.0 - (ufo_speed / 1500.0)).timeout

	$LaserBeam2D.set_is_casting(false)
	delete_ufo(ufo)


func delete_ufo(ufo):
	if ufo != null:
		ufo.disconnect("destroyed", _on_ufo_destroyed)
		ufo.disconnect("letter_failed", _on_letter_failed)
		ufos.erase(ufo)
		ufos_by_word.erase(ufo)
		ufo.queue_free()
		if len(ufos) == 0:
			moving_ufo = null
			win()
		elif ufo == moving_ufo:
			moving_ufo = ufos[0]
			moving_ufo.activate()
			moving_ufo_row = 0

func win():
	playing = false
	$PopUp.init("¡Has ganado!", "[center][b]Nivel "+str(current_level)+"[/b][/center]", "Salir", "Siguiente", exit_to_menu, next_level)
	$PopUp.visible = true

func exit_to_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func next_level():
	for ufo in ufos:
		delete_ufo(ufo)

	current_level += 1
	create_ufos()
	moving_ufo_row = 0
	moving_ufo = ufos[0]
	moving_ufo.activate()
	$PopUp.visible = false
	$Explosion.visible = false
	playing = true


func _on_letter_failed():
	writing_to_ufo = null
