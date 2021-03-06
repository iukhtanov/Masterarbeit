% Funktion zum Erzeugen des Ortsbereichs f�r die Auswertung
% f�r eine Doppelleitung in beliebige Richtung
% Autor: Mathias Magdowski
% Datum: 2009-03-16
% eMail: mathias.magdowski@ovgu.de

% Optionen:
    % s - Abstand der Leiter (in m) -> Skalar
    % l - L�nge der Leitung (in m) -> Skalar
    % R - Diskretisierung -> Skalar
% Geometrie:
    % geometry - Geometrie -> String
        % xy -> Leitung in x-Richtung, R�ck- zu Hinleiter in y-Richtung
        % yz -> Leitung in y-Richtung, R�ck- zu Hinleiter in z-Richtung
        % zx -> Leitung in z-Richtung, R�ck- zu Hinleiter in x-Richtung
    % spacetype - linspace oder equspace (optional) -> String
% Ausgabe:
%   r_vector - Ortsbereich f�r die Auswertung (in m) -> Matrix(3,2*R+2)
%   r_x      - x-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   r_y      - y-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   r_z      - z-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   Die Struktur ergibt sich aus:
%   Hinleiter(1,R),R�ckleiter(1,R),Punkt am Anfang,Punkt am Ende

function [r_vector,r_x,r_y,r_z]=r_vector_tl_twisted(s,l,P,R,geometry,spacetype)
    % pr�fen, ob spacetype gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=5
        spacetype='equspace';
    end
    
    % halber Abstand zwischen den Leitern (in m) -> Skalar
    h=s/2;
    
    % in Funktions-Handle umwandeln
    spacefunc=str2func(spacetype);

    % Punkte, entlang der Leitung (in m) -> Zeilenvektor(1,R)
    along_tl=spacefunc(0,l,R);
    
    % Verdrehwinkel (in rad) -> Zeilenvektor(1,R)
    psi=2*pi*along_tl/P;

    % Komponenten des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
    % Anteil parallel zur Leitung -> Skalar
    % Anmerkung: entspricht der x-Richtung bei Tesche
    r_tl=[along_tl,along_tl,0,l];
    % Anteil transversal zur Leitung -> Skalar
    % Anmerkung: entspricht der z-Richtung bei Tesche
    r_tr=[h*cos(psi),-h*cos(psi),0,0];
    % Anteil orthogonal zur Leitung -> Skalar
    % Anmerkung: entspricht der y-Richtung bei Tesche
    r_or=[h*sin(psi),-h*sin(psi),0,0];
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

    % Ortsbereich f�r die Auswertung (in m) -> Matrix(3,2*R+2)
    r_vector=[r_x;r_y;r_z];
end