% Funktion zum Erzeugen des Ortsbereichs für die Auswertung
% für die Berechnung des Feldes im Frequenzbereich
% Autor: Mathias Magdowski
% Datum: 2009-09-22
% eMail: mathias.magdowski@ovgu.de

% Optionen:
%   r_end - Länge des Ortsbereichs (in m) -> Skalar
%   R     - Diskretisierung -> Skalar
%   modus    - Modus für die Berechnung -> String
%       plane_wave -> Ansatz ebener Wellen im Arbeitsvolumen
%       pw_nw_xy   -> Ansatz ebener Wellen nahe einer Wand in der x-y-Ebene bei z=0
%       pw_nw_yz   -> Ansatz ebener Wellen nahe einer Wand in der y-z-Ebene bei x=0
%       pw_nw_xz   -> Ansatz ebener Wellen nahe einer Wand in der x-z-Ebene bei y=0
%       pw_nw_xy_w -> Ansatz ebener Wellen nahe einer Wand in der x-y-Ebene bei z=w
%       pw_nb_z    -> Ansatz ebener Wellen nahe einer Kante in z-Richtung
%       pw_nb_y    -> Ansatz ebener Wellen nahe einer Kante in y-Richtung
%       pw_nb_x    -> Ansatz ebener Wellen nahe einer Kante in x-Richtung
%       pw_nc      -> Ansatz ebener Wellen nahe einer Ecke

% Ausgabe:
%   r_vector - Ortsbereich für die Auswertung (in m) -> Matrix(3,R)
%   r_x      - x-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,R)
%   r_y      - y-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,R)
%   r_z      - z-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,R)

function [r_vector,r_x,r_y,r_z]=r_vector_modus(r_end,R,modus)
    % Komponenten des Ortsbereichs (in m) -> Zeilenvektor(1,R)
    if strcmp(modus,'plane_wave') || strcmp(modus,'fixed') || strcmp(modus,'stand_wave')
        % im Arbeitsvolumen
        r_x=zeros(1,R);
        r_y=zeros(1,R);
        r_z=linspace(0,r_end,R);
    elseif strcmp(modus,'pw_nw_xy') || strcmp(modus,'sw_nw_xy')
        % nahe einer Wand in der x-y-Ebene bei z=0
        r_x=zeros(1,R);
        r_y=zeros(1,R);
        r_z=linspace(0,r_end,R);
    elseif strcmp(modus,'pw_nw_yz') || strcmp(modus,'sw_nw_yz')
        % nahe einer Wand in der y-z-Ebene bei x=0
        r_x=linspace(0,r_end,R);
        r_y=zeros(1,R);
        r_z=zeros(1,R);
    elseif strcmp(modus,'pw_nw_xz') || strcmp(modus,'sw_nw_xz')
        % nahe einer Wand in der x-z-Ebene bei y=0
        r_x=zeros(1,R);
        r_y=linspace(0,r_end,R);
        r_z=zeros(1,R);
    elseif strcmp(modus,'pw_nw_xy_w')
        % nahe einer Wand in der x-y-Ebene bei z=w
        r_x=zeros(1,R);
        r_y=zeros(1,R);
        r_z=linspace(0,r_end,R);
    elseif strcmp(modus,'pw_nb_z') || strcmp(modus,'sw_nb_z')
        % nahe einer Kante in z-Richtung
        r_x=linspace(0,r_end/sqrt(2),R);
        r_y=linspace(0,r_end/sqrt(2),R);
        r_z=zeros(1,R);
    elseif strcmp(modus,'pw_nb_y') || strcmp(modus,'sw_nb_y')
        % nahe einer Kante in y-Richtung
        r_x=linspace(0,r_end/sqrt(2),R);
        r_y=zeros(1,R);
        r_z=linspace(0,r_end/sqrt(2),R);
    elseif strcmp(modus,'pw_nb_x') || strcmp(modus,'sw_nb_x')
        % nahe einer Kante in x-Richtung
        r_x=zeros(1,R);
        r_y=linspace(0,r_end/sqrt(2),R);
        r_z=linspace(0,r_end/sqrt(2),R);
    elseif strcmp(modus,'pw_nc')
        % nahe einer Ecke
        r_x=linspace(0,r_end/sqrt(3),R);
        r_y=linspace(0,r_end/sqrt(3),R);
        r_z=linspace(0,r_end/sqrt(3),R);
    else
        error(['The modus ',modus,' is unknown.'])
    end

    % Ortsbereich für die Auswertung (in m) -> Matrix(3,R)
    r_vector=[r_x;r_y;r_z];
end