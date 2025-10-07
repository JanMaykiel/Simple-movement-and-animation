extends RigidBody3D

var shoot: bool = false

const SPEED = 50.0

@onready var bullet_mesh = $MeshInstance3D 

func _ready() -> void:
	set_as_top_level(true)
	$Timer.start()

func _physics_process(delta: float) -> void:
	if shoot:
		apply_impulse(-transform.basis.z, transform.basis.z * SPEED)

func _on_timer_timeout() -> void:
	queue_free()
