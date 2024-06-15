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
    MAX_MAP_X_SIZE = 128;   // Largura maxima de um mapa
    MAX_MAP_Y_SIZE = 128;   // Altura maxima de um mapa

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
         
    function Q_atan(tansrc: Single): Single; export;   

implementation 

// A função natural de aproximação de um arco tangente é bem lenta,
// e não precisamos de tanta precisão, apenas algo que remeta ao suficiente
function Q_atan(tansrc: Single): Single; 
begin
    Q_atan := (0.785 * tansrc) - ((1-tansrc*tansrc) * (0.2447 + (0.06633 * tansrc)));   // prevista em  "Fast Computation of arctangent Functions for
                                                                                        //               Embedded Applications: A Comparative Analysis" 
end; 
  

end.