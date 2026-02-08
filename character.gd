extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var traits := {
	"color": "red"
}

func _ready() -> void:
	apply_traits()

func apply_traits() -> void:
	match traits["color"]:
		"red":
			sprite.modulate = Color.RED
		"blue":
			sprite.modulate = Color.BLUE
