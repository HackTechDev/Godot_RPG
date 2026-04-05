extends CanvasLayer

@onready var npc_name_label: Label = $Panel/Margin/VBox/NPCName
@onready var dialogue_text: Label = $Panel/Margin/VBox/DialogueText
@onready var choices_container: VBoxContainer = $Panel/Margin/VBox/Choices
@onready var next_button: Button = $Panel/Margin/VBox/NextButton

var _current_dialogue: Dictionary = {}
var _pending_next_key = null

func open(p_npc_name: String, p_dialogue: Dictionary) -> void:
	npc_name_label.text = p_npc_name
	_current_dialogue = p_dialogue
	visible = true
	get_tree().paused = true
	_show_node("start")

func _show_node(key) -> void:
	if key == null or not _current_dialogue.has(key):
		_close()
		return

	var node: Dictionary = _current_dialogue[key]
	dialogue_text.text = node.get("text", "")

	for child in choices_container.get_children():
		child.queue_free()

	var choices: Array = node.get("choices", [])

	if choices.size() > 1:
		choices_container.visible = true
		next_button.visible = false
		for choice in choices:
			var btn := Button.new()
			btn.text = choice.get("text", "")
			var next_key = choice.get("next", null)
			btn.pressed.connect(func(): _show_node(next_key))
			btn.add_theme_font_size_override("font_size", 12)
			choices_container.add_child(btn)
	else:
		choices_container.visible = false
		next_button.visible = true
		if choices.size() == 1:
			next_button.text = choices[0].get("text", "Suivant")
			_pending_next_key = choices[0].get("next", null)
		else:
			next_button.text = "Fermer"
			_pending_next_key = null

func _on_next_button_pressed() -> void:
	_show_node(_pending_next_key)

func _close() -> void:
	visible = false
	get_tree().paused = false
