extends Node

#obstacles scenes
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/birdie.tscn")

var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
@export var bird_heights := [450, 365]

#game variables
const DINO_START_POS := Vector2i(150, 495)
const CAM_START_POS := Vector2i(576, 324)
var Ground_h : int

var score : int
var high_score : int  # Add high score variable
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
var screen_size : Vector2i
var game_running : bool
var game_paused : bool

# Obstacle spawning variables
var next_obstacle_distance : float = 0
const MIN_OBSTACLE_DISTANCE = 700
const MAX_OBSTACLE_DISTANCE = 900
var last_obstacle_x : float = 0

# Bird cooldown variables
var bird_cooldown_until : float = 0
const BIRD_COOLDOWN_DISTANCE = 500
const BIRD_SPAWN_CHANCE = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	Ground_h = $Ground.get_node("Sprite2D").texture.get_height()
	load_high_score()  # Load saved high score
	new_game()

func new_game():
	#reset the nodes & score
	game_running = false
	game_paused = false
	score = 0
	
	# Clear existing obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	# Reset spawning variables
	next_obstacle_distance = MIN_OBSTACLE_DISTANCE
	last_obstacle_x = 0
	bird_cooldown_until = 0
	
	UI()
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	$Ui.get_node("StartGame").show()
	
	set_physics_process(false)

func _process(delta):
	# Handle pause toggle
	if Input.is_action_just_pressed("PAUSE"):
		if game_running:
			game_paused = !game_paused
			set_physics_process(!game_paused)
	
	# Handle start game
	if Input.is_action_just_pressed("START") and !game_running:
		game_running = true
		game_paused = false
		$Ui.get_node("StartGame").hide()
		set_physics_process(true)
	
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
		
		# Check for new high score
		if floor(score) > high_score:
			high_score = floor(score)
			save_high_score()  # Save when high score is beaten
		
		# Move dino and camera
		$Dino.position.x += speed
		$Camera2D.position.x += speed

		# Ground update
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		# Obstacle spawning
		_obstacles()
	
func UI():
	$Ui.get_node("Scorelabel").text = "Score: " + str(floor(score))
	$Ui.get_node("HighScoreLabel").text = "High Score: " + str(high_score)  # Add this label
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
	var camera_x = $Camera2D.position.x
	
	if camera_x >= next_obstacle_distance:
		var distance_to_next = randi_range(MIN_OBSTACLE_DISTANCE, MAX_OBSTACLE_DISTANCE)
		next_obstacle_distance = camera_x + distance_to_next
		
		var can_spawn_bird = camera_x >= bird_cooldown_until
		var should_spawn_bird = false
		if can_spawn_bird:
			should_spawn_bird = randi() % 100 < BIRD_SPAWN_CHANCE
		
		if should_spawn_bird:
			var bird = bird_scene.instantiate()
			var bird_y = bird_heights[randi() % bird_heights.size()]
			var obs_x = camera_x + screen_size.x + 100
			_add_obs(bird, obs_x, bird_y)
			bird_cooldown_until = camera_x + BIRD_COOLDOWN_DISTANCE
			print("Bird spawned at Y: ", bird_y)
		else:
			var obs_type = obstacle_types[randi() % obstacle_types.size()]
			var obs = obs_type.instantiate()
			var obs_x = camera_x + screen_size.x + 100
			var obs_h = obs.get_node("Sprite2D").texture.get_height()
			var obs_s = obs.get_node("Sprite2D").scale
			var obs_y = screen_size.y - Ground_h - (obs_h * obs_s.y / 2) - 30
			_add_obs(obs, obs_x, obs_y)
	
	for i in range(obstacles.size() - 1, -1, -1):
		if obstacles[i].position.x < camera_x - screen_size.x:
			obstacles[i].queue_free()
			obstacles.remove_at(i)

func _add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)

# Score saving functions
func save_high_score():
	var config = ConfigFile.new()
	var save_path = "user://highscore.cfg"
	
	config.set_value("score", "high_score", high_score)
	config.save(save_path)
	print("High score saved: ", high_score)

func load_high_score():
	var config = ConfigFile.new()
	var save_path = "user://highscore.cfg"
	
	if config.load(save_path) == OK:
		high_score = config.get_value("score", "high_score", 0)
	else:
		high_score = 0
	
	print("High score loaded: ", high_score)


func _on_area_2d_area_entered(area):
	$Ui/StartGame.show()
	$Ui/StartGame.text = " !! GAME OVER !! "
	set_physics_process(false)
	get_tree().create_timer(5)
	get_tree().reload_current_scene()
