extends CharacterBody2D

class_name MergedCreature

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func appear():
	animation_player.play("Appear")

func emit_hearts():
	gpu_particles_2d.emitting = true
