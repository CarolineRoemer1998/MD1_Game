extends Node2D

@onready var win_animation: AnimationPlayer = $WinScreen/WinAnimation

func _ready() -> void:
	Globals.SHOW_WIN_SCREEN.connect(show_win_screen)

func show_win_screen():
	win_animation.play("You win")
