extends CharacterBody3D

const SPEED = 5
const DASH = 8
const CROUCH = 3
const CROUCH_depth = 0.5
const JUMP_VELOCITY = 8

const ACCELERATION = 0.1
const FRICTION = 0.3

@onready var player_collision = $CollisionShape3D
@onready var player_camera = $Camera3D

@onready var interact_ray = $Camera3D/RayCast3D

var INERTIA:Vector2 = Vector2.ZERO

var current_menu = "HUD"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Lock Mouse.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	# Player camera.
	if event is InputEventMouseMotion and current_menu == "HUD":
		rotate_y(-deg_to_rad(event.relative.x * 0.4))
		player_camera.rotate_x(-deg_to_rad(event.relative.y * 0.4))
		player_camera.rotation.x = clamp(player_camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))
func _unhandled_input(event):
	# Pause.
	if Input.is_action_just_pressed("pause"):
		match current_menu :
			"HUD":
				current_menu = "Pause"
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			"Pause":
				current_menu = "HUD"
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(_delta):
	# Record Inerita & Add the gravity.
	if is_on_floor():
		INERTIA.x = velocity.x
		INERTIA.y = velocity.z
	else:
		velocity.y -= gravity * 0.05

	# Handle Jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Move Input.
	var input_vec = Vector3.ZERO
	input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vec.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vec = (transform.basis * Vector3(input_vec.x,0,input_vec.z)).normalized()
	
	var isDash = 0
	isDash = Input.get_action_strength("shift")
	var isCrouch = 0
	isCrouch = Input.get_action_strength("crouch")
	
	# Move.
	velocity.x = lerp(velocity.x,input_vec.x * (SPEED + isDash * DASH * (1 - isCrouch) - isCrouch * CROUCH ) , ACCELERATION)
	velocity.z = lerp(velocity.z,input_vec.z * (SPEED + isDash * DASH * (1 - isCrouch) - isCrouch * CROUCH ) , ACCELERATION)
	# Stop.
	if velocity.x * input_vec.x <= 0 and velocity.x!=0:
		if is_on_floor():	velocity.x = lerp(velocity.x,0.0,FRICTION)
		else:				velocity.x = lerp(INERTIA.x,0.0,FRICTION)
	if velocity.z * input_vec.z <= 0 and velocity.z!=0:
		if is_on_floor():	velocity.z = lerp(velocity.z,0.0,FRICTION)
		else:				velocity.z = lerp(INERTIA.y,0.0,FRICTION)
	
	move_and_slide()
