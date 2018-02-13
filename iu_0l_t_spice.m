% Funktion zur Berechnung der Zeitbereichslösung für die Einkopplung in 
% eine Leitung mittels einer Netzwerksimulation mit SPICE
% Autor: Mathias Magdowski
% Datum: 2009-03-13
% eMail: mathias.magdowski@ovgu.de

% Optionen:
% Allgemeine Konstanten
    % t       - Zeitbereich (in s) -> Zeilenvektor(1,T)
    % mu      - Permeabilität (in Vs/Am) -> Skalar
    % epsilon - Permittivität (in As/Vm) -> Skalar
% Daten der Doppelleitung
    % s     - Abstand der Leiter (in m) -> Skalar
    % r_0   - Radius der Leiter (in m) -> Skalar
    % l     - Länge der Leitung (in m) -> Skalar
    % Z_1_n - Abschlusswiderstand am Anfang, normiert auf Z_c -> Skalar
    % Z_2_n - Abschlusswiderstand am Ende, normiert auf Z_c -> Skalar
% Daten der einfallenden Welle
    % E_0       - Feldstärke des E-Feldes (in V/m) -> Skalar
    % parameter - Parameter der Funktion
        % bei exppuls    -> Zeitkonstante tau (in s) -> Skalar
        % bei sinuspuls  -> Kreisfrequenz omega (in 1/s) und Anzahl der Perioden n_p -> Vektor(1,2)
        % bei sinus      -> Kreisfrequenz omega (in 1/s) -> Skalar
        % bei dblexppuls -> Parameter alpha und beta (in 1/s) -> Vektor(1,2)
        % bei sqrpuls    -> Pulsbreite tau (in s) -> Skalar
        % bei triangpuls -> Anstiegszeit und Abfallzeit (in s) -> Vektor(1,2)
        % bei trapezpuls -> Anstiegszeit, Haltezeit und Abfallzeit (in s) -> Vektor(1,3)
        % bei ramp       -> Anstiegszeit (in s) -> Skalar
        % bei step       -> leer
    % t_beta    - zusätzliche Zeitverschiebung (in s) -> Skalar
    % k_vector  - normierter Wellenvektor -> Spaltenvektor(3,1)
    % e_vector  - normierter E-Feldvektor -> Spaltenvektor(3,1)
    % time_func - Zeitfunktion -> String
        % exppuls    -> einfach-exponentieller Puls mit E_0 und tau
        % sinuspuls  -> Sinuspuls mit E_0, omega und n_p
        % sinus      -> eingeschalteter Sinus mit E_0 und omega
        % dblexppuls -> doppelt-exponentieller Puls mit E_0, alpha und beta
        % sqrpuls    -> Rechteckpuls mit E_0 und tau
        % triangpuls -> Dreieckpuls mit E_0, t_rise und t_fall
        % trapezpuls -> Trapezpuls mit E_0, t_rise, t_top und t_fall
        % ramp       -> Rampe mit E_0 und t_rise
        % step       -> Sprung mit E_0        
% Größe
    % quantity - physikalische Größe -> String
        % U -> Spannung (in V)
        % I -> Strom (in A)
        % U_along -> Spannung entlang der Leitung (in V)
        % I_along -> Strom entlang der Leitung (in A)
    % typeof   - Art der Spannung/des Stromes -> String
        % total     -> Gesamtspannung (in V)/Gesamtstrom (in A)
        % scattered -> Streuspannung (in V)
        % incident  -> einfallende Spannung (in V)
% Anderes
    % geometry - Geometrie der Leitung -> String
        % xy -> Leitung in x-Richtung, Rück- zu Hinleiter in y-Richtung
        % yz -> Leitung in y-Richtung, Rück- zu Hinleiter in z-Richtung
        % zx -> Leitung in z-Richtung, Rück- zu Hinleiter in x-Richtung        
    % d        - Anzahl der Zellen pro Wellenlänge (optional, Standard=20) -> Skalar
    % losses   - Berücksichtigung von Verlusten (optional, Standard=lossless) -> String
        % lossless -> verlustlos        
        % DC       -> Gleichstromverluste
        % max_f    -> Verluste bei der maximalen Frequenz
        
% Ausgabe:
    % plots    - Lösung im Zeitbereich am Anfang und Ende der Leitung -> Matrix(2,T)
    % comptime - R

function [plots,comptime]=iu_0l_t_spice(t,mu,epsilon,s,r_0,l,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,quantity,typeof,geometry,d,losses)
    % prüfen, ob d gesetzt wurden, wenn nicht auf Standardwert setzen
    if nargin<=17
        d=1;
    end

    % prüfen, ob losses gesetzt wurden, wenn nicht auf Standardwert setzen
    if nargin<=18
        losses='lossless';
    end
    
    % Debug
    %disp(d);

    % Dateiname -> String
    if strcmp(losses,'lossless')
        filename='tl_lossless.net';
    elseif strcmp(losses,'DC')
        filename='tl_DC_losses.net';
    elseif strcmp(losses,'max_f')
        filename='tl_max_f_losses.net';
    end

    % Netzliste erstellen
    R=spice_source(filename,t,mu,epsilon,s,r_0,l,Z_1_n,Z_2_n,quantity,typeof,d,losses);

    % Ortsbereich für die Auswertung -> Zeilenvektor(1,2*R+2);
    r_vector=r_vector_tl(s,l,R,geometry);
    
    % Lichtgeschwindigkeit (in m/s) -> Skalar
    c=1/sqrt(mu*epsilon);
    
    % Lösung berechnen
    [t,plots,comptime]=spice(filename,E_0,c,e_vector,k_vector,r_vector,t_beta,time_func,parameter,geometry);
end