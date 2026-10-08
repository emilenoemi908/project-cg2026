class_name Peixe3D
extends Area3D

const LIMITE_X := 9.0

var quantidade: int = 1
var peso: float = 0.5
var base: Vector3
var tempo := 0.0
var fase := 0.0
var velocidade := 0.8
var amplitude := 1.2

var corpo_visual: Node3D
var pivo_rabo: Node3D
var rotulo: Label3D

func _ready():
	fase = randf() * TAU
	velocidade = randf_range(0.5, 1.0)
	amplitude = randf_range(0.8, 1.8)
	base = position
	_montar_visual()
	_sortear_dados()
	area_entered.connect(_ao_ser_alcancado)

func _mat(cor: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = cor
	m.roughness = 0.6
	return m

func _montar_visual():
	var col := CollisionShape3D.new()
	var forma := SphereShape3D.new()
	forma.radius = 0.9
	col.shape = forma
	add_child(col)

	corpo_visual = Node3D.new()
	corpo_visual.scale = Vector3.ONE * 1.3
	add_child(corpo_visual)

	var laranja := Color("ff9a1f")
	var claro := Color("ffc24d")

	var esfera := SphereMesh.new()
	esfera.radius = 0.5
	esfera.height = 1.0
	var corpo := MeshInstance3D.new()
	corpo.mesh = esfera
	corpo.scale = Vector3(1.0, 0.6, 0.38)
	corpo.material_override = _mat(laranja)
	corpo_visual.add_child(corpo)

	pivo_rabo = Node3D.new()
	pivo_rabo.position = Vector3(-0.45, 0, 0)
	corpo_visual.add_child(pivo_rabo)
	var prisma_rabo := PrismMesh.new()
	prisma_rabo.size = Vector3(0.5, 0.45, 0.06)
	var rabo := MeshInstance3D.new()
	rabo.mesh = prisma_rabo
	rabo.position = Vector3(-0.17, 0, 0)
	rabo.rotation_degrees = Vector3(0, 0, -90)
	rabo.material_override = _mat(claro)
	pivo_rabo.add_child(rabo)

	var prisma_dorsal := PrismMesh.new()
	prisma_dorsal.size = Vector3(0.4, 0.28, 0.05)
	var dorsal := MeshInstance3D.new()
	dorsal.mesh = prisma_dorsal
	dorsal.position = Vector3(0, 0.3, 0)
	dorsal.material_override = _mat(claro)
	corpo_visual.add_child(dorsal)

	for lado in [-1.0, 1.0]:
		var olho_mesh := SphereMesh.new()
		olho_mesh.radius = 0.045
		olho_mesh.height = 0.09
		var olho := MeshInstance3D.new()
		olho.mesh = olho_mesh
		olho.position = Vector3(0.3, 0.06, 0.145 * lado)
		olho.material_override = _mat(Color("1a1a1a"))
		corpo_visual.add_child(olho)

	rotulo = Label3D.new()
	rotulo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rotulo.font_size = 48
	rotulo.pixel_size = 0.012
	rotulo.outline_size = 10
	rotulo.position = Vector3(0, 1.1, 0)
	add_child(rotulo)

func _sortear_dados():
	quantidade = randi_range(1, 5)
	peso = float(randi_range(1, 5)) * 0.5
	rotulo.text = "%d peixe(s)\n%.1f kg" % [quantidade, peso]

func _process(delta):
	tempo += delta
	var s := sin(tempo * velocidade + fase)
	var ds := cos(tempo * velocidade + fase)
	position.x = base.x + s * amplitude
	position.y = base.y + sin(tempo * 2.0 + fase) * 0.05
	var alvo := 0.0 if ds > 0.0 else PI
	corpo_visual.rotation.y = lerp_angle(corpo_visual.rotation.y, alvo, 6.0 * delta)
	pivo_rabo.rotation_degrees.y = sin(tempo * 9.0 + fase) * 25.0

func _ao_ser_alcancado(area: Area3D):
	if not area.is_in_group("area_pesca"):
		return
	GameManager.registrar_peixe(quantidade, peso)
	_reaparecer()

func _reaparecer():
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	visible = false
	await get_tree().create_timer(randf_range(1.5, 3.0)).timeout
	_sortear_dados()
	base = Vector3(randf_range(-LIMITE_X, LIMITE_X), 0.02, randf_range(-3.0, -6.0))
	position = base
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
