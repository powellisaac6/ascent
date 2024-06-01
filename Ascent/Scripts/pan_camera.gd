extends Camera2D

class_name PanCamera
const SCREEN_SIZE : Vector2 = Vector2(320, 180)
const TRANSITION_SPEED := 5.0  # Adjust this value to control the speed of the transition

enum CameraState { GAME, GAMEOVER }
var current_state : CameraState = CameraState.GAME
var cur_screen := Vector2(0, 0)
var target_position := Vector2()

func _ready():
	print(global_position)
	set_as_top_level(true)
	global_position = get_parent().global_position
	target_position = global_position
	_update_screen(cur_screen)
	GameManager.game_started.connect(enter_state, CameraState.GAME)

func _physics_process(delta):
	update_state(delta)

func _update_screen(new_screen: Vector2):
	cur_screen = Vector2(new_screen.x, min(new_screen.y, cur_screen.y))
	target_position = (cur_screen * SCREEN_SIZE) + SCREEN_SIZE * 0.5
	
func update_state(delta):
	match current_state:
		CameraState.GAME:
			var parent_screen: Vector2 = (get_parent().global_position / SCREEN_SIZE).floor()
			if not parent_screen.is_equal_approx(cur_screen):
				_update_screen(parent_screen)
			# Smoothly interpolate the camera's position towards the target position
			global_position = global_position.lerp(target_position, TRANSITION_SPEED * delta)
			global_position.x = clamp(get_parent().global_position.x, SCREEN_SIZE[0] / 2, 640 - SCREEN_SIZE[0] / 2)
		CameraState.GAMEOVER:
			pass
func enter_state(new_state: CameraState):
	current_state = new_state
	match new_state:
		CameraState.GAME:
			var player = get_parent() as Player
			var spawn_points = GameManager.spawn_points
			var latest = spawn_points[spawn_points.size() - 1]
			cur_screen = Vector2(latest.global_position.x, spawn_points.size() - 1)
			target_position = (cur_screen * SCREEN_SIZE) + SCREEN_SIZE * 0.5
			global_position = target_position
			player.global_position = latest.global_position if spawn_points.size() > 0 else GameManager.spawn.global_position
			player.collision.disabled = false
			player.enter_state(Player.PlayerState.IDLE)
			print(player.global_position)
		CameraState.GAMEOVER:
			pass
			
