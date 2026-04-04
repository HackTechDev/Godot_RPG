extends Node2D

@onready var title_label: Label = $CanvasLayer/VBox/Title
@onready var subtitle_label: Label = $CanvasLayer/VBox/Subtitle

func _ready():
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.2)
	tween.tween_interval(0.5)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.5)
	tween.tween_callback(_go_to_main_menu)

func _go_to_main_menu():
	SceneTransition.change_scene("res://UI/main_menu.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_go_to_main_menu()
