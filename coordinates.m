function [x_1,y_1,z_1,x_2,y_2,z_2,r_0] = coordinates(modus)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
if strcmp(modus,'two_lines')
        % start coordinates
        % x-Koordinaten der Anf�nge der Leiter (in m) -> Zeilenvektor(1,L)
        x_1=[0,0];
        % y-Koordinaten der Anf�nge der Leiter (in m) -> Zeilenvektor(1,L)
        y_1=[0,0];
        % z-Koordinaten der Anf�nge der Leiter (in m) -> Zeilenvektor(1,L)
        z_1=[0.05,0];
        
        % end coordinates
        % x-Koordinaten der Enden der Leiter (in m) -> Zeilenvektor(1,L)
        x_2=[0,0];
        % y-Koordinaten der Enden der Leiter (in m) -> Zeilenvektor(1,L)
        y_2=[30,];
        % z-Koordinaten der Enden der Leiter (in m) -> Zeilenvektor(1,L)
        z_2=[0.05,];
        
        % Radii der Leiter (in m) -> Zeilenvektor(1,L)
        r_0=[0.0005];

end

