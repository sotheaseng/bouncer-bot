extends ColorRect

# -------------------------
# CHARACTER DATA
# -------------------------
var traits := {
	"color": "red"
}

# -------------------------
# VISUAL SETUP
# -------------------------
func _ready() -> void:
	apply_traits()


func apply_traits() -> void:
	match traits["color"]:
		"red":
			color = Color.RED
		"blue":
			color = Color.BLUE
