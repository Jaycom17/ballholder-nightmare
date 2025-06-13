extends Node3D

signal picked_up

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		picked_up.emit()
		$AudioStreamPlayer3D.play()
		$Area3D/CollisionShape3D.queue_free()

func _on_audio_stream_player_3d_finished() -> void:
	queue_free()
