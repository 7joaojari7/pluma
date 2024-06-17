//////////////////////////////////////////////////////////////////////////////////////////
//   __       __    __   __   __    ______          __        ______     ______ 
//  |  |     |  |  |  | |  \ |  |  /  __  \        |  |      /  __  \   /      |
//  |  |     |  |  |  | |   \|  | |  |  |  |       |  |     |  |  |  | |  ,----'
//  |  |     |  |  |  | |       | |  |  |  |       |  |     |  |  |  | |  |     
//  |  `----.|  `--'  | |  |\   | |  `--'  |       |  `----.|  `--'  | |  `----.
//  |_______| \______/  |__| \__|  \______/   _____|_______| \______/   \______|
//                                           |______|             
//////////////////////////////////////////////////////////////////////////////////////////
{
    Esta unidade é responsável por fazer todos os processamentos de localização do robô.
    Escrito por João Jari;
}
unit luno_loc;

interface

uses 
    luno_math, sysutils, math;

const 
    LOCDRIVER_DEBUG = true;

type
    // estados no quais uma entidade pode estar
    ENTITY_STATE_LIST = (   EM_STANDBY              = 0, 
                            EM_MOVING               = 1,
                            EM_PROCESSING_COORDS    = 2,
                            EM_WAITING_FOR_INPUT    = 3); 

    // A entidade é um registro nuclear de um corpo. ele possui as informações mais básicas 
    // como posições, tamanho e modelo vetorial e pode ser usado tanto independentemente como
    // tambem um nucleo de um ator.
    entity = record
        state: ENTITY_STATE_LIST;   // estado atual da entidade
        
        pos: vec2;                  // posição atual da entidade. Pode estar fora 
                                    // das coordenadas previstas já que demonstra sua localização atual.

        last_pos: ^vec2;            // diferente de <pos>, que é um tipo de dado que representa qualquer posição possivel,
        next_pos: ^vec2;            // estes dois (<last_pos> e <next_pos>) são ponteiros que apontam a coordenada anterior e seguinte
                                    // previstas nas coordenadas.
         

        model: vec2_array;          // modelo vetorial da entidade
        size: vec2;                 // tamanho em x e y
    end;

    // O ator, por sua vez, é uma abstração de uma entidade e pode ser usado como um modelo cinematico 
    // já que possui caracteristicas como deslocamento, tempo decorrido, 
    // velocidade média e lógicamente herda as caracteristicas de uma entidade através de
    // um corpo
    actor = record
        body: entity;       // Herdando as caracteristicas essenciais de uma entidade
        movspeed: single;   // Velocidade média
        delta_s: single;    // deslocamento físico
        delta_t: single;    // tempo decorrido
    end;

    // configurações da função locdriver_setup
    LD_SETUP_FLAGS = (
        LD_FORMAT_VERTEX,   // formate os vertices baseado em sua proximidade
        LD_COME_AS_YOU_ARE  // sem formatação
    );

    // ponteiro do ator
    actor_ptr = ^actor;

    // O evento descrito aqui é utilizado para receber as informações processadas pelo locdriver.
    locdriver_event = record
        distance: single;   // Nome meramente ilustrativo. O correto seria Hipotenusa
        angle: single;      // Angulo entre dois pontos
        sides: vec2;        // Nome meramente ilustrativo. O correto seria Catetos (x -> oposto), (y -> adjacente)
    end; 

    // Uma surface seria basicamente o tipo que recebe as informações do mapa, como suas dimensões
    surface = record    
        size_cm: vec2;              // tamanho em centimetros
        size_e:  vec2;              // tamanho em elementos de array
        e_length: single;           // comprimento de cada elemento em centimetros
        vindex: integer;            // indice de vertice
        vertex_list: vec2_array;    // lista de vertices
    end; 

    surface_ptr = ^surface;

    // O locdriver (localização / driver) é um objeto que guarda todas as informações necessarias para o sistema
    // de caminho vetorial proposto para o desafio.
    locdriver = record
        current_event: locdriver_event;
        surf: surface;      // mapa
        robot: actor;      // ator principal
    end;

    locdriver_ptr = ^locdriver;

    function surface_setup(vertex_list: vec2_array; size_cm: vec2; size_e: vec2): surface;                      export;
    function entity_setup(pos: vec2; model: vec2_array): entity;                                                export;
    function actor_setup(body: entity): actor;                                                                  export;
    function locdriver_process(ld_s: locdriver_ptr): locdriver_event;                                       export;
    function locdriver_setup(surf: surface; robot: actor; flags__: LD_SETUP_FLAGS): locdriver_ptr;              export;
    procedure locdriver_destroy(ld: locdriver_ptr);                                                             export;      

implementation

// Esta função realiza toda a configuração da surface
function surface_setup(vertex_list: vec2_array; size_cm: vec2; size_e: vec2): surface;
var
    surf_s: surface; 
begin
    // receba os parametros previstos na função
    surf_s.size_cm.x := size_cm.x;
    surf_s.size_cm.y := size_cm.y; 
    surf_s.size_e.x := size_e.x;
    surf_s.size_e.y := size_e.y; 
    surf_s.vertex_list := vertex_list; 
    surf_s.vindex := 0; 
    surf_s.e_length := (size_cm.x * size_cm.y) / (size_e.x * size_e.y); // calcule o tamanho (em cm) de cada elemento

    if (LOCDRIVER_DEBUG = true) then
    begin
        writeln('surface size (in cm): ' + FloatToStr(surf_s.size_cm.x) + ' * ' + FloatToStr(surf_s.size_cm.y));
        writeln('surface size (in elements): ' + FloatToStr(surf_s.size_e.x) + ' * ' + FloatToStr(surf_s.size_e.y));
        writeln('size of element (in cm): ' + FloatToStr(surf_s.e_length) + '^2');
    end;

    surface_setup := surf_s;
