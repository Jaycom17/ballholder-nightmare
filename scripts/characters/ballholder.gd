extends CharacterBody3D

var is_moving = false
var speed = 3.0

signal player_entered

var vertical_velocity

@onready var timer = $"Timer"
@onready var audio_player = $AudioStreamPlayer3D

var movement_step = 0

func _ready() -> void:
	$AnimationPlayer.play("ballholder/floating")
	audio_player.play()
	
func _physics_process(_delta: float) -> void:
	vertical_velocity = ($"..".carlitos_y - $"..".ballholder_y - 1) / 2
	if is_moving:
		velocity.x = speed 
		velocity.y = vertical_velocity
	move_and_slide()

func _on_timer_timeout() -> void:
	match movement_step:
		0:
			is_moving = true
			speed = 3.0
			timer.wait_time = 5.0
			timer.start()
			movement_step = 1
		1:
			speed = 6
			timer.wait_time = 3.0
			timer.start()
			movement_step = 2
		2:
			speed = 3.0
			timer.wait_time = 7.0
			timer.start()
			movement_step = 1

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		player_entered.emit()
