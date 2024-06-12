# PLUMA: Plataforma da LUnokhod - MArista
## ÍNDICE DE MODULOS:
- lunoloc: modulo de localização vetorial;
- lunomath: conjunto de funções matematicas formuladas para os desafios;

### LunoLoc (Localização Vetorial) // lunoloc.pas
O LunoLoc é um módulo feito para lidar com o Sistema de localização Vetorial.
Nele, o robo é tratado como uma **entidade**, ou seja, um objeto que tem propriedades como _posição atual_, _posição passada_ e _próxima posição_.
Para dar inicio, é necessário fazer o setup do **driver**, ou seja, o objeto que vai lidar com todo o processamento do sistema.
#### locdriver* locdriver_setup(vec2[] vetor_lista, entidade* ator, vec2 inicial_pos, int flags = LD_FORMAT_VLIST);
> flags: *inteiro*: configurações possiveis como:
.LD_FORMAT_VLIST: configuração (padrão) para formatar a lista do mais perto ao mais distante;
.LD_COME_AS_YOU_ARE: configuração para manter os parametros como estão;
<br>
> vetor_lista: matriz de *vec2*: lista de vetores onde o robo poderá passar;
> ator: *ponteiro* de *entidade*: entidade de nosso robo, tem propriedades como:
.pos: posição atual: vec2 (x, y);
.last_pos: ultima posição percorrida: vec2 (x, y);
.prox_pos: próxima posição a ser percorrida: vec2 (x, y);

para desalocar a memoria utilizada pelo **locdriver**, utiliza-se **locdriver_destroy*.
#### void locdriver_destroy(locdriver* ld);


