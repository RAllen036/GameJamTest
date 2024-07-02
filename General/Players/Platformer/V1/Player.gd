class_name BasicPlatformerPlayer
extends CharacterBody2D

@onready var temp_body: MeshInstance2D = $TempBody
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export_category("Player Statistics")
@export_subgroup("Speed Variables")
@export_range(1.0, 100.0, 1.0, "or_greater") var walk_speed: float = 150.0
@export_range(1.0, 100.0, 1.0, "or_greater") var running_speed: float = 200.0
@export_range(1.0, 100.0, 1.0, "or_greater") var dash_speed: float = 400.0
@export_range(1.0, 100.0, 1.0, "or_greater") var crouching_speed: float = 50.0

@export_subgroup("Dash Default Variables")
@export_range(0.0, 5.0) var default_dash_time: float = 0.2
@export_range(0.0, 5.0) var default_dash_interval: float = 1.0

@export_subgroup("Jump Default Variables")
@export_range(1.0, 100.0, 1.0, "or_greater") var jump_strength: float = 400.0
@export_range(1, 2, 1, "or_greater") var default_jumps: int = 2
@export_range(1, 2, 1, "or_greater") var default_wall_jumps: int = 1

@export_subgroup("Other Variables")
@export_range(0.0, 1.0) var crouched_height_multiplier: float = 0.5

var original_collision_height: float = 0.0
var original_body_height: float = 0.0
var dash_time: float = default_dash_time
var dash_interval: float = 0.0
var dashing: bool = false
# NOTE: default gravity = 980 but it is a little to strong for the size of the player etc
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") / 50 
# Setting default dash direction to the right since that will most likely be the direction of the sprite
var direction_buffer: float = 1.0
var jumps: int = default_jumps
var wall_jumps: int = default_wall_jumps
var crouching: bool = false

func _ready() -> void:
	original_body_height = temp_body.scale.y
	original_collision_height = collision_shape_2d.scale.y

func _physics_process(delta: float) -> void:
	# Linear acceleration for gravity towards the floor
	velocity.y += gravity
	
	dash_interval -= delta
	
	# NOTE direction buffer is a float which dictates the x direction of the last move
	if Input.is_action_just_pressed("dash") and not dashing and dash_interval <= 0.0:
		dashing = true
	
	if dashing and not crouching:
		velocity.x = direction_buffer * dash_speed
		dash_time -= delta
		if dash_time <= 0.0:
			dash_time = default_dash_time
			dash_interval = default_dash_interval
			dashing = false
		move_and_slide()
		return
	
	# Moving the player left and right based on input (if a controller is used then it returns the input strength)
	var direction = Input.get_axis("left", "right")
	
	# Converts the direction to +-1 for the direction buffer
	if direction > 0:
		direction_buffer = 1
	elif direction < 0:
		direction_buffer = -1
	
	# Resets the dash timer
	dash_time = default_dash_time
	
	# Reset jumps if the player is on the floor
	if is_on_floor():
		jumps = default_jumps
		wall_jumps = default_wall_jumps
	
	# The main jump function
	if Input.is_action_just_pressed("jump") and jumps > 0:
		# The condition block allows for wall jumping without penalties but limits its utility
		if is_on_wall() and wall_jumps > 0:
			wall_jumps -= 1
		else:
			jumps -= 1
		velocity.y = -jump_strength
	
	if Input.is_action_just_pressed("crouch"):
		crouching = true
		temp_body.scale.y = crouched_height_multiplier * temp_body.scale.y
		collision_shape_2d.scale.y = crouched_height_multiplier * collision_shape_2d.scale.x
	elif Input.is_action_just_released("crouch"):
		crouching = false
		temp_body.scale.y = original_body_height
		collision_shape_2d.scale.y = original_collision_height
	
	if crouching:
		velocity.x = direction * crouching_speed
	elif Input.is_action_pressed("sprint"):
		velocity.x = direction * running_speed
	else:
		velocity.x = direction * walk_speed
	
	
	
	move_and_slide()
