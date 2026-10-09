
extends CanvasLayer

@onready var panel = $Panel
@onready var label_pergunta = $Panel/LabelPergunta
@onready var label_feedback = $Panel/LabelFeedback
@onready var botao_a = $Panel/BotaoA
@onready var botao_b = $Panel/BotaoB
@onready var botao_c = $Panel/BotaoC
@onready var som_certo = $SomCerto
@onready var som_errado = $SomErrado

var opcoes: Array = []

func _ready():
	var largura = get_viewport().get_visible_rect().size.x
	panel.size = Vector2(560, 260)
	panel.position = Vector2((largura - 560) / 2.0, 20)
	label_pergunta.position = Vector2(20, 14)
	label_pergunta.size = Vector2(520, 110)
	label_pergunta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var botoes = [botao_a, botao_b, botao_c]
	for i in 3:
		botoes[i].position = Vector2(20 + i * 180, 140)
		botoes[i].size = Vector2(160, 54)
	label_feedback.position = Vector2(20, 208)
	label_feedback.size = Vector2(520, 40)
	label_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	panel.visible = false
	botao_a.pressed.connect(func(): _responder(botao_a))
	botao_b.pressed.connect(func(): _responder(botao_b))
	botao_c.pressed.connect(func(): _responder(botao_c))
	GameManager.desafio_pronto.connect(_mostrar_desafio)

func _mostrar_desafio():
	var texto_pergunta = ""
	match GameManager.operacao:
		"soma":
			texto_pergunta = "%.1f kg + %.1f kg = ?" % [GameManager.pescaria_a.peso, GameManager.pescaria_b.peso]
		"subtracao":
			texto_pergunta = "%.1f kg - %.1f kg = ?" % [GameManager.pescaria_a.peso, GameManager.pescaria_b.peso]
		"multiplicacao":
			texto_pergunta = "%d peixes x %.1f kg cada = ?" % [GameManager.pescaria_a.quantidade, GameManager.pescaria_a.peso]
		"falta":
			texto_pergunta = "Meta: %s\nVocê já pescou: %s\nQuanto falta para a meta?" % [GameManager.texto_valor(GameManager.meta_valor), GameManager.texto_valor(GameManager.desafio_acumulado)]
		"excesso":
			texto_pergunta = "Meta: %s\nVocê pescou: %s\nQuanto passou da meta?" % [GameManager.texto_valor(GameManager.meta_valor), GameManager.texto_valor(GameManager.desafio_acumulado)]

	label_pergunta.text = texto_pergunta
	label_feedback.text = ""

	var correta = GameManager.resposta_correta
	var passo = GameManager.passo_opcoes
	var candidatas: Array = []
	for k in range(1, 5):
		candidatas.append(snappedf(correta + k * passo, 0.1))
		var abaixo = snappedf(correta - k * passo, 0.1)
		if abaixo >= 0.0:
			candidatas.append(abaixo)
	candidatas.shuffle()

	opcoes = [correta, candidatas[0], candidatas[1]]
	opcoes.shuffle()

	botao_a.text = GameManager.texto_resposta(opcoes[0])
	botao_b.text = GameManager.texto_resposta(opcoes[1])
	botao_c.text = GameManager.texto_resposta(opcoes[2])
	panel.visible = true

func _responder(botao_pressionado: Button):
	var valor = float(botao_pressionado.text)
	if GameManager.verificar_resposta(valor):
		label_feedback.text = "Certo!"
		som_certo.play()
	else:
		label_feedback.text = "Tente de novo. Resposta certa: %s" % GameManager.texto_resposta(GameManager.resposta_correta)
		som_errado.play()

	await get_tree().create_timer(2.0).timeout
	panel.visible = false
