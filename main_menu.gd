extends Control

@onready var click_sound = $AudioStreamPlayer2D2

func _on_play_pressed():
	click_sound.play()
	await click_sound.finished
	get_tree().change_scene_to_file("res://bouncer_bot.tscn")

func _on_quit_pressed():
	click_sound.play()
	await click_sound.finished
	get_tree().quit()
