extends Node2D

@onready var win_animation: AnimationPlayer = $WinScreen/WinAnimation


@export var final_level: bool = false
@export var level_number: int = 0

func _ready() -> void:
	Globals.SHOW_WIN_SCREEN.connect(show_win_screen)
	SceneSwitcher.set_curent_level(level_number)

func show_win_screen():
	if final_level:
		$GameCompleted/WinAnimation.play("You win")
		return
	win_animation.play("You win")
