//////////////////////////////////////////////////////////////////////////////////////////
// __       __    __  .__   __.   ______         .______      ___      .______          _______. _______ 
//|  |     |  |  |  | |  \ |  |  /  __  \        |   _  \    /   \     |   _  \        /       ||   ____|
//|  |     |  |  |  | |   \|  | |  |  |  |       |  |_)  |  /  ^  \    |  |_)  |      |   (----`|  |__   
//|  |     |  |  |  | |  . `  | |  |  |  |       |   ___/  /  /_\  \   |      /        \   \    |   __|  
//|  `----.|  `--'  | |  |\   | |  `--'  |       |  |     /  _____  \  |  |\  \----.----)   |   |  |____ 
//|_______| \______/  |__| \__|  \______/   _____| _|    /__/     \__\ | _| `._____|_______/    |_______|
//                                         |______|                                                
//////////////////////////////////////////////////////////////////////////////////////////
{
    Esta unidade é responsável pelas funções de leitura de arquivos lcl;
    Escrito por João Jari;
}
unit luno_parse;

interface

uses
    Sysutils, strutils, luno_math;

type 
    LCL_TOKEN_LIST = (TK_NULL, TK_YES);
    function read_lcl_file(filename: string): vec2_array;

implementation


function read_lcl_file(filename: string): vec2_array;
var
    __input: TextFile;
    data: string; 
    vertex_list: vec2_array;
    i, j, startIndex, endIndex: Integer;
begin
    Assign(__input, filename);
    Reset(__input);
    SetLength(vertex_list, 0);
    j := 0;
    while not eof(__input) do
    begin
        ReadLn(__input, data);
        for i := 0 to Length(data) do
        begin 
            if (Pos('1', data) = 1) then  
            begin 
                vertex_list[j].x := i;  
                vertex_list[j].y := j; 
            end;
        end;
        Inc(j);
    end;
    Close(__input);
    read_lcl_file := vertex_list;  
end;



end.
