extends Node

#obstacles scenes
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/birdie.tscn")

var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
@export var bird_heights := [300, 400]

#game variables
const DINO_START_POS := Vector2i(150, 495)
const CAM_START_POS := Vector2i(576, 324)
var Ground_h : int

var score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
var screen_size : Vector2i
var game_running : bool
var game_paused : bool
var last_obstacle

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	Ground_h = $Ground.get_node("Sprite2D").texture.get_height()
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
			
		#Obstacle spawning
		_obstacles()
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

func _obstacles():
	#Grounded
	if obstacles.is_empty() or last_obstacle.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs = obs_type.instantiate()
		var obs_h = obs.get_node("Sprite2D").texture.get_height()
		var obs_s = obs.get_node("Sprite2D").scale
		var obs_x : int = screen_size.x + score * 100
		var obs_y : int = screen_size.y - Ground_h - (obs_s.y / 2) - 33
		last_obstacle = obs
		_add_obs(obs, obs_x, obs_y)
		
		
		
		
	#Aerial


func _add_obs(obs,x,y):
		obs.position = Vector2i(x, y)
		add_child(obs)
		obstacles.append(obs)
		print("Obstacle Added at: X: ", x, ": Y : ", y)
