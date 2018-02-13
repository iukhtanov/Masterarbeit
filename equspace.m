% Funktion zum eines Zeilenvektor mit gleichmäßig abgestuften Abständen
% ähnlich wie linspace
% Autor: Mathias Magdowski
% Datum: 2009-01-28
% eMail: mathias.magdowski@ovgu.de

% Optionen:
%   a - Anfang -> Skalar
%   b - Ende -> Skalar
%   N - Diskretisierung (optional) -> Skalar
%           Standardwert = 100

% Ausgabe:
%   output - Positionen -> Zeilenvektor(1,N)

% Anmerkungen:
% Im Unterschied zu linspace liefert equspace immer den Mittelpunkt einer
% jeweiligen Zelle.

function output=equspace(a,b,N)
    % prüfen, ob N gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=2
        N=100;
    end

    % Länge einer Zelle
    h=(b-a)/N;
    
    % Position -> Zeilenvektor(1,N)
    output=linspace(a+h/2,b-h/2,N);
end