extends CanvasLayer

signal _space_pressed

@onready var label_message: Label = $Panel/Margin/VBox/LabelMessage
@onready var label_dice: Label = $Panel/Margin/VBox/LabelDice
@onready var label_result: Label = $Panel/Margin/VBox/LabelResult
@onready var label_prompt: Label = $Panel/Margin/VBox/LabelPrompt

var _waiting_for_space: bool = false
var _cancelled: bool = false

func _ready():
	visible = false

func _unhandled_input(event: InputEvent):
	if _waiting_for_space and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_waiting_for_space = false
		_space_pressed.emit()

# Annule toute attente en cours et cache l'overlay
func cancel() -> void:
	_cancelled = true
	visible = false
	if _waiting_for_space:
		_waiting_for_space = false
		_space_pressed.emit()

# Attend que le joueur appuie sur Espace, puis défile et retourne le résultat
func prompt_player_roll(message: String) -> int:
	_cancelled = false
	visible = true
	label_message.text = message
	label_dice.text = "?"
	label_result.text = ""
	label_prompt.text = "[ ESPACE ] Lancer le dé"
	label_prompt.add_theme_color_override("font_color", Color(1.0, 1.0, 0.4))

	_waiting_for_space = true
	await _space_pressed
	if _cancelled:
		return -1

	label_prompt.text = ""
	var final_value = randi_range(1, 20)
	await _scroll_dice(final_value)
	return final_value

# Lancer automatique (ennemi), défile puis retourne le résultat
func auto_roll(message: String) -> int:
	_cancelled = false
	visible = true
	label_message.text = message
	label_dice.text = "?"
	label_result.text = ""
	label_prompt.text = ""

	await get_tree().create_timer(0.4).timeout
	if _cancelled:
		return -1
	var final_value = randi_range(1, 20)
	await _scroll_dice(final_value)
	return final_value

func show_result(text: String, success: bool):
	label_result.text = text
	var color = Color(0.4, 1.0, 0.4) if success else Color(1.0, 0.4, 0.4)
	label_result.add_theme_color_override("font_color", color)

func wait_for_continue() -> void:
	label_prompt.text = "[ ESPACE ] Continuer"
	label_prompt.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_waiting_for_space = true
	await _space_pressed
	label_prompt.text = ""

func show_game_over_screen() -> void:
	_cancelled = false
	visible = true
	label_message.text = "GAME OVER"
	label_message.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	label_dice.text = ""
	label_result.text = ""
	label_prompt.text = "[ ESPACE ] Recommencer"
	label_prompt.add_theme_color_override("font_color", Color(1.0, 1.0, 0.4))
	_waiting_for_space = true
	await _space_pressed

func hide_ui():
	visible = false

func _scroll_dice(final_value: int) -> void:
	var steps = 15
	var delay = 0.04
	for i in range(steps):
		if _cancelled:
			return
		label_dice.text = str(randi_range(1, 20))
		await get_tree().create_timer(delay).timeout
		delay += 0.016
	if _cancelled:
		return
	label_dice.text = str(final_value)
	await get_tree().create_timer(0.3).timeout
