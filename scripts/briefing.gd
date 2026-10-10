class_name Briefing
extends CanvasLayer

signal comecou

func _ready():
	layer = 10
	var largura = get_viewport().get_visible_rect().size.x
	var altura = get_viewport().get_visible_rect().size.y

	var fundo := ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.55)
	fundo.size = Vector2(largura, altura)
	add_child(fundo)

	var painel := Panel.new()
	painel.size = Vector2(700, 520)
	painel.position = Vector2((largura - 700) / 2.0, (altura - 520) / 2.0)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("6b4226")
	estilo.set_corner_radius_all(18)
	estilo.set_border_width_all(4)
	estilo.border_color = Color("d4af6a")
	painel.add_theme_stylebox_override("panel", estilo)
	add_child(painel)

	var titulo := Label.new()
	titulo.text = _titulo()
	titulo.position = Vector2(30, 20)
	titulo.size = Vector2(640, 50)
	titulo.add_theme_font_size_override("font_size", 34)
	titulo.add_theme_color_override("font_color", Color("ffd978"))
	titulo.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	titulo.add_theme_constant_override("outline_size", 6)
	painel.add_child(titulo)

	var texto := Label.new()
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.custom_minimum_size = Vector2(640, 0)
	texto.position = Vector2(30, 85)
	texto.size = Vector2(640, 340)
	texto.add_theme_font_size_override("font_size", 21)
	texto.add_theme_color_override("font_color", Color.WHITE)
	texto.text = _descricao()
	painel.add_child(texto)

	var botao := Button.new()
	botao.text = "Começar"
	botao.size = Vector2(220, 56)
	botao.position = Vector2(240, 445)
	botao.add_theme_font_size_override("font_size", 24)
	botao.pressed.connect(_comecar)
	painel.add_child(botao)
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
		_:
			return "Você é pescador na Lagoa Mundaú. Lance a tarrafa sobre os peixes e recolha. Depois de duas pescarias, vamos comparar os pesos das tarrafas: some ou subtraia para achar o resultado e escolha a resposta certa." + comum
func _comecar():
	comecou.emit()
	queue_free()
