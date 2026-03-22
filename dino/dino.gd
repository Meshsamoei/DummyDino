extends CharacterBody2D

@export var GRAVITY = 4500;
@export var JUMP = -1500;
@export var SPEED = 50;


func _physics_process(delta):
	if Input.is_action_just_pressed("RESET"):
		get_tree().reload_current_scene()


	velocity.y += GRAVITY * delta;


	# Ground animations (only if on floor)
	if is_on_floor():
		if Input.is_action_just_pressed("JUMP"):
			velocity.y = JUMP;
		
		if Input.is_action_just_pressed("DUCK") or Input.is_action_pressed("DUCK"):
			%DinoSprites.play("duck")
			%RunColl.disabled = true
			
		else:
			%RunColl.disabled = false
			%DinoSprites.play("run")
	else:
		%DinoSprites.play("jump")
	# Airborne animation overrides ground animations
	#if !is_on_floor():
	#	%DinoSprites.play("jump")
	
	move_and_slide()
