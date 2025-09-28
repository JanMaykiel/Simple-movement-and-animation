extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8
const SENSITIVITY = 1.0 / 500
const LERP = 0.15

#Player
@onready var parent = $"."
@onready var armature = $Armature
@onready var head = $Armature/Skeleton3D/head/Camera_container
@onready var camera = $Armature/Skeleton3D/head/Camera_container/Player_camera
@onready var anim_tree = $AnimationTree
@onready var weapon = $Armature/Skeleton3D/right_hand/Weapon_container
@onready var weapon_hitbox = $Armature/Skeleton3D/right_hand/Weapon_container/sword/weapon_hitbox/CollisionShape3D

#Raycast
@onready var bullet_raycast = $Armature/Skeleton3D/head/Camera_container/Bullet_RayCast3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		armature.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	#Add Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	#Handle Jumping and Movement
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("move_right","move_left","move_backward","move_forward")
	var direction = (armature.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	update_animation_parameters(delta)

	move_and_slide()

func attack():
	var enemies = weapon_hitbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.has_method("hurt"):
			enemy.hurt()

func update_animation_parameters(delta):
	#Blend the animation smoothly to avoid camera snapping constantly when moving
	var target_blend_position = velocity.length() / SPEED
	var current_blend_positon = anim_tree.get("parameters/StateMachine/BlendSpace1D/blend_position")
	current_blend_positon = lerp(current_blend_positon, target_blend_position, 5 * delta)
	anim_tree.set("parameters/StateMachine/BlendSpace1D/blend_position", current_blend_positon)
	
	if(Input.is_action_just_pressed("attack")):
		weapon_hitbox.disabled = false
		anim_tree["parameters/StateMachine/conditions/attack"] = true
	else:
		weapon_hitbox.disabled = true
		anim_tree["parameters/StateMachine/conditions/attack"] = false

func _on_weapon_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("hurt"):
		body.hurt()
