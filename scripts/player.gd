extends CharacterBody3D

const MAX_SPEED: float = 10.0
const ACCELERATION: float = 3.0
const DECELERATION: float = 50.0
const JUMP_VELOCITY: float = 5.0
const GRAVITY: float = 9.8
const SENSITIVITY: float = 1.0 / 500
const LERP: float = 0.15

var current_speed: float = 0.0
var drag = DECELERATION

#Player
@onready var parent = $"."
@onready var armature = $Armature
@onready var head = $Armature/Skeleton3D/head/Camera_container
@onready var camera = $Armature/Skeleton3D/head/Camera_container/Player_camera
@onready var anim_tree = $AnimationTree
@onready var weapon = $Armature/Skeleton3D/right_hand/Weapon_container
@onready var weapon_hitbox = $Armature/Skeleton3D/right_hand/Weapon_container/sword/weapon_hitbox/CollisionShape3D
@onready var raycast = $Armature/Skeleton3D/head/Camera_container/RayCast3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		armature.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	#Add Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	#Handle Jumping, Sliding and Movement
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("move_right","move_left","move_backward","move_forward")
	var direction = (armature.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		current_speed = move_toward(current_speed, MAX_SPEED / 2, ACCELERATION * delta)
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		if not is_on_floor():
			drag = DECELERATION / 5
		current_speed = move_toward(current_speed, 0, drag * delta)
		velocity.x = move_toward(velocity.x, 0, drag * delta)
		velocity.z = move_toward(velocity.z, 0, drag * delta)

	slide(delta, direction)
	attack()
	update_animation_parameters(delta)

	move_and_slide()

func update_animation_parameters(delta: float):
	#Blend the animation smoothly to avoid camera snapping constantly when moving
	var target_blend_position = velocity.length() / 5
	var current_blend_positon = anim_tree.get("parameters/StateMachine/run/blend_position")
	current_blend_positon = lerp(current_blend_positon, target_blend_position, 5 * delta)
	anim_tree.set("parameters/StateMachine/run/blend_position", current_blend_positon)

func attack():
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("slide"):
			anim_tree["parameters/StateMachine/conditions/slide_attack"] = true
		anim_tree["parameters/StateMachine/conditions/attack"] = true
		if anim_tree.get("parameters/StateMachine/conditions/attack") == true or anim_tree.get("parameters/StateMachine/conditions/slide_attack") == true:
			weapon_hitbox.disabled = false
	else:
		weapon_hitbox.disabled = true
		anim_tree["parameters/StateMachine/conditions/attack"] = false
		anim_tree["parameters/StateMachine/conditions/slide_attack"] = false

func slide(delta: float, direction: Vector3):
	if direction and Input.is_action_pressed("slide") and is_on_floor():
		anim_tree["parameters/StateMachine/conditions/not_sliding"] = false
		anim_tree["parameters/StateMachine/conditions/sliding"] = true
		var target_blend_position = velocity.length() / 5
		var current_blend_positon = anim_tree.get("parameters/StateMachine/slide/blend_position")
		current_blend_positon = lerp(current_blend_positon, target_blend_position, 5 * delta)
		anim_tree.set("parameters/StateMachine/slide/blend_position", current_blend_positon)
		current_speed = move_toward(current_speed, MAX_SPEED, ((ACCELERATION * 4) * delta))
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	if (direction.x == 0 and direction.z == 0) or Input.is_action_just_released("slide") or not is_on_floor():
		anim_tree["parameters/StateMachine/conditions/not_sliding"] = true
		anim_tree["parameters/StateMachine/conditions/sliding"] = false

#func raycast_check_intersect():
	#var object_hit = raycast.get_collider()
	#if object_hit != null and object_hit.name == "Enemy":
		#if object_hit.has_method("hurt"):
			#object_hit.hurt()
