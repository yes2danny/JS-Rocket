extends Node3D
class_name PhysicsCable
## Physics-simulated cable using a chain of RigidBody3D segments connected by PinJoint3D.
## Sags under gravity and reacts when the door moves.
## Color matches the access panel and door strip for the visual puzzle.

@export_node_path("Node3D") var start_anchor_path: NodePath  ## Panel's CableAnchor
@export_node_path("Node3D") var end_anchor_path: NodePath     ## Door's CableAnchor
@export var segment_count: int = 10
@export var cable_color: Color = Color(1, 0.3, 0.1)
@export var cable_thickness: float = 0.012
@export var cable_mass: float = 0.04
@export var cable_damping: float = 4.0
@export var initial_sag: float = 0.25

var _end_body: AnimatableBody3D
var _end_node: Node3D
var _segments: Array[RigidBody3D] = []
var _connectors: Array[MeshInstance3D] = []
var _cable_material: StandardMaterial3D


func _ready() -> void:
	# Wait for physics to initialize positions
	await get_tree().physics_frame
	_build_cable()


func _build_cable() -> void:
	var start_node := get_node_or_null(start_anchor_path) as Node3D
	_end_node = get_node_or_null(end_anchor_path) as Node3D
	if not start_node or not _end_node:
		push_warning("PhysicsCable: Missing start or end anchor")
		return

	var start_pos := start_node.global_position
	var end_pos := _end_node.global_position

	# Shared material for the whole cable
	_cable_material = StandardMaterial3D.new()
	_cable_material.albedo_color = cable_color
	_cable_material.emission_enabled = true
	_cable_material.emission = cable_color
	_cable_material.emission_energy_multiplier = 0.8

	# Start anchor — fixed to the panel wall
	var start_body := _create_anchor(start_pos, false)

	var prev_body: PhysicsBody3D = start_body

	# Chain of rigid body segments
	for i in segment_count:
		var t := float(i + 1) / float(segment_count + 1)
		var pos := start_pos.lerp(end_pos, t)
		# Apply catenary-like sag
		pos.y -= sin(t * PI) * initial_sag

		var seg := _create_segment(pos)
		_segments.append(seg)

		# Visual connector from previous body to this one
		var connector := _create_connector()
		_connectors.append(connector)

		# Pin joint constraining this segment to the previous
		_create_pin_joint(prev_body, seg)
		prev_body = seg

	# End anchor — follows the door via AnimatableBody3D
	_end_body = _create_anchor(end_pos, true) as AnimatableBody3D

	# Final connector + joint
	_connectors.append(_create_connector())
	_create_pin_joint(prev_body, _end_body)


func _create_anchor(pos: Vector3, animatable: bool) -> PhysicsBody3D:
	var body: PhysicsBody3D
	if animatable:
		body = AnimatableBody3D.new()
	else:
		body = StaticBody3D.new()
	body.global_position = pos
	body.collision_layer = 0
	body.collision_mask = 0
	# Small sphere for the joint to attach to
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.01
	col.shape = shape
	body.add_child(col)
	# Visible anchor point
	var mesh_inst := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = cable_thickness * 1.5
	mesh.height = cable_thickness * 3.0
	mesh.material = _cable_material
	mesh_inst.mesh = mesh
	body.add_child(mesh_inst)
	add_child(body)
	return body


func _create_segment(pos: Vector3) -> RigidBody3D:
	var body := RigidBody3D.new()
	body.mass = cable_mass
	body.linear_damp = cable_damping
	body.angular_damp = cable_damping
	body.global_position = pos
	body.collision_layer = 0
	body.collision_mask = 0
	# Physics shape
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = cable_thickness
	col.shape = shape
	body.add_child(col)
	# Visible joint node
	var mesh_inst := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = cable_thickness
	mesh.height = cable_thickness * 2.0
	mesh.material = _cable_material
	mesh_inst.mesh = mesh
	body.add_child(mesh_inst)
	add_child(body)
	return body


func _create_connector() -> MeshInstance3D:
	var mesh_inst := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = cable_thickness * 0.7
	mesh.bottom_radius = cable_thickness * 0.7
	mesh.height = 1.0  # Will be scaled per frame
	mesh.material = _cable_material
	mesh_inst.mesh = mesh
	add_child(mesh_inst)
	return mesh_inst


func _create_pin_joint(a: PhysicsBody3D, b: PhysicsBody3D) -> void:
	var joint := PinJoint3D.new()
	joint.node_a = a.get_path()
	joint.node_b = b.get_path()
	# Soften the joint slightly for a more organic cable feel
	joint.set_param(PinJoint3D.PARAM_IMPULSE_CLAMP, 10.0)
	add_child(joint)


func _physics_process(_delta: float) -> void:
	# End anchor follows the door
	if _end_body and _end_node:
		_end_body.global_position = _end_node.global_position

	# Update visual connectors between segments
	_update_connectors()


func _update_connectors() -> void:
	if _connectors.is_empty() or _segments.is_empty():
		return

	# Build full list of positions: start_anchor, segments..., end_anchor
	var positions: Array[Vector3] = []
	# First child is the start anchor
	var start_body := get_child(0) as Node3D
	if start_body:
		positions.append(start_body.global_position)
	for seg in _segments:
		positions.append(seg.global_position)
	if _end_body:
		positions.append(_end_body.global_position)

	# Position each connector cylinder between adjacent points
	for i in _connectors.size():
		if i + 1 >= positions.size():
			break
		var pos_a := positions[i]
		var pos_b := positions[i + 1]
		var mid := (pos_a + pos_b) / 2.0
		var diff := pos_b - pos_a
		var dist := diff.length()

		if dist < 0.001:
			_connectors[i].visible = false
			continue

		_connectors[i].visible = true
		_connectors[i].global_position = mid

		# Orient the cylinder (Y-axis) along the direction between points
		var up := diff.normalized()
		# Find a perpendicular vector for the basis
		var right: Vector3
		if abs(up.dot(Vector3.UP)) < 0.99:
			right = up.cross(Vector3.UP).normalized()
		else:
			right = up.cross(Vector3.RIGHT).normalized()
		var forward := right.cross(up).normalized()

		_connectors[i].global_transform.basis = Basis(right, up, forward)
		# Scale Y to match distance
		_connectors[i].scale = Vector3(1, dist, 1)
