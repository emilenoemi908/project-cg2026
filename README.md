# Pesca na Lagoa Mundaú: Matemática & Aventura

Jogo educativo desenvolvido na **Godot Engine 4** para a disciplina de Computação Gráfica (CG-2026). Une **Cultura de Alagoas** e **Matemática do Ensino Fundamental**: o jogador pesca na Lagoa Mundaú (Maceió) e usa o peso e a quantidade do que pescou para resolver contas de soma, subtração, multiplicação e divisão por 2.

**Equipe:** Emile Noemi Alves da Silva e Fernanda Correia Matias de Menezes

## Estrutura do jogo

- **Menu inicial (2D):** fundo ilustrado com nuvens, canoas e bolhas animadas, e quatro botões de modo.
- **Jogo (3D):** cena montada por código, com barco, pescador, tarrafa, peixes e cenário da lagoa.
- **Rodada:** cada partida tem **8 desafios**. Ao responder o último, aparece a tela final com acertos, estrelas e as opções "Jogar de novo" e "Voltar ao menu".

## Modos de jogo

| Modo | Como funciona | Conta trabalhada |
|---|---|---|
| Soma e Subtração | Lança a tarrafa duas vezes e compara o peso das duas pescarias | Soma e diferença em kg |
| Multiplicação | Numa rodada, todos os peixes são de uma espécie e pesam o mesmo | Quantidade x peso de cada peixe |
| Meta de Pesca | Há uma meta em kg ou em número de peixes. Cada pescaria é somada ao total | Quanto falta e quanto passou |

## Controles

| Ação | Teclado | Mouse |
|---|---|---|
| Mover o barco | Setas esquerda e direita | |
| Lançar e recolher a tarrafa (ou mergulhar, no modo Sururu) | Enter ou Espaço | Clique na cena |
| Escolher o modo, responder, jogar de novo | Enter no botão em foco | Clique nos botões |

## Requisitos da disciplina e onde aparecem

| Requisito | Onde está no jogo |
|---|---|
| **Modelar objetos** | Todos os objetos 3D são **modelados por código com primitivas (esferas, cilindros, cápsulas, caixas, prismas, toros) e CSG, sem modelos importados**. A canoa é uma esfera esticada, esvaziada e cortada com CSG. O pescador, a tarrafa (disco, aro, cordas e chumbadas), os peixes de cinco espécies, o mergulhador, as latas, as árvores de manguezal com raízes, as ilhas, as casas e as colinas seguem o mesmo método |
| **Aplicar transformações** | Tarrafa abre com escala e rotação animadas (`Tween`). Peixes nadam com translação senoidal, giram ao mudar de direção, balançam o rabo e pulam de vez em quando. O barco balança e inclina. Anéis de respingo crescem e somem. Nuvens se deslocam. Mergulhador sobe e desce |
| **Interação mouse e teclado** | Setas e Espaço no jogo. Mouse nos botões do menu, nas respostas, na tela final e para lançar a tarrafa |
| **Som e música** | Música de fundo, **som ambiente de água batendo no casco** (sintetizado por script, em loop), efeitos de lançar, pescar, acerto e erro |
| **Navegação do usuário** | O jogador conduz o barco pela lagoa com o teclado e escolhe modo e respostas com o mouse |
| **Qualidade e realismo** | Luz direcional com sombras, céu procedural, névoa de profundidade, sol com reflexo, água clara com mapa de normais animado e reflexo do céu, **texturas procedurais** (tábuas de madeira no casco, grama nas margens), respingos e círculos na água, peixes que pulam, margem distante com casas de alvenaria |

## Fidelidade à Lagoa Mundaú

O que o jogo representa a partir das fontes consultadas:

- Lagoa estuarina com manguezal, canoa escavada em tronco, uso de tarrafa e de rede de espera.
- Espécies reais: tainha, curimã, carapeba, camurim e mandim.

Simplificações assumidas, por serem um jogo educativo:

- **Os pesos dos peixes** (múltiplos de 0,5 kg), **o peso da lata (20 kg)** e **o rendimento de 50% do sururu** são valores didáticos, escolhidos para facilitar as contas. O jogo avisa isso no painel de instruções.
- A tarrafa é uma das artes de pesca da lagoa, mas não a mais usada (a rede de espera é).
- Não foram usadas palafitas, porque não encontramos fonte que as confirme na lagoa. As casas ao fundo são de alvenaria simples.

## Como executar

1. Instale a **Godot 4.x** (desenvolvido na 4.7.2).
2. Abra o Godot, clique em **Importar** e selecione o `project.godot` desta pasta.
3. Pressione **F5** para rodar a partir do menu inicial.

## Estrutura do projeto

```
assets/      sprites, fontes e sons
scenes/      menu inicial e cena do jogo 3D
scripts/     lógica do jogo
```

Scripts principais:

- `GameManager.gd`: autoload com modos, espécies, geração dos desafios, placar e fim de rodada.
- `jogo_3d.gd`: monta e controla a cena 3D.
- `peixe_3d.gd`: modelagem e comportamento dos peixes.
- `efeito_agua.gd`: respingos e círculos na água.
- `ui_desafio.gd`, `briefing.gd`, `painel_tarrafa.gd`, `painel_meta.gd`, `tela_final.gd`: interface.
- `menu_inicial.gd`: menu 2D animado.

## Créditos

- Peixes do menu: **Fish Pack** de [Kenney](https://kenney.nl) (CC0).
- Fonte **Lilita One**, de Juan Montoreano (SIL Open Font License).
- Fundo, canoas, ícones e bolhas do menu: imagens geradas por script em Python (Pillow).
- Som ambiente de água: sintetizado por script em Python (NumPy).
- Música e demais sons: indicar aqui a origem de cada arquivo de `assets/sons`.

