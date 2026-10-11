class_name Peixe3D
extends Area3D

const LIMITE_X := 9.0
const NUM_SLOTS := 6
const DUR_PULO := 0.8

var slot := 0
var especie: Dictionary = {}
var peso: float = 0.5
var base: Vector3
var tempo := 0.0
var fase := 0.0
var velocidade := 0.8
var amplitude := 0.8

var pulando := false
var t_pulo := 0.0
var proximo_pulo := 8.0

var corpo_visual: Node3D = null
var pivo_rabo: Node3D = null
var rotulo: Label3D = null

func _ready():
	fase = randf() * TAU
	velocidade = randf_range(0.5, 1.0)
	amplitude = randf_range(0.5, 1.0)
	proximo_pulo = randf_range(4.0, 12.0)
	base = position

	var col := CollisionShape3D.new()
	var forma := SphereShape3D.new()
	forma.radius = 0.9
	col.shape = forma
	add_child(col)

	rotulo = Label3D.new()
	rotulo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rotulo.font_size = 36
	rotulo.pixel_size = 0.011
	rotulo.outline_size = 12
	rotulo.position = Vector3(0, 1.3 + (slot % 2) * 0.9, 0)
	var f := EstiloUI.fonte()
	if f:
		rotulo.font = f
	add_child(rotulo)

	_sortear()
	area_entered.connect(_ao_ser_alcancado)
	GameManager.rodada_mudou.connect(_sortear)

func _mat(cor: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = cor
	m.roughness = 0.45
	return m

func _sortear():
	especie = GameManager.sortear_especie()
	peso = GameManager.peso_para(especie)
	_montar_visual()
	rotulo.text = "%s\n%s" % [especie["nome"], GameManager.fmt_kg(peso)]

func _montar_visual():
	if corpo_visual:
		corpo_visual.queue_free()
	corpo_visual = Node3D.new()
	corpo_visual.scale = Vector3.ONE * 1.7
	add_child(corpo_visual)

	var comp: float = especie["comp"]
	var alt: float = especie["alt"]
	var cor: Color = especie["cor"]
	var cor_nad: Color = especie["nadadeira"]

	var esfera := SphereMesh.new()
	esfera.radius = 0.5
	esfera.height = 1.0
	var corpo := MeshInstance3D.new()
	corpo.mesh = esfera
	corpo.scale = Vector3(comp, 0.6 * alt, 0.38)
	corpo.material_override = _mat(cor)
	corpo_visual.add_child(corpo)

	# barriga mais clara
	var barriga := MeshInstance3D.new()
	barriga.mesh = esfera
	barriga.scale = Vector3(comp * 0.98, 0.34 * alt, 0.39)
	barriga.position = Vector3(0, -0.12 * alt, 0)
	barriga.material_override = _mat(cor.lightened(0.5))
	corpo_visual.add_child(barriga)

	if especie["linha"]:
		var faixa := MeshInstance3D.new()
		faixa.mesh = esfera
		faixa.scale = Vector3(comp, 0.04, 0.42)
		faixa.position = Vector3(0, 0.02 * alt, 0)
		faixa.material_override = _mat(Color("2b2b24"))
		corpo_visual.add_child(faixa)

	pivo_rabo = Node3D.new()
	pivo_rabo.position = Vector3(-0.45 * comp, 0, 0)
	corpo_visual.add_child(pivo_rabo)
	var prisma_rabo := PrismMesh.new()
	prisma_rabo.size = Vector3(0.5 * alt, 0.45, 0.06)
	var rabo := MeshInstance3D.new()
	rabo.mesh = prisma_rabo
	rabo.position = Vector3(-0.17, 0, 0)
	rabo.rotation_degrees = Vector3(0, 0, -90)
	rabo.material_override = _mat(cor_nad)
	pivo_rabo.add_child(rabo)

	var prisma_dorsal := PrismMesh.new()
	prisma_dorsal.size = Vector3(0.4 * comp, 0.28 * alt, 0.05)
	var dorsal := MeshInstance3D.new()
	dorsal.mesh = prisma_dorsal
	dorsal.position = Vector3(0, 0.3 * alt, 0)
	dorsal.material_override = _mat(cor_nad)
	corpo_visual.add_child(dorsal)

	if especie["barbilhoes"]:
		for lado in [-1.0, 1.0]:
			var cil := CylinderMesh.new()
			cil.top_radius = 0.012
			cil.bottom_radius = 0.012
			cil.height = 0.25
			var barb := MeshInstance3D.new()
			barb.mesh = cil
			barb.position = Vector3(0.5 * comp + 0.04, -0.06 * alt, 0.07 * lado)
			barb.rotation_degrees = Vector3(0, 0, -105)
			barb.material_override = _mat(cor_nad)
			corpo_visual.add_child(barb)

	for lado in [-1.0, 1.0]:
		var olho_mesh := SphereMesh.new()
		olho_mesh.radius = 0.045
		olho_mesh.height = 0.09
		var olho := MeshInstance3D.new()
		olho.mesh = olho_mesh
		olho.position = Vector3(0.3 * comp, 0.06 * alt, 0.145 * lado)
		olho.material_override = _mat(Color("1a1a1a"))
		corpo_visual.add_child(olho)

func _respingo():
	EfeitoAgua.respingo(get_parent(), Vector3(global_position.x, 0.0, global_position.z), 0.7)

func _process(delta):
	tempo += delta
	var s := sin(tempo * velocidade + fase)
	var ds := cos(tempo * velocidade + fase)
	position.x = base.x + s * amplitude

	var salto := 0.0
	if pulando:
		t_pulo += delta
		var u := t_pulo / DUR_PULO
		if u >= 1.0:
			pulando = false
			corpo_visual.rotation.z = 0.0
			proximo_pulo = tempo + randf_range(6.0, 15.0)
			_respingo()
		else:
			salto = sin(u * PI) * 1.3
			corpo_visual.rotation.z = cos(u * PI) * 0.7
	elif visible and tempo >= proximo_pulo:
		pulando = true
		t_pulo = 0.0
		_respingo()

	position.y = base.y + sin(tempo * 2.0 + fase) * 0.05 + salto
	var alvo := 0.0 if ds > 0.0 else PI
	corpo_visual.rotation.y = lerp_angle(corpo_visual.rotation.y, alvo, 6.0 * delta)
	pivo_rabo.rotation_degrees.y = sin(tempo * 9.0 + fase) * 25.0

func _ao_ser_alcancado(area: Area3D):
	if not area.is_in_group("area_pesca"):
		return
	if not GameManager.pode_pescar():
		return
	GameManager.registrar_peixe(String(especie["nome"]), peso)
	_reaparecer()

func _reaparecer():
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	visible = false
	pulando = false
	await get_tree().create_timer(randf_range(1.5, 3.0)).timeout
	_sortear()
	var largura_slot := (2.0 * LIMITE_X) / float(NUM_SLOTS)
	var cx := -LIMITE_X + (slot + 0.5) * largura_slot + randf_range(-0.4, 0.4)
	var cz := -3.4 if slot % 2 == 0 else -5.6
	base = Vector3(cx, 0.02, cz)
	position = base
	tempo = 0.0
	proximo_pulo = randf_range(4.0, 12.0)
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
