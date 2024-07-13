class_name RPGPlayerV1
extends CharacterBody2D

@onready var body_collision_shape: CollisionShape2D = $BodyCollisionShape
@onready var animation_sprite: AnimatedSprite2D = %AnimationSprite
# For inventory and general interaction with objects
@onready var mouse_ray_cast: RayCast2D = $MouseRayCast
@onready var directional_ray_cast: RayCast2D = $DirectionalRayCast


@export_category("Player Modifiers")

@export_group("Walking")
@export_range(100.0, 500.0, 1.0, "or_greater") var walking_speed: float = 100.0

@export_group("Running")
@export_range(100.0, 500.0, 1.0, "or_greater") var running_speed: float = 200.0
@export_range(0.0, 10.0, 0.01, "or_greater") var running_animation_modifier: float = 1.0

@export_group("Dashing")
@export_range(100.0, 500.0, 1.0, "or_greater") var dashing_speed: float = 100.0
@export_range(0.0, 10.0, 0.01, "or_greater") var default_dashing_invicible_time: float = 0.5

#@export_group("Crouching")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Getting the players input direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	# Normalising the direction vector (prevents the user from walking faster sideways)
	direction = direction.normalized()
	
	# Setting up raycast directions
	mouse_ray_cast.look_at(get_global_mouse_position())
	directional_ray_cast.look_at(global_position + direction)
	
	# Movement
	
	if Input.is_action_pressed("sprint"):
		velocity = direction * running_speed
	#elif Input.is_action_pressed("crouch"):
		#pass
	else:
		velocity = direction * walking_speed
	
	move_and_slide()
	
	if Input.is_action_just_pressed("sprint"):
		modulate = Color.BLUE
	elif Input.is_action_just_released("sprint"):
		modulate = Color.WHITE
		
	