end;

// Função que realiza a configuração principal do locdriver, sendo assim um ponteiro
function locdriver_setup(surf: surface; robot: actor; flags__: LD_SETUP_FLAGS): locdriver_ptr;
var
    i, j: integer;
    ld_s: locdriver_ptr;
begin
    // aloque um pouco de memoria para o nosso ponteiro de locdriver
    new(ld_s); 
 
    // receba os parametros
    ld_s^.robot     := robot; 
    ld_s^.surf      := surf;

    // loop para varrer por toda lista de vertices
    for i := 0 to (High(ld_s^.surf.vertex_list) - 1) do
    begin
        // se as coordenadas atuais do robo baterem com algum ponto da lista de vertices da surface
        if((ld_s^.robot.body.pos.x = ld_s^.surf.vertex_list[i].x) and (ld_s^.robot.body.pos.y = ld_s^.surf.vertex_list[i].y)) then
        begin
            // entao o indice é o mesmo que o loop
            ld_s^.surf.vindex := i;

            if(flags__ = LD_FORMAT_VERTEX)then
            begin
                //ld_s^.surf.vertex_list := vec2_array_format(ld_s^.surf.vertex_list, ld_s^.robot.body.pos);
                //ld_s^.robot.body.pos.x := ld_s^.surf.vertex_list[i].x;
                //ld_s^.robot.body.pos.y := ld_s^.surf.vertex_list[i].y;
            end;

            // se não houver elementos anteriores 
            if ld_s^.surf.vindex = 0 then
            begin
                ld_s^.robot.body.last_pos := @ld_s^.surf.vertex_list[ld_s^.surf.vindex];
            end
            else
            begin
                ld_s^.robot.body.last_pos := @ld_s^.surf.vertex_list[ld_s^.surf.vindex-1];
            end;

            // se não houver elementos próximos
            if ld_s^.surf.vindex > High(ld_s^.surf.vertex_list) then
            begin
                ld_s^.robot.body.next_pos := @ld_s^.surf.vertex_list[ld_s^.surf.vindex];
            end
            else
            begin
                ld_s^.robot.body.next_pos := @ld_s^.surf.vertex_list[ld_s^.surf.vindex+1];
            end;
        
            if(LOCDRIVER_DEBUG = true) then
            begin
                writeln('ld_s^.robot.body.pos : '          + FloatToStr(ld_s^.robot.body.pos.x)       + ' ' + FloatToStr(ld_s^.robot.body.pos.y));
                writeln('ld_s^.robot.body.last_pos : '     + FloatToStr(ld_s^.robot.body.last_pos^.x) + ' ' + FloatToStr(ld_s^.robot.body.last_pos^.y));
                writeln('ld_s^.robot.body.next_pos  : '    + FloatToStr(ld_s^.robot.body.next_pos^.x) + ' ' + FloatToStr(ld_s^.robot.body.next_pos^.y));
            end;
 
        end;
    end;

    locdriver_setup := ld_s;
end;

function locdriver_process(ld_s: locdriver_ptr): locdriver_event; export;
var
    ev_s: locdriver_event;
begin
    ev_s.sides.x := (ld_s^.robot.body.next_pos^.x - ld_s^.robot.body.pos.x) * (ld_s^.robot.body.next_pos^.x - ld_s^.robot.body.pos.x);
    ev_s.sides.y := (ld_s^.robot.body.next_pos^.y - ld_s^.robot.body.pos.y) * (ld_s^.robot.body.next_pos^.y - ld_s^.robot.body.pos.y);
    ev_s.distance := Q_sqrrt(ev_s.sides.x + ev_s.sides.y); 
    ev_s.angle := Q_atan(ev_s.sides.y / ev_s.sides.x);

    locdriver_process := ev_s;
end;

// Configure a entidade
function entity_setup(pos: vec2; model: vec2_array): entity;
var
    en_s: entity; 
begin
    // Aloque um pouco de memoria para estes dois
    new(en_s.last_pos); 
    new(en_s.next_pos); 

    // parametros
    en_s.state      := EM_STANDBY; // STANDBY é o padrão para iniciar uma entidade
    en_s.pos        := pos;
    en_s.model      := model;
    en_s.size.x     := 0;
    en_s.size.y     := 0;
    en_s.last_pos   := nil; 
    en_s.next_pos   := nil;  

    if(LOCDRIVER_DEBUG = true) then
    begin
        writeln('en_s.pos : ' + FloatToStr(en_s.pos.x) + ' ' + FloatToStr(en_s.pos.y));
        writeln('en_s.size : ' + FloatToStr(en_s.size.x) + ' ' + FloatToStr(en_s.size.y));
    end;

    entity_setup := en_s;
end;

// Configure o ator
function actor_setup(body: entity): actor;
var
    act_s: actor;
begin
    // parametros
    act_s.body          := body;
    act_s.movspeed      := 0; 
    act_s.delta_s       := 0; 
    act_s.delta_t       := 0; 


    actor_setup := act_s;
end; 

// Desaloque o locdriver
procedure locdriver_destroy(ld: locdriver_ptr);
begin
    Dispose(ld);
end;

end.
