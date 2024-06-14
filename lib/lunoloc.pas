unit lunoloc;

interface

uses 
    lunomath, sysutils;

const 
    MAX_MAP_X_SIZE = 128;
    MAX_MAP_Y_SIZE = 128;
    LOCDRIVER_DEBUG = true;

type
    ENTITY_STATE_LIST = (EM_STANDBY, EM_MOVING); 

    entity = record
        state: ENTITY_STATE_LIST;
        pos: vec2;
        model: vec2_array;
        size: vec2;
        last_pos: ^vec2; 
        next_pos: ^vec2; 
    end;

    actor = record
        body: entity; 
        movspeed: single;
        delta_s: single;
        delta_t: single;
    end;

    locdriver = record
        vertex_list: vec2_array;
        vindex: integer;
        player: actor;
    end;

    LD_SETUP_FLAGS = (
        LD_FORMAT_VERTEX,
        LD_COME_AS_YOU_ARE
    );

    locdriver_ptr = ^locdriver;
    actor_ptr = ^actor;

    function locdriver_setup(
        vertex_list: vec2_array;
        player: actor; 
        flags__: LD_SETUP_FLAGS
    ): locdriver_ptr;

    function entity_setup(pos: vec2; model: vec2_array): entity; export;
    function actor_setup(body: entity): actor; export;
    procedure locdriver_start_event(ld_s: locdriver_ptr); export;

    procedure locdriver_destroy(ld: locdriver_ptr); export;

implementation

function locdriver_setup(vertex_list: vec2_array; player: actor; flags__: LD_SETUP_FLAGS): locdriver_ptr;
var
    i, j: integer;
    ld_s: locdriver_ptr;
begin
    new(ld_s); 

    ld_s^.player := player; // Assign the whole record

    for i := 0 to (High(vertex_list) - 1) do
    begin
        if((ld_s^.player.body.pos.x = vertex_list[i].x) and (ld_s^.player.body.pos.y = vertex_list[i].y)) then
        begin
            ld_s^.vindex := i;
            if i = 0 then
            begin
                ld_s^.player.body.last_pos := @vertex_list[i];
            end
            else
            begin
                ld_s^.player.body.last_pos := @vertex_list[i-1];
            end;
            ld_s^.player.body.next_pos := @vertex_list[i+1];
        
            if(LOCDRIVER_DEBUG = true) then
            begin
                writeln('ld_s^.player.body.pos : '          + FloatToStr(ld_s^.player.body.pos.x)       + ' ' + FloatToStr(ld_s^.player.body.pos.y));
                writeln('ld_s^.player.body.last_pos : '     + FloatToStr(ld_s^.player.body.last_pos^.x) + ' ' + FloatToStr(ld_s^.player.body.last_pos^.y));
                writeln('ld_s^.player.body.next_pos  : '    + FloatToStr(ld_s^.player.body.next_pos^.x) + ' ' + FloatToStr(ld_s^.player.body.next_pos^.y));
            end;
        
        end;
    end;

    locdriver_setup := ld_s;
end;

procedure locdriver_start_event(ld_s: locdriver_ptr);
var
    cateto: vec2;
    distance: single;
    angle: single;
begin
    cateto.x := (ld_s^.player.body.next_pos^.x * ld_s^.player.body.next_pos^.x) - (ld_s^.player.body.pos.x * ld_s^.player.body.pos.x);
    cateto.y := (ld_s^.player.body.next_pos^.y * ld_s^.player.body.next_pos^.y) - (ld_s^.player.body.pos.y * ld_s^.player.body.pos.y);
    distance := Sqrt(cateto.x + cateto.y);
    angle := Q_atan(cateto.y / cateto.x);

    if(LOCDRIVER_DEBUG = true) then
    begin
        writeln('cateto x : '   + FloatToStr(cateto.x));
        writeln('cateto y : '   + FloatToStr(cateto.y));
        writeln('distance : '   + FloatToStr(distance));
        writeln('tan      : '   + FloatToStr(cateto.y / cateto.x));
        writeln('angle    : '   + FloatToStr(angle));
    end;
end;


function entity_setup(pos: vec2; model: vec2_array): entity;
var
    en_s: entity; 
begin
    new(en_s.last_pos); 
    new(en_s.next_pos); 

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

function actor_setup(body: entity): actor;
var
    act_s: actor;
begin
    act_s.body          := body;
    act_s.movspeed      := 0; 
    act_s.delta_s       := 0; 
    act_s.delta_t       := 0; 


    actor_setup := act_s;
end; 

procedure locdriver_destroy(ld: locdriver_ptr);
begin
    Dispose(ld);
end;

end.
