% Funktion zur Berechnung der Zeitbereichslösung für die Einkopplung in 
% eine verdrillte Leitung mittels einer Netzwerksimulation mit SPICE
% Autor: Mathias Magdowski
% Datum: 2012-01-16
% eMail: mathias.magdowski@ovgu.de

% Optionen:
% Allgemeine Konstanten
    % t       - Zeitbereich (in s) -> Zeilenvektor(1,T)
    % mu      - Permeabilität (in Vs/Am) -> Zeilenvektor(1,2)
        % erster Wert: Permeabilität des Freiraums
        % zweiter Wert: Permeabilität der Leitung
    % epsilon - Permittivität (in As/Vm) -> Zeilenvektor(1,2)
        % erster Wert: Permittivität des Freiraums
        % zweiter Wert: Permittivität der Leitung
% Daten der Doppelleitung
    % s - Abstand der Leiter (in m) -> Skalar
    % l - Länge der Leitung (in m) -> Skalar
    % Z_1_n - Abschlusswiderstand am Anfang, normiert auf Z_c -> Skalar
    % Z_2_n - Abschlusswiderstand am Ende, normiert auf Z_c -> Skalar
    % Z_1_n=0 oder Z_2_n=0 gibt es bei der Berechnung des Laststromes
    % Probleme, weil der zugehörige Leitwert gegen unendlich geht.
    % Z_1_n=inf oder Z_2_n=inf ist dagegen problemlos.
% Daten der einfallenden Welle
    % E_0       - Feldstärke des E-Feldes (in V/m) -> Skalar
    % parameter - Parameter der Funktion
        % bei exppuls    -> Zeitkonstante tau (in s) -> Skalar
        % bei sinuspuls  -> Kreisfrequenz omega (in 1/s) und Anzahl der Perioden n_p -> Vektor(1,2)
        % bei sinus      -> Kreisfrequenz omega (in 1/s) -> Skalar
        % bei dblexppuls -> Parameter alpha und beta (in 1/s) -> Vektor(1,2)
    % t_beta    - zusätzliche Zeitverschiebung (in s) -> Skalar
    % k_vector  - Wellenvektor -> Spaltenvektor(3,1)
    % e_vector  - E-Feldvektor -> Spaltenvektor(3,1)
% Zeitfunktion
    % time_func - Zeitfunktion -> String
        % exppuls    -> einfach-exponentieller Puls mit E_0 und tau
        % sinuspuls  -> Sinuspuls mit E_0, omega und n_p
        % sinus      -> eingeschalteter Sinus mit E_0 und omega
        % dblexppuls -> doppelt-exponentieller Puls mit E_0, alpha und beta
% Physikalische Größe
    % quantity - physikalische Größe -> String
        % U -> Spannung (in V)
        % I -> Strom (in A)
    % typeof   - Art der Spannung/des Stromes -> String
        % total     -> Gesamtspannung (in V)/Gesamtstrom (in A)
        % scattered -> Streuspannung (in V)
        % incident  -> einfallende Spannung (in V)
% Geometrie
    % geometry - Richtung der Leitung -> String
    % d        - Anzahl der Zellen pro Wellenlänge (optional, Standard=20) -> Skalar
    % losses   - Berücksichtigung von Verlusten (optional, Standard=lossless) -> String
        % lossless -> verlustlos        
        % DC       -> Gleichstromverluste
        % max_f    -> Verluste bei der maximalen Frequenz

% Ausgabe:
    % plots    - Movie im Zeitbereich entlang der Leitung der Leitung -> Cell-Array(N_r,T)
    % comptime - R

