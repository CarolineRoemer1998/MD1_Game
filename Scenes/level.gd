extends Node2D

@onready var win_animation: AnimationPlayer = $WinScreen/WinAnimation

@export var level_number: int = 0

func _ready() -> void:
	Globals.SHOW_WIN_SCREEN.connect(show_win_screen)
	SceneSwitcher.set_curent_level(level_number)

func show_win_screen():
	win_animation.play("You win")
