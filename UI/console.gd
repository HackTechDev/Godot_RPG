extends CanvasLayer

const MAX_LINES := 5

var _history: Array[String] = []
var _labels:  Array[Label]  = []
var _line_edit:   LineEdit

func _ready() -> void:
	layer        = 9
	visible      = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _build_ui() -> void:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top    = -148
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

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 2)
	vbox.add_child(hbox)

	var prompt := Label.new()
	prompt.text = ">"
	prompt.add_theme_color_override("font_color", Color(0.0, 0.85, 0.0))
	prompt.add_theme_font_size_override("font_size", 12)
	hbox.add_child(prompt)

	_line_edit = LineEdit.new()
	_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_line_edit.add_theme_color_override("font_color",      Color(0.0, 0.85, 0.0))
	_line_edit.add_theme_color_override("caret_color",     Color(0.0, 0.85, 0.0))
	_line_edit.add_theme_color_override("selection_color", Color(0.0, 0.5, 0.0, 0.5))
	_line_edit.add_theme_font_size_override("font_size", 12)
	_line_edit.placeholder_text = ""
	var flat := StyleBoxFlat.new()
	flat.bg_color = Color(0, 0, 0, 0)
	flat.set_border_width_all(0)
	_line_edit.add_theme_stylebox_override("normal", flat)
	_line_edit.add_theme_stylebox_override("focus",  flat)
	# Pas de connexion text_submitted — on intercepte Enter nous-mêmes
	hbox.add_child(_line_edit)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F1:
		get_viewport().set_input_as_handled()
		toggle()
		return
	if not visible:
		return
	if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		get_viewport().set_input_as_handled()
		var cmd := _line_edit.text.strip_edges()
		_line_edit.clear()
		if cmd != "":
			print_line("> " + cmd)
			_execute(cmd)


func toggle() -> void:
	visible = !visible
	GameConfig.console_open = visible
	if visible:
		_line_edit.grab_focus()
	else:
		_line_edit.release_focus()


func print_line(text: String) -> void:
	_history.append(text)
	if _history.size() > MAX_LINES:
		_history = _history.slice(_history.size() - MAX_LINES)
	_refresh()


func _refresh() -> void:
	var pad := MAX_LINES - _history.size()
	for i in MAX_LINES:
		_labels[i].text = "" if i < pad else _history[i - pad]


func _execute(cmd: String) -> void:
	var parts := cmd.split(" ", false)
	if parts.is_empty():
		return
	match parts[0].to_lower():
		"help":
			print_line("help  clear  pos  level  credits  version  debug")
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
		"debug":
			print_line("sfx:%s vol:%.2f  music:%s" % [GameConfig.sfx_enabled, GameConfig.sfx_volume_linear, GameConfig.intro_music_enabled])
			print_line("speed:%d/%d  cone:%s  aim:%s" % [GameConfig.player_speed_normal, GameConfig.player_speed_slow, GameConfig.show_cone, GameConfig.show_aim_line])
			print_line("dbg_hitbox:%s  dbg_coll:%s  dbg_tiles:%s" % [GameConfig.debug_show_hitbox, GameConfig.debug_show_collision, GameConfig.debug_show_tile_collisions])
			print_line("DEBUG:%s  console_open:%s" % [GameConfig.DEBUG, GameConfig.console_open])
		_:
			print_line("inconnu: " + parts[0] + "  (help pour la liste)")
