extends CharacterBody3D

var original_color = "#7f5c17"
var red = "#b91115"

@onready var hit_timer = $Armature/Skeleton3D/Timer
@onready var enemy_mesh = %Cube
@onready var hurtbox = $Hurtbox_enemy

func hurt():
	var material = enemy_mesh.get_active_material(0)
	material.albedo_color = red
	print("hit")
	hit_timer.start()
	hit_timer.timeout.connect(_on_hit_timer_timeout)

func _on_hit_timer_timeout():
	var material = enemy_mesh.get_active_material(0)
	material.albedo_color = original_color
