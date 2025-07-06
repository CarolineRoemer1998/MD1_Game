extends Button

const HOVER_SOUND = "res://Sounds/step4.mp3"
const PRESS_SOUND = "res://Sounds/Push Button 4.mp3"

func _ready():
	# Delay hover sound until after the first frame
	await get_tree().process_frame

	focus_entered.connect(self._on_focus_entered)
	pressed.connect(self._on_button_pressed)
	
func _on_focus_entered():
	AudioManager.play_sfx(HOVER_SOUND)
		
func _on_button_pressed():
	AudioManager.play_sfx(PRESS_SOUND)
