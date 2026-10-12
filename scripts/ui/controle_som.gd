class_name ControleSom
extends CanvasLayer
# Botão SOM/MUDO + controle de volume expansível para a esquerda .

var posicao_y: float = 14.0
var botao: Button
var slider: HSlider
var painel: PanelContainer
var caixa: HBoxContainer
var slider_visivel: bool = false
var largura_tela: float = 0.0
var e_jogo: bool = false


func _ready():
	layer = 12
	largura_tela = get_viewport().get_visible_rect().size.x

	var cena_atual := get_tree().current_scene.scene_file_path.to_lower() if get_tree().current_scene else ""
	e_jogo = not ("menu" in cena_atual or "inicial" in cena_atual)

	painel = PanelContainer.new()
	_atualizar_posicao_painel()

	var e := StyleBoxFlat.new()
	e.bg_color = Color(0.24, 0.14, 0.07, 0.78)
	e.set_corner_radius_all(12)
	e.set_border_width_all(2)
	e.border_color = Color("d4af6a")
	e.set_content_margin_all(6)
	painel.add_theme_stylebox_override("panel", e)
	add_child(painel)

	caixa = HBoxContainer.new()
	caixa.add_theme_constant_override("separation", 10)
	painel.add_child(caixa)

	botao = Button.new()
	botao.custom_minimum_size = Vector2(84, 36)
	botao.focus_mode = Control.FOCUS_NONE
	EstiloUI.botao(botao, 18)
	
	botao.pressed.connect(func():
		slider_visivel = not slider_visivel
		_atualizar_estado_slider()
	)

	slider = HSlider.new()
	slider.custom_minimum_size = Vector2(110, 36)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.focus_mode = Control.FOCUS_NONE
	slider.add_theme_stylebox_override("slider", _trilho(Color(0.89, 0.76, 0.49, 0.35)))
	slider.add_theme_stylebox_override("grabber_area", _trilho(Color("ffd978")))
	slider.add_theme_stylebox_override("grabber_area_highlight", _trilho(Color("ffe9a8")))
	slider.value_changed.connect(func(v): Trilha.definir_volume(v))

	# Adiciona apenas o botão inicialmente
	caixa.add_child(botao)
	painel.reset_size()

	Trilha.mudou.connect(_atualizar)
	_atualizar()


func _atualizar_estado_slider():
	var y := 64.0 if e_jogo else posicao_y
	
	if slider_visivel:
		if not slider.get_parent():
			caixa.add_child(slider)
		painel.position = Vector2(largura_tela - 245.0, y)
	else:
		if slider.get_parent():
			caixa.remove_child(slider)
		painel.position = Vector2(largura_tela - 130.0, y)
	
	# Força o painel a recalcular a largura exata imediatamente após mudar os filhos
	painel.reset_size()


func _atualizar_posicao_painel():
	if not painel:
		return
	var y := 64.0 if e_jogo else posicao_y
	painel.position = Vector2(largura_tela - 130.0, y)


func _trilho(cor: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = cor
	s.set_corner_radius_all(4)
	s.content_margin_top = 3
	s.content_margin_bottom = 3
	return s


func _atualizar():
	botao.text = "MUDO" if (Trilha.mudo or Trilha.volume <= 0.001) else "SOM"
	slider.set_value_no_signal(Trilha.volume)
