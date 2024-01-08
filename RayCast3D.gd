extends RayCast3D

var hit_point : Vector3

var Sterrain : VoxelLodTerrain = null
var Sterrain_tool = null
@onready var _cursor = $"../../../CSGBox3D"

@onready var Player = $"../.."
	
func get_world_terrain():
	Sterrain = $"../../../VoxelLodTerrain"
	Sterrain_tool = Sterrain.get_voxel_tool()
	
func get_pointed_voxel() -> VoxelRaycastResult:
	var origin = get_global_transform().origin
	var forward = get_global_transform().basis.z.normalized()
	var hit =	Sterrain_tool.raycast(origin, -forward, 20)
	return hit
	
#Interact
func _unhandled_input(event):
	if Sterrain_tool != null and !(event is InputEventMouseMotion):
		if Player.current_menu == "HUD":
	#Dig & Place
			var hit = get_pointed_voxel()
			if event.pressed and is_colliding():
				if Input.is_action_just_pressed("main_attack"):
					if hit != null :	dig(hit_point)
				elif Input.is_action_just_pressed("secondary_attack"):
					var pos : Vector3
					if is_colliding() and !(get_collider() is VoxelLodTerrain) : pos = hit_point
					elif hit != null :	pos = hit.previous_position
					place(pos)
	#Hardcode edit
	if Input.is_action_just_pressed("hardcode"):
		Sterrain_tool.channel = VoxelBuffer.CHANNEL_SDF
		Sterrain_tool.mode = VoxelTool.MODE_REMOVE
		for i in range(3):
			for j in range(3):
				Sterrain_tool.do_point(Vector3i(i,j-2,9))
				Sterrain_tool.do_point(Vector3i(i,j-2,10))
				Sterrain_tool.do_point(Vector3i(i,j-2,11))
						
func _physics_process(_delta):
	#Get terrain
	get_world_terrain()
	#Get hit point & Change cursor color
	if is_colliding() :
		if Sterrain_tool == null:
			hit_point = floor(get_collision_point())
		else:
			var hit := get_pointed_voxel()
			if !(get_collider() is VoxelLodTerrain):
				hit_point = floor(get_collision_point())
			elif hit != null :
				hit_point = hit.position
				#hit_point = floor(get_collision_point())
	#Move cursor
	_cursor.set_global_position(Vector3(hit_point)+Vector3(0.5,0.5,0.5))

func dig(center: Vector3i):
	if Sterrain_tool.get_voxel(center):
		Sterrain_tool.channel = VoxelBuffer.CHANNEL_SDF
		Sterrain_tool.mode = VoxelTool.MODE_REMOVE
		#Sterrain_tool.do_sphere(center,1.0)
		Sterrain_tool.do_point(center)
		print(center)
	
func place(center: Vector3i):
	Sterrain_tool.channel = VoxelBuffer.CHANNEL_SDF
	Sterrain_tool.mode = VoxelTool.MODE_ADD
	Sterrain_tool.set_sdf_scale(0.002)
	#Sterrain_tool.do_sphere(center,1)
	Sterrain_tool.do_point(center)
