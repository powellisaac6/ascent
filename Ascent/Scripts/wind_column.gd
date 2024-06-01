extends Area2D

class_name WindColumn

@export var wind_speed = 650
@onready var timer = $Timer
@export var switch_time : float = 3
@onready var animator = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
var up = preload("res://Sprites/up.png")
var down = preload("res://Sprites/down.png")
var left = preload("res://Sprites/left.png")
var right = preload("res://Sprites/right.png")

var multiplier : int = 100
var drag : float = 0.2
var player : Player = null

enum WindState{UP,DOWN,RIGHT,LEFT}
@export var wind_state : WindState = WindState.UP
var initial_state : WindState
@export var other_state : WindState = WindState.DOWN
var cur_state : WindState
@onready var collision_box : CollisionShape2D  = $Area2D/CollisionShape2D

signal entered_wind
signal exit_wind

func _ready():
	var p = GameManager.current_scene.get_node("Player") as Player
	initial_state = wind_state
	
	match wind_state:
		WindState.UP:
			animator.play("up")
		WindState.DOWN:
			animator.play("down")
		WindState.LEFT:
			animator.play("left")
		WindState.RIGHT:
			animator.play("right")
	
	entered_wind.connect(p.disable_gravity)
	exit_wind.connect(p.enable_gravity)
	timer.timeout.connect(switch_state)
	timer.wait_time = switch_time
	timer.start()
	
func _process(delta):
	
	if player: 
		var wind_dir: Vector2 = Vector2(0,0)
		match wind_state:
			WindState.UP:
				wind_dir = Vector2(0, -1)
				player.velocity = lerp(player.velocity, wind_dir * wind_speed * multiplier * delta, drag)
			WindState.DOWN:
				wind_dir = Vector2(0,1)
				player.velocity = lerp(player.velocity, wind_dir * wind_speed * multiplier * delta, drag)
			WindState.RIGHT:
				wind_dir = Vector2(1,0)
				player.velocity = lerp(player.velocity, wind_dir * wind_speed * multiplier * delta, drag)
				player.move_and_slide()
			WindState.LEFT:
				wind_dir = Vector2(-1,0)
				player.velocity = lerp(player.velocity, wind_dir * wind_speed * multiplier * delta, drag)
				player.move_and_slide()
	
func _on_body_entered(body):
	
	if body.is_in_group("Player"):
		
		if not AudioManager.wind.playing :
			AudioManager.wind.play()
		
		player = body as Player
		if wind_state == WindState.UP:
			entered_wind.emit()

func _on_body_exited(body):
	
	exit_wind.emit()
	player = null

func switch_state():
	
	if wind_state != initial_state:
		wind_state = initial_state
	else:
		wind_state = other_state
	
	match wind_state:
		WindState.UP:
			animator.play("up")
		WindState.DOWN:
			animator.play("down")
		WindState.LEFT:
			animator.play("left")
		WindState.RIGHT:
			animator.play("right")
