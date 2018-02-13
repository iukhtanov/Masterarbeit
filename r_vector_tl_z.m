% Funktion zum Erzeugen des Ortsbereichs f�r die Auswertung
% f�r eine Doppelleitung in z-Richtung
% Autor: Mathias Magdowski
% Datum: 2008-10-20
% eMail: mathias.magdowski@ovgu.de

% Optionen:
%   s - Abstand der Leiter (in m) -> Skalar
%   l - L�nge der Leitung (in m) -> Skalar
%   R - Diskretisierung -> Skalar

% Ausgabe:
%   r_vector - Ortsbereich f�r die Auswertung (in m) -> Matrix(3,2*R+2)
%   r_x      - x-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   r_y      - y-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   r_z      - z-Komponente des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
%   Die Struktur ergibt sich aus:
%   Hinleiter(1,R),R�ckleiter(1,R),Punkt am Anfang,Punkt am Ende

function [r_vector,r_x,r_y,r_z]=r_vector_tl_z(s,l,R)
    % L�nge einer Zelle
    h=l/R;
    
    % Komponenten des Ortsbereichs (in m) -> Zeilenvektor(1,2*R+2)
    r_x=[ones(1,R)*s/2,-ones(1,R)*s/2,0,0];
    r_y=[zeros(1,R),zeros(1,R),0,0];
    r_z=[equspace(0,l,R),equspace(0,l,R),0,l];

    % Ortsbereich f�r die Auswertung (in m) -> Matrix(3,2*R+2)
    r_vector=[r_x;r_y;r_z];
end