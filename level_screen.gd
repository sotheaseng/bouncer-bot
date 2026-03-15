extends Node2D

signal finished

var level := 1
var break_time := 2.5

@onready var level_label: Label = $CenterContainer/VBoxContainer/LevelLabel


func _ready():

	level_label.text = "LEVEL %d" % level

	await get_tree().create_timer(break_time).timeout

	finished.emit()

	queue_free()
