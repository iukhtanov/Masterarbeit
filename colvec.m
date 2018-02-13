% Funktion, die einen beliebigen Vektor in einen Spaltenvektor umwandelt
% Autor: Mathias Magdowski
% Datum: 2009-03-09
% eMail: mathias.magdowski@ovgu.de

% Optionen:
    % vec - Vektor -> Zeilenvektor oder Spaltenvektor

% Ausgabe:
    % output - Vektor -> Spaltenvektor

function output=colvec(vec)
    if all(size(vec)==0)
        % komplett leerer Vektor, als leeren Spaltenvektor schreiben -> Spaltenvektor(0,1)
        vec=zeros(0,1);
    elseif size(vec,1)~=1 && size(vec,2)~=1
        % Eingabe ist Matrix, kein Vektor
        error('Input is a matrix, not a vector.');
    elseif size(vec,2)~=1
        % Eingabe ist Zeilenvektor, transponieren -> Spaltenvektor
        vec=vec.';
    end
    % Vektor ausgeben -> Spaltenvektor
    output=vec;
end