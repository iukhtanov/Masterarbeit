% Funktion zum Erzeugen des Ortsbereichs für die Auswertung
% für eine Doppelleitung in beliebige Richtung
% Autor: Mathias Magdowski
% Datum: 2009-03-16
% eMail: mathias.magdowski@ovgu.de

% Optionen:
    % s - Abstand der Leiter (in m) -> Skalar
    % l - Länge der Leitung (in m) -> Skalar
    % R - Diskretisierung -> Skalar
% Geometrie:
    % geometry - Geometrie -> String
        % xy -> Leitung in x-Richtung, Rück- zu Hinleiter in y-Richtung
        % yz -> Leitung in y-Richtung, Rück- zu Hinleiter in z-Richtung
        % zx -> Leitung in z-Richtung, Rück- zu Hinleiter in x-Richtung
    % spacetype - linspace oder equspace (optional) -> String
% Ausgabe:
%   r_vector - Ortsbereich für die Auswertung (in m) -> Matrix(3,2*R+2)
%   r_x      - x-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   r_y      - y-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   r_z      - z-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   Die Struktur ergibt sich aus:
%   Hinleiter(1,R),Rückleiter(1,R),Punkt am Anfang,Punkt am Ende

function [r_vector,r_x,r_y,r_z]=r_vector_tl(s,l,R,geometry,spacetype)
    % prüfen, ob spacetype gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=4
        spacetype='equspace';
    end

    % in Funktions-Handle umwandeln
    spacefunc=str2func(spacetype);

    % Komponenten des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
    % Anteil parallel zur Leitung -> Skalar
    r_tl=[spacefunc(0,l,R),spacefunc(0,l,R),0,l];
    % Anteil transversal zur Leitung -> Skalar
    r_tr=[ones(1,R)*s/2,-ones(1,R)*s/2,0,0];
    % Anteil orthogonal zur Leitung -> Skalar
    r_or=[zeros(1,R),zeros(1,R),0,0];
    if strcmp(geometry,'zx')
        r_x=r_tr;
        r_y=r_or;
        r_z=r_tl;
    elseif strcmp(geometry,'yz')
        r_x=r_or;
        r_y=r_tl;
        r_z=r_tr;
    elseif strcmp(geometry,'xy')
        r_x=r_tl;
        r_y=r_tr;
        r_z=r_or;
    elseif strcmp(geometry,'xz')
        r_x=r_tl;
        r_y=r_or;
        r_z=r_tr;
    else
        error(['The geometry ',geometry,' is unknown.']);
    end

    % Ortsbereich für die Auswertung (in m) -> Matrix(3,2*R+2)
    r_vector=[r_x;r_y;r_z];
end