extends Node

@onready var track_1 = $Track1
@onready var jump = $Jump
@onready var land = $Land
@onready var run = $Run
@onready var wind = $Wind
@onready var game_over = $GameOver
@onready var menu = $Menu

var SOUND_OFF : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if SOUND_OFF:
		track_1.playing = false
		jump.playing = false
		land.playing = false
		run.playing = false
		wind.playing = false
		game_over.playing = false
		menu.playing = false
