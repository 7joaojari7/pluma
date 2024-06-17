//////////////////////////////////////////////////////////////////////////////////////////
//   __       __    __  .__   __.   ______         .___  ___.      ___   .___________. __    __  
//  |  |     |  |  |  | |  \ |  |  /  __  \        |   \/   |     /   \  |           ||  |  |  | 
//  |  |     |  |  |  | |   \|  | |  |  |  |       |  \  /  |    /  ^  \ `---|  |----`|  |__|  | 
//  |  |     |  |  |  | |  . `  | |  |  |  |       |  |\/|  |   /  /_\  \    |  |     |   __   | 
//  |  `----.|  `--'  | |  |\   | |  `--'  |       |  |  |  |  /  _____  \   |  |     |  |  |  | 
//  |_______| \______/  |__| \__|  \______/  ______|__|  |__| /__/     \__\  |__|     |__|  |__| 
//                                          |______|             
//////////////////////////////////////////////////////////////////////////////////////////
{
    Esta unidade é responsável pelas funções matemáticas custumizadas;
    Escrito por João Jari;
}

unit luno_math;

interface

uses math, sysutils;

const
    // Nossos valores customizados
    Q_PI = 3.14159;         // não precisamos de uma aproximação muito larga de PI, apenas o suficiente
    MAX_MAP_X_SIZE = 8;   // Largura maxima de um mapa
    MAX_MAP_Y_SIZE = 8;   // Altura maxima de um mapa
    EPSILON = 1e-6;

type
    // tipo de vetor bidimensional
    vec2 = record
        x: single;      // posição horizontal
        y: single;      // posição vertical
    end; 

    // ponteiro para o vetor bidimensional
    vec2_ptr = ^vec2;

    // matriz de vetores bidimensionais
    vec2_array = Array of vec2; 
         
    function Q_atan(tansrc: Single): single;                                        export;    
    function Q_sqrrt(x: single): single;                                            export; 
    function vec2_array_format(list: vec2_array; initial_pos: vec2): vec2_array;    export;
    function to_degree(ang: single): single;                                        export; 

implementation 

// A função natural de aproximação de um arco tangente é bem lenta,
// e não precisamos de tanta precisão, apenas algo que remeta ao suficiente
function Q_atan(tansrc: Single): Single; 
begin
    Q_atan := (0.785 * tansrc) - ((1-tansrc*tansrc) * (0.2447 + (0.06633 * tansrc)));   // prevista em  "Fast Computation of arctangent Functions for
                                                                                        //               Embedded Applications: A Comparative Analysis" 
end; 
  
// função para formatar uma matriz de vetores bidimensionais
function vec2_array_format(     list: vec2_array;                   // lista para receber dados
                                initial_pos: vec2): vec2_array;     // posição inicial/de referencia                                                     
var
    f_list: Array[0..(MAX_MAP_X_SIZE*MAX_MAP_Y_SIZE)] of vec2;      // criando uma matriz para ser a saida
    i, j:   integer;                                                // indices
    diff: vec2;                                                     // diferença entre dois pontos
begin
    // primeira verificação, feita apenas para descobrir a diferença
    for i := 0 to High(list) do
    begin
        // compare os dois pontos
        if ((list[i].x = initial_pos.x) and (list[i].y = initial_pos.y)) then
        begin
            diff.x := abs(list[i].x);   // utilizamos um valor absoluto ja que apartir daqui o valor inicial deve ser (0, 0)
            diff.y := abs(list[i].y);
        end;
    end;
    
    // segunda verificação / inicio de formatação
    for j := 0 to High(list) do
    begin
        // autodescritivo.
        if (list[j].x < 0) then
        begin
            f_list[j].x := list[j].x + diff.x; 
        end
        else if (list[j].x > 0) then
        begin
            f_list[j].x := list[j].x - diff.x; 
        end;

        if (list[j].y < 0) then
        begin
            f_list[j].y := list[j].y + diff.y; 
        end
        else if (list[j].y > 0) then
        begin
            f_list[j].y :=list[j].y - diff.y; 
        end; 
    end;

    vec2_array_format := f_list;
end;

function to_degree(ang: single): single;
begin
    to_degree := ang * 180 / Q_PI;
end;

function Q_sqrrt(x: single): single;
var
    xn, xn1: single;
begin
    if x = 0 then
        Q_sqrrt := 0
    else
    begin
        // Initial guess (you can choose any positive value)
        xn := x / 2.0;

        repeat
        xn1 := xn;
        xn := 0.5 * (xn1 + x / xn1); // Newton's method iteration
        until Abs(xn - xn1) < EPSILON; // Convergence criterion

        Q_sqrrt := xn;
    end;
end;
end.
