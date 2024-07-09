class_name PlatformerPlayerV1
extends CharacterBody2D

signal toggle_inventory

@onready var temp_body: MeshInstance2D = $TempBody
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var keyed_raycast: RayCast2D = $KeyedRayCast
@onready var mouse_ray_cast: RayCast2D = $MouseRayCast

@export_category("Player Statistics")

@export_group("Inventories")
@export var inventory: InventoryData = null
@export var equipment_inventory: EquipmentInventoryData = null

@export_group("Speed Defaults")
@export_range(1.0, 100.0, 10.0, "or_greater") var walk_speed: float = 150.0
@export_range(1.0, 100.0, 10.0, "or_greater") var running_speed: float = 200.0
# NOTE, the following variable is for the maximum downward speed of the player, this will help reduce engine collision bugs like fazing through the floor
#@export_range(100.0, 1000.0, 10.0, "or_greater") var max_falling_velovity: float = 600.0

@export_group("Dash Defaults")
@export_range(1.0, 100.0, 1.0, "or_greater") var dash_speed: float = 400.0
@export_range(0.0, 5.0) var default_dash_time: float = 0.2
@export_range(0.0, 5.0) var default_dash_interval: float = 1.0

@export_group("Jump Defaults")
@export_range(1.0, 100.0, 1.0, "or_greater") var jump_strength: float = 400.0
@export_range(1, 2, 1, "or_greater") var default_jumps: int = 2
@export_range(1, 2, 1, "or_greater") var default_wall_jumps: int = 1

@export_group("Crouching Deafaults")
@export_range(1.0, 100.0, 1.0, "or_greater") var crouching_speed: float = 50.0
@export_range(0.0, 1.0) var crouched_height_multiplier: float = 0.75

@export_subgroup("Other Variables")

var original_collision_height: float = 0.0
var original_body_height: float = 0.0
var dash_time: float = default_dash_time
var dash_interval: float = 0.0
var dashing: bool = false
# NOTE: default gravity = 980 but it is a little to strong for the size of the player etc
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") / 50 
# Setting default dash direction to the right since that will most likely be the direction of the sprite
var direction_buffer: int = 1
var jumps: int = default_jumps
var wall_jumps: int = default_wall_jumps
var crouching: bool = false

func _ready() -> void:
	PlayerManager.player = self
	original_body_height = temp_body.scale.y
	original_collision_height = collision_shape_2d.scale.y

func _physics_process(delta: float) -> void:
	
	mouse_ray_cast.look_at(get_global_mouse_position())
	
	# Linear acceleration for gravity towards the floor
	velocity.y += gravity
	
	dash_interval -= delta
	
	# NOTE direction buffer is a float which dictates the x direction of the last move
	if Input.is_action_just_pressed("dash") and not dashing and dash_interval <= 0.0:
		dashing = true
	
	if dashing and not crouching:
		velocity.x = direction_buffer * dash_speed
		dash_time -= delta
		temp_body.self_modulate = Color.RED
		if dash_time <= 0.0:
			temp_body.self_modulate = Color.WHITE
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
		keyed_raycast.target_position.x = 50
	elif direction < 0:
		direction_buffer = -1
		keyed_raycast.target_position.x = -50
	
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

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		interact()

func interact() -> void:
	if keyed_raycast.is_colliding():
		keyed_raycast.get_collider().player_interact()
	elif mouse_ray_cast.is_colliding() and \
			mouse_ray_cast.get_collider().has_method("player_interact"):
		mouse_ray_cast.get_collider().player_interact()
	else:
		toggle_inventory.emit()

func heal(_heal_value: float) -> void:
	print("Healing.")
