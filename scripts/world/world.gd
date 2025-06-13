extends Node3D

@onready var song = $AudioStreamPlayer
var coffee_count = 0
@onready var coin_label = $CanvasLayer/Control/Label
@onready var carlitos = $Carlitos
@export var carlitos_y = 3
@onready var ballholder = $Ballholder
@export var ballholder_y = 3

func _ready() -> void:
	update_coin_ui(0)
	song.play()
	
func _process(_delta: float) -> void:
	carlitos_y = carlitos.global_position.y
	ballholder_y = ballholder.global_position.y


func update_coin_ui(count):
	coin_label.text = str(count)

func _on_audio_stream_player_finished() -> void:
	song.play()


func _on_ballholder_player_entered() -> void:
	song.stop()
	get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")


func _on_carlitos_player_fell() -> void:
	song.stop()
	get_tree().reload_current_scene()


func _on_chunck_holder_game_ending() -> void:
	song.stop()
	get_tree().change_scene_to_file("res://scenes/ui/credits.tscn")


func _on_chunck_holder_coffee_picked_up() -> void:
	coffee_count+=1
	update_coin_ui(coffee_count)
