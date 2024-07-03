class_name SlotData
extends Resource

const MAX_STACK_SIZE: int = 99

@export var item_data: ItemData
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1:
	set(v):
		if not item_data.stackable:
			push_warning("Item %s is not stackable, value set to 1." % [item_data.name])
			v = 1
		quantity = v
