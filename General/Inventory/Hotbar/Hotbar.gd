extends PanelContainer

signal  hotbar_use(index: int)

@onready var slot_container: HBoxContainer = %SlotContainer

@export var packed_slot: PackedScene

# For controller inputs later
func _unhandled_input(event: InputEvent) -> void:
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return
	
	if range(KEY_1, KEY_8).has(event.keycode):
		hotbar_use.emit(event.keycode - KEY_1)

func set_inventory_data(inv_data: InventoryData) -> void:
	inv_data.inv_updated.connect(populate_hotbar)
	hotbar_use.connect(inv_data.use_slot)
	populate_hotbar(inv_data)

func populate_hotbar(inv_data: InventoryData) -> void:
	for slot in slot_container.get_children():
		slot.queue_free()
	
	for slot_data in inv_data.data.slice(0, 8):
		var new_slot := packed_slot.instantiate()
		slot_container.add_child(new_slot)
		
		if slot_data:
			new_slot.set_slot_data(slot_data)
