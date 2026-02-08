extends Node2D

# ==================================================
# CONFIG
# ==================================================
var character_scene: PackedScene = preload("res://character.tscn")

@export var entry_x: float = -120.0
@export var queue_start_x: float = 900.0
@export var queue_y: float = 300.0
@export var queue_spacing: float = 70.0

@export var base_spawn_interval: float = 1.5
@export var spawn_speed_increase: float = 0.15
@export var min_spawn_interval: float = 0.4

const CHARACTERS_PER_LEVEL: int = 25
const MAX_QUEUE_SIZE: int = 10

# ==================================================
# STATE
# ==================================================
var queue: Array = []
var lives: int = 3
var level: int = 1
var processed_count: int = 0
var spawn_interval: float
var game_over: bool = false

# ==================================================
# UI REFERENCES
# ==================================================
@onready var feedback_label: Label = $FeedbackLabel
@onready var lives_label: Label = $LivesLabel
@onready var allow_button: Button = $AllowButton
@onready var block_button: Button = $BlockButton


# ==================================================
# LIFECYCLE
# ==================================================
func _ready() -> void:
	randomize()
	spawn_interval = base_spawn_interval
	update_lives_ui()
	start_spawn_loop()


# ==================================================
# SPAWN LOOP
# ==================================================
func start_spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout

		if game_over:
			return

		if queue.size() > MAX_QUEUE_SIZE:
			trigger_game_over()
			return

		spawn_character()


# ==================================================
# SPAWNING
# ==================================================
func spawn_character() -> void:
	var character = character_scene.instantiate()
	add_child(character)

	# Start off-screen (left)
	character.global_position = Vector2(entry_x, queue_y)

	# Assign traits
	if randf() < 0.5:
		character.traits["color"] = "red"
	else:
		character.traits["color"] = "blue"

	character.apply_traits()

	queue.append(character)
	update_queue_positions()


# ==================================================
# QUEUE POSITIONING + ANIMATION
# ==================================================
func update_queue_positions() -> void:
	for i in queue.size():
		var target_position = Vector2(
			queue_start_x - i * queue_spacing,
			queue_y
		)
		animate_character_to(queue[i], target_position)


func animate_character_to(character: CanvasItem, target_position: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
		character,
		"global_position",
		target_position,
		0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# ==================================================
# INPUT
# ==================================================
func _on_allow_button_pressed() -> void:
	process_decision(true)


func _on_block_button_pressed() -> void:
	process_decision(false)


# ==================================================
# UI
# ==================================================
func update_lives_ui() -> void:
	lives_label.text = "Lives: %d" % lives


# ==================================================
# GAME LOGIC
# ==================================================
func process_decision(allowed: bool) -> void:
	if game_over:
		return
	if queue.is_empty():
		return

	var front = queue[0]
	var is_red: bool = front.traits["color"] == "red"

	if allowed and is_red:
		feedback_label.text = "Correct!"
	elif not allowed and not is_red:
		feedback_label.text = "Correct!"
	else:
		feedback_label.text = "Wrong!"
		lives -= 1
		update_lives_ui()

	front.queue_free()
	queue.pop_front()
	update_queue_positions()

	processed_count += 1
	check_level_up()

	if lives <= 0:
		trigger_game_over()


# ==================================================
# LEVEL SYSTEM
# ==================================================
func check_level_up() -> void:
	if processed_count >= CHARACTERS_PER_LEVEL:
		level += 1
		processed_count = 0

		# Reset lives for new level
		lives = 3
		update_lives_ui()

		increase_difficulty()

func increase_difficulty() -> void:
	spawn_interval = max(
		min_spawn_interval,
		spawn_interval - spawn_speed_increase
	)
	feedback_label.text = "LEVEL %d!" % level


# ==================================================
# GAME OVER
# ==================================================
func trigger_game_over() -> void:
	game_over = true
	feedback_label.text = "GAME OVER"
	allow_button.disabled = true
	block_button.disabled = true
