extends Node

#obstacles scenes
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/birdie.tscn")

var obstacle := [stump_scene, rock_scene, barrel_scene]

#game variables
const DINO_START_POS := Vector2i(150, 495)
const CAM_START_POS := Vector2i(576, 324)

var score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
var screen_size : Vector2i
var game_running : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	new_game()

func new_game():
	#reset the nodes & score
	score = 0
	Score()
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	$Ui.get_node("StartGame").show()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_running:

		speed = START_SPEED + score / 500
		score += 1.5
		Score()
		print("Dino Score: ", score)
		print("Dino Speed: ", speed)
		$Dino.position.x += speed
		$Camera2D.position.x += speed

		#Ground update
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
	
	else:
		if Input.is_action_just_pressed("START"):
			game_running = true
			$Ui.get_node("StartGame").hide()

			
func Score():
	$Ui.get_node("Scorelabel").text = "Dino's Score: " + str(score)
	$Ui.get_node("DinoSpeed").text = str(speed) + " M/s"
