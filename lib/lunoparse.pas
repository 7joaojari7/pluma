unit lunoparse;

interface

uses
    Sysutils, strutils, lunomath;

type
    LCL_TOKEN_LIST = (VARIABLE, INFORMATION);
    function read_lcl_file(filename: string): vec2_array;

implementation


function read_lcl_file(filename: string): vec2_array;
var
    __input: TextFile;
    data: string;
    vertex_list: vec2_array;
    j, startIndex, endIndex: Integer;
begin
    Assign(__input, filename);
    Reset(__input);
    SetLength(vertex_list, 0);
    j := 0;
    while not eof(__input) do
    begin
        ReadLn(__input, data);
        if (Pos('$', data) = 1) then  
        begin
            SetLength(vertex_list, Length(vertex_list) + 1); 
        
            startIndex := 2;
            endIndex := PosEx('$', data, startIndex + 1);
            if endIndex = 0 then
                endIndex := Length(data);
            
            vertex_list[j].x := StrToFloat(Trim(Copy(data, startIndex, endIndex - startIndex)));
        
            startIndex := endIndex + 1;
            endIndex := Length(data);
            
            vertex_list[j].y := StrToFloat(Trim(Copy(data, startIndex, endIndex - startIndex)));
            writeln('jj');
            Inc(j);
        end;
    end;
    Close(__input);
    read_lcl_file := vertex_list;  
end;



end.
