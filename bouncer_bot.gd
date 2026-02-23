extends Node2D

# =====================================================
# SCENE
# =====================================================
var character_scene: PackedScene = preload("res://character.tscn")

# =====================================================
# POSITIONING (VERTICAL QUEUE)
# =====================================================
@export var queue_x: float = 800.0
@export var queue_bottom_y: float = 850.0
@export var queue_spacing: float = 75.0
@export var spawn_offset_y: float = -800.0

# =====================================================
# DIFFICULTY SETTINGS
# =====================================================
@export var base_spawn_interval: float = 1.5
@export var spawn_speed_increase: float = 0.15
@export var min_spawn_interval: float = 0.4

const CHARACTERS_PER_LEVEL: int = 25
const MAX_QUEUE_SIZE: int = 10

# =====================================================
# GAME STATE
# =====================================================
var queue: Array[Node2D] = []
var lives: int = 3
var level: int = 1
var processed_count: int = 0
var spawn_interval: float = 1.5
var game_over: bool = false

# =====================================================
# UI REFERENCES (UPDATED PATHS)
# =====================================================
@onready var rule_label: Label = $TopHud/Padding/Content/RuleLabel
@onready var lives_label: Label = $TopHud/Padding/Content/LivesLabel
@onready var feedback_label: Label = $FeedbackLabel
@onready var allow_button: Button = $AllowButton
@onready var block_button: Button = $BlockButton

# =====================================================
# READY
# =====================================================
func _ready() -> void:
	randomize()
	spawn_interval = base_spawn_interval
	update_lives_ui()
	start_spawn_loop()

# =====================================================
# SPAWN LOOP
# =====================================================
func start_spawn_loop() -> void:
	while not game_over:
		await get_tree().create_timer(spawn_interval).timeout
		
		if queue.size() >= MAX_QUEUE_SIZE:
			trigger_game_over()
			return
		
		spawn_character()

# =====================================================
# SPAWN CHARACTER + SHADOW
# =====================================================
func spawn_character() -> void:
	var character: Node2D = character_scene.instantiate()
	add_child(character)

	character.scale = Vector2(1.2, 1.2)
	character.global_position = Vector2(queue_x, queue_bottom_y + spawn_offset_y)

	var shadow: Sprite2D = create_shadow()
	add_child(shadow)

	shadow.global_position = character.global_position + Vector2(0, 22)
	shadow.z_index = character.z_index - 1

	character.set_meta("shadow", shadow)

	queue.append(character)
	update_queue_positions()

# =====================================================
# CREATE SHADOW
# =====================================================
func create_shadow() -> Sprite2D:
	var shadow: Sprite2D = Sprite2D.new()

	var img: Image = Image.create(40, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	for x in range(40):
		for y in range(12):
			var dx: float = (x - 20) / 20.0
			var dy: float = (y - 6) / 6.0
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(x, y, Color(0, 0, 0, 0.28))

	var tex: ImageTexture = ImageTexture.create_from_image(img)
	shadow.texture = tex

	return shadow

# =====================================================
# UPDATE QUEUE (VERTICAL)
# =====================================================
func update_queue_positions() -> void:
	for i in range(queue.size()):
		var character: Node2D = queue[i]
		var target: Vector2 = Vector2(
			queue_x,
			queue_bottom_y - i * queue_spacing
		)

		animate_character_to(character, target)

		var shadow: Sprite2D = character.get_meta("shadow") as Sprite2D
		if shadow != null:
			var tween := get_tree().create_tween()
			tween.tween_property(shadow, "global_position", target + Vector2(0, 22), 0.3)

func animate_character_to(character: Node2D, target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(character, "global_position", target, 0.3)

# =====================================================
# BUTTONS
# =====================================================
func _on_allow_button_pressed() -> void:
	process_decision(true)

func _on_block_button_pressed() -> void:
	process_decision(false)

# =====================================================
# CORE GAME LOGIC
# =====================================================
func process_decision(allowed: bool) -> void:
	if game_over or queue.is_empty():
		return
	
	var front: Node2D = queue[0]
	var is_invalid: bool = front.has_red
	
	var correct: bool = false
	
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
	
	var shadow: Sprite2D = front.get_meta("shadow") as Sprite2D
	if shadow != null:
		shadow.queue_free()
	
	front.queue_free()
	queue.pop_front()
	update_queue_positions()
	
	processed_count += 1
	check_level_up()
	
	if lives <= 0:
		trigger_game_over()

# =====================================================
# LEVEL SYSTEM
# =====================================================
func check_level_up() -> void:
	if processed_count >= CHARACTERS_PER_LEVEL:
		level += 1
		processed_count = 0
		lives = 3
		update_lives_ui()
		increase_difficulty()

func increase_difficulty() -> void:
	spawn_interval = max(
		min_spawn_interval,
		spawn_interval - spawn_speed_increase
	)
	feedback_label.text = "LEVEL %d!" % level

# =====================================================
# UI
# =====================================================
func update_lives_ui() -> void:
	lives_label.text = "Lives: %d" % lives

# =====================================================
# GAME OVER
# =====================================================
func trigger_game_over() -> void:
	game_over = true
	feedback_label.text = "GAME OVER"
	allow_button.disabled = true
	block_button.disabled = true
