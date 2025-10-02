extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -900.0
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

# Powerups
# TODO: Move power ups to their own class/scene
const double_jump = "pw_double_jump"
const tripple_jump = "pw_tripple_jump"
const slow_fall = "pw_slow_fall"

var active_power = ""
var remaining_jumps = 1

@onready
var debug_powerup_label = get_parent().get_node("DebugPowerupLabel")

func _physics_process(delta: float) -> void:
	var gravity_modifier = 1
	
	# Add the gravity.
	if not is_on_floor():
		if get_active_power() == slow_fall:
			gravity_modifier = 0.8
		velocity += get_gravity() * delta
		sprite_2d.animation = "jumping"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if velocity.y > 0:
			velocity.y *= gravity_modifier

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			match active_power:
				double_jump:
					remaining_jumps = 2
				tripple_jump:
					remaining_jumps = 3
				_:
					remaining_jumps = 1
		if remaining_jumps > 0:
			remaining_jumps -= 1
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 12)
	
	#Animations
	print(velocity.x)
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "default"

	move_and_slide()
	var isLeft = velocity.x < 0
	sprite_2d.flip_h = isLeft
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
			set_active_power(tripple_jump)
		tripple_jump:
			set_active_power(slow_fall)
		slow_fall:
			set_active_power("")
		_:
			set_active_power(double_jump)
