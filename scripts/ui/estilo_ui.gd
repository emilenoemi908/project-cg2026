class_name EstiloUI
extends RefCounted

static var _fonte: Font = null

static func fonte() -> Font:
	if _fonte == null:
		var caminho := "res://assets/fonts/LilitaOne-Regular.ttf"
		if ResourceLoader.exists(caminho):
			_fonte = load(caminho)
	return _fonte

static func rotulo(l: Label, tamanho: int, cor: Color = Color.WHITE, contorno: int = 6):
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	l.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	l.add_theme_constant_override("outline_size", contorno)
	var f := fonte()
	if f:
		l.add_theme_font_override("font", f)

static func _caixa_botao(cor: Color) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = cor
	e.set_corner_radius_all(18)
	e.set_border_width_all(4)
	e.border_width_bottom = 7
	e.border_color = Color("e2c27d")
	e.shadow_color = Color(0, 0, 0, 0.4)
	e.shadow_size = 6
	e.shadow_offset = Vector2(0, 5)
	e.set_content_margin_all(10)
	return e

static func botao(b: Button, tamanho: int = 24):
	b.add_theme_font_size_override("font_size", tamanho)
	var f := fonte()
	if f:
		b.add_theme_font_override("font", f)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color("fff2c4"))
	b.add_theme_color_override("font_focus_color", Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	b.add_theme_constant_override("outline_size", 5)
	b.add_theme_stylebox_override("normal", _caixa_botao(Color("7a4b2a")))
	b.add_theme_stylebox_override("hover", _caixa_botao(Color("93603a")))
	b.add_theme_stylebox_override("pressed", _caixa_botao(Color("5e3a20")))
	# contorno claro quando o botão está em foco (navegação pelo teclado)
	var foco := StyleBoxFlat.new()
	foco.draw_center = false
	foco.set_corner_radius_all(18)
	foco.set_border_width_all(3)
	foco.border_color = Color("ffe9a8")
	b.add_theme_stylebox_override("focus", foco)
	b.mouse_entered.connect(func(): EstiloUI._escalar(b, 1.05))
	b.mouse_exited.connect(func(): EstiloUI._escalar(b, 1.0))

static func _escalar(b: Button, alvo: float):
	b.pivot_offset = b.size / 2.0
	var tw := b.create_tween()
	tw.tween_property(b, "scale", Vector2(alvo, alvo), 0.1)

static func caixa_painel() -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = Color("6b4226")
	e.set_corner_radius_all(18)
	e.set_border_width_all(4)
	e.border_color = Color("d4af6a")
	e.shadow_color = Color(0, 0, 0, 0.4)
	e.shadow_size = 10
	e.shadow_offset = Vector2(0, 6)
	return e

static func painel(c: Control):
	c.add_theme_stylebox_override("panel", caixa_painel())

# Placa de madeira translúcida atrás de um texto do HUD. Deixa os cliques passarem para o jogo.
static func placa(pai: Node, l: Label, pos: Vector2) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.position = pos
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var e := StyleBoxFlat.new()
	e.bg_color = Color(0.24, 0.14, 0.07, 0.78)
	e.set_corner_radius_all(12)
	e.set_border_width_all(2)
	e.border_color = Color("d4af6a")
	e.set_content_margin_all(8)
	pc.add_theme_stylebox_override("panel", e)
	pc.add_child(l)
	pai.add_child(pc)
	l.visibility_changed.connect(func(): pc.visible = l.visible)
	return pc
