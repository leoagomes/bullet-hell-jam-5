extends RigidBody2D

@export_category("Movement")
@export var jump_impulse: Vector2 = Vector2(0.0, -600.0)
@export var jump_cooldown: float = 0.15
@export var wall_kick_impulse: Vector2 = Vector2(200.0, -400.0)
@export var movement_force: float = 500.0

var seconds_since_last_jump: float = INF

var fluid_density: float = 1.293
var cross_sec_area: float = 0.1
var drag_coeff: float = 0.42

func _integrate_forces(state):
	process_movement()
	process_jump(state)
	process_drag()
	
	if linear_velocity.y > 0.1:
		$Sprite.animation = "fall"
	elif linear_velocity.y < 0.1:
		$Sprite.animation = "rise"

func process_movement():
	var movement: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		movement.x -= movement_force
		$Sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		movement.x += movement_force
		$Sprite.flip_h = false
	apply_central_force(movement)

func process_jump(state):
	seconds_since_last_jump += state.step
	if Input.is_action_just_pressed("jump") and can_jump():
		var direction = Input.get_axis("move_left", "move_right")
		if is_on_wall(state) and direction:
			wall_kick(-direction)
		else:
			jump()

func can_jump() -> bool:
	return seconds_since_last_jump >= jump_cooldown

func jump():
	apply_central_impulse(jump_impulse)
	seconds_since_last_jump = 0.0

func wall_kick(direction: float):
	var transform = Vector2(sign(direction), 1)
	apply_central_impulse(transform * wall_kick_impulse)

func process_drag():
	var v = linear_velocity
	var v_squared = v * v
	var drag_const = 0.5 * cross_sec_area * drag_coeff * fluid_density
	var drag = -v.sign() * v_squared * drag_const
	apply_central_force(drag)

var wall_layer = 2
func is_on_wall(state: PhysicsDirectBodyState2D):
	var contact_count = state.get_contact_count()
	for i in range(contact_count):
		var normal = state.get_contact_local_normal(i)
		if normal.x != 0:
			return true
	return false
