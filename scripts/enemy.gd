extends CharacterBody3D

var original_color = "#7f5c17"
var red = "#b91115"

@onready var hit_timer = $Armature/Skeleton3D/Timer
@onready var enemy_mesh = %Cube

func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	var material = enemy_mesh.get_active_material(0)
	material.albedo_color = red
	print("hit")

func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	var material = enemy_mesh.get_active_material(0)
	material.albedo_color = original_color
