class_name EfeitoAgua
extends Node

static func respingo(pai: Node, pos: Vector3, escala: float = 1.0):
	if pai == null or not pai.is_inside_tree():
		return

	for i in 3:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1, 1, 1, 0.7)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var anel := TorusMesh.new()
		anel.inner_radius = 0.42
		anel.outer_radius = 0.5
		var mi := MeshInstance3D.new()
		mi.mesh = anel
		mi.material_override = mat
		mi.position = pos + Vector3(0, 0.04, 0)
		mi.scale = Vector3(0.2, 1.0, 0.2) * escala
		pai.add_child(mi)
		var tw := pai.create_tween()
		tw.set_parallel(true)
		tw.tween_property(mi, "scale", Vector3(2.6, 1.0, 2.6) * escala, 1.2).set_delay(i * 0.18)
		tw.tween_property(mat, "albedo_color:a", 0.0, 1.2).set_delay(i * 0.18)
		tw.chain().tween_callback(mi.queue_free)

	var gotas := CPUParticles3D.new()
	var esf := SphereMesh.new()
	esf.radius = 0.05
	esf.height = 0.1
	var m2 := StandardMaterial3D.new()
	m2.albedo_color = Color(0.9, 0.97, 1.0, 0.85)
	m2.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	esf.material = m2
	gotas.mesh = esf
	gotas.position = pos
	gotas.amount = 20
	gotas.lifetime = 0.9
	gotas.one_shot = true
	gotas.explosiveness = 1.0
	gotas.direction = Vector3.UP
	gotas.spread = 45.0
	gotas.gravity = Vector3(0, -9.0, 0)
	gotas.initial_velocity_min = 2.5 * escala
	gotas.initial_velocity_max = 4.5 * escala
	gotas.emitting = true
	pai.add_child(gotas)
	pai.get_tree().create_timer(1.6).timeout.connect(gotas.queue_free)
