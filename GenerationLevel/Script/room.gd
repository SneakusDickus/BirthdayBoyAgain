extends Node3D

@onready var enemies_inst: Dictionary[String, PackedScene] = {
	"Pistol" : preload("res://Enemies/EnemyPistol/Scenes/enemy_pistol.tscn"),
	"Pipe" : preload("res://Enemies/EnemyPipe/Scene/enemy_pipe.tscn")
}

@onready var enemy_node := $Enemies
@onready var enemy_spawn_poins := $EnemiesSpawnpoints

@onready var corridor_inst := preload("res://Rooms/Scenes/corridor_floor1.tscn")

@onready var areas: Dictionary = {
	"West" : $Areas/West,
	"East" : $Areas/East,
	"North" : $Areas/North,
	"South" : $Areas/South
}

@onready var doors: Dictionary[String, Node3D] = {
	"West" : $Doors/WestDoor,
	"East" : $Doors/EastDoor,
	"North" : $Doors/NorthDoor,
	"South" : $Doors/SouthDoor
}

@onready var adjoining_rooms: Dictionary[String, Node3D] = {
	"West" : null,
	"East" : null,
	"North" : null,
	"South" : null
}

var last_area_name: String
var is_passed := false

#func _ready():
	#for key in doors:
		#var material = StandardMaterial3D.new()
		#material.albedo_color = Color("#ff4819")
		#doors[key].material_override = material


func change_area_state(area: Area3D, mode: String) -> void:
	match mode:
		"disable":
			area.set_deferred("monitoring", false)
			area.set_deferred("monitorable", false)
		"enable":
			area.set_deferred("monitoring", true)
			area.set_deferred("monitorable", true)


func _change_door_state() -> void:
	for key in adjoining_rooms:
		if adjoining_rooms[key] != null:
			#doors[key].material_override.albedo_color = Color("#00b236")
			doors[key].door_open()


func _on_west_area_entered(area):
	if area.name == "RoomArea":
		change_area_state($Areas/West, "disable")
		adjoining_rooms["West"] = area.get_parent()
		var corridor = corridor_inst.instantiate()
		$CorridorsSpawnPoints/WestCorridor.add_child(corridor)
		_change_door_state()


func _on_east_area_entered(area):
	if area.name == "RoomArea":
		change_area_state($Areas/East, "disable")
		adjoining_rooms["East"] = area.get_parent()
		var corridor = corridor_inst.instantiate()
		$CorridorsSpawnPoints/EastCorridor.add_child(corridor)
		_change_door_state()


func _on_south_area_entered(area):
	if area.name == "RoomArea":
		change_area_state($Areas/South, "disable")
		adjoining_rooms["South"] = area.get_parent()
		var corridor = corridor_inst.instantiate()
		$CorridorsSpawnPoints/SouthCorridor.add_child(corridor)
		_change_door_state()


func _on_north_area_entered(area):
	if area.name == "RoomArea":
		change_area_state($Areas/North, "disable")
		adjoining_rooms["North"] = area.get_parent()
		var corridor = corridor_inst.instantiate()
		$CorridorsSpawnPoints/NorthCorridor.add_child(corridor)
		_change_door_state()


func preapre_level_to_fight() -> void:
	for key in doors:
		doors[key].door_close()
	var spawn_points = enemy_spawn_poins.get_children()
	for spawn in spawn_points:
		var enemy = enemies_inst[spawn.enemy_type].instantiate()
		enemy_node.add_child(enemy)
		enemy.global_position = spawn.global_position
		enemy.global_rotation = spawn.global_rotation  


func _on_room_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		if is_passed: return
		is_passed = true
		preapre_level_to_fight()


func _on_enemies_child_exiting_tree(node: Node) -> void:
	if len(enemy_node.get_children()) <= 1:
		_change_door_state()
