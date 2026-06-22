extends CanvasLayer

const MAX_LINES := 5

var _history: Array[String] = []
var _labels:  Array[Label]  = []
var _input:   LineEdit

func _ready() -> void:
	layer   = 9
	visible = false
	_build_ui()

func _build_ui() -> void:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.size         = Vector2(0, 148)
	panel.offset_top   = -148
	panel.offset_bottom = 0

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.04, 0.04, 0.04, 0.93)
	bg.border_color = Color(0.0, 0.75, 0.0, 1.0)
	bg.set_border_width_all(1)
	bg.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", bg)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left   =  8
	vbox.offset_top    =  6
	vbox.offset_right  = -8
	vbox.offset_bottom = -6
	vbox.add_theme_constant_override("separation", 1)
	panel.add_child(vbox)

	# 5 lignes d'historique
	for _i in MAX_LINES:
		var lbl := Label.new()
		lbl.text = ""
		lbl.add_theme_color_override("font_color", Color(0.0, 0.85, 0.0))
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.clip_text = true
		lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_labels.append(lbl)
		vbox.add_child(lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0.0, 0.6, 0.0, 0.7))
	vbox.add_child(sep)

	# Ligne de saisie
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 2)
	vbox.add_child(hbox)

	var prompt := Label.new()
	prompt.text = ">"
	prompt.add_theme_color_override("font_color", Color(0.0, 0.85, 0.0))
	prompt.add_theme_font_size_override("font_size", 12)
	hbox.add_child(prompt)

	_input = LineEdit.new()
	_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_input.add_theme_color_override("font_color",       Color(0.0, 0.85, 0.0))
	_input.add_theme_color_override("caret_color",      Color(0.0, 0.85, 0.0))
	_input.add_theme_color_override("selection_color",  Color(0.0, 0.5, 0.0, 0.5))
	_input.add_theme_font_size_override("font_size", 12)
	_input.placeholder_text = ""
	var flat := StyleBoxFlat.new()
	flat.bg_color = Color(0, 0, 0, 0)
	flat.set_border_width_all(0)
	_input.add_theme_stylebox_override("normal", flat)
	_input.add_theme_stylebox_override("focus",  flat)
	_input.connect("text_submitted", _on_submitted)
	hbox.add_child(_input)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F1 and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		toggle()


func toggle() -> void:
	visible = !visible
	if visible:
		_input.grab_focus()
	else:
		_input.release_focus()


func print_line(text: String) -> void:
	_history.append(text)
	if _history.size() > MAX_LINES:
		_history = _history.slice(_history.size() - MAX_LINES)
	_refresh()


func _refresh() -> void:
	var pad := MAX_LINES - _history.size()
	for i in MAX_LINES:
		_labels[i].text = "" if i < pad else _history[i - pad]


func _on_submitted(text: String) -> void:
	var cmd := text.strip_edges()
	_input.clear()
	if cmd == "":
		return
	print_line("> " + cmd)
	_execute(cmd)


func _execute(cmd: String) -> void:
	var parts := cmd.split(" ", false)
	if parts.is_empty():
		return
	match parts[0].to_lower():
		"help":
			print_line("help  clear  pos  level  credits  version")
		"clear":
			_history.clear()
			_refresh()
		"version":
			print_line("Commando Zombi RPG v4")
		"credits":
			print_line("Le Sanglier des Ardennes")
		"pos":
			var player := get_tree().get_first_node_in_group("player") as Node2D
			if player:
				print_line("pos: %.0f, %.0f" % [player.position.x, player.position.y])
			else:
				print_line("joueur introuvable")
		"level":
			print_line("niveau: " + Player_data.player_previous_scene)
		_:
			print_line("inconnu: " + parts[0] + "  (help pour la liste)")
