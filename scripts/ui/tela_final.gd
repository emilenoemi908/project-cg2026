class_name TelaFinal
extends CanvasLayer

var metas := 0
var aberta := false

func _ready():
	layer = 20
	GameManager.ultimo_respondido.connect(_agendar)
	GameManager.meta_atingida.connect(func(): metas += 1)

func _agendar():
	await get_tree().create_timer(3.4).timeout
	_mostrar()

func _estilo() -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = Color("6b4226")
	e.set_corner_radius_all(18)
	e.set_border_width_all(4)
	e.border_color = Color("d4af6a")
	return e

func _label(texto: String, pos: Vector2, tam: Vector2, tamanho_fonte: int, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = pos
	l.size = tam
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", tamanho_fonte)
	l.add_theme_color_override("font_color", cor)
	l.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	l.add_theme_constant_override("outline_size", 6)
	
	var f := EstiloUI.fonte()
	if f:
		l.add_theme_font_override("font", f)
		
	return l

func _estrela(centro: Vector2, raio: float, cheia: bool) -> Node2D:
	var grupo := Node2D.new()
	grupo.position = centro
	for camada in 2:
		var pts := PackedVector2Array()
		var r_ext := raio
		if camada == 0:
			r_ext = raio * 1.12
		for i in 10:
			var ang := -PI / 2.0 + i * PI / 5.0
			var r := r_ext
			if i % 2 == 1:
				r = r_ext * 0.45
			pts.append(Vector2(cos(ang), sin(ang)) * r)
		var poly := Polygon2D.new()
		poly.polygon = pts
		if camada == 0:
			poly.color = Color("2d1b0e")
		elif cheia:
			poly.color = Color("ffd24a")
		else:
			poly.color = Color("8a7a66")
		grupo.add_child(poly)
	return grupo

func _mostrar():
	if aberta:
		return
	aberta = true
	var largura = get_viewport().get_visible_rect().size.x
	var altura = get_viewport().get_visible_rect().size.y

	var fundo := ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.6)
	fundo.size = Vector2(largura, altura)
	add_child(fundo)

	var alt_painel := 440.0
	if GameManager.extras_total > 0:
		alt_painel += 32.0
	var painel := Panel.new()
	painel.size = Vector2(640, alt_painel)
	painel.position = Vector2((largura - 640) / 2.0, (altura - alt_painel) / 2.0)
	EstiloUI.painel(painel)
	add_child(painel)

	var total: int = GameManager.LIMITE_DESAFIOS
	var certas: int = GameManager.acertos_perguntas
	var fracao := float(certas) / float(total)
	var estrelas := 0
	if fracao >= 0.85:
		estrelas = 3
	elif fracao >= 0.6:
		estrelas = 2
	elif fracao >= 0.35:
		estrelas = 1
	var mensagens := ["Continue treinando, você vai melhorar!", "Bom começo! Tente de novo.", "Muito bem, pescador!", "Excelente! Você domina as contas da lagoa!"]

	painel.add_child(_label("Fim da pescaria!", Vector2(0, 22), Vector2(640, 50), 38, Color("ffd978")))
	painel.add_child(_label("Você acertou %d de %d desafios." % [certas, total], Vector2(0, 95), Vector2(640, 36), 26, Color.WHITE))
	var y_msg := 140.0
	if GameManager.modo == "meta":
		painel.add_child(_label("Metas atingidas: %d" % metas, Vector2(0, 135), Vector2(640, 36), 24, Color.WHITE))
		y_msg = 175.0
	if GameManager.extras_total > 0:
		painel.add_child(_label("Conta extra da surpresa: %d de %d" % [GameManager.extras_certas, GameManager.extras_total], Vector2(0, y_msg - 4), Vector2(640, 32), 22, Color("ffd978")))
		y_msg += 32.0
	for i in 3:
		painel.add_child(_estrela(Vector2(220 + i * 100, y_msg + 70), 40.0, i < estrelas))
	painel.add_child(_label(mensagens[estrelas], Vector2(20, y_msg + 130), Vector2(600, 40), 22, Color.WHITE))

	var de_novo := Button.new()
	de_novo.text = "Jogar de novo"
	de_novo.size = Vector2(240, 56)
	de_novo.position = Vector2(50, alt_painel - 80)
	EstiloUI.botao(de_novo, 26)
	de_novo.pressed.connect(func(): get_tree().reload_current_scene())
	painel.add_child(de_novo)

	var voltar := Button.new()
	voltar.text = "Voltar ao menu"
	voltar.size = Vector2(240, 56)
	voltar.position = Vector2(350, alt_painel - 80)
	EstiloUI.botao(voltar, 26)
	voltar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menuInicial.tscn"))
	painel.add_child(voltar)
	de_novo.grab_focus()
