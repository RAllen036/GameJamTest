class_name ItemData
extends Resource

@export_placeholder("Enter Item Name") var name: String
@export_multiline var description: String
@export var stackable: bool = true
@export var icon: AtlasTexture

func use(_target) -> void:
	pass
