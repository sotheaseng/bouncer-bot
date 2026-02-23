extends Node2D

# =====================================================
# RED SYSTEM
# =====================================================
var has_red: bool = false
const RED_CHANCE: float = 0.35

# =====================================================
# NODE REFERENCES
# =====================================================
@onready var body: Sprite2D = $Body
@onready var pants: Sprite2D = $Pants
@onready var shirt: Sprite2D = $Shirt

var red_marker: Sprite2D

# =====================================================
# SPRITESHEET CONFIG
# =====================================================
const TILE_SIZE: int = 16
const MARGIN: int = 1

const BODY_ROWS: Array[int] = [1, 2, 3, 4]
const BODY_COLS: Array[int] = [1, 2]

const PANTS_COL: int = 4
const PANTS_ROWS: Array[int] = [1,2,3,4,5,6,7,8,9]

const SHIRT_ROWS: Array[int] = [1,2,3,4,5,6,7,8,9,10]
const SHIRT_COLS: Array[int] = [6,7,8,9,10,11,12,13,14,15,16,17]

# =====================================================
# READY
# =====================================================
func _ready() -> void:
	randomize()
	create_red_marker()
	randomize_character()

# =====================================================
# CREATE RED MARKER
# =====================================================
func create_red_marker() -> void:
	red_marker = Sprite2D.new()
	add_child(red_marker)

	# Create simple red circle texture
	var image := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 0, 0))
	var texture := ImageTexture.create_from_image(image)

	red_marker.texture = texture
	red_marker.position = Vector2(0, -20)
	red_marker.visible = false

# =====================================================
# CHARACTER RANDOMIZATION
# =====================================================
func randomize_character() -> void:
	has_red = false
	red_marker.visible = false
	
	randomize_body()
	randomize_pants()
	randomize_shirt()
	
	apply_random_red_marker()

# =====================================================
# BODY
# =====================================================
func randomize_body() -> void:
	var row: int = BODY_ROWS[randi() % BODY_ROWS.size()]
	var col: int = BODY_COLS[randi() % BODY_COLS.size()]
	apply_region(body, row, col)

# =====================================================
# PANTS
# =====================================================
func randomize_pants() -> void:
	var row: int = PANTS_ROWS[randi() % PANTS_ROWS.size()]
	apply_region(pants, row, PANTS_COL)

# =====================================================
# SHIRT
# =====================================================
func randomize_shirt() -> void:
	var row: int = SHIRT_ROWS[randi() % SHIRT_ROWS.size()]
	var col: int = SHIRT_COLS[randi() % SHIRT_COLS.size()]
	apply_region(shirt, row, col)

# =====================================================
# RED MARKER LOGIC
# =====================================================
func apply_random_red_marker() -> void:
	if randf() > RED_CHANCE:
		return
	
	has_red = true
	red_marker.visible = true

# =====================================================
# REGION HELPER
# =====================================================
func apply_region(sprite: Sprite2D, row: int, col: int) -> void:
	var x: int = MARGIN + (col - 1) * (TILE_SIZE + MARGIN)
	var y: int = MARGIN + (row - 1) * (TILE_SIZE + MARGIN)

	sprite.region_enabled = true
	sprite.region_rect = Rect2(x, y, TILE_SIZE, TILE_SIZE)
	sprite.visible = true
	sprite.modulate = Color.WHITE
