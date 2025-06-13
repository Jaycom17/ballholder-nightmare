extends Node3D

@export var direction = 1
@export var velocity: float = 2

var player_on_platform: Node3D = null
var last_position: Vector3

func _ready():
	last_position = global_position

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		player_on_platform = body
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player_on_platform:
		player_on_platform = null

func _process(delta: float) -> void:
	var old_position = global_position
	global_position.x += velocity * direction * delta
	var displacement = global_position - old_position

	if player_on_platform:
		player_on_platform.global_position += displacement


func _on_timer_timeout() -> void:
	direction = direction * -1
	$Timer.wait_time = 2