function [plots,comptime]=iu_r_t_twisted_spice(t,mu,epsilon,s,r_0,l,P,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,quantity,typeof,geometry,d,losses)
    % prüfen, ob die Permeabilität für die Leitung gesetzt wurde
    if length(mu)==1
        % Standardwert setzen
        mu(2)=mu(1);
    end
    % prüfen, ob die Permittivität für die Leitung gesetzt wurde
    if length(epsilon)==1
        % Standardwert setzen
        epsilon(2)=epsilon(1);
    end
    % prüfen, ob d gesetzt wurden, wenn nicht auf Standardwert setzen
    if nargin<=18
        d=1;
    end
    % prüfen, ob losses gesetzt wurden, wenn nicht auf Standardwert setzen
    if nargin<=19
        losses='lossless';
    end

    % Dateiname -> String
    if strcmp(losses,'lossless')
        filename='tl_twisted_lossless.net';
    elseif strcmp(losses,'DC')
        filename='tl_twisted_DC_losses.net';
    elseif strcmp(losses,'max_f')
        filename='tl_twisted_max_f_losses.net';
    end
    
    % Verdrillungswinkel (in rad) -> Skalar
    delta=atan(P/(pi*s));
    % delta liegt zwischen 0 und 90°
    % wenn delta=90° -> keine Verdrillung
    % wenn delta=0° -> totale Verdrillung
    
    % neue Länge der verdrillten Leiter (in m) -> Skalar
    l_twisted=l/sin(delta);

    % Lichtgeschwindigkeit (in m/s) -> Skalar
    c=1/sqrt(mu(1)*epsilon(1));
    
    if strcmp(quantity,'U')
        % für die Spannung
        if strcmp(typeof,'scattered')
            % Netzliste erstellen
            R=spice_source(filename,t,mu(2),epsilon(2),s,r_0,l_twisted,Z_1_n,Z_2_n,[quantity,'_along'],typeof,d,losses);
            % Ortsbereich für die Auswertung -> Zeilenvektor(1,2*R+2);
            r_vector=r_vector_tl_twisted(s,l,P,R,geometry);
            % Lösung berechnen
            [t,plots,comptime]=spice(filename,E_0,c,e_vector,k_vector,r_vector,t_beta,time_func,parameter,geometry,false,P);
        elseif strcmp(typeof,'incident')
            % Lösung berechnen
            plots=U_r_t_incident_twisted(t+t_beta,c,s,l,P,E_0,parameter,k_vector,e_vector,time_func,geometry,d);
            % Zeit zur Lösung (in s) -> Skalar
            comptime=0;        
        elseif strcmp(typeof,'total')
            % Streuspannung entlang der Leitung über der Zeit (in V) -> Matrix(R,T)
            [plots_scattered,comptime]=iu_r_t_twisted_spice(t,mu,epsilon,s,r_0,l,P,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,quantity,'scattered',geometry,d,losses);

            % einfallende Spannung entlang der Leitung über der Zeit (in V) -> Matrix(R,T)
            plots_incident=iu_r_t_twisted_spice(t,mu,epsilon,s,r_0,l,P,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,quantity,'incident',geometry,d,losses);

            % Gesamtspannung entlang der Leitung über der Zeit (in V) -> Matrix(R,T)
            plots=plots_scattered+plots_incident;
        else
            error(['The ',typeof,'-type of the voltage is unknown.']);
        end
    elseif strcmp(quantity,'I')
        % für den Strom
        if strcmp(typeof,'total')
            % Netzliste erstellen
            R=spice_source(filename,t,mu(2),epsilon(2),s,r_0,l_twisted,Z_1_n,Z_2_n,[quantity,'_along'],typeof,d,losses);
            % Ortsbereich für die Auswertung -> Zeilenvektor(1,2*R+2);
            r_vector=r_vector_tl_twisted(s,l,P,R,geometry);
            % Lösung berechnen
            [t,plots,comptime]=spice(filename,E_0,c,e_vector,k_vector,r_vector,t_beta,time_func,parameter,geometry,false,P);
        else
            error(['The ',typeof,'-type of the current is unknown.']);
        end
    else
        error(['The quantity ',quantity,' is unknown.']);
    end
end