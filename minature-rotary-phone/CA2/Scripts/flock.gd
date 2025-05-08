class_name SimpleVFormation extends Node
@export var leader_bird_path: NodePath
@export var bird_scene: PackedScene
@export var num_followers: int = 6
@export var v_angle_degrees: float = 30.0
@export var spacing: float = 5.0
@export var height_offset: float = 0.5
@export var smooth_factor: float = 2.0  # How quickly birds move to their positions

var leader_bird: Node3D
var followers = []
var offsets = []  # Store the offset for each follower

func _ready():
	# Get the leader bird
	leader_bird = get_node_or_null(leader_bird_path)
	if !leader_bird:
		push_error("Leader bird not set or not found!")
		return
	
	# Create the flock
	create_flock()

func create_flock():
	if not leader_bird:
		return
	
	# Create follower birds
	for i in range(num_followers):
		var bird = bird_scene.instantiate()
		add_child(bird)
		
		# Calculate initial position in V formation
		var side = 1 if i % 2 == 0 else -1  # Alternate sides
		var row = ceil((i+1) / 2.0)         # Position in row
		var angle_rad = deg_to_rad(v_angle_degrees)
		var offset = Vector3(
			side * spacing * sin(angle_rad) * row,
			height_offset * row,
			-spacing * cos(angle_rad) * row
		)
		
		# Store the offset for this bird
		offsets.append(offset)
		
		# Position bird initially
		bird.global_transform.origin = leader_bird.global_transform.origin + leader_bird.global_transform.basis * offset
		bird.global_transform.basis = leader_bird.global_transform.basis  # Match rotation
		
		# Add to followers array
		followers.append(bird)
		
		var boid = null
		if bird is Boid:
			boid = bird
		else:
			boid = bird.find_child("Boid", true)
		
		if boid:
			for child in boid.get_children():
				if child.has_method("calculate"):  # Check if Calculate is working
					child.enabled = false

func _process(delta):
	# Update all follower positions based on leader
	for i in range(followers.size()):
		update_follower_position(i, delta)

func update_follower_position(index, delta):
	if index >= followers.size() or index >= offsets.size():
		return
	
	var follower = followers[index]
	var offset = offsets[index]
	
	# Calculate target position based on leader's current transform
	var target_position = leader_bird.global_transform.origin + leader_bird.global_transform.basis * offset
	
	# Smoothly move follower toward target position
	follower.global_transform.origin = follower.global_transform.origin.lerp(
		target_position, 
		delta * smooth_factor
	)
	
	# Match leader's orientation
	follower.global_transform.basis = follower.global_transform.basis.slerp(
		leader_bird.global_transform.basis, 
		delta * smooth_factor * 0.8
	)
