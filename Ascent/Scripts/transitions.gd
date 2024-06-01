extends Control

class_name Transition

@onready var animation_tex : TextureRect = $TextureRect
@onready var animator : AnimationPlayer = $AnimationPlayer

@export var scene_switch_anim : String = "fade_out"

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tex.visible = false
	

func set_next_animation(fading_out: bool):
	if fading_out:
		animator.queue("fade_out")
	else: 
		animator.queue("fade_in")
		

		
	
