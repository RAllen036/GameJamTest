# NOTE Player Manager
extends Node

var player: CharacterBody2D

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)

func get_player_global_position() -> Vector2:
	return player.global_position
