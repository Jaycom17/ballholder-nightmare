extends Control

@onready var audio = $AudioStreamPlayer

func _ready() -> void:
	audio.play()

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
