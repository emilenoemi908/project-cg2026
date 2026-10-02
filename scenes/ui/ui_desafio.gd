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
	var simbolo = "+" if GameManager.operacao == "soma" else "-"
	label_pergunta.text = "%.1f kg %s %.1f kg = ?" % [GameManager.pescaria_a.peso, simbolo, GameManager.pescaria_b.peso]
	label_feedback.text = ""

	var correta = GameManager.resposta_correta
	opcoes = [correta, snappedf(correta + randf_range(0.5, 1.5), 0.1), snappedf(max(0.0, correta - randf_range(0.5, 1.5)), 0.1)]
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
