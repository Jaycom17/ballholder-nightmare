extends Node3D

@export var chunk_size = 40

var chunks_data = []
var chunk_index = 0

var last_chunks_data = []

var current_chunk: Node3D

var prefab_platform_static = preload("res://scenes/world/platform_static.tscn")
var prefab_platform_moving = preload("res://scenes/world/platform_moving.tscn")
var prefab_stalagmite = preload("res://scenes/world/stalagmite.tscn")
var prefab_coffee = preload("res://scenes/world/coffee.tscn")

signal coffee_picked_up
signal game_ending

@onready var chunk_holder = $"."
var chunk_to_delete: Node3D = null

func _ready():
	load_chunks_config()
	load_next_chunk()

func load_chunks_config():
	var file = FileAccess.open("res://chuncks/chuncks.json", FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var lfile = FileAccess.open("res://chuncks/last_chunk.json", FileAccess.READ)
	var ljson_text = lfile.get_as_text()
	lfile.close()
	
	var json = JSON.new()
	var result = json.parse(json_text)
	if result == OK:
		chunks_data = json.data
	else:
		push_error("❌ Error parsing JSON: " + json.get_error_message())
		
	var ljson = JSON.new()
	var lresult = ljson.parse(ljson_text)
	if lresult == OK:
		last_chunks_data = ljson.data
	else:
		push_error("❌ Error parsing last_chunk.json: " + ljson.get_error_message())

func load_next_chunk():
	if chunk_index >= chunks_data.size():
		print("🎉 All chunks generated.")
		load_last_chunk()
		return

	var config = chunks_data[chunk_index]
	var chunk = Node3D.new()
	chunk.name = "Chunk_%d" % chunk_index
	chunk.position.x = chunk_index * chunk_size 

	# Static platforms
	for entry in config.get("platform", []):
		var pos = Vector3(entry["x"], entry["y"], 0)
		var platform = prefab_platform_static.instantiate()
		platform.position = pos
		chunk.add_child(platform)

	# Moving platforms
	for entry in config.get("mobile_platform", []):
		var pos = Vector3(entry["x"], entry["y"], 0)
		var moving = prefab_platform_moving.instantiate()
		moving.position = pos
		moving.direction = entry["direction"]
		moving.velocity = entry["speed"]
		chunk.add_child(moving)

	# Coffee pickups
	for entry in config.get("coffee", []):
		var pos = Vector3(entry["x"], entry["y"], 0)
		var coffee = prefab_coffee.instantiate()
		coffee.position = pos
		coffee.connect("picked_up", Callable(self, "_on_coffee_picked_up"))
		chunk.add_child(coffee)

	# Stalagmites
	for entry in config.get("stalactite", []):
		var pos = Vector3(entry["x"], entry["y"], 0)
		var s = prefab_stalagmite.instantiate()
		s.position = pos
		chunk.add_child(s)

	# EndTrigger
	var trigger = Area3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.extents = Vector3(1, 10, 1)
	trigger.name = "EndTrigger"
	trigger.add_child(shape)
	trigger.position = Vector3((chunk_size - 5), 0, 0)
	trigger.connect("body_entered", Callable(self, "_on_trigger_entered").bind(trigger))
	chunk.add_child(trigger)

	# Visibility checker
	var visibility = VisibleOnScreenNotifier3D.new()
	visibility.name = "VisibleOnScreenNotifier3D"
	visibility.position = Vector3((chunk_size + 0.5), 0, 0)
	chunk.add_child(visibility)

	chunk_holder.add_child(chunk)
	current_chunk = chunk
	chunk_index += 1

func _on_trigger_entered(body, trigger):
	print("Entered trigger: ", body.name)
	if body is Player:
		print("It's the player, loading next chunk")

		chunk_to_delete = current_chunk
		load_next_chunk()

		if chunk_to_delete.has_node("VisibleOnScreenNotifier3D"):
			var checker = chunk_to_delete.get_node("VisibleOnScreenNotifier3D")
			checker.connect("screen_exited", Callable(self, "_on_chunk_screen_exited"))
		else:
			print("❌ VisibilityChecker not found")
		trigger.queue_free()

func _on_chunk_screen_exited():
	if chunk_to_delete:
		print("🧹 Chunk off-screen, deleting: ", chunk_to_delete.name)
		chunk_to_delete.queue_free()
		chunk_to_delete = null

func _on_coffee_picked_up():
	coffee_picked_up.emit()

func load_last_chunk():
	print("Last chunk")
	var config = last_chunks_data[0]
	var chunk = Node3D.new()
	chunk.name = "Chunk_%d" % chunk_index
	chunk.position.x = chunk_index * chunk_size 

	for entry in config.get("platform", []):
		var pos = Vector3(entry["x"], entry["y"], 0)
		var platform = prefab_platform_static.instantiate()
		platform.position = pos
		chunk.add_child(platform)

	for entry in config.get("mobile_platform", []):
		var pos = Vector3(entry["x"], entry["y"], 0)
		var moving = prefab_platform_moving.instantiate()
		moving.position = pos
		moving.direction = entry["direction"]
		moving.velocity = entry["speed"]
		chunk.add_child(moving)

	for entry in config.get("coffee", []):
		var pos = Vector3(entry["x"], entry["y"], 0)
		var coffee = prefab_coffee.instantiate()
		coffee.position = pos
		coffee.connect("picked_up", Callable(self, "_on_coffee_picked_up"))
		chunk.add_child(coffee)

	for entry in config.get("stalactite", []):
		var pos = Vector3(entry["x"], entry["y"], 0)
		var s = prefab_stalagmite.instantiate()
		s.position = pos
		chunk.add_child(s)

	var trigger = Area3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.extents = Vector3(1, 10, 1)
	trigger.name = "EndTrigger"
	trigger.add_child(shape)
	trigger.position = Vector3((chunk_size), 0, 0)
	trigger.connect("body_entered", Callable(self, "_on_last_trigger_entered"))
	chunk.add_child(trigger)

	var visibility = VisibleOnScreenNotifier3D.new()
	visibility.name = "VisibleOnScreenNotifier3D"
	visibility.position = Vector3((chunk_size + 0.5), 0, 0)
	chunk.add_child(visibility)

	chunk_holder.add_child(chunk)
	current_chunk = chunk
	chunk_index += 1
	
func _on_last_trigger_entered(body):
	if body is Player:
		game_ending.emit()
