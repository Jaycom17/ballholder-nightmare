extends Node3D

var chunk_size = 40
var background_count = 0
var position_x = 0
var position_y = 0

var background_prefab = preload("res://scenes/world/cave.tscn")

@onready var background_holder = $"."
var generated_backgrounds = []

var current_chunk

func _ready() -> void:
	load_background()
	
func load_background():
	var chunk = Node3D.new()
	chunk.name = "Chunk_%d" % background_count
	chunk.position.x = background_count * chunk_size 
	
	var pos = Vector3(chunk.position.x, 0, 0)
	var background_instance = background_prefab.instantiate()
	background_instance.position = pos
	chunk.add_child(background_instance)
	
	var trigger = Area3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.extents = Vector3(1, 10, 1)
	trigger.name = "EndTrigger"
	trigger.add_child(shape)
	trigger.position = Vector3(chunk.position.x, 0, 0)
	trigger.connect("body_entered", Callable(self, "_on_trigger_entered").bind(trigger))
	chunk.add_child(trigger)
	
	background_holder.add_child(chunk)
	generated_backgrounds.append(chunk)
	background_count += 1
	
func _on_trigger_entered(body, trigger):
	if body is Player:
		print(len(generated_backgrounds))
		load_background()
		# Remove the oldest chunk if more than 3
		if generated_backgrounds.size() > 3:
			var oldest_chunk = generated_backgrounds[0]
			oldest_chunk.queue_free()
			generated_backgrounds.remove_at(0)
		trigger.queue_free()
