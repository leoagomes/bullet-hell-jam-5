extends CharacterBody2D

const GROUND_SPEED: float = 120.0
const AIR_SPEED: float = 120.0

const GROUND_JUMP_VELOCITY: float = -300.0
const AIR_JUMP_VELOCITY: float = -250.0
const JUMP_COOLDOWN_SECONDS: float = 0.3

const WALL_KICK_VELOCITY: float = 500.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var forces = { [gravity]: true }
var seconds_since_last_jump: float = 0.0

func _ready():
	pass

func _physics_process(delta: float):
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# left/right movement
	var speed = GROUND_SPEED if is_on_floor() else AIR_SPEED
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# jump
	seconds_since_last_jump += delta
	if Input.is_action_just_pressed("jump") and can_jump():
		var jump_velocity: float = GROUND_JUMP_VELOCITY if is_on_floor() else AIR_JUMP_VELOCITY
		velocity.y = jump_velocity
		# check wall kick
		if is_on_wall():
			if Input.is_action_pressed("move_right"):
				velocity.x -= WALL_KICK_VELOCITY
			elif Input.is_action_pressed("move_left"):
				velocity.x += WALL_KICK_VELOCITY

	move_and_slide()

func can_jump() -> bool:
	return seconds_since_last_jump >= JUMP_COOLDOWN_SECONDS
