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
var game_paused : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	new_game()

func new_game():
	#reset the nodes & score
	game_running = false  # Changed: game doesn't start automatically
	game_paused = false
	score = 0
	UI()
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	$Ui.get_node("StartGame").show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle pause toggle
	if Input.is_action_just_pressed("PAUSE"):
		if game_running:
			game_paused = !game_paused  # Toggle pause state
			if game_paused:
				set_physics_process(false)  # Stop physics when paused
			else:
				set_physics_process(true)   # Resume physics when unpaused
	
	# Handle start game
	if Input.is_action_just_pressed("START") and !game_running:
		game_running = true
		game_paused = false
		$Ui.get_node("StartGame").hide()
		set_physics_process(true)  # Enable physics when game starts
	
	# Update UI every frame
	UI()

func _physics_process(delta):
	if game_running and !game_paused:
		# Update speed based on score
		speed = START_SPEED + score / 500
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		
		# Update score
		score += 1.5
		
		# Move dino and camera
		$Dino.position.x += speed
		$Camera2D.position.x += speed

		# Ground update
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		# Spawn obstacles logic would go here
	else:
		set_physics_process(false)
func UI():
	$Ui.get_node("Scorelabel").text = "Dino's Score: " + str(floor(score))
	$Ui.get_node("DinoSpeed").text = str(floor(speed)) + " M/s"
	
	if !game_running:
		$Ui.get_node("StartGame").text = "Press Enter to Play!"
		$Ui.get_node("StartGame").show()
	elif game_paused:
		$Ui.get_node("StartGame").text = "PAUSED - Press P to Resume"
		$Ui.get_node("StartGame").show()
	else:
		$Ui.get_node("StartGame").hide()
