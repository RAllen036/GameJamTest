# NOTE Player Manager
extends Node

var player: CharacterBody2D

func create_player() -> CharacterBody2D:
	return null

func create_new_player_inventory(inv_data: InventoryData = null) -> InventoryData:
	if not inv_data:
		var new_inv_data: InventoryData = InventoryData.new()
		for i in range(0, 7): new_inv_data.data.append(SlotData.new())
		return new_inv_data
	
	return inv_data

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)

func get_player_global_position() -> Vector2:
	return player.global_position
