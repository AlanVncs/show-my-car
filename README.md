# Show my vehicle

Diferente de outros mods, aqui o carro fica realmente fácil de achar. O pin aparece na tela e some sozinho: quando você entra no veículo, ou quando chega perto depois de um tempo. Esse pin e unpin automático deixa a gameplay fluida — você pede o veículo, vai até ele e continua jogando, sem marcar nem desmarcar nada.

Cada jogador tem o próprio pin.

## Como usar

Pressione **Shift + V** ou clique em **Mostre-me um veículo** (ícone do carro) na barra de atalhos. A tecla pode ser alterada em Configurações → Controles.

## Como o veículo é mostrado

O pin fica sempre visível na tela, não só com o mapa aberto, e acompanha o veículo se ele se mover — inclusive ao mudar de superfície.

Ele desaparece sozinho:

- Na hora, quando o jogador entra naquele veículo.
- Depois de pelo menos 10 segundos, se o jogador estiver na mesma superfície e a até 10 tiles do veículo. Nesse intervalo o pin continua, mesmo ao lado do veículo.
- Quando o veículo deixa de existir.

Entrar em outro veículo não apaga o pin. Esse outro veículo passa a ser o lembrado para a próxima vez.

## Qual veículo

O jogo escolhe nesta ordem:

1. O último veículo em que o jogador entrou, se ele ainda existir.
2. O carro mais próximo na superfície em que o jogador está.

Qualquer coisa que o jogador tenha dirigido vale como último veículo: carro, tanque, spidertron, locomotiva ou um veículo de outro mod. Esse é o alvo do próximo pin.

A busca pelo mais próximo só olha entidades chamadas `car`, na superfície atual. Tanque, spidertron, locomotiva e veículos de mods com outro nome só aparecem se o jogador já os tiver dirigido. Se esse último veículo foi destruído, ou se o jogador ainda não dirigiu nenhum, a busca cai no carro mais próximo.

Se não houver carro nessa superfície, o pin atual some, toca o som de ação inválida e aparece a mensagem *Não há um carro nesta superfície.*
