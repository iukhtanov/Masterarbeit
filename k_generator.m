% Funktion zur Berechnung des Wellenvektors aus der Winkelverteilung
% für eine Randbedingungen aus mehreren Wellen
% Autor: Mathias Magdowski
% Datum: 2009-09-20
% eMail: mathias.magdowski@ovgu.de

% Optionen:
%   k     - Wellenzahl (in 1/m) -> Skalar
%   theta - Polarwinkel (in rad) -> Zeilenvektor(1,N)
%   phi   - Azimutwinkel (in rad) -> Zeilenvektor(1,N)
%   modus - Modus -> String
%       normal  -> Definition wie in [1]
%       graf    -> Definition wie in [2]
%       tesche  -> Definition wie in [3]
%       nec     -> Definition wie in [4]
%       concept -> Definition wie in [5]

% Ausgabe:
%   k_vector - Wellenvektor in x,y,z-Koordinaten (in 1/m) -> Matrix(3,N)
%   k_x      - x-Komponente des Wellenvektors (in 1/m) -> Zeilenvektor(1,N)
%   k_y      - y-Komponente des Wellenvektors (in 1/m) -> Zeilenvektor(1,N)
%   k_z      - z-Komponente des Wellenvektors (in 1/m) -> Zeilenvektor(1,N)

% Anmerkung:
%   N - Anzahl der überlagerten Wellen pro Randbedingung -> Skalar

function [k_vector,k_x,k_y,k_z]=k_generator(k,theta,phi,modus)
    % prüfen, ob der Modus gesetzt ist, wenn nicht Standardmodus setzen
    if nargin<=3
        modus='normal';
    end
    % Komponenten des Wellenvektors in x,y,z-Koordinaten (in 1/m) -> Zeilenvektor(1,N)
    if strcmp(modus,'normal')
        % Definition wie in [1]
        k_x=k*sin(theta).*cos(phi);
        k_y=k*sin(theta).*sin(phi);
        k_z=k*cos(theta);
    elseif strcmp(modus,'graf')
        % Definition wie in [2]
        % Anmerkung: Der Elevationswinkel theta wird bei Graf als psi
        % bezeichnet.
        k_x=-k*sin(theta);
        k_y=-k*cos(theta).*sin(phi);
        k_z=k*cos(theta).*cos(phi);
    elseif strcmp(modus,'tesche')
        % Definition wie in [3]
        % Formel (10) aus [3]
        % Achtung! Fehler in der Quelle
        % bei Tesche werden k_y und k_z mit anderem Vorzeichen definiert
        % damit stimmen die Definitionen nicht mit den Abbildungen überein
        % in den Formeln werden k_y und k_z allerdings immer invertiert
        % benutzt, damit stimmen die Ergebnisse
        k_x=k*cos(theta).*cos(phi);
        k_y=-k*cos(theta).*sin(phi);
        k_z=-k*sin(theta);
    elseif strcmp(modus,'nec')
        % Definition wie in [4]
        k_x=-k*sin(theta).*cos(phi);
        k_y=-k*sin(theta).*sin(phi);
        k_z=-k*cos(theta);
    elseif strcmp(modus,'concept')
        % Definition wie in [5]
        k_x=k*sin(theta).*cos(phi);
        k_y=k*sin(theta).*sin(phi);
        k_z=k*cos(theta);
    else
        error('The modus is unknown.');
    end
    % Wellenvektor in x,y,z-Koordinaten (in 1/m) -> Matrix(3,N)
    k_vector=[k_x;k_y;k_z];
end

% Quellen
% [1] Mathias Magdowski, "Entwicklung und Validierung eines Werkzeugs zur
% Berechnung der elektromagnetischen Einkopplung von stochastischen Feldern
% in Leitungsstrukturen", Diplomarbeit, Otto-von-Guericke Universität
% Magdeburg, September 2008
% [2] W. Graf, "Die Einkopplung des Exo-EMP in eine verlustlose Leitung
% über einer unendlich gut leitenden Metallplatte", Bericht Nr. 127,
% Fraunhofer Institut für naturwissenschaftliche Trendanalysen (INT) in
% Euskirchen, April 1987
% [3] Frederic M. Tesche, "Plane Wave Coupling to Cables", 49 pages
% [4] G. J. Burke, A. J. Poggio, "Numerical Electromagnetics Code (NEC) -
% Method of Moments, Part III: User Guide", informal report, Lawrence
% Livermore Laboratory, January 1981
% [5] H.-D. Brüns, A. Freiberg, H. Singer, Concept II, Method of Moments
% Code developed at the Technische Universität Hamburg-Harburg
