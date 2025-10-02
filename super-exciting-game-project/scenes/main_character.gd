extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Powerups
# TODO: Move power ups to their own class/scene
const double_jump: String = "pw_double_jump"
const triple_jump: String = "pw_triple_jump"
const slow_fall: String = "pw_slow_fall"
const low_gravity: String = "pw_low_gravity"
const speed_increase: String = "pw_speed_increase"

var active_power: String = ""
var remaining_jumps: int = 1

@onready
var debug_powerup_label = get_parent().get_node("DebugPowerupLabel")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if (get_active_power() == slow_fall or get_active_power() == low_gravity) and velocity.y > 0:
			velocity.y *= 0.8

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			match active_power:
				triple_jump:
					remaining_jumps = 3
				double_jump:
					remaining_jumps = 2
				_:
					remaining_jumps = 1
		if remaining_jumps > 0:
			remaining_jumps -= 1
			velocity.y = JUMP_VELOCITY
			if get_active_power() == low_gravity:
				velocity.y *= 1.5

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		var speed_modifier = 1
		if get_active_power() == speed_increase:
			speed_modifier = 1.2
		velocity.x = direction * SPEED * speed_modifier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	#TODO: Temp button to cycle through powerups, remove later
	if Input.is_action_just_pressed("ui_page_up"):
		cycle_power()
	move_and_slide()

func get_active_power() -> String:
	return active_power

func set_active_power(power: String) -> void:
	active_power = power
	debug_powerup_label.text = "Active Powerup: " + power
	
func cycle_power() -> void:
	match get_active_power():
		double_jump:
			set_active_power(triple_jump)
		triple_jump:
			set_active_power(slow_fall)
		slow_fall:
			set_active_power(low_gravity)
		low_gravity:
			set_active_power(speed_increase)
		speed_increase:
			set_active_power("")
		_:
			set_active_power(double_jump)
