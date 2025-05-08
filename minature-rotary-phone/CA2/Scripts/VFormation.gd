class_name VFormation extends SteeringBehavior

@export var leader_path: NodePath
@export var flock_index: int = 1  # Position in the flock (1-based)
@export var spacing: float = 5.0  # Distance between birds
@export var v_angle_degrees: float = 30.0  # Angle of the V
@export var height_offset: float = 0.5  # Vertical staggering
@export var formation_tightness: float = 2.0  # How strongly to maintain formation

var leader: Node3D = null
var formation_offset = Vector3.ZERO
var target_position = Vector3.ZERO

func _ready():
	boid = get_parent()
	
	# Get leader reference if path is set
	if not leader_path.is_empty():
		leader = get_node(leader_path)
	
	# Calculate formation offset
	calculate_formation_offset()

func calculate_formation_offset():
	# Calculate position in V formation
	var side = 1 if flock_index % 2 == 0 else -1  # Alternate sides
	var row = ceil(flock_index / 2.0)              # Position in row
	
	# Calculate offset relative to leader
	var angle_rad = deg_to_rad(v_angle_degrees)
	formation_offset = Vector3(
		side * spacing * sin(angle_rad) * row,  # X offset (left/right)
		height_offset * row,                    # Y offset (up/down)
		-spacing * cos(angle_rad) * row         # Z offset (behind)
	)

func on_draw_gizmos():
	if leader and enabled:
		# Draw desired position
		target_position = get_formation_position()
		DebugDraw3D.draw_sphere(target_position, 0.3, Color.YELLOW)
		DebugDraw3D.draw_line(boid.global_transform.origin, target_position, Color.YELLOW)

func get_formation_position():
	if not leader:
		return boid.global_transform.origin
	
	# Get desired position based on leader's orientation and our offset
	return leader.global_transform.origin + leader.global_transform.basis * formation_offset

func calculate():
	if not leader or not enabled:
		return Vector3.ZERO
	
	# Get target position in formation
	target_position = get_formation_position()
	
	# Calculate distance to target
	var to_target = target_position - boid.global_transform.origin
	var distance = to_target.length()
	
	# Use arrival for better positioning
	if distance < spacing:
		return boid.arrive_force(target_position, spacing * 0.5) * formation_tightness
	else:
		return boid.seek_force(target_position) * formation_tightness
