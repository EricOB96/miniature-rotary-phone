class_name SimpleVFormation extends Node

@export var leader_bird_path: NodePath
@export var bird_scene: PackedScene
@export var num_followers: int = 6
@export var v_angle_degrees: float = 30.0
@export var spacing: float = 5.0
@export var height_offset: float = 0.5
@export var smooth_factor: float = 2.0  # How quickly birds move to their positions
@export var rotation_smooth_factor: float = 1.6  # Separate rotation smoothing

var leader_bird: Node3D
var followers = []
var offsets = []  # Store the offset for each follower
var prev_leader_basis: Basis  # Store previous leader orientation

func _ready():
	# Get the leader bird
	leader_bird = get_node_or_null(leader_bird_path)
	if !leader_bird:
		push_error("Leader bird not set or not found!")
		return
		
	# Initialize previous leader basis
	prev_leader_basis = leader_bird.global_transform.basis.orthonormalized()
		
	# Connect to BirdManager signals
	BirdManager.connect("add_bird_requested", Callable(self, "add_bird"))
	BirdManager.connect("remove_bird_requested", Callable(self, "remove_bird"))
	BirdManager.connect("set_bird_count_requested", Callable(self, "set_bird_count"))
	
	# Create the flock
	create_flock()
	
	# Update BirdManager with initial count
	BirdManager.update_bird_count(followers.size() + 1)  # +1 for leader

func create_flock():
	if not leader_bird:
		return
	
	# Clear existing followers if any
	for follower in followers:
		if is_instance_valid(follower):
			follower.queue_free()
	
	followers.clear()
	offsets.clear()
	
	# Create follower birds
	for i in range(num_followers):
		add_follower(i)

func add_follower(index):
	var bird = bird_scene.instantiate()
	add_child(bird)
	
	# Calculate position in V formation
	var side = 1 if index % 2 == 0 else -1  # Alternate sides
	var row = ceil((index+1) / 2.0)         # Position in row
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
	bird.global_transform.basis = leader_bird.global_transform.basis.orthonormalized()  # Match rotation
	
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

func add_bird():
	# Add a new follower
	add_follower(followers.size())
	num_followers = followers.size()
	
	# Update the BirdManager with the new count
	BirdManager.update_bird_count(followers.size() + 1)  # +1 for leader

func remove_bird():
	if followers.size() > 0:
		# Remove last follower
		var bird = followers.pop_back()
		offsets.pop_back()
		
		if is_instance_valid(bird):
			bird.queue_free()
		
		num_followers = followers.size()
		
		# Update the BirdManager with the new count
		BirdManager.update_bird_count(followers.size() + 1)  # +1 for leader

func set_bird_count(count):
	# Ensure count doesn't include the leader
	var follower_count = max(0, count - 1)
	
	# Add or remove birds to match requested count
	var current_count = followers.size()
	
	if follower_count > current_count:
		# Add birds
		for i in range(follower_count - current_count):
			add_follower(current_count + i)
	elif follower_count < current_count:
		# Remove birds
		for i in range(current_count - follower_count):
			if followers.size() > 0:
				var bird = followers.pop_back()
				offsets.pop_back()
				
				if is_instance_valid(bird):
					bird.queue_free()
	
	num_followers = followers.size()
	
	# Update the BirdManager with the new count
	BirdManager.update_bird_count(followers.size() + 1)  # +1 for leader

func _process(delta):
	if !is_instance_valid(leader_bird):
		return
	
	# Ensure leader basis is orthonormalized
	var current_leader_basis = leader_bird.global_transform.basis.orthonormalized()
	
	# Update all follower positions based on leader
	for i in range(followers.size()):
		update_follower_position(i, delta, current_leader_basis)
	
	# Store current leader basis for next frame
	prev_leader_basis = current_leader_basis

func update_follower_position(index, delta, current_leader_basis):
	if index >= followers.size() or index >= offsets.size() or !is_instance_valid(leader_bird):
		return
	
	var follower = followers[index]
	if !is_instance_valid(follower):
		return
		
	var offset = offsets[index]
	
	# Calculate target position based on leader's current transform
	var target_position = leader_bird.global_transform.origin + current_leader_basis * offset
	
	# Smoothly move follower toward target position
	follower.global_transform.origin = follower.global_transform.origin.lerp(
		target_position, 
		delta * smooth_factor
	)
	
	# Calculate smooth rotation factor based on position in formation
	var row = ceil((index+1) / 2.0)  # Higher rows get slightly slower rotation
	var rotation_factor = rotation_smooth_factor / (1.0 + row * 0.1)
	
	# Get current follower basis and ensure it's orthonormalized
	var follower_basis = follower.global_transform.basis.orthonormalized()
	
	# Calculate target rotation with proper normalization
	var target_basis = current_leader_basis.orthonormalized()
	
	# Smoothly interpolate rotation, ensuring result is orthonormalized
	follower.global_transform.basis = follower_basis.slerp(
		target_basis, 
		delta * rotation_factor
	).orthonormalized()  # Ensure result is orthonormalized
