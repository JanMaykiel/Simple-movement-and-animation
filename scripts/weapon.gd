extends Resource
class_name Weapon

enum WeaponType {
	MELEE
}


@export var type : WeaponType
@export var ammo : String
@export var mesh : ArrayMesh
@export var cooldown : float = 0.2
@export var sway : float = 0.15
@export var automatic : bool = false

@export_category("Stats")
@export var damage : int
@export var range : int = 40
