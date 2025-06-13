extends Control



func _ready() -> void:
	pass



func _process(delta: float) -> void:
	pass


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
