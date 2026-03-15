extends Node2D

@onready var restart_button: Button = $CenterContainer/VBoxContainer/Restart
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/"Go to Main Menu"


func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://bouncer_bot.tscn")


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
