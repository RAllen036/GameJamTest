class_name Consumable
extends ItemData

@export_range(1.0, 10.0, 1.0, "or_greater") var heal_value: float

func use(target) -> void:
	target.heal(heal_value)
