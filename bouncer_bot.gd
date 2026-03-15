extends Node2D

# =====================================================
# SCENES
# =====================================================
var character_scene: PackedScene = preload("res://character.tscn")
var level_popup_scene: PackedScene = preload("res://level_screen.tscn")
var game_over_scene: PackedScene = preload("res://game_over.tscn")

# =====================================================
# AUDIO
# =====================================================
@onready var click_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var wrong_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D3
@onready var level_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D4

# =====================================================
# POSITIONING
# =====================================================
@export var queue_x: float = 800.0
@export var queue_bottom_y: float = 850.0
@export var queue_spacing: float = 75.0
@export var spawn_offset_y: float = -800.0

# =====================================================
# DIFFICULTY
# =====================================================
@export var base_spawn_interval: float = 1.0

const CHARACTERS_PER_LEVEL := 25
const MAX_QUEUE_SIZE := 10

# =====================================================
# GAME STATE
# =====================================================
var queue: Array[Node2D] = []
var lives := 3
var level := 1
var score := 0
var processed_count := 0
var spawn_interval := 1.0
var game_over := false
var spawning := true

# =====================================================
# UI
# =====================================================
@onready var rule_label: Label = $TopHud/Padding/Content/PanelContainer/RuleLabel
@onready var lives_label: Label = $TopHud/Padding/Content/PanelContainer2/LivesLabel
@onready var level_label: Label = $TopHud/Padding/Content/PanelContainer3/LevelLabel
@onready var score_label: Label = $TopHud/Padding/Content/PanelContainer4/ScoreLabel
@onready var feedback_label: Label = $FeedbackLabel

@onready var allow_button: Button = $AllowButton
@onready var block_button: Button = $BlockButton


# =====================================================
# READY
# =====================================================
func _ready():

	randomize()

	spawn_interval = base_spawn_interval

	update_lives_ui()
	update_level_ui()
	update_score_ui()

	show_level_popup()

	start_spawn_loop()


# =====================================================
# SPAWN LOOP
# =====================================================
func start_spawn_loop():

	while not game_over:

		if spawning:

			await get_tree().create_timer(spawn_interval).timeout

			if queue.size() >= MAX_QUEUE_SIZE:
				trigger_game_over()
				return

			spawn_character()

		else:
			await get_tree().process_frame


# =====================================================
# SPAWN CHARACTER
# =====================================================
func spawn_character():

	var character: Node2D = character_scene.instantiate()
	add_child(character)

	character.scale = Vector2(1.2, 1.2)
	character.global_position = Vector2(queue_x, queue_bottom_y + spawn_offset_y)

	var shadow := create_shadow()
	add_child(shadow)

	shadow.global_position = character.global_position + Vector2(0,22)
	shadow.z_index = character.z_index - 1

	character.set_meta("shadow", shadow)

	queue.append(character)

	update_queue_positions()


# =====================================================
# SHADOW
# =====================================================
func create_shadow() -> Sprite2D:

	var shadow := Sprite2D.new()

	var img := Image.create(40,12,false,Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))

	for x in range(40):
		for y in range(12):

			var dx = (x-20)/20.0
			var dy = (y-6)/6.0

			if dx*dx + dy*dy <= 1.0:
				img.set_pixel(x,y,Color(0,0,0,0.28))

	var tex := ImageTexture.create_from_image(img)

	shadow.texture = tex

	return shadow


# =====================================================
# QUEUE POSITION
# =====================================================
func update_queue_positions():

	for i in range(queue.size()):

		var character = queue[i]

		var target = Vector2(
			queue_x,
			queue_bottom_y - i * queue_spacing
		)

		var tween = get_tree().create_tween()
		tween.tween_property(character,"global_position",target,0.3)

		var shadow = character.get_meta("shadow")

		if shadow:

			var tween2 = get_tree().create_tween()
			tween2.tween_property(
				shadow,
				"global_position",
				target + Vector2(0,22),
				0.3
			)


# =====================================================
# BUTTONS
# =====================================================
func _on_allow_button_pressed():

	click_sound.play()
	process_decision(true)


func _on_block_button_pressed():

	click_sound.play()
	process_decision(false)


# =====================================================
# DECISION LOGIC
# =====================================================
func process_decision(allowed: bool):

	if game_over or queue.is_empty():
		return

	var front = queue[0]

	var is_invalid = front.has_red

	var correct = false

	if allowed and not is_invalid:
		correct = true
	elif not allowed and is_invalid:
		correct = true


	if correct:

		feedback_label.text = "Correct!"

		var points = 10 + (level * 5)
		score += points

		update_score_ui()

	else:

		feedback_label.text = "Wrong!"

		lives -= 1
		update_lives_ui()

		play_wrong_sound()


	remove_front_character()

	processed_count += 1

	check_level_up()

	if lives <= 0:
		trigger_game_over()


func remove_front_character():

	var front = queue[0]

	var shadow = front.get_meta("shadow")

	if shadow:
		shadow.queue_free()

	front.queue_free()

	queue.pop_front()

	update_queue_positions()


# =====================================================
# WRONG SOUND
# =====================================================
func play_wrong_sound():

	for i in range(3):
		wrong_sound.play()
		await wrong_sound.finished


# =====================================================
# LEVEL SYSTEM
# =====================================================
func check_level_up():

	if level < 10 and processed_count >= CHARACTERS_PER_LEVEL:

		level += 1
		processed_count = 0
		lives = 3

		update_lives_ui()
		update_level_ui()

		increase_difficulty()

		show_level_popup()


func increase_difficulty():

	if level == 2:
		spawn_interval = 0.5

	elif level >= 3:
		spawn_interval = max(0.1, spawn_interval - 0.05)

	if level == 10:
		feedback_label.text = "ENDLESS MODE"
	else:
		feedback_label.text = "LEVEL %d!" % level


# =====================================================
# LEVEL POPUP
# =====================================================
func show_level_popup():

	spawning = false

	if level_sound:
		level_sound.play()

	var popup = level_popup_scene.instantiate()

	popup.level = level

	add_child(popup)

	await popup.finished

	spawning = true


# =====================================================
# UI
# =====================================================
func update_lives_ui():

	lives_label.text = "Lives: %d" % lives


func update_level_ui():

	level_label.text = "Level: %d" % level


func update_score_ui():

	score_label.text = "Score: %d" % score


# =====================================================
# GAME OVER
# =====================================================
func trigger_game_over():

	game_over = true
	spawning = false

	var popup = game_over_scene.instantiate()

	add_child(popup)
