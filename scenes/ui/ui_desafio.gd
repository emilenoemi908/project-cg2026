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

	label_pergunta.text = texto_pergunta
	label_feedback.text = ""

	var correta = GameManager.resposta_correta
	var candidatas: Array = []
	for k in range(1, 5):
		var acima = snappedf(correta + k * 0.5, 0.1)
		var abaixo = snappedf(correta - k * 0.5, 0.1)
		candidatas.append(acima)
		if abaixo >= 0.0:
			candidatas.append(abaixo)
	candidatas.shuffle()

	opcoes = [correta, candidatas[0], candidatas[1]]
	opcoes.shuffle()

	botao_a.text = str(opcoes[0])
	botao_b.text = str(opcoes[1])
	botao_c.text = str(opcoes[2])
	panel.visible = true

func _responder(botao_pressionado: Button):
	var valor = float(botao_pressionado.text)
	if GameManager.verificar_resposta(valor):
		label_feedback.text = "Certo!"
		som_certo.play()
	else:
		label_feedback.text = "Tente de novo. Resposta certa: %.1f" % GameManager.resposta_correta
		som_errado.play()

	await get_tree().create_timer(2.0).timeout
	panel.visible = false
	
