program lunomain;

uses 
    lunoloc, 
    lunomath, 
    lunoparse,
    sysutils, 
    math, DateUtils;


var
    x, y: Single;
    ld: locdriver_ptr;
    robot: entity;
    pos: vec2;
begin
    pos.x := 6;
    pos.y := 28; 
    ld := locdriver_setup(read_lcl_file('map.lcl'), @robot, pos, LD_FORMAT_VERTEX);
    locdriver_destroy(ld);
end.
