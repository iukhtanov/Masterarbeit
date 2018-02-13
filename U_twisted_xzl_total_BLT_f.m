% Funktion zur Berechnung der Terminal Responses einer Twisted-Pair-Leitung
% mit Hilfe der BLT-Gleichung
% Anregung erfolgt durch eine ebene Welle mit verschiedenen Frequenzen
% basiert auf:
% "Plane Wave Coupling to Cables" von Frederic M. Tesche 
% Autor: Mathias Magdowski
% Datum: 2009-02-03
% eMail: mathias.magdowski@ovgu.de

% die Leitung zeigt in x-Richtung
% der Hinleiter beginnt bei z=s/2, y=0
% der Rückleiter beginnt bei z=-s/2, y=0
% der Anfang bei x=0
% das Ende ist bei x=l

% Optionen:
% allgemeine Konstanten:
    % f       - Frequenz (in Hz) -> Zeilenvektor(1,F)
    % mu      - Permeabilität (in Vs/Am) -> Skalar
    % epsilon - Permittivität (in As/Vm) -> Skalar
% Daten der Doppelleitung
    % s   - Abstand der Leiter (in m) -> Skalar
    % r_0 - Radius der Leiter (in m) -> Skalar
    % l   - Länge der Leitung (in m) -> Skalar
    % P   - Länge einer Verdrillung (in m) -> Skalar
% Daten der einfallenden Welle
    % E_0   - Feldstärke des E-Feldes (in V/m) -> Skalar
    % beta  - Phasenwinkel (in rad) -> Skalar
    % k_vector - Wellenvektor, normiert -> Spaltenvektor(3,1)
    % e_vector - E-Feld-Vektor, normiert -> Spaltenvektor(3,1)
% Abschlusswiderstände
    % Z_1_n - Abschlusswiderstand am Anfang (normiert auf Z_c) -> Skalar
    % Z_2_n - Abschlusswiderstand am Ende (normiert auf Z_c) -> Skalar

function output=U_twisted_xzl_total_BLT_f(f,mu,epsilon,s,l,P,E_0,beta,k_vector,e_vector,Z_1_n,Z_2_n)
    % Terminal Responce Currents (in A) -> Matrix(2,F)
    U_BLT=U_twisted_xz_total_BLT_f(f,mu,epsilon,s,l,P,E_0,beta,k_vector,e_vector,Z_1_n,Z_2_n);

    % Strom am Ende der Leitung (in A) -> Zeilenvektor(1,F) 
    output=U_BLT(2,:);
end

% [1] Frederic M. Tesche, "Plane Wave Coupling to Cables", 49 pages
