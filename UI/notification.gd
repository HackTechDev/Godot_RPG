extends CanvasLayer

@onready var panel: PanelContainer = $Panel

func _ready():
	visible = false
	EventBus.item_collected.connect(_on_item_collected)

func _on_item_collected(text: String):
	$Panel/Margin/Label.text = text
	panel.modulate.a = 1.0
	visible = true
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): visible = false)
