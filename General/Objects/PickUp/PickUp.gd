extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite

@export var slot_data: SlotData = null

func _ready() -> void:
	sprite.texture = slot_data.item_data.icon

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	
	if body.inventory.pick_up_slot_data(slot_data):
		queue_free()
