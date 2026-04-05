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

func _go_to_main_menu():
	SceneTransition.change_scene("res://UI/main_menu.tscn")

func _input(event):
	if event is InputEventKey and event.pressed:
		_go_to_main_menu()
