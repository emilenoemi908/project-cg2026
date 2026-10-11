class_name Briefing
extends CanvasLayer

signal comecou

func _ready():
	layer = 10

	var fundo := ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.55)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var painel := PanelContainer.new()
	EstiloUI.painel(painel)
	centro.add_child(painel)

	var margem := MarginContainer.new()
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margem.add_theme_constant_override(lado, 30)
	painel.add_child(margem)

	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 14)
	margem.add_child(caixa)

	var titulo := Label.new()
	titulo.text = _titulo()
	EstiloUI.rotulo(titulo, 40, Color("ffd978"), 8)
	caixa.add_child(titulo)

	var texto := Label.new()
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.custom_minimum_size = Vector2(660, 0)
	texto.add_theme_font_size_override("font_size", 21)
	texto.add_theme_color_override("font_color", Color.WHITE)
	texto.text = _descricao()
	caixa.add_child(texto)

	var botao := Button.new()
	botao.text = "Começar"
	botao.custom_minimum_size = Vector2(240, 58)
	botao.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	EstiloUI.botao(botao, 28)
	botao.pressed.connect(_comecar)
	caixa.add_child(botao)
	botao.grab_focus()

func _titulo() -> String:
	match GameManager.modo:
		"multiplicacao":
			return "Multiplicação"
		"meta":
			return "Meta de Pesca"
		_:
			return "Soma e Subtração"

func _descricao() -> String:
	var comum := "\n\nCada peixe mostra, acima dele, a espécie e o peso.\nControles: setas movem o barco; Espaço ou clique lançam e recolhem a tarrafa.\nOs pesos do jogo são valores aproximados, escolhidos para facilitar as contas."
	match GameManager.modo:
		"multiplicacao":
			return "Você é pescador na Lagoa Mundaú. Hoje só aparece uma espécie de peixe, e todos pesam o mesmo (veja no canto da tela). Lance a tarrafa, recolha, conte quantos peixes vieram e multiplique pelo peso de cada um." + comum
		"meta":
			return "A pescaria de hoje tem uma meta, em quilos ou em número de peixes (ela aparece no canto da tela). Cada vez que você recolhe a tarrafa, o que veio é somado ao total. Se ainda faltar, responda quanto falta. Se passar da meta, responda quanto passou e tente de novo. Se acertar a meta exata, você ganha um ponto e recebe uma nova meta." + comum
		"sururu":
			return "O sururu é o principal recurso pesqueiro da Lagoa Mundaú e patrimônio cultural de Alagoas. Ele é catado no fundo da lagoa em mergulhos, sem equipamento, e levado em latas. No jogo, um companheiro mergulha ao lado da canoa. Aperte Espaço ou clique para mergulhar e resolva a conta de cada mergulho.\n\nCada lata tem 20 kg de sururu com casca, e cerca da metade do peso vira carne depois do despinicar, quando as marisqueiras tiram o molusco da casca. Esses valores são aproximados e servem para as contas.\n\nControles: setas movem o barco; Espaço ou clique fazem o mergulho."
		_:
			return "Você é pescador na Lagoa Mundaú. Lance a tarrafa sobre os peixes e recolha. Depois de duas pescarias, vamos comparar os pesos das tarrafas: some ou subtraia para achar o resultado e escolha a resposta certa." + comum

func _comecar():
	comecou.emit()
	queue_free()
