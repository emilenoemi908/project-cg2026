extends CanvasLayer
# Tela da pesca surpresa: mostra o fruto do mar especial depois de recolher a tarrafa.

signal continuar

const PASTA_MODELOS := "res://assets/modelos/"

var overlay: Control
var painel: Panel
var nome_label: Label
var valor_label: Label
var botao_continuar: Button
var container_modelo: Node3D
var modelo_atual: Node3D


func _ready():
	layer = 5
	_montar_interface()
	overlay.visible = false


func _montar_interface():
	var tamanho := get_viewport().get_visible_rect().size

	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var fundo := ColorRect.new()
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.color = Color(0.02, 0.05, 0.08, 0.84)
	fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(fundo)

	painel = Panel.new()
	painel.size = Vector2(560, 510)
	painel.position = (tamanho - painel.size) / 2.0
	EstiloUI.painel(painel)
	overlay.add_child(painel)

	var titulo := Label.new()
	titulo.text = "PESCARIA SURPRESA!"
	titulo.position = Vector2(20, 16)
	titulo.size = Vector2(520, 50)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloUI.rotulo(titulo, 34, Color("ffd978"))
	painel.add_child(titulo)

	var moldura := Panel.new()
	moldura.position = Vector2(130, 78)
	moldura.size = Vector2(300, 270)
	painel.add_child(moldura)

	var estilo_moldura := StyleBoxFlat.new()
	estilo_moldura.bg_color = Color("243b42")
	estilo_moldura.set_corner_radius_all(14)
	moldura.add_theme_stylebox_override("panel", estilo_moldura)

	var viewport_container := SubViewportContainer.new()
	viewport_container.position = Vector2(5, 5)
	viewport_container.size = Vector2(290, 260)
	viewport_container.stretch = true
	moldura.add_child(viewport_container)

	var viewport_3d := SubViewport.new()
	viewport_3d.size = Vector2i(512, 512)
	viewport_3d.transparent_bg = false
	# Mundo 3D próprio: sem isso o modelo apareceria no meio do cenário do jogo.
	viewport_3d.own_world_3d = true
	viewport_3d.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(viewport_3d)

	var mundo := Node3D.new()
	viewport_3d.add_child(mundo)

	var ambiente := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("243b42")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.8
	ambiente.environment = env
	mundo.add_child(ambiente)

	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-30, -25, 0)
	luz.light_energy = 1.5
	mundo.add_child(luz)

	var camera := Camera3D.new()
	camera.position = Vector3(0, 0.4, 4)
	mundo.add_child(camera)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera.fov = 45
	camera.make_current()

	container_modelo = Node3D.new()
	mundo.add_child(container_modelo)

	nome_label = Label.new()
	nome_label.position = Vector2(20, 355)
	nome_label.size = Vector2(520, 42)
	nome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloUI.rotulo(nome_label, 30, Color("ffd978"))
	painel.add_child(nome_label)

	valor_label = Label.new()
	valor_label.position = Vector2(20, 397)
	valor_label.size = Vector2(520, 35)
	valor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloUI.rotulo(valor_label, 24, Color.WHITE, 5)
	painel.add_child(valor_label)

	botao_continuar = Button.new()
	botao_continuar.text = "Continuar"
	botao_continuar.position = Vector2(170, 442)
	botao_continuar.size = Vector2(220, 52)
	EstiloUI.botao(botao_continuar, 24)
	botao_continuar.pressed.connect(_ao_continuar)
	painel.add_child(botao_continuar)


# especie: dicionário de _montar_especies() no jogo_3d.gd
# com_bonus: true quando o fruto do mar foi somado à captura.
# Retorna false (e não mostra nada) se o modelo não for encontrado.
func abrir(especie: Dictionary, com_bonus: bool) -> bool:
	var caminho: String = PASTA_MODELOS + String(especie["arquivo"])
	if not ResourceLoader.exists(caminho):
		push_warning("Modelo da pesca surpresa não encontrado: " + caminho)
		return false
	var cena := load(caminho) as PackedScene
	if cena == null:
		return false
	var instancia := cena.instantiate()
	if not instancia is Node3D:
		instancia.free()
		return false

	if modelo_atual != null:
		modelo_atual.queue_free()
		modelo_atual = null

	# O pivô é quem gira; o modelo fica deslocado dentro dele para girar pelo centro.
	var modelo := instancia as Node3D
	modelo.scale = Vector3.ONE * float(especie["escala"])
	var centro: Vector3 = especie["centro"]
	modelo.position = -(modelo.transform.basis * centro)
	modelo_atual = Node3D.new()
	container_modelo.add_child(modelo_atual)
	modelo_atual.add_child(modelo)

	nome_label.text = String(especie["nome"])
	if com_bonus:
		var q := int(especie["quantidade"])
		var texto: String = "+" + GameManager.fmt_kg(float(especie["peso"]))
		if q > 1:
			texto += "   (vale %s)" % GameManager.fmt_peixes(q)
		valor_label.text = texto
	else:
		valor_label.text = "Achado especial!"

	# Evita pular a tela sem querer com um duplo clique/Espaço.
	botao_continuar.disabled = true
	overlay.visible = true
	painel.scale = Vector2(0.85, 0.85)
	painel.pivot_offset = painel.size / 2.0

	var tween := create_tween()
	tween.tween_property(painel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	get_tree().create_timer(0.5).timeout.connect(_liberar_botao)

	# A ostra com pérola (vale mais de 1) tem um som mais longo e brilhante.
	if int(especie["quantidade"]) > 1:
		_tocar_som("som_perola")
	else:
		_tocar_som("som_revelacao")
	return true


func _tocar_som(nome: String):
	var caminho := "res://assets/sons/%s.wav" % nome
	if not ResourceLoader.exists(caminho):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(caminho)
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


func _liberar_botao():
	if overlay.visible:
		botao_continuar.disabled = false
		botao_continuar.grab_focus()


func _process(delta: float):
	if overlay.visible and modelo_atual != null:
		modelo_atual.rotate_y(delta * 1.5)


func _ao_continuar():
	overlay.visible = false

	if modelo_atual != null:
		modelo_atual.queue_free()
		modelo_atual = null

	continuar.emit()
