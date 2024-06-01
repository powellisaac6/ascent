extends CharacterBody2D

class_name Player

#region Movement
@export var move_speed : float = 75
@export var jump_speed : float = 300
@export var gravity : float = 15
@export var acceleration : float = 0.8
@export var deceleration : float = 0.4
@export var air_deceleration : float = 0.1
#endregion
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var camera : PanCamera = $Camera2D
@onready var collision : CollisionShape2D = $CollisionShape2D
enum PlayerState { IDLE, RUNNING, JUMPING, FALLING, DEAD}
var current_state : PlayerState = PlayerState.IDLE
var multiplier = 100
var jumped : bool = true
var horizontal_input : int
var vertical_input : int
var gravity_enabled : bool = true

var running : bool = false
var jumping : bool = false
@export var facing_right : bool = true
signal dead


# Called when the node enters the scene tree for the first time.
func _ready():
	# get the wind
	
	var wind : WindColumn = get_parent().get_node("WindColumn")
	animator.play("idle")
	# wind.entered_wind.connect(disable_gravity)
	add_to_group("Player")
	name = "Player"
	if !facing_right:
		sprite.flip_h = 1


func get_input():
	# get the input
	horizontal_input = Input.get_axis("left", "right")
	
	if horizontal_input > 0: 
		facing_right = true
	elif horizontal_input < 0: 
		facing_right = false


func _process(delta):
	if facing_right:
		sprite.flip_h = 0
	else:
		sprite.flip_h = 1
		
func _physics_process(delta):
	
	get_input()
	
	if !is_on_floor() and current_state != PlayerState.JUMPING and current_state != PlayerState.DEAD:
		enter_state(PlayerState.FALLING)
	update_state(delta)
	
	
	if gravity_enabled:
		velocity.y += gravity * delta * multiplier
	
	move_and_slide()
	
	# check to see if the player falls below the camera, if so die
	
	if global_position.y >= camera.global_position.y + 180 and current_state != PlayerState.DEAD and GameManager.game_state == GameManager.GameState.GAME:
		death()
	
func running_state(delta):
	
	$ParticleRun.emitting = true
	
	if not AudioManager.run.playing :
		AudioManager.run.play()
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		AudioManager.jump.play()
		velocity.y = -(jump_speed) * multiplier * delta
		enter_state(PlayerState.JUMPING)
		jumped = true
		$ParticleRun.emitting = true
		
	# check if acceleration or decelerating 
	
	if(abs(horizontal_input) > 0): # accelerate 
		velocity.x = lerpf(velocity.x, horizontal_input * move_speed * multiplier * delta, acceleration)
	else: # decelerate
		velocity.x = lerpf(velocity.x, 0, deceleration)
	if abs(velocity.x) <= 0:
		enter_state(PlayerState.IDLE)
		$ParticleRun.emitting = false
	
func idle_state(delta):
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -(jump_speed) *multiplier * delta
		AudioManager.jump.play()
		enter_state(PlayerState.JUMPING)
		
	velocity.x = lerpf(velocity.x, horizontal_input * move_speed * multiplier * delta, acceleration)
	
	if abs(horizontal_input) > 0:
		enter_state(PlayerState.RUNNING)
		
	await get_tree().create_timer(2.0).timeout
	$ParticleFall.emitting = false

func jumping_state(delta):
	
	$ParticleFall.emitting = false
	
	if(abs(horizontal_input) > 0): # accelerate 
		velocity.x = horizontal_input * move_speed * multiplier * delta
	else: # decelerate
		velocity.x = lerpf(velocity.x, 0, air_deceleration)
	
	if sign(velocity.y) > 0:
		enter_state(PlayerState.FALLING)

func falling_state(delta):
	
	$ParticleRun.emitting = false
	
	if(abs(horizontal_input) > 0): # accelerate 
		velocity.x = horizontal_input * move_speed * multiplier * delta
	else: # decelerate
		velocity.x = lerpf(velocity.x, 0, air_deceleration)
		
	if is_on_floor():
		if jumped:
			AudioManager.land.play()
			$ParticleFall.emitting = true
		enter_state(PlayerState.IDLE)

func update_state(delta):
	match current_state:
		PlayerState.IDLE:
			idle_state(delta)
			AudioManager.run.stop()
		PlayerState.RUNNING:
			running_state(delta)
		PlayerState.JUMPING:
			jumping_state(delta)
			AudioManager.run.stop()
		PlayerState.FALLING:
			falling_state(delta)
		_:
			pass
			
func enter_state(new_state: PlayerState):
	animator.stop()
	current_state = new_state
	match new_state:
		PlayerState.IDLE:
			animator.play("idle")
		PlayerState.RUNNING:
			animator.play("run")
		PlayerState.JUMPING:
			animator.play("jump")
		PlayerState.FALLING:
			animator.play("jump")
		PlayerState.DEAD:
			print("Player has died")
		_:
			pass
		
func disable_gravity():
	gravity_enabled = false
	
	
func enable_gravity():
	gravity_enabled = true
	
func death():
	dead.emit()
	collision.disabled = true
	velocity = Vector2.ZERO
	enter_state(PlayerState.DEAD)
