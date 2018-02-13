% Funktion zum Ändern der Ausrichtung der Leitung
% Autor: Mathias Magdowski
% Datum: 2009-03-11
% eMail: mathias.magdowski@ovgu.de

% Optionen:
    % geometry - Geometrie -> String
        % xy -> Leitung in x-Richtung, Rück- zu Hinleiter in y-Richtung
        % yz -> Leitung in y-Richtung, Rück- zu Hinleiter in z-Richtung
        % zx -> Leitung in z-Richtung, Rück- zu Hinleiter in x-Richtung
    % x_vector - normierter Vektor -> Matrix(3,N)

% Anmerkung: Der normierte Vektor x_vector kann sowohl der normierte
% Wellenvektor k_vector, der normierte E-Feldvektor e_vector oder der
% normierte H-Feldvektor h_vector sein.

% Ausgabe:
    % x_tl - Komponente des Vektors in Richtung der Leitung (parallel) -> Zeilenvektor(1,N)
    % x_tr - Komponente des Vektors vom Rückleiter zum Hinleiter (transversal) -> Zeilenvektor(1,N)
    % x_or - Komponente des Vektors orthogonal zur Leitung -> Zeilenvektor(1,N)
    
function [x_tl,x_tr,x_or]=change_geometry(geometry,x_vector)
    if strcmp(geometry,'xy')
        % Anteil der Vektoren parallel zur Leitung -> Skalar
        tl=1;
        % Anteil der Vektoren transversal zur Leitung -> Skalar
        tr=2;
        % Anteil der Vektoren orthogonal zur Leitung -> Skalar
        or=3;
    elseif strcmp(geometry,'xz')
        % Anteil der Vektoren parallel zur Leitung -> Skalar
        tl=1;
        % Anteil der Vektoren transversal zur Leitung -> Skalar
        tr=3;
        % Anteil der Vektoren orthogonal zur Leitung -> Skalar
        or=-2;
    elseif strcmp(geometry,'yz')
        % Anteil der Vektoren parallel zur Leitung -> Skalar
        tl=2;
        % Anteil der Vektoren transversal zur Leitung -> Skalar
        tr=3;
        % Anteil der Vektoren orthogonal zur Leitung -> Skalar
        or=1;
    elseif strcmp(geometry,'zx')
        % Anteil der Vektoren parallel zur Leitung -> Skalar
        tl=3;
        % Anteil der Vektoren transversal zur Leitung -> Skalar
        tr=1;
        % Anteil der Vektoren orthogonal zur Leitung -> Skalar
        or=2;
    else
        error(['The geometry ',geometry,' is unknown.']);
    end
    % Anteil des Wellenvektors parallel zur Leitung -> Zeilenvektor(1,N)
    x_tl=sign(tl)*x_vector(abs(tl),:);
    % Anteil des Wellenvektors transversal zur Leitung -> Zeilenvektor(1,N)
    x_tr=sign(tr)*x_vector(abs(tr),:);
    % Anteil des Wellenvektors orthogonal zur Leitung -> Zeilenvektor(1,N)
    x_or=sign(or)*x_vector(abs(or),:);
end
    