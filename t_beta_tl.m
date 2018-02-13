% Funktion zum Berechnen der zus�tzlichen Zeitverschiebung 
% f�r eine Doppelleitung mit allgemeiner Richtung
% Autor: Mathias Magdowski
% Datum: 2009-03-09
% eMail: mathias.magdowski@ovgu.de

% Leitung zeigt in k_tl-Richtung
% Richtung vom R�ckleiter zum Hinleiter zeigt in k_tr-Richtung

% Optionen:
    % c        - Lichtgeschwindigkeit (in m/s) -> Skalar
    % k_vector - normierter Wellenvektor -> Matrix(3,N)
    % s        - Abstand der Leiter (in m) -> Skalar
    % l        - L�nge der Leitung (in m) -> Skalar
    % geometry - Geometrie (optional) -> String
        % 'zx' -> Leitung in z-Richtung, R�ck- zu Hinleiter in x-Richtung (Standard)

% Ausgabe:
    % t_beta  - Zeitverschiebung (in s) -> Zeilenvektor(1,N)

function t_beta=t_beta_tl(c,k_vector,s,l,geometry)
    % wenn Geometrie nicht gesetzt, Standardwert benutzen
    if nargin<=4 
        geometry='zx';
    end
    
    % Geometrie �ndern
    [k_tl,k_tr]=change_geometry(geometry,k_vector);
    
    % Anmerkung: Die Variable h f�r s/2 kann nicht eingef�hrt werden, das
    % sonst die Heaviside-Funktion nicht funktioniert.

    % zus�tzliche Zeitverschiebung (in s) -> Zeilenvektor(1,N)
    t_beta=-abs(k_tr)*s/2/c+k_tl*l/c.*h(-k_tl);
    
    % Anmerkung: Die L�sung setzt sich aus 2 Anteilen zusammen.
    % 1. Anteil: Transversal zur Leitung, Richtung von k_tr ist egal,
    % deshalb interessiert nur der Absolutwert.
    % 2. Anteil: Parallel zur Leitung, hier muss nur phasenverschoben
    % werden, wenn die Welle das Ende zuerst erreicht, deshalb mit
    % Multiplikation mit Heaviside-Funktion.
    % Alle 2 Anteile haben im Normalfall ein negative Vorzeichen. 
    
    % Das ist auch konsistent mit der Definition von E_i=E_0*exp(j*beta)
    % und der Definition der Phasenverschiebung t_beta in den
    % Zeitfunktionen der zugeh�rigen Spektren.
end