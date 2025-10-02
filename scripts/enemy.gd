extends CharacterBody3D

@onready var enemy_mesh = %Cube

var health = 3
var original_color = "#74612d"
var red = "#b91115"

func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "slap_hitbox":
		var material = enemy_mesh.get_active_material(0)
		material.albedo_color = red
		health -= 1
		print("health: " + str(health))

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.name == "slap_hitbox":
		var material = enemy_mesh.get_active_material(0)
		material.albedo_color = original_color
