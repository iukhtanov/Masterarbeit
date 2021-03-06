% Funktion zum Festlegen der Leitungsparameter
% Autor: Mathias Magdowski
% Datum: 2009-03-12
% eMail: mathias.magdowski@ovgu.de

% Optionen:
    % modus - Modus -> String
        % tesche -> Standardkonfiguration wie in [1]

% Ausgabe:
    % s   - Abstand der Leiter (in m) -> Skalar
    % r_0 - Radius der Leiter (in m) -> Skalar
    % l   - L�nge der Leitung (in m) -> Skalar

% function [s,r_0,l]=tl_dimensions(modus)
function [s,r_0,l]=tl_dimensions(modus)
    if strcmp(modus,'tesche')
        % wie in [1]
        s=0.2;                  % Abstand der Leiter (in m) -> Skalar
        r_0=1.5e-3;             % Radius der Leiter (in m) -> Skalar
        l=30;                   % L�nge der Leitung (in m) -> Skalar
    elseif strcmp(modus,'mag')
        s=10e-3;                % Abstand der Leiter (in m) -> Skalar
        r_0=0.5e-3;             % Radius der Leiter (in m) -> Skalar
        l=0.4;                  % L�nge der Leitung (in m) -> Skalar
    elseif strcmp(modus,'musso3')
        s=6e-2;                 % Abstand der Leiter (in m) -> Skalar
        r_0=1.5e-3;             % Radius der Leiter (in m) -> Skalar
        l=0.5;                  % L�nge der Leitung (in m) -> Skalar
    elseif strcmp(modus,'musso5')
        s=10e-2;                % Abstand der Leiter (in m) -> Skalar
        r_0=1.5e-3;             % Radius der Leiter (in m) -> Skalar
        l=0.5;                  % L�nge der Leitung (in m) -> Skalar
    elseif strcmp(modus,'twisted')
        % f�r die Ver�ffentlichung in D�sseldorf 2009
        s=0.01;                 % Abstand der Leiter (in m) -> Skalar
        %r_0=0.5e-3;             % Radius der Leiter (in m) -> Skalar
        % l=30;                   % L�nge der Leitung (in m) -> Skalar
        % Problem: Berechnungszeit in CONCEPT zu lang
    elseif strcmp(modus,'twisted2')
        % f�r die Ver�ffentlichung in D�sseldorf 2009
        s=0.02;                 % Abstand der Leiter (in m) -> Skalar
        r_0=0.5e-3;             % Radius der Leiter (in m) -> Skalar
        l=30;                   % L�nge der Leitung (in m) -> Skalar
        % Problem: Da in NEC Segmente l�nger als lambda/1000 sein m�ssen,
        % gilt: f_min=c/(1000*s)
	elseif strcmp(modus,'twisted3')
        % f�r die Ver�ffentlichung in D�sseldorf 2009
        s=0.1;                 % Abstand der Leiter (in m) -> Skalar
        r_0=0.5e-3;             % Radius der Leiter (in m) -> Skalar
        l=30;                   % L�nge der Leitung (in m) -> Skalar
    elseif strcmp(modus,'twisted_plot')
        % f�r die Ver�ffentlichung in D�sseldorf 2009
        s=1;                    % Abstand der Leiter (in m) -> Skalar
        r_0=0.5e-3;             % Radius der Leiter (in m) -> Skalar
        l=30;                   % L�nge der Leitung (in m) -> Skalar
        % Abstand der Leiter extrem vergr��ert, damit man auf den
        % Abbildungen etwas erkennen kann
    elseif strcmp(modus,'measure')
        % wie bei der Messung in der mittleren MVK
        s=32e-3;                % Abstand der Leiter (in m) -> Skalar
        r_0=0.6910e-3;          % Radius der Leiter (in m) -> Skalar
        l=0.4;                  % L�nge der Leitung (in m) -> Skalar
    elseif strcmp(modus,'msl100')
        % wie bei der Messung in der mittleren MVK von Herzig
        s=0.1e-3;               % Abstand der Leiter (in m) -> Skalar
        r_0=10e-6;              % Radius der Leiter (in m) -> Skalar
        l=100e-3;               % L�nge der Leitung (in m) -> Skalar
    elseif strcmp(modus,'msl300')
        % wie bei der Messung in der mittleren MVK von Herzig
        s=0.1e-3;               % Abstand der Leiter (in m) -> Skalar
        r_0=10e-6;              % Radius der Leiter (in m) -> Skalar
        l=300e-3;               % L�nge der Leitung (in m) -> Skalar
    elseif strcmp(modus,'conti')
        % typischer Kabelbaum aus dem Automobilbereich
        s=0.005;                % Abstand der Leiter (in m) -> Skalar
        r_0=0.0005;             % Radius der Leiter (in m) -> Skalar
        l=1.85;                 % L�nge der Leitung (in m) -> Skalar
    else
        error(['The modus ',modus,' is unknown.'])
    end
end

% Quellen:
% [1] Frederic M. Tesche, "Plane Wave Coupling to Cables", 49 pages