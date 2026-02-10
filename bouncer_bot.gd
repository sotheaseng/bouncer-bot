extends Node2D

var character_scene: PackedScene = preload("res://character.tscn")

@export var entry_x := -120.0
@export var queue_start_x := 900.0
@export var queue_y := 420.0
@export var queue_spacing := 70.0

@export var base_spawn_interval := 1.5
@export var spawn_speed_increase := 0.15
@export var min_spawn_interval := 0.4

const CHARACTERS_PER_LEVEL := 25
const MAX_QUEUE_SIZE := 10

var queue: Array = []
var lives := 3
var level := 1
var processed_count := 0
var spawn_interval := 1.5
var game_over := false

@onready var feedback_label: Label = $FeedbackLabel
@onready var lives_label: Label = $LivesLabel
@onready var allow_button: Button = $AllowButton
@onready var block_button: Button = $BlockButton

func _ready() -> void:
	randomize()
	spawn_interval = base_spawn_interval
	update_lives_ui()
	start_spawn_loop()

func start_spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout

		if game_over:
			return

		if queue.size() >= MAX_QUEUE_SIZE:
			trigger_game_over()
			return

		spawn_character()

func spawn_character() -> void:
	var character = character_scene.instantiate()
	add_child(character)

	character.global_position = Vector2(entry_x, queue_y)

	queue.append(character)
	update_queue_positions()

func update_queue_positions() -> void:
	for i in queue.size():
		var target := Vector2(
			queue_start_x - i * queue_spacing,
			queue_y
		)
		animate_character_to(queue[i], target)

func animate_character_to(character: CanvasItem, target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(character, "global_position", target, 0.3)

func _on_allow_button_pressed() -> void:
	process_decision(true)

func _on_block_button_pressed() -> void:
	process_decision(false)

func update_lives_ui() -> void:
	lives_label.text = "Lives: %d" % lives

func process_decision(allowed: bool) -> void:
	if game_over or queue.is_empty():
		return

	var front = queue[0]
	var is_invalid: bool = front.has_red

	var correct := false

	if allowed and not is_invalid:
		correct = true
	elif not allowed and is_invalid:
		correct = true

	if correct:
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

func check_level_up() -> void:
	if processed_count >= CHARACTERS_PER_LEVEL:
		level += 1
		processed_count = 0
		lives = 3
		update_lives_ui()
		increase_difficulty()

func increase_difficulty() -> void:
	spawn_interval = max(min_spawn_interval, spawn_interval - spawn_speed_increase)
	feedback_label.text = "LEVEL %d!" % level

func trigger_game_over() -> void:
	game_over = true
	feedback_label.text = "GAME OVER"
	allow_button.disabled = true
	block_button.disabled = true
