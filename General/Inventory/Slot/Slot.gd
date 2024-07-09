extends PanelContainer

signal clicked(index: int, button: int)

@onready var item_texture: TextureRect = $Margin/ItemTexture
@onready var quantity_label: Label = $Margin/QuantityLabel

func set_slot_data(slot_data: SlotData) -> void:
	var item_data: ItemData = slot_data.item_data
	item_texture.texture = item_data.icon
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	 
	quantity_label.text = "x%s" % slot_data.quantity
	quantity_label.visible = slot_data.quantity > 1
	

# NOTE
# Mouse inputs use Enums
# 1 refers to the left mouse button
# 2 refers to the right mouse button
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index in [1, 2] and event.is_pressed():
		clicked.emit(get_index(), event.button_index)
