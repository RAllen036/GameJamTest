extends Node2D

@onready var player: PlatformerPlayerV1 = $Player
@onready var tile_map: TileMap = $TileMap
@onready var player_inventory: PanelContainer = %PlayerInventory
@onready var inventory_interface: InventoryInterface = $UI/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = %HotBarInventory
@onready var equipment_inventory: PanelContainer = %EquipmentInventory
@onready var items: Node2D = $Items

@export var packed_pickup: PackedScene

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory)
	inventory_interface.force_close.connect(toggle_inventory)
	inventory_interface.set_player_inventory_data(player.inventory)
	inventory_interface.set_equipment_inventory_data(player.equipment_inventory)
	hot_bar_inventory.set_inventory_data(player.inventory)
	
	for node in tile_map.get_children():
		if not node.is_in_group("chest"):
			continue
		node.toggle_inventory.connect(toggle_inventory)

func toggle_inventory(ext_inv_owner = null) -> void:
	player_inventory.visible = not player_inventory.visible
	equipment_inventory.visible = player_inventory.visible
	hot_bar_inventory.visible = not player_inventory.visible
	if ext_inv_owner and player_inventory.visible:
		inventory_interface.set_external_inventory(ext_inv_owner)
	else:
		inventory_interface.clear_ext_inv()

func _on_tile_map_child_entered_tree(node: Node) -> void:
	if node.is_in_group("chest"):
		node.toggle_inventory.connect(toggle_inventory)

func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pickup := packed_pickup.instantiate()
	pickup.name = slot_data.item_data.name
	pickup.slot_data = slot_data
	pickup.global_position = player.global_position + Vector2(30, 5) * player.direction_buffer
	items.add_child(pickup)
