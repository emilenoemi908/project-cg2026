extends Node3D

@export var cena_ui_desafio: PackedScene

const LIMITE_X := 9.0
const VELOCIDADE := 6.0
const RAIO_TARRAFA := 2.4
const NUM_PEIXES := 6
const CAMERA_POS := Vector3(0, 6.5, 11.5)
const CAMERA_ROT := Vector3(-17, 0, 0)


var pescador: CharacterBody3D
var barco: Node3D
var tarrafa: Area3D
var tarrafa_visual: Node3D
var tarrafa_colisao: CollisionShape3D
var tween_rede: Tween
var rede_lancada := false

var agua_mat: StandardMaterial3D
var nuvens: Array = []
var sons := {}
var label_pontos: Label
var tempo := 0.0
var jogando := false

func criar_material(cor: Color, alpha := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = cor
	m.roughness = 0.7
	if alpha:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func criar_malha(mesh: Mesh, cor: Color, pos := Vector3.ZERO, rot := Vector3.ZERO, escala := Vector3.ONE, alpha := false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = criar_material(cor, alpha)
	mi.position = pos
	mi.rotation_degrees = rot
	mi.scale = escala
	return mi

func caixa(x: float, y: float, z: float) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = Vector3(x, y, z)
	return m

func esfera(r: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	return m

func cilindro(r_topo: float, r_base: float, h: float) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = r_topo
	m.bottom_radius = r_base
	m.height = h
	return m

func capsula(r: float, h: float) -> CapsuleMesh:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = h
	return m

# ---------- inicialização ----------
func _ready():
	GameManager.reiniciar()
	montar_ambiente()
	montar_agua()
	montar_cenario()
	montar_pescador()
	montar_peixes()
	montar_interface()
	montar_sons()
	GameManager.placar_mudou.connect(atualizar_placar)
	atualizar_placar()
	var briefing := Briefing.new()
	add_child(briefing)
	briefing.comecou.connect(func(): jogando = true)
	add_child(PainelMeta.new())
	add_child(PainelTarrafa.new())
	

func montar_ambiente():
	var ceu := ProceduralSkyMaterial.new()
	ceu.sky_top_color = Color("00b9af")
	ceu.sky_horizon_color = Color("fff0dc")
	ceu.ground_horizon_color = Color("bfe6e0")
	ceu.ground_bottom_color = Color("0a6e96")

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ceu
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.0
	env.fog_enabled = true
	env.fog_light_color = Color("dff3ea")
	env.fog_density = 0.01
	env.fog_sky_affect = 0.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-40, 25, 0)
	luz.light_color = Color("fff4d6")
	luz.light_energy = 1.2
	luz.shadow_enabled = true
	luz.directional_shadow_max_distance = 40.0
	add_child(luz)

	var cam := Camera3D.new()
	cam.position = CAMERA_POS
	cam.rotation_degrees = CAMERA_ROT
	cam.fov = 60
	add_child(cam)
	cam.make_current()

func montar_agua():
	var plano := PlaneMesh.new()
	plano.size = Vector2(600, 600)

	var ruido := FastNoiseLite.new()
	ruido.frequency = 0.02
	var tex := NoiseTexture2D.new()
	tex.noise = ruido
	tex.as_normal_map = true
	tex.seamless = true
	tex.width = 512
	tex.height = 512

	agua_mat = criar_material(Color("0a7ea6"))
	agua_mat.roughness = 0.15
	agua_mat.normal_enabled = true
	agua_mat.normal_texture = tex
	agua_mat.normal_scale = 0.6
	agua_mat.uv1_scale = Vector3(40, 40, 1)

	var agua := MeshInstance3D.new()
	agua.mesh = plano
	agua.material_override = agua_mat
	add_child(agua)

# ---------- cenário ----------

func criar_margem_distante():
	add_child(criar_malha(caixa(180, 1.0, 14), Color("7a9a55"), Vector3(0, -0.2, -62)))
	var cores = [Color("e6d3a8"), Color("c9dbe6"), Color("e3b7a8"), Color("d8e0b0"), Color("f0e4c8")]
	var x := -80.0
	while x < 80.0:
		if absf(x) > 14.0:
			criar_casa_alvenaria(Vector3(x + randf_range(-1.5, 1.5), 0.3, -62 + randf_range(-3, 3)), cores[randi() % cores.size()])
		x += randf_range(6.0, 10.0)

func criar_casa_alvenaria(pos: Vector3, cor: Color):
	var raiz := Node3D.new()
	raiz.position = pos
	raiz.rotation_degrees.y = randf_range(-8, 8)
	add_child(raiz)
	var h := randf_range(1.8, 2.6)
	raiz.add_child(criar_malha(caixa(3.2, h, 2.6), cor, Vector3(0, h / 2.0, 0)))
	var telhado := PrismMesh.new()
	telhado.size = Vector3(3.6, 1.0, 3.0)
	raiz.add_child(criar_malha(telhado, Color("b8643c"), Vector3(0, h + 0.5, 0)))
	raiz.add_child(criar_malha(caixa(0.6, 1.1, 0.05), Color("6b4226"), Vector3(0.6, 0.55, 1.31)))
	
func montar_cenario():
	# colinas distantes
	for d in [[Vector3(-70, -3, -130), Vector3(50, 14, 30)], [Vector3(30, -3, -140), Vector3(70, 18, 30)], [Vector3(110, -3, -125), Vector3(45, 12, 30)]]:
		add_child(criar_malha(esfera(1.0), Color("8fae78"), d[0], Vector3.ZERO, d[1]))

	# sol
	var sol_mat := criar_material(Color("fff4d6"))
	sol_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sol_mat.disable_fog = true
	var sol := MeshInstance3D.new()
	sol.mesh = esfera(9.0)
	sol.material_override = sol_mat
	sol.position = Vector3(45, 22, -150)
	add_child(sol)

	# nuvens em blocos
	criar_nuvem(Vector3(-60, 22, -100), 1.3)
	criar_nuvem(Vector3(10, 26, -105), 1.0)
	criar_nuvem(Vector3(70, 20, -95), 1.5)

	# lado esquerdo
	criar_ilha(Vector3(-32, 0, -34), 7.0)
	criar_arvore(Vector3(-34, 0.4, -35), 1.2)
	criar_arvore(Vector3(-30, 0.4, -33), 1.0)
	criar_arvore(Vector3(-36, 0.4, -32), 0.9)
	criar_margem_distante()

	# lado direito
	criar_ilha(Vector3(34, 0, -36), 7.5)
	criar_arvore(Vector3(33, 0.4, -37), 1.2)
	criar_arvore(Vector3(37, 0.4, -35), 1.0)
	criar_arvore(Vector3(31, 0.4, -34), 0.9)
	criar_margem_distante()
	criar_casa(Vector3(22, 1.55, -28))

func criar_ilha(pos: Vector3, raio: float):
	add_child(criar_malha(cilindro(raio, raio, 1.0), Color("7a9a55"), pos + Vector3(0, -0.1, 0)))

func criar_arvore(pos: Vector3, escala := 1.0):
	var raiz := Node3D.new()
	raiz.position = pos
	raiz.scale = Vector3.ONE * escala
	add_child(raiz)
	raiz.add_child(criar_malha(cilindro(0.2, 0.28, 2.2), Color("5a3b1e"), Vector3(0, 1.1, 0)))
	var verdes = [Color("3a7d44"), Color("4f9a55")]
	var blobs = [Vector3(0, 3.0, 0), Vector3(-0.9, 2.5, 0.2), Vector3(0.9, 2.5, -0.1), Vector3(0, 3.7, 0.1)]
	for i in blobs.size():
		raiz.add_child(criar_malha(esfera(1.1), verdes[i % 2], blobs[i]))

func criar_palafita(pos: Vector3, largura := 8.0):
	var raiz := Node3D.new()
	raiz.position = pos
	add_child(raiz)
	raiz.add_child(criar_malha(caixa(largura, 0.3, 3.0), Color("8b5a32"), Vector3(0, 1.4, 0)))
	for i in 5:
		var x := -largura / 2.0 + 0.4 + i * (largura - 0.8) / 4.0
		for z in [-1.2, 1.2]:
			raiz.add_child(criar_malha(cilindro(0.12, 0.12, 3.0), Color("4e341c"), Vector3(x, 0.2, z)))

func criar_casa(pos: Vector3):
	var raiz := Node3D.new()
	raiz.position = pos
	add_child(raiz)
	raiz.add_child(criar_malha(caixa(2.8, 1.8, 2.4), Color("a87b4f"), Vector3(0, 1.0, 0)))
	var prisma := PrismMesh.new()
	prisma.size = Vector3(3.4, 1.3, 2.9)
	raiz.add_child(criar_malha(prisma, Color("6b4226"), Vector3(0, 2.55, 0)))

func criar_nuvem(pos: Vector3, escala: float):
	var raiz := Node3D.new()
	raiz.position = pos
	raiz.scale = Vector3.ONE * escala
	var m := criar_material(Color.WHITE)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.disable_fog = true
	for d in [[Vector3(0, 0, 0), Vector3(14, 2.6, 4)], [Vector3(-1, 2.4, 0), Vector3(8, 2.4, 4)], [Vector3(1.5, 4.6, 0), Vector3(4, 2.2, 4)]]:
		var mi := MeshInstance3D.new()
		mi.mesh = caixa(d[1].x, d[1].y, d[1].z)
		mi.material_override = m
		mi.position = d[0]
		raiz.add_child(mi)
	add_child(raiz)
	nuvens.append(raiz)

# ---------- pescador, barco e tarrafa ----------
func montar_pescador():
	pescador = CharacterBody3D.new()
	add_child(pescador)

	var col := CollisionShape3D.new()
	var forma := BoxShape3D.new()
	forma.size = Vector3(6.2, 1.0, 1.5)
	col.shape = forma
	col.position = Vector3(0, 0.3, 0)
	pescador.add_child(col)

	barco = Node3D.new()
	barco.position = Vector3(0, 0.3, 0)
	pescador.add_child(barco)

	# casco da canoa (esfera esticada, esvaziada e cortada em cima)
	var casco := CSGCombiner3D.new()
	barco.add_child(casco)
	var externo := CSGSphere3D.new()
	externo.radius = 1.0
	externo.radial_segments = 24
	externo.rings = 12
	externo.scale = Vector3(3.0, 0.7, 0.85)
	externo.position = Vector3(0, 0.15, 0)
	externo.material = criar_material(Color("8b5a32"))
	casco.add_child(externo)
	var interno := CSGSphere3D.new()
	interno.radius = 1.0
	interno.radial_segments = 24
	interno.rings = 12
	interno.operation = CSGShape3D.OPERATION_SUBTRACTION
	interno.scale = Vector3(2.8, 0.58, 0.65)
	interno.position = Vector3(0, 0.25, 0)
	casco.add_child(interno)
	var corte := CSGBox3D.new()
	corte.size = Vector3(14, 2, 4)
	corte.operation = CSGShape3D.OPERATION_SUBTRACTION
	corte.position = Vector3(0, 1.45, 0)
	casco.add_child(corte)

	barco.add_child(criar_malha(caixa(2.6, 0.06, 0.9), Color("a86f3f"), Vector3(0, -0.2, 0)))

	# pescador
	var pele := Color("d2a078")
	barco.add_child(criar_malha(capsula(0.28, 0.95), Color("2f4bff"), Vector3(0, 0.35, 0.1)))
	barco.add_child(criar_malha(esfera(0.2), pele, Vector3(0, 1.0, 0.1)))
	barco.add_child(criar_malha(cilindro(0.5, 0.5, 0.03), Color("e0bd6e"), Vector3(0, 1.15, 0.1)))
	barco.add_child(criar_malha(cilindro(0.0, 0.3, 0.28), Color("e0bd6e"), Vector3(0, 1.3, 0.1)))
	for lado in [-1.0, 1.0]:
		barco.add_child(criar_malha(capsula(0.08, 0.6), pele, Vector3(0.34 * lado, 0.55, -0.15), Vector3(-65, 0, 8.0 * lado)))

	# tarrafa (área de detecção + visual)
	tarrafa = Area3D.new()
	tarrafa.add_to_group("area_pesca")
	tarrafa.position = Vector3(0, 0.1, -4.5)
	pescador.add_child(tarrafa)

	tarrafa_colisao = CollisionShape3D.new()
	var cil := CylinderShape3D.new()
	cil.radius = RAIO_TARRAFA
	cil.height = 2.0
	tarrafa_colisao.shape = cil
	tarrafa_colisao.disabled = true
	tarrafa.add_child(tarrafa_colisao)

	tarrafa_visual = Node3D.new()
	tarrafa_visual.visible = false
	tarrafa.add_child(tarrafa_visual)
	tarrafa_visual.add_child(criar_malha(cilindro(RAIO_TARRAFA, RAIO_TARRAFA, 0.04), Color(0.82, 0.68, 0.45, 0.55), Vector3.ZERO, Vector3.ZERO, Vector3.ONE, true))
	var aro := TorusMesh.new()
	aro.inner_radius = RAIO_TARRAFA - 0.12
	aro.outer_radius = RAIO_TARRAFA
	tarrafa_visual.add_child(criar_malha(aro, Color("555555")))
	for i in 8:
		var ang := i * 45.0
		var dir := Vector3(cos(deg_to_rad(ang)), 0, -sin(deg_to_rad(ang)))
		tarrafa_visual.add_child(criar_malha(caixa(RAIO_TARRAFA, 0.02, 0.03), Color("5a3b1e"), dir * RAIO_TARRAFA / 2.0 + Vector3(0, 0.03, 0), Vector3(0, ang, 0)))
	for i in 12:
		var ang2 := i * 30.0
		var pos_c := Vector3(cos(deg_to_rad(ang2)), 0, -sin(deg_to_rad(ang2))) * RAIO_TARRAFA
		tarrafa_visual.add_child(criar_malha(esfera(0.11), Color("3c3c3c"), pos_c))

	tarrafa.area_entered.connect(_ao_pescar)

func montar_peixes():
	for i in NUM_PEIXES:
		var p := Peixe3D.new()
		p.position = Vector3(randf_range(-LIMITE_X, LIMITE_X), 0.02, randf_range(-3.0, -6.0))
		add_child(p)

# ---------- interface e som ----------
func montar_interface():
	if cena_ui_desafio:
		add_child(cena_ui_desafio.instantiate())
	else:
		push_warning("Arraste UIDesafio.tscn para a propriedade 'Cena Ui Desafio' do nó Jogo3D.")

	var hud := CanvasLayer.new()
	add_child(hud)

	label_pontos = Label.new()
	label_pontos.position = Vector2(20, 16)
	label_pontos.add_theme_font_size_override("font_size", 26)
	label_pontos.add_theme_color_override("font_color", Color.WHITE)
	label_pontos.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	label_pontos.add_theme_constant_override("outline_size", 6)
	hud.add_child(label_pontos)

	var ajuda := Label.new()
	ajuda.text = "Setas: mover o barco   |   Espaço ou clique: lançar/recolher a tarrafa"
	ajuda.position = Vector2(20, 598)
	ajuda.add_theme_font_size_override("font_size", 18)
	ajuda.add_theme_color_override("font_color", Color.WHITE)
	ajuda.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	ajuda.add_theme_constant_override("outline_size", 5)
	hud.add_child(ajuda)

	var voltar := Button.new()
	voltar.text = "Menu"
	voltar.size = Vector2(100, 40)
	voltar.position = Vector2(get_viewport().get_visible_rect().size.x - 120, 16)
	voltar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MenuInicial.tscn"))
	hud.add_child(voltar)

func atualizar_placar():
	if label_pontos:
		label_pontos.text = "Acertos: %d" % GameManager.acertos

func carregar_som(nome: String) -> AudioStream:
	for ext in ["ogg", "mp3", "wav"]:
		var caminho := "res://assets/sons/%s.%s" % [nome, ext]
		if ResourceLoader.exists(caminho):
			return load(caminho)
	return null

func montar_sons():
	for nome in ["som_lancar", "som_pescar"]:
		var fluxo := carregar_som(nome)
		if fluxo:
			var p := AudioStreamPlayer.new()
			p.stream = fluxo
			add_child(p)
			sons[nome] = p
	var musica := carregar_som("musica_fundo")
	if musica:
		if "loop" in musica:
			musica.loop = true
		var pm := AudioStreamPlayer.new()
		pm.stream = musica
		pm.volume_db = -10.0
		add_child(pm)
		pm.play()

func tocar(nome: String):
	if sons.has(nome):
		sons[nome].play()

# ---------- jogo ----------
func _process(delta):
	tempo += delta
	agua_mat.uv1_offset += Vector3(delta * 0.01, delta * 0.006, 0)
	for n in nuvens:
		n.position.x += delta * 2.0
		if n.position.x > 130.0:
			n.position.x = -130.0

func _physics_process(_delta):
	var dir := Input.get_axis("ui_left", "ui_right") if jogando else 0.0
	pescador.velocity = Vector3(dir * VELOCIDADE, 0, 0)
	pescador.move_and_slide()
	pescador.position.x = clampf(pescador.position.x, -LIMITE_X, LIMITE_X)
	barco.position.y = 0.3 + sin(tempo * 1.6) * 0.04
	barco.rotation.z = sin(tempo * 1.2) * 0.03 - dir * 0.04
	barco.rotation.x = sin(tempo * 0.9) * 0.02
	

func _unhandled_input(event):
	if not jogando:
		return
	var acionar : bool = event.is_action_pressed("ui_accept")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		acionar = true
	if acionar:
		if rede_lancada:
			recolher_rede()
		else:
			lancar_rede()

func lancar_rede():
	rede_lancada = true
	tarrafa_colisao.disabled = false
	tocar("som_lancar")
	if tween_rede:
		tween_rede.kill()
	tarrafa_visual.visible = true
	tarrafa_visual.scale = Vector3(0.1, 1, 0.1)
	tarrafa_visual.rotation_degrees.y = -90.0
	tween_rede = create_tween().set_parallel(true)
	tween_rede.tween_property(tarrafa_visual, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_rede.tween_property(tarrafa_visual, "rotation_degrees:y", 0.0, 0.45)

func recolher_rede():
	rede_lancada = false
	tarrafa_colisao.disabled = true
	GameManager.finalizar_pescaria()
	if tween_rede:
		tween_rede.kill()
	tween_rede = create_tween()
	tween_rede.tween_property(tarrafa_visual, "scale", Vector3(0.1, 1, 0.1), 0.3)
	tween_rede.tween_callback(func(): tarrafa_visual.visible = false)

func _ao_pescar(_area):
	tocar("som_pescar")
