extends CanvasLayer

const SCROLL_SPEED = 55.0

@onready var credits_panel: VBoxContainer = $CreditsPanel
@onready var _music: AudioStreamPlayer = $Music

func _ready():
	get_tree().paused = false
	if not GameConfig.intro_music_enabled:
		_music.stop()
	SceneTransition.fade_in()
	await get_tree().process_frame
	credits_panel.position.y = get_viewport().get_visible_rect().size.y

func _process(delta):
	credits_panel.position.y -= SCROLL_SPEED * delta
	if credits_panel.position.y + credits_panel.size.y < 0:
		get_tree().quit()

func _input(event):
	if (event is InputEventKey and event.pressed) or \
	   (event is InputEventMouseButton and event.pressed):
		get_tree().quit()
