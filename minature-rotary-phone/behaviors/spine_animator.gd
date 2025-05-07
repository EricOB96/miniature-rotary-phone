class_name SpineAnimator extends Node

@export var bones:Array[Node] = []
@export var damping:float = 7
@export var angular_damping:float = 20
				
var offsets = [] 

#For Bird flapping wings
@export var enable_flapping: bool = true
@export var flap_speed: float = 3.0
@export var flap_amplitude: float = 0.5
@export var left_flap_axis: Vector3 = Vector3(0, 0, 1)  # For left wing
@export var right_flap_axis: Vector3 = Vector3(0, 0, -1) # For right wing
var time: float = 0.0

func calculateOffsets():
	offsets.clear()	
	for i in bones.size():
		if i > 0:
			var offset = bones[i].global_transform.origin - bones[i-1].global_transform.origin
			# offset = bones[i-1].global_transform.basis.xform_inv(offset)
			offset = bones[i-1].global_transform.basis.inverse() * offset
			offsets.push_back(offset)

# Called when the node enters the scene tree for the first time.
func _ready():
	calculateOffsets()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	time += delta
	
	# Apply flapping to BOTH wings if enabled
	if enable_flapping and bones.size() >= 2:
		var flap = sin(time * flap_speed) * flap_amplitude
		
		# Apply to left wing (bone[0])
		var left_rotation = Quaternion(left_flap_axis, flap)
		bones[0].quaternion = left_rotation
		
		# Apply to right wing (bone[1]) - note we use right_flap_axis
		var right_rotation = Quaternion(right_flap_axis, flap)
		bones[1].quaternion = right_rotation
	
	
	for i in offsets.size():
		var prev = bones[i]
		var next = bones[i + 1]
		
		var wantedPos = prev.global_transform * (offsets[i])
		
		# Clamp it, they dont get too far apart
		var lerped = lerp(next.global_transform.origin, wantedPos, delta * damping)
		var limit_length = (lerped - prev.global_transform.origin).normalized() * offsets[i].length()
		var pos = prev.global_transform.origin + limit_length
		# next.move_and_slide(pos - next.global_transform.origin)
		next.global_transform.origin = pos
		
		var prevRot = prev.global_transform.basis.orthonormalized()
		
		# Why?
		var target_rot = prev.global_transform.looking_at(next.global_transform.origin, prev.global_transform.basis.y).basis.orthonormalized()			
		# var next_rot = nextRot.slerp(prevRot, angular_damping * delta).orthonormalized()		 
		next.global_transform.basis = next.global_transform.basis.slerp(target_rot, angular_damping * delta).orthonormalized()
		
