unit lunoloc;

interface

uses 
    lunomath, sysutils;

const 
    MAX_MAP_X_SIZE = 128;
    MAX_MAP_Y_SIZE = 128;
    LOCDRIVER_DEBUG = true;

type
    ENTITY_MODE_LIST = (EM_STANDBY, EM_MOVING); 

    entity = record
        mode: ENTITY_MODE_LIST;
        pos: vec2;
        last_vpos: ^vec2; // Changed to pointer
        next_vpos: ^vec2; // Changed to pointer
    end;

    ld_error = (
        ld_vlist_out_of_bounds = 0,
        ld_aaaa = 1
    );

    entity_ptr = ^entity;

    locdriver = record
        vertex_list: vec2_array;
        vlist_index: integer;
        actor: entity_ptr;
    end;

    locdriver_ptr = ^locdriver;

    LD_SETUP_FLAGS = (
        LD_FORMAT_VERTEX,
        LD_COME_AS_YOU_ARE
    );

    function locdriver_setup(
        vertex_list: vec2_array;
        actor: entity_ptr;
        initial_pos: vec2; // Changed to vec2
        flags__: LD_SETUP_FLAGS
    ): locdriver_ptr;

    function locdriver_start_event(Ld: locdriver_ptr): ld_error;

    procedure locdriver_destroy(ld: locdriver_ptr);

implementation

function locdriver_setup(vertex_list: vec2_array; actor: entity_ptr; initial_pos: vec2; flags__: LD_SETUP_FLAGS): locdriver_ptr;
var
    j: integer;
    ld_s: locdriver_ptr;
begin
    new(ld_s);
    new(ld_s^.actor);
    new(ld_s^.actor^.last_vpos);
    new(ld_s^.actor^.next_vpos);

    ld_s^.actor^ := actor^; // Assign the whole record

    for j := Low(vertex_list) to High(vertex_list) do
    begin
        if (initial_pos.x = vertex_list[j].x) and (initial_pos.y = vertex_list[j].y) then
        begin
            ld_s^.actor^.pos := vertex_list[j];

            if j > 0 then
                ld_s^.actor^.last_vpos := @vertex_list[j - 1]
            else
                ld_s^.actor^.last_vpos := nil;

            if j < High(vertex_list) then
                ld_s^.actor^.next_vpos := @vertex_list[j + 1]
            else
                ld_s^.actor^.next_vpos := nil;

            if LOCDRIVER_DEBUG then
            begin
                writeln('actor current pos: ', ld_s^.actor^.pos.x, ' ', ld_s^.actor^.pos.y);
                if ld_s^.actor^.last_vpos <> nil then
                    writeln('actor last pos: ', ld_s^.actor^.last_vpos^.x, ' ', ld_s^.actor^.last_vpos^.y)
                else
                    writeln('actor last pos: nil');
                if ld_s^.actor^.next_vpos <> nil then
                    writeln('actor next pos: ', ld_s^.actor^.next_vpos^.x, ' ', ld_s^.actor^.next_vpos^.y)
                else
                    writeln('actor next pos: nil');
            end;
        end;
    end;

    locdriver_setup := ld_s;
end;

function locdriver_start_event(Ld: locdriver_ptr): ld_error;
begin
    // Implement this function if needed
    // Currently, it doesn't do anything
end;

procedure locdriver_destroy(ld: locdriver_ptr);
begin
    Dispose(ld);
end;

end.
