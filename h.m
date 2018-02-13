% Heaviside-Funktion
% Autor: Mathias Magdowski
% Datum: 2007-02-28
% eMail: mathias.magdowski@ovgu.de

% Optionen:
% t - Argument

% Besonderheit:
% y ist 1 an der Stelle 0 

function y = h(t)
    y = ( t>=0 );
end

% Quelle: Eine Einf�hrung in MATLAB aus der Sicht eines Mathematikers
% G�nter M. Gramlich
% Professor f�r Mathematik an der
% Fachhochschule Ulm
% Fachbereich Grundlagen
% http://www.rz.fh-ulm.de/gramlich
% Ulm, 16. Mai 2005
