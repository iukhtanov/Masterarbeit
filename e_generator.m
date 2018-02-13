% Funktion zur Berechnung des max. E-Feldvektors aus der Winkelverteilung
% für eine Randbedingungen aus mehreren Wellen
% Autor: Mathias Magdowski
% Datum: 2009-09-20
% eMail: mathias.magdowski@ovgu.de

% Optionen:
%   alpha - Polarisationswinkel (in rad) -> Zeilenvektor(1,N)
%   theta - Polarwinkel (in rad) -> Zeilenvektor(1,N)
%   phi   - Azimutwinkel (in rad) -> Zeilenvektor(1,N)
%   modus - Modus -> String
%       normal  -> Definition wie in [1]
%       graf    -> Definition wie in [2]
%       tesche  -> Definition wie in [3]
%       nec     -> Definition wie in [4]
%       concept -> Definition wie in [5]

% Ausgabe:
%   e_vector - max. E-Feldvektor in x,y,z-Koordinaten -> Matrix(3,N)
%   e_x      - x-Komponente des max. E-Feldvektors -> Zeilenvektor(1,N)
%   e_y      - y-Komponente des max. E-Feldvektors -> Zeilenvektor(1,N)
%   e_z      - z-Komponente des max. E-Feldvektors -> Zeilenvektor(1,N)


% Anmerkung:
%   N - Anzahl der überlagerten Wellen pro Randbedingung -> Skalar

function [e_vector,e_x,e_y,e_z]=e_generator(alpha,theta,phi,modus)
    % prüfen, ob der Modus gesetzt ist, wenn nicht Standardmodus setzen
    if nargin<=3
        modus='normal';
    end
    % Komponenten des max. E-Feldvektors in x,y,z-Koordinaten -> Zeilenvektor(1,N)
    if strcmp(modus,'normal')
        % Definition wie in [1]
        e_x=cos(alpha).*cos(theta).*cos(phi)-sin(alpha).*sin(phi);
        e_y=cos(alpha).*cos(theta).*sin(phi)+sin(alpha).*cos(phi);
        e_z=-cos(alpha).*sin(theta);
    elseif strcmp(modus,'graf')
        % Definiton wie in [2]
        e_x=cos(alpha).*cos(theta);
        e_y=-cos(alpha).*sin(theta).*sin(phi)+sin(alpha).*cos(phi);
        e_z=cos(alpha).*sin(theta).*cos(phi)+sin(alpha).*sin(phi);
    elseif strcmp(modus,'tesche')
        % Definiton wie in [3]
        e_x=cos(alpha).*sin(theta).*cos(phi)-sin(alpha).*sin(phi);
        e_y=-cos(alpha).*sin(theta).*sin(phi)-sin(alpha).*cos(phi);
        e_z=cos(alpha).*cos(theta);
    elseif strcmp(modus,'nec')
        % Definiton wie in [4]
        e_x=cos(alpha).*cos(theta).*cos(phi)-sin(alpha).*sin(phi);
        e_y=cos(alpha).*cos(theta).*sin(phi)+sin(alpha).*cos(phi);
        e_z=-cos(alpha).*sin(theta);
    elseif strcmp(modus,'concept')
        % Definiton wie in [5] 
        e_x=-cos(alpha).*cos(theta).*cos(phi)+sin(alpha).*sin(phi);
        e_y=-cos(alpha).*cos(theta).*sin(phi)-sin(alpha).*cos(phi);
        e_z=cos(alpha).*sin(theta);
    else
        error('The modus is unknown.');
    end
    % max. E-Feldvektor in x,y,z-Koordinaten -> Matrix(3,N)
    e_vector=[e_x;e_y;e_z];
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