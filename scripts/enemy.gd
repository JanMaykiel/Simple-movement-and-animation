extends CharacterBody3D

var original_color = "#7f5c17"
var red = "#b91115"

@onready var enemy_mesh = %Cube

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "weapon_hitbox":
		var material = enemy_mesh.get_active_material(0)
		material.albedo_color = red
		print("hit")


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.name == "weapon_hitbox":
		var material = enemy_mesh.get_active_material(0)
		material.albedo_color = original_color
