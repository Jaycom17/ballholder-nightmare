class_name Player
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DASH_VELOCITY = 5
const DASH_DURATION = 0.9
const MIN_HEIGHT_METERS = -1

@onready var animation_tree = $AnimationTree
@onready var audio_player = $AudioStreamPlayer3D

signal player_fell

var dash_count = 1
var coyote_time = 0.15
var coyote_timer = 0.0
var has_fallen = false

var dash_direction = 1
var dash_timer = 0.0
var is_dashing = false

var can_double_jump = true

func reset_animation_conditions():
	animation_tree["parameters/conditions/running"] = false
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/jump"] = false
	animation_tree["parameters/conditions/doubleJump"] = false
	animation_tree["parameters/conditions/dash"] = false

func set_animation_condition(state: String):
	reset_animation_conditions()
	animation_tree["parameters/conditions/%s" % state] = true

func _physics_process(delta: float) -> void:
	var height_meters = global_transform.origin.y

	if not has_fallen and height_meters < MIN_HEIGHT_METERS:
		has_fallen = true
		audio_player.play()
		await get_tree().create_timer(2.0).timeout
		player_fell.emit()

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Gravity
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		set_animation_condition("jump")
		
	elif Input.is_action_just_pressed("ui_accept") and not is_on_floor() and can_double_jump:
		if is_dashing:
			velocity.x = velocity.x / 2
			velocity.y = JUMP_VELOCITY / 1.8
		else:
			velocity.y = JUMP_VELOCITY
		set_animation_condition("doubleJump")
		can_double_jump = false
	elif is_on_floor():
		dash_count = 1
		can_double_jump = true
		var input_x = Input.get_axis("ui_left", "ui_right")
		if abs(input_x) > 0:
			set_animation_condition("running")
		else:
			set_animation_condition("idle")
	elif not is_on_floor() and velocity.y < 0:
		set_animation_condition("idle")

	# Dash
	if Input.is_action_just_pressed("ui_dash") and dash_count > 0:
		dash_timer = DASH_DURATION
		is_dashing = true
		velocity.y = 0
		set_animation_condition("dash")
		var input_axis = Input.get_axis("ui_left", "ui_right")
		dash_direction = sign(input_axis) if input_axis != 0 else dash_direction
		dash_count = 0

	# Horizontal Movement
	if dash_timer > 0:
		velocity.x = DASH_VELOCITY * dash_direction
		dash_timer -= delta
	else:
		var input_x = Input.get_axis("ui_left", "ui_right")
		if abs(input_x) > 0:
			velocity.x = input_x * SPEED
			dash_direction = sign(input_x)
			if input_x > 0:
				rotation.y = deg_to_rad(90)
			else:
				rotation.y = deg_to_rad(-90)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Lock Z-axis movement
	velocity.z = 0

	move_and_slide()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "animations/dash" == anim_name:
		is_dashing = false
