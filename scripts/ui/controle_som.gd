class_name ControleSom
extends CanvasLayer
# Botão SOM/MUDO + controle de volume, no canto superior direito.
# Defina posicao_y antes de adicionar à cena, se precisar descer o painel.

var posicao_y := 14.0
var botao: Button
var slider: HSlider


func _ready():
	layer = 12
	var largura := get_viewport().get_visible_rect().size.x

	var painel := PanelContainer.new()
	painel.position = Vector2(largura - 250.0, posicao_y)
	var e := StyleBoxFlat.new()
	e.bg_color = Color(0.24, 0.14, 0.07, 0.78)
	e.set_corner_radius_all(12)
	e.set_border_width_all(2)
	e.border_color = Color("d4af6a")
	e.set_content_margin_all(6)
	painel.add_theme_stylebox_override("panel", e)
	add_child(painel)

	var caixa := HBoxContainer.new()
	caixa.add_theme_constant_override("separation", 10)
	painel.add_child(caixa)

	# Sem foco: assim Espaço/Enter (que lançam a tarrafa) não apertam estes controles.
	botao = Button.new()
	botao.custom_minimum_size = Vector2(84, 36)
	botao.focus_mode = Control.FOCUS_NONE
	EstiloUI.botao(botao, 18)
	botao.pressed.connect(func(): Trilha.alternar_mudo())
	caixa.add_child(botao)

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
	caixa.add_child(slider)

	Trilha.mudou.connect(_atualizar)
	_atualizar()


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
