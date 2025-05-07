extends CharacterBody3D

@export var sensitivity = 0.1
@export var speed:float = 1.0

var controlling = true

@export var left:XRController3D
@export var right:XRController3D

# Snap turn movement for right controller XR
@export var snap_angle: float = 30.0
@export var snap_deadzone: float = 0.5
@export var snap_cooldown: float = 0.3

var snap_timer = 0.0


func _input(event):
	if event is InputEventMouseMotion and controlling:
		rotate(Vector3.DOWN, deg_to_rad(event.relative.x * sensitivity))
		rotate(transform.basis.x,deg_to_rad(- event.relative.y * sensitivity))
	if event.is_action_pressed("ui_cancel"):
		if controlling:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:			
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		controlling = ! controlling


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

@export var can_move:bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if can_move:
		var v = Vector3.ZERO
		
		var mult = 1
		if Input.is_key_pressed(KEY_SHIFT):
			mult = 3
		
		if left:
			var joy = left.get_vector2("primary")
			var cam_basis = $XROrigin3D/XRCamera3D.global_transform.basis
			global_translate(cam_basis.z * speed * mult * delta * -joy.y)
			global_translate(cam_basis.x * speed * mult * delta * joy.x)
			
		if right:
			snap_turing(delta)
				
		var turn = Input.get_axis("turn_left", "turn_right") - v.x	
		if abs(turn) > 0:     
			global_translate(global_transform.basis.x * speed * turn * mult * delta)
		
		var movef = Input.get_axis("move_forward", "move_back")
		#print(movef)
		if abs(movef) > 0:     
			global_translate(global_transform.basis.z * speed * movef * mult * delta)
		
		var upanddown = Input.get_axis("move_up", "move_down")
		if abs(upanddown) > 0:     
			global_translate(- global_transform.basis.y * speed * upanddown * mult * delta)
		
		move_and_slide()	
			
func snap_turing(delta):
	
	if snap_timer > 0:
		snap_timer -= delta
		return
		
	var joy = right.get_vector2("primary")
	
	if abs(joy.x) > snap_deadzone:
		var turn_direction = sign(joy.x)
		var turn_angle = snap_angle * -turn_direction
		
		rotate(Vector3.UP, deg_to_rad(turn_angle))
		
		snap_timer = snap_cooldown
