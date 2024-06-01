extends Node

var current_scene = null
var start_button : BaseButton = null
var quit_button : BaseButton = null

var player : Player = null
var camera : Camera2D = null
var spawn_points : Array[Node2D] = []
var spawn : Node2D
enum GameState { START, GAME, GAMEOVER }
var game_state : GameState = GameState.START
signal game_started
signal game_ended
@export var DEBUG_MODE : bool = false

@onready var transitioner = $CanvasLayer/Transitions
@onready var animator = $CanvasLayer/Transitions/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	if !DEBUG_MODE:
		var root = get_tree().root
		current_scene = root.get_child(root.get_child_count() - 1)
		# connect button signals to call back functions
		AudioManager.menu.play()
		load_menu()
		animator.animation_finished.connect(on_transition_finished)

func start_game():
	print("starting game")
	animator.play("fade_out")

func quit_game():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	
func load_menu():
	#transitioner = current_scene.get_node("UI/CanvasLayer/Transitions")
	#animator = transitioner.get_node("AnimationPlayer")
	start_button = current_scene.get_node("Start")
	quit_button = current_scene.get_node("Quit")
	start_button.pressed.connect(start_game)
	quit_button.pressed.connect(quit_game)

func load_scene(path, isGame: bool):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	call_deferred("_deferred_goto_scene", path, isGame)
 
func _deferred_goto_scene(path, isGame):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	
	if isGame:
		AudioManager.menu.stop()
		AudioManager.track_1.play()
		enter_state(GameState.GAME)

func find_player():
	player = current_scene.get_node("Player")
	camera = player.get_node("Camera2D")
	player.dead.connect(game_over)
	

func update_state(delta):
	match game_state:
		GameState.START:
			pass
		GameState.GAME:
			
			pass
		GameState.GAMEOVER:
			pass
			
func enter_state(new_state: GameState):
	game_state = new_state
	match new_state:
		GameState.START:
			spawn_points = []
			pass
		GameState.GAME:
			game_started.emit()
			animator.play("fade_in")
			spawn = current_scene.get_node("SpawnPoints").get_child(0)
			find_player()
		GameState.GAMEOVER:
			AudioManager.game_over.play()
			animator.play("fade_out")
			
func game_over():
	enter_state(GameState.GAMEOVER)
	
func restart():
	player.camera.enter_state(PanCamera.CameraState.GAME)
	
	
func on_transition_finished(anim_name):
	print("animation finished")
	if anim_name == transitioner.scene_switch_anim:
		if game_state == GameState.START: 
			load_scene("res://Levels/game.tscn", true)
		elif game_state == GameState.GAMEOVER: 
			print("restarting")
			enter_state(GameState.GAME)
	else:
		restart()
