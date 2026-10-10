extends Node2D

@onready var nuvem1 = $Nuvem1
@onready var nuvem2 = $Nuvem2
@onready var nuvem3 = $Nuvem3
@onready var botao_soma = $BotaoSoma
@onready var botao_mult = $BotaoMultiplicacao
@onready var botao_meta = $BotaoMeta

var pos_nuvem1: Vector2
var pos_nuvem2: Vector2
var pos_nuvem3: Vector2
var tempo: float = 0.0

var canoas: Array = []
var icones: Array = []
var titulo = null
var subtitulo = null
var titulo_y: float = 0.0
var fonte: Font = null

func _ready():
	pos_nuvem1 = nuvem1.position
	pos_nuvem2 = nuvem2.position
	pos_nuvem3 = nuvem3.position

	fonte = _carregar_fonte()
	_trocar_fundo()
	_criar_canoas()
	_criar_bolhas()
	_estilizar_textos()
	_criar_icones()
	for b in [botao_soma, botao_mult, botao_meta]:
		_estilizar_botao(b)

	botao_soma.pressed.connect(func(): iniciar("soma_subtracao"))
	botao_mult.pressed.connect(func(): iniciar("multiplicacao"))
	botao_meta.pressed.connect(func(): iniciar("meta"))

func _carregar_fonte() -> Font:
	var caminho := "res://assets/fonts/LilitaOne-Regular.ttf"
	if ResourceLoader.exists(caminho):
		return load(caminho)
	return null

func _trocar_fundo():
	var fundo = get_node_or_null("Fundo")
	var caminho := "res://assets/sprites/fundo_menu_v2.png"
	if fundo and ResourceLoader.exists(caminho):
		fundo.texture = load(caminho)
		fundo.z_index = -10
	for n in [nuvem1, nuvem2, nuvem3]:
		n.z_index = -8

func _criar_canoas():
	var caminho := "res://assets/sprites/canoa_menu.png"
	if not ResourceLoader.exists(caminho):
		return
	var tex = load(caminho)
	for dados in [[Vector2(320, 432), 0.6, 1.0], [Vector2(850, 448), 0.6, -1.0]]:
		var s := Sprite2D.new()
		s.texture = tex
		s.position = dados[0]
		s.scale = Vector2(dados[1] * dados[2], dados[1])
		s.z_index = -5
		add_child(s)
		canoas.append({"no": s, "base": dados[0], "fase": randf() * TAU})

func _criar_bolhas():
	var caminho := "res://assets/sprites/bolha.png"
	if not ResourceLoader.exists(caminho):
		return
	var p := CPUParticles2D.new()
	p.texture = load(caminho)
	p.amount = 16
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.position = Vector2(576, 640)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(560, 6)
	p.direction = Vector2(0, -1)
	p.spread = 10.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 22.0
	p.initial_velocity_max = 40.0
	p.scale_amount_min = 0.25
	p.scale_amount_max = 0.7
	var rampa := Gradient.new()
	rampa.set_color(0, Color(1, 1, 1, 0.0))
	rampa.set_color(1, Color(1, 1, 1, 0.0))
	rampa.add_point(0.15, Color(1, 1, 1, 0.85))
	p.color_ramp = rampa
	p.z_index = -4
	add_child(p)

func _estilizar_textos():
	titulo = get_node_or_null("Titulo")
	subtitulo = get_node_or_null("Subtitulo")
	var largura = get_viewport().get_visible_rect().size.x
	if titulo:
		titulo.text = "PESCA NA\nLAGOA MUNDAÚ"
		titulo.size = Vector2(largura, 170)
		titulo.position = Vector2(0, 40)
		titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		titulo.add_theme_font_size_override("font_size", 72)
		titulo.add_theme_constant_override("line_spacing", -12)
		titulo.add_theme_color_override("font_color", Color.WHITE)
		titulo.add_theme_color_override("font_outline_color", Color("2d1b0e"))
		titulo.add_theme_constant_override("outline_size", 14)
		if fonte:
			titulo.add_theme_font_override("font", fonte)
		titulo_y = titulo.position.y
	if subtitulo:
		subtitulo.text = "MATEMÁTICA & AVENTURA"
		subtitulo.size = Vector2(largura, 40)
		subtitulo.position = Vector2(0, 212)
		subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitulo.add_theme_font_size_override("font_size", 30)
		subtitulo.add_theme_color_override("font_color", Color("ffd978"))
		subtitulo.add_theme_color_override("font_outline_color", Color("2d1b0e"))
		subtitulo.add_theme_constant_override("outline_size", 8)
		if fonte:
			subtitulo.add_theme_font_override("font", fonte)

func _criar_icones():
	var itens = [
		[botao_soma, "res://assets/sprites/icone_soma_v2.png"],
		[botao_mult, "res://assets/sprites/icone_mult_v2.png"],
		[botao_meta, "res://assets/sprites/icone_meta_v2.png"],
	]
	for item in itens:
		var b: Button = item[0]
		if not ResourceLoader.exists(item[1]):
			continue
		var s := Sprite2D.new()
		s.texture = load(item[1])
		s.scale = Vector2(0.55, 0.55)
		s.position = Vector2(b.position.x + b.size.x / 2.0, b.position.y - 8.0)
		s.z_index = 5
		add_child(s)
		icones.append({"no": s, "base": s.position, "fase": randf() * TAU})
		
func _estilo(cor: Color) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = cor
	e.set_corner_radius_all(20)
	e.set_border_width_all(4)
	e.border_width_bottom = 8
	e.border_color = Color("e2c27d")
	e.shadow_color = Color(0, 0, 0, 0.45)
	e.shadow_size = 8
	e.shadow_offset = Vector2(0, 6)
	return e

func _estilizar_botao(b: Button):
	b.add_theme_font_size_override("font_size", 28)
	if fonte:
		b.add_theme_font_override("font", fonte)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color("fff2c4"))
	b.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	b.add_theme_constant_override("outline_size", 6)
	b.add_theme_stylebox_override("normal", _estilo(Color("7a4b2a")))
	b.add_theme_stylebox_override("hover", _estilo(Color("93603a")))
	b.add_theme_stylebox_override("pressed", _estilo(Color("5e3a20")))
	b.pivot_offset = b.size / 2.0
	b.mouse_entered.connect(func(): _escalar(b, 1.06))
	b.mouse_exited.connect(func(): _escalar(b, 1.0))

func _escalar(b: Button, alvo: float):
	var tw := create_tween()
	tw.tween_property(b, "scale", Vector2(alvo, alvo), 0.12)

func _process(delta):
	tempo += delta
	nuvem1.position.x = pos_nuvem1.x + sin(tempo * 0.1) * 40
	nuvem2.position.x = pos_nuvem2.x + sin(tempo * 0.08 + 1.0) * 50
	nuvem3.position.x = pos_nuvem3.x + sin(tempo * 0.12 + 2.0) * 35
	for c in canoas:
		c.no.position.y = c.base.y + sin(tempo * 1.4 + c.fase) * 3.0
		c.no.rotation = sin(tempo * 1.1 + c.fase) * 0.04
		
	for i in icones:
		i.no.position.y = i.base.y + sin(tempo * 2.0 + i.fase) * 3.0
		
	if titulo:
		titulo.position.y = titulo_y + sin(tempo * 1.5) * 4.0

func iniciar(modo_escolhido: String):
	GameManager.modo = modo_escolhido
	get_tree().change_scene_to_file("res://scenes/Jogo3D.tscn")
