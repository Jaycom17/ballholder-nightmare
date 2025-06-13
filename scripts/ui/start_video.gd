extends Node3D

@onready var video = $VideoStreamPlayer

func _ready():
	video.play()
	video.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
