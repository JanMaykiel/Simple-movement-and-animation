extends CharacterBody3D

const MAX_SPEED: float = 10.0
const SPEED_MULTIPLIER: float = 2.0
const ACCELERATION: float = 3.0
const DECELERATION: float = 50.0
const AIR_DRAG: float = 0.2

const JUMP_VELOCITY: float = 5.0
const GRAVITY: float = 9.8
const MOUSE_SENSITIVITY: float = 0.002
const LERP: float = 0.15

const ANIMATION_SMOOTHING: float = 5.0
const VELOCITY_TO_ANIM_SCALE: float = 0.2

#Player State
var current_speed: float = 0.0
var is_run: bool = true
var is_sliding: bool = false
var is_attacking: bool = false
var is_run_gun: bool = false

#Node References
@onready var parent = $"."
@onready var head = $Armature/Skeleton3D/head/Camera_container
@onready var camera = $Armature/Skeleton3D/head/Camera_container/Player_camera
@onready var anim_tree = $AnimationTree
@onready var hand = $Armature/Skeleton3D/right_hand/hand_container
@onready var slap_hitbox = $Armature/Skeleton3D/right_hand/hand_container/slap_hitbox/CollisionShape3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	slap_hitbox.disabled = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_camera_rotation(event)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	apply_gravity(delta)

	#Handle Player Actions
	var input_direction = get_movement_input()
	handle_jump()
	handle_movement(input_direction, delta)
	handle_sliding(input_direction, delta)
	handle_attack()
	change_attack()

	update_animations(delta)

	move_and_slide()

func handle_camera_rotation(event: InputEventMouseMotion) -> void:
	rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
	camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func get_movement_input() -> Vector3:
	var input_vec = Input.get_vector("move_right","move_left","move_backward","move_forward")
	return (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()

func handle_movement(direction: Vector3, delta: float) -> void:
	var target_speed = MAX_SPEED / 2
	
	if direction:
		current_speed = move_toward(current_speed, target_speed, ACCELERATION * delta)
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		var drag = DECELERATION if is_on_floor() else DECELERATION * AIR_DRAG
		current_speed = move_toward(current_speed, 0, drag * delta)
		velocity.x = move_toward(velocity.x, 0, drag * delta)
		velocity.z = move_toward(velocity.z, 0, drag * delta)

func handle_sliding(direction: Vector3, delta: float) -> void:
	var should_slide = direction and current_speed >= 4 and Input.is_action_pressed("slide") and is_on_floor()
	
	if should_slide and not is_sliding:
		start_sliding()
	elif is_sliding and not should_slide:
		stop_sliding()
	
	if is_sliding:
		apply_slide_movement(direction, delta)

func start_sliding() -> void:
	is_sliding = true
	if is_run:
		set_animation_condition("sliding", true)
		set_animation_condition("slide_gun", false)
		set_animation_condition("not_sliding", false)
	if is_run_gun: 
		set_animation_condition("slide_gun", true)
		set_animation_condition("sliding", false)
		set_animation_condition("not_sliding", false)

func stop_sliding() -> void:
	is_sliding = false
	set_animation_condition("sliding", false)
	set_animation_condition("slide_gun", false)
	set_animation_condition("not_sliding", true)

func apply_slide_movement(direction: Vector3, delta: float) -> void:
	#Faster movement when sliding
	current_speed = move_toward(current_speed, MAX_SPEED, ACCELERATION * 4 * delta)
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	update_animation_blend("parameters/StateMachine/slide/blend_position", delta)

func change_attack() -> void:
	if Input.is_action_just_pressed("change_attack") and is_run_gun:
		is_run_gun = false
		is_run = true
		set_animation_condition("is_run_gun", false)
		set_animation_condition("is_run", true)
		if is_sliding:
			set_animation_condition("sliding", true)
			set_animation_condition("slide_gun", false)
	elif is_run and Input.is_action_just_pressed("change_attack"):
		is_run_gun = true
		is_run = false
		set_animation_condition("is_run_gun", true)
		set_animation_condition("is_run", false)
		if is_sliding:
			set_animation_condition("sliding", false)
			set_animation_condition("slide_gun", true)

func handle_attack() -> void:
	if Input.is_action_pressed("attack") and not is_attack_animation_playing():
		start_attack()
	elif is_attacking and is_attack_animation_playing():
		end_attack()

func start_attack() -> void:
	is_attacking = true
	if is_run:
		slap_hitbox.disabled = false
		if is_sliding:
			set_animation_condition("slide_attack", true)
		else:
			set_animation_condition("attack", true)
	elif is_run_gun:
		if is_sliding:
			set_animation_condition("slide_shoot", true)
		else:
			set_animation_condition("shoot", true)

func end_attack() -> void:
	slap_hitbox.disabled = true
	set_animation_condition("attack", false)
	set_animation_condition("slide_attack", false)
	set_animation_condition("shoot", false)
	set_animation_condition("slide_shoot", false)

func is_attack_animation_playing() -> bool:
	return (anim_tree.get("parameters/StateMachine/conditions/attack") or anim_tree.get("parameters/StateMachine/conditions/slide_attack")) or (anim_tree.get("parameters/StateMachine/conditions/shoot") or anim_tree.get("parameters/StateMachine/conditions/slide_shoot"))

func update_animations(delta: float) -> void:
	if not is_sliding:
		if is_run:
			update_animation_blend("parameters/StateMachine/run/blend_position", delta)
		if is_run_gun:
			update_animation_blend("parameters/StateMachine/run_gun/blend_position", delta)
	else:
		if is_run:
			update_animation_blend("parameters/StateMachine/slide/blend_position", delta)
		if is_run_gun:
			update_animation_blend("parameters/StateMachine/slide_gun/blend_position", delta)

func update_animation_blend(path: String, delta: float) -> void:
	var target_blend = velocity.length() * VELOCITY_TO_ANIM_SCALE
	var current_blend = anim_tree.get(path)
	var new_blend = lerp(current_blend, target_blend, ANIMATION_SMOOTHING * delta)
	anim_tree.set(path, new_blend)

func set_animation_condition(condition: String, value: bool) -> void:
	anim_tree["parameters/StateMachine/conditions/" + condition] = value
