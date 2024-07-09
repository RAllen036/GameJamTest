class_name InventoryInterface
extends Control

signal drop_slot_data(slot_data: SlotData)
signal force_close

@onready var player_inventory: PanelContainer = %PlayerInventory
@onready var grabbed_slot: PanelContainer = %GrabbedSlot
@onready var equipment_inventory: PanelContainer = %EquipmentInventory
@onready var extra_inventory: PanelContainer = %ExtraInventory

var grabbed_slot_data: SlotData
var extra_inv_owner

func _physics_process(_delta: float) -> void:
	if grabbed_slot_data:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2.ONE * 5
	
	if extra_inv_owner \
		and \
		extra_inv_owner.global_position.distance_to(PlayerManager.get_player_global_position()) > 100:
			force_close.emit()

func set_player_inventory_data(inv_data: InventoryData) -> void:
	inv_data.inv_interact.connect(on_inv_interact)
	player_inventory.set_inventory_data(inv_data)

func set_equipment_inventory_data(inv_data: InventoryData) -> void:
	inv_data.inv_interact.connect(on_inv_interact)
	equipment_inventory.set_inventory_data(inv_data)

func on_inv_interact(inv_data: InventoryData, index: int, button: int) -> void:
	
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inv_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inv_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			inv_data.use_slot(index)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inv_data.drop_single_slot_data(grabbed_slot_data, index)
		
	 
	update_grabbed_slot()
	

func update_grabbed_slot() -> void:
	if not grabbed_slot_data:
		grabbed_slot.hide()
		return
	
	grabbed_slot.show()
	grabbed_slot.set_slot_data(grabbed_slot_data)

func set_external_inventory(external_inv_owner) -> void:
	extra_inv_owner = external_inv_owner
	var inv_data: InventoryData = external_inv_owner.inventory
	
	inv_data.inv_interact.connect(on_inv_interact)
	extra_inventory.set_inventory_data(inv_data)
	
	extra_inventory.show()

func clear_ext_inv() -> void:
	if not extra_inv_owner:
		return
	
	var inv_data: InventoryData = extra_inv_owner.inventory
	
	inv_data.inv_interact.disconnect(on_inv_interact)
	extra_inventory.clear_inventory_data(inv_data)
	
	extra_inventory.hide()
	extra_inv_owner = null
	

func _on_gui_input(event: InputEvent) -> void:
	if not grabbed_slot_data or not event is InputEventMouseButton:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
		if grabbed_slot_data.quantity <= 0:
			grabbed_slot_data = null
		update_grabbed_slot()

func _on_visibility_changed() -> void:
	if not visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
