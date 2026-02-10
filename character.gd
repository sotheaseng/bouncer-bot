extends Node2D

@onready var body: Sprite2D = $Body
@onready var pants: Sprite2D = $Pants
@onready var shirt: Sprite2D = $Shirt

# =============================
# SPRITESHEET CONFIG
# =============================
const TILE_SIZE: int = 16
const MARGIN: int = 1

# =============================
# BODY: rows 1–4, cols 1–2
# =============================
const BODY_ROWS := [1, 2, 3, 4]
const BODY_COLS := [1, 2]

# =============================
# PANTS: column 4, rows 1–9
# =============================
const PANTS_COL := 4
const PANTS_ROWS := [1,2,3,4,5,6,7,8,9]

# =============================
# SHIRTS: rows 1–10, cols 6–17
# =============================
const SHIRT_ROWS := [1,2,3,4,5,6,7,8,9,10]
const SHIRT_COLS := [
	6,7,8,9,10,11,12,13,14,15,16,17
]

func _ready() -> void:
	randomize()
	randomize_character()

# =============================
# CHARACTER RANDOMIZATION
# =============================
func randomize_character() -> void:
	randomize_body()
	randomize_pants()
	randomize_shirt()

# =============================
# BODY
# =============================
func randomize_body() -> void:
	var row: int = BODY_ROWS.pick_random()
	var col: int = BODY_COLS.pick_random()
	apply_region(body, row, col)

# =============================
# PANTS
# =============================
func randomize_pants() -> void:
	var row: int = PANTS_ROWS.pick_random()
	apply_region(pants, row, PANTS_COL)

# =============================
# SHIRT
# =============================
func randomize_shirt() -> void:
	var row: int = SHIRT_ROWS.pick_random()
	var col: int = SHIRT_COLS.pick_random()
	apply_region(shirt, row, col)

# =============================
# REGION HELPER
# =============================
func apply_region(sprite: Sprite2D, row: int, col: int) -> void:
	var x: int = MARGIN + (col - 1) * (TILE_SIZE + MARGIN)
	var y: int = MARGIN + (row - 1) * (TILE_SIZE + MARGIN)

	sprite.region_enabled = true
	sprite.region_rect = Rect2(x, y, TILE_SIZE, TILE_SIZE)
	sprite.visible = true
