extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 0, 0)
@export var smooth_speed: float = 5.0

func _process(delta):
	if target:
		var target_pos = target.global_transform.origin
		var desired_position = Vector3(target_pos.x, target_pos.y, global_transform.origin.z) + offset
		global_transform.origin = global_transform.origin.lerp(desired_position, smooth_speed * delta)
