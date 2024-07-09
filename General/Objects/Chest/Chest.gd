extends StaticBody2D

signal toggle_inventory(ext_inv_owner)

@export var inventory: InventoryData

func player_interact() -> void:
	toggle_inventory.emit(self)
