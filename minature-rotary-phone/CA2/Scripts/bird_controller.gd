extends Node
class_name BirdBehaviorController

# References to other nodes
@export var bird: Node  # Boid bird node
@export var seek_behavior_path: NodePath  # Path to Seek behavior
@export var follow_path_behavior_path: NodePath  # Path to FollowPath behavior
@export var floor_detector: Area3D  # Reference to floor FoodDetector
@export var food_scene: PackedScene  # The food to spawn
@export var food_spawn_point: Node3D  # Where to spawn new food
@export var food_group: Node  # Parent node containing food items

# Behavior settings
@export var arrival_distance: float = 1.0  # How close bird needs to be to catch food
@export var auto_spawn_food: bool = true  # Whether to automatically spawn new food
@export var spawn_delay: float = 2.0  # Seconds to wait before spawning new food

# State variables
enum BirdState {FOLLOW_PATH, SEEK_FOOD, RETURN_TO_PATH}
var current_state = BirdState.FOLLOW_PATH
var target_food = null
var seek_behavior: Node  # Changed from Seek to Node
var follow_path_behavior: Node  # Changed from FollowPath to Node
var spawn_timer: float = 0.0
var should_spawn_food: bool = false
var path_index_before_seek: int = 0
var return_target: Node3D = null

func _ready():
	# Get behavior references
	seek_behavior = get_node_or_null(seek_behavior_path)
	follow_path_behavior = get_node_or_null(follow_path_behavior_path)

	# Set initial state
	set_state(BirdState.FOLLOW_PATH)
	
	# Spawn initial food if needed
	if auto_spawn_food and food_group and food_group.get_child_count() == 0:
		spawn_food()

func _process(delta):
	# Handle behavior based on state
	match current_state:
		BirdState.FOLLOW_PATH:
			follow_path(delta)
		
		BirdState.SEEK_FOOD:
			if target_food and is_instance_valid(target_food):
				seek_food(delta)
			else:
				# Target food was removed
				set_state(BirdState.RETURN_TO_PATH)
		
		BirdState.RETURN_TO_PATH:
			return_to_path(delta)
	
	# Handle food spawning timer
	if should_spawn_food:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_food()
			should_spawn_food = false

func _on_floor_detector_body_entered(body):
	
	print("Floor detected body: ", body.name)
	print("Is food item: ", is_food_item(body))
	# Only respond if currently following the path
	if current_state != BirdState.FOLLOW_PATH:
		return
	
	# Check if the body is a food item
	if is_food_item(body):
		# Found food on ground, target it
		print("Food detected on floor: ", body.name) # DEBUG
		target_food = body
		set_state(BirdState.SEEK_FOOD)

# function to identify food items
func is_food_item(node):
	# Check if it's in the Food group
	if node.is_in_group("Food"):
		return true
	
	# Check if it's a child of food_group
	if food_group:
		for food in food_group.get_children():
			if food == node:
				return true
	
	# Check if XRToolsPickable component
	if node.has_node("XRToolsPickable"):
		return true
	
	# Check name as fallback
	if "food" in node.name.to_lower():
		return true
	
	return false

func set_state(new_state):
	if new_state == current_state:
		return
	
	# Exit actions for old state
	match current_state:
		BirdState.FOLLOW_PATH:
			# Store current path index before seeking food
			if follow_path_behavior and follow_path_behavior.has_method("calculate"):
				# Check if it has pathIndex property
				if "pathIndex" in follow_path_behavior:
					path_index_before_seek = follow_path_behavior.pathIndex
	
	current_state = new_state
	print("Bird state changed to: ", BirdState.keys()[current_state])
	
	# Entry actions for new state
	match new_state:
		BirdState.FOLLOW_PATH:
			# Enable path following, disable seeking
			if follow_path_behavior:
				follow_path_behavior.enabled = true
			if seek_behavior:
				seek_behavior.enabled = false
				seek_behavior.target = null
		
		BirdState.SEEK_FOOD:
			# Enable seeking, disable path following
			if follow_path_behavior:
				follow_path_behavior.enabled = false
			if seek_behavior:
				seek_behavior.enabled = true
				# Set target food as target for seeking
				seek_behavior.target = target_food
		
		BirdState.RETURN_TO_PATH:
			# Reset target
			target_food = null
			
			# For returning, create a temporary target at the path point
			if return_target == null:
				return_target = Node3D.new()
				add_child(return_target)
				return_target.name = "ReturnTarget"
			
			if follow_path_behavior and "path" in follow_path_behavior:
				var path = follow_path_behavior.path
				if path and path is Path3D:
					var path_point = path.global_transform * (
						path.get_curve().get_point_position(path_index_before_seek)
					)
					return_target.global_transform.origin = path_point
				else:
					# Use bird's position as fallback
					return_target.global_transform.origin = bird.global_transform.origin
			else:
				# Use bird's position as fallback
				return_target.global_transform.origin = bird.global_transform.origin
			
			# Enable seeking, disable path following
			if follow_path_behavior:
				follow_path_behavior.enabled = false
			if seek_behavior:
				seek_behavior.enabled = true
				seek_behavior.target = return_target

func follow_path(delta):
	
	# Ensure the path follow behaviors are active
	if follow_path_behavior and not follow_path_behavior.enabled:
		follow_path_behavior.enabled = true
	
	if seek_behavior and seek_behavior.enabled:
		seek_behavior.enabled = false

func seek_food(delta):
	if not target_food or not is_instance_valid(target_food):
		set_state(BirdState.RETURN_TO_PATH)
		return
	
	if seek_behavior:
		if not seek_behavior.enabled:
			seek_behavior.enabled = true
		seek_behavior.target = target_food
	
	# Check if bird reached the food
	var distance = bird.global_transform.origin.distance_to(target_food.global_transform.origin)
	print("Distance to food: ", distance) # Debug line
	if distance < arrival_distance:
		_on_food_caught(target_food)

func return_to_path(delta):
	# Calculate distance to return target
	if return_target:
		var distance = bird.global_transform.origin.distance_to(return_target.global_transform.origin)
		
		if distance < arrival_distance:
			# Bird has returned to path, resume following
			if follow_path_behavior and "pathIndex" in follow_path_behavior:
				follow_path_behavior.pathIndex = path_index_before_seek
			
			set_state(BirdState.FOLLOW_PATH)

func _on_food_caught(food):
	print("Food caught: ", food.name)
	# Remove the food
	food.queue_free()
	
	# Schedule new food to spawn after delay
	if auto_spawn_food:
		should_spawn_food = true
		spawn_timer = spawn_delay
	
	# Return to path
	set_state(BirdState.RETURN_TO_PATH)

func spawn_food():
	if not food_scene or not food_spawn_point:
		print("ERROR: Cannot spawn food - missing food_scene or food_spawn_point")
		return
	
	# Instance the food scene
	var new_food = food_scene.instantiate()
	
	# Add to the food group
	food_group.add_child(new_food)
	
	# Position it at the spawn point
	new_food.global_transform = food_spawn_point.global_transform
	
	# Add to Food group for identification
	new_food.add_to_group("Food")
	
	print("Spawned new food at: ", food_spawn_point.global_transform.origin) # DEBUG
