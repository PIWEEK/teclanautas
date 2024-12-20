extends Node2D


var score_up_scene: PackedScene = preload("res://score_up.tscn")
var planet_scene: PackedScene = preload("res://planet.tscn")

var space_speed = 125
var ship_speed = 500
const ship_height = 240
const margin_to_stargate = 1200

var shadows = []
var playing = false
var ship_alive = false

var writing_to = null
var ship_target = Vector2()
var score = 0
var current_level = 0

var space_items = []
var word_size = 2

var level_width = 0
var advance = 0

var levels = [
	[
		"      S  P              P     ",
		"  S P           P            G",
		"S      P  S     S     P   S   ",
		"     P      S      S P   S    ",
		"            P           S     "
	],
	[
		"P  S  P   S   P      P     P  ",
		"       S      P      S    S G",
		"P                P     S    ",
		"     S  P  P       S  P       ",
		"S   P    P   S      P         "
	],
	[
		"      S      P   S  P  S  P   ",
		"S        P      S      P     G",
		"   S   P    P  S P            ",
		" P       S          S  P      ",
		"     P       S          P S   "
	],
	[
		"   S  P  P   P  P    S        ",
		"P        P           P    S  G",
		"       S P    P   S           ",
		" S P          S       S   P   ",
		"  P      P S P         S P    ",
	],
	[
		"S P                     S P   ",
		"   S P               S P   S G",
		"      S P         S P         ",
		"         S P   S P            ",
		"            S P               ",
	],
	[
		"P P P P P P P P P P P P P P P ",
		"   S P   S P   S P   S P   S G",
		"S P                        P  ",
		"      S P   S P   S P   S P   ",
		"P P P P P P P P P P P P P P P ",
	],
	[
		"S  P     P    P   S       P   ",
		"   S    P  P                 G",
		" P    S P          P  S       ",
		"   P         S  P  P      P   ",
		"  P  P  S P SP        P SP    ",
	],
	[
		"P     P P PP   P    P    P    ",
		"P   P     P   P   P   P      G",
		"P   P  SPSPSPSPSPSPSPSPSPS    ",
		"    P   P   P   P   P   P     ",
		"P   P     P   P    P      P   ",
	]
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shadows = [$Shadow1, $Shadow2, $Shadow3, $Shadow4, $Shadow5]
	$Ship/Anim.play("default")
	$Ship.visible = false

	$LevelSelection.init(exit_to_menu, start)
	$LevelSelection.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		move_space(delta)

	if ship_alive:
		Globals.move($Ship, ship_target, ship_speed, delta)


func move_space(delta):
	var inc = delta * space_speed

	# background
	$Bg1.position.x -= inc
	$Bg2.position.x -= inc

	if $Bg1.position.x + $Bg1.size.x * 2 < -100:
		$Bg1.position.x += $Bg1.size.x * 4

	if $Bg2.position.x + $Bg2.size.x * 2 < -100:
		$Bg2.position.x += $Bg2.size.x * 4

	# items
	var to_delete = []
	for item in space_items:
		item.position.x -= inc
		if item.position.x < -500:
			to_delete.append(item)

	to_delete.map(delete_item)


	# stargate
	$Stargate1.position.x -= inc
	$Stargate2.position.x -= inc
	if $Stargate2.position.distance_to($Ship.position) < margin_to_stargate:
		start_end_animation()

	# progress_bar

	advance += inc
	var percent = advance / level_width
	$ProgressBar.set_progress(percent)


func delete_item(item):
	if item != null:
		space_items.erase(item)
		item.queue_free()
		$Planets.remove_child(item)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				exit_to_menu()
				#get_tree().quit()
			elif playing:
				var character = char(event.unicode)
				if writing_to != null and writing_to.alive:
					writing_to.add_letter(character)
				else:
					for shadow in shadows:
						if shadow.alive and shadow.word[0] == character:
							shadow.add_letter(character)
							writing_to = shadow
							break
					if writing_to == null:
						_on_letter_failed()

func start():
	while len(space_items) > 0:
		delete_item(space_items[0])


	$LevelSelection.visible = false
	$WinPopup.visible = false
	$Ship.visible = true
	$Ship/Explosion.visible = false
	$Progress.visible = true
	$ProgressBar.visible = true

	load_level()

	for shadow in shadows:
		shadow.alive = true
		update_shadow(shadow)
		shadow.visible = true

	$Shadow3.visible = false
	$Shadow3.alive = false

	$Ship.position.x = $Shadow3.position.x
	$Ship.position.y = $Shadow3.position.y
	ship_target.x = $Ship.position.x
	ship_target.y = $Ship.position.y
	score = 0
	writing_to = null

	ship_alive = true
	playing = true



func create_item(scene, x, y):
	var item: Node = scene.instantiate()
	space_items.append(item)
	item.position.x = x
	item.position.y = y
	$Planets.add_child(item)


func load_level():
	var column_size = 500
	var col_gap = 1500
	var l = current_level % 8
	word_size = 2 + round(current_level / 8)
	space_speed = 125 + current_level * 10
	ship_speed = 500 + 5 * current_level
	advance = 0

	var map = levels[l]

	for row in range(5):
		for col in range(len(map[row])):
			var x = col_gap + col * column_size
			var y = shadows[row].position.y
			var s = map[row][col]
			if s == "S":
				create_item(score_up_scene, x, y)
			elif s == "P":
				create_item(planet_scene, x, y)
			elif s == "G":
				$Stargate1.position.x = x
				$Stargate1.position.y = y

				$Stargate2.position.x = x + $Stargate1/Stargate1Img.size.x
				$Stargate2.position.y = y

				level_width = x - margin_to_stargate




func update_shadow(shadow):
	var letters = shadows.map(func(s): return s.word[0])
	var word = Globals.next_word(word_size, letters)
	shadow.set_word(word)

func _on_letter_failed():
	writing_to = null
	score -= 5
	$Progress/Score.text = str(score)
	$Error.play()

func exit_to_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_shadow_finished(num: Variant) -> void:
	writing_to = null
	ship_target.y = shadows[num].position.y
	for shadow in shadows:
		shadow.visible = true
		shadow.alive = true
	shadows[num].visible = false
	update_shadow(shadows[num])
	shadows[num].alive = false


func start_end_animation():
	playing = false
	for shadow in shadows:
		shadow.visible = false
	ship_target.x = $Stargate1.position.x
	ship_target.y = $Stargate1.position.y + $Stargate1/Stargate1Img.size.y / 2 - ship_height/2





func _on_stargate_1_area_entered(area: Area2D) -> void:
	if (area == $Ship):
		$AudioTeleport.play()
		$Stargate2/Stargate2Img/Warp.visible = true
		$Stargate2/Stargate2Img/Warp.play("default")


func _on_stargate_2_area_entered(area: Area2D) -> void:
	if (area == $Ship):
		$Ship.visible = false
		await get_tree().create_timer(1.0).timeout
		win()


func win():
	playing = false

	$Progress.visible = false
	$ProgressBar.visible = false

	var best_scores = []
	best_scores.resize(40)
	best_scores.fill(0)
	best_scores = Globals.config.get_value("scroller", "best_scores", best_scores)
	if best_scores[current_level]== 0 or (score > best_scores[current_level]):
		best_scores[current_level] = score
		Globals.config.set_value("scroller", "best_scores", best_scores)

	var stars = 1
	if score == 1000:
		stars = 3
	elif score > 700:
		stars = 2

	$WinPopup.init("¡Has ganado!", "Puntuación: " + str(score), "Mejor puntuación: " + str(best_scores[current_level]), stars, current_level+1, exit_to_menu, next_level)
	$WinPopup.visible = true

	var max_level = Globals.config.get_value("scroller", "level", -1)
	if current_level+1 > max_level:
		Globals.config.set_value("scroller", "level", current_level + 1)
	Globals.save_config()

func next_level():
	current_level = min(current_level+1, 39)
	start()


func _on_ship_area_entered(area: Area2D) -> void:
	print(area.collision_layer)
	if area.collision_layer == 2: #score_up
		score += 100
		$Progress/Score.text = str(score)
		delete_item(area)
		$AudioScoreUp.play()
	elif area.collision_layer == 4: #planet
		lose()


func lose():
	playing = false
	ship_alive = false
	for shadow in shadows:
		shadow.visible = false

	$AudioExplosion.play()

	$Ship/Explosion.visible = true

	$WinPopup.init("Has perdido :(", "¿Quieres jugar otra vez?", "", 0, current_level+1, exit_to_menu, start)
	$WinPopup.visible = true


func _on_level_selection_level_select(level: Variant) -> void:
	current_level = level
