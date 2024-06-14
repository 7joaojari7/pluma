unit lunomath;

interface

uses math, sysutils;
const
    Q_PI = 3.14159;

type
    vec2 = record
        x: Real;
        y: Real;
    end; 

    vec2_ptr = ^vec2;

    vec2_array = Array of vec2;
 
    fl_2 = record
        i: shortint;
        u: shortint;
    end;
        
    //function set_fl_2(x: single): fl_2;
    function Q_atan(tansrc: Single): Single; export;   
    //procedure bsort_vec2(a: vec2_array);

implementation
{
procedure bsort_vec2(a: vec2_array);
var
    i, j, temp, size: Integer;
begin
    size := high(@vec2_ptr);

    for i := 1 to n - 1 do
    begin
        for j := 1 to n - i do
        begin
            if a[j] > a[j + 1] then
            begin
                temp := a[j];
                a[j] := a[j + 1];
                a[j + 1] := temp;
            end;
        end;
    end;
end;}

function Q_atan(tansrc: Single): Single; 
begin
    Q_atan := (0.785 * tansrc) - ((1-tansrc*tansrc) * (0.2447 + (0.06633 * tansrc)));   //predicted in    "Fast Computation of arctangent Functions for
                                                                                        //                 Embedded Applications: A Comparative Analysis" 
end; 
  

end.