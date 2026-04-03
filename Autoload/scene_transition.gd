extends CanvasLayer

var overlay: ColorRect

func _ready():
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

func change_scene(path: String):
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.35)
	tween.tween_callback(func(): get_tree().change_scene_to_file(path))

func fade_in():
	overlay.color.a = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 0.35)
