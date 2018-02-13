% inverse Fouriertransformation via FFT
% Original von Dr. Kochetov
% bearbeitet von Mathias Magdowski
% Datum: 2008-07-23
% eMail: mathias.magdowski@ovgu.de
%
% Eingabe:
% f     - Frequenzbereich (in Hz) -> Vektor der Länge N
%           - die erste Frequenz ist 0
%           - äquidistante Frequenzschritte
% X_f   - Spektrum -> Vektor der Länge N
% modus - Modus -> String
%   'pulse' -> Transformation eines Pulses
%   'sinus' -> Transformation eines kontinuierlichen Signals
%   Hintergrund: Der Modus beeinflusst allein die Normierung der Amplitude
%                des Spektrums.
%
% Ausgabe:
% t   - Zeitbereich (in s) -> Zeilenvektor der Länge 2*N
%           - die erste Zeit ist 0
%           - äquidistante Zeitschritte
% x_t - Zeitverlauf -> Zeilenvektor der Länge 2*N
%
% Anmerkung:
% - bei der Eingabe sind sowohl Zeilen- als auch Spaltenvektoren erlaubt
% - die Länge der Vektoren sollte eine Potenz von 2 sein

function [t,x_t]=invfourier(f,X_f,modus) 
    % prüfen ob modus gesetzt ist
    if nargin<3
        % auf Standardwert setzen
        modus='pulse';
    end

    % Anzahl der Werte -> Skalar
    N=length(f);
    
    % Frequenzschritt (in Hz) -> Skalar
    f_step=f(2);
    % maximale Zeit (in s) -> Skalar
    t_max=0.5/f_step;

    % Frequenzvektor ausfüllen -> Vektor
    % Gleichanteil (XX_f(1)) und positive Frequenzen in aufsteigender Richtung
    XX_f(1:N)=X_f;
    % höchste Frequenz auf Null setzen
    XX_f(N+1)=0;
    % negative Spiegelfrequenzen in abfallender Richtung
    XX_f(N+2:2*N)=conj(XX_f(N:-1:2));
    
    % inverse Fouriertransformation durchführen -> Vektor
    if strcmp(modus,'pulse')
        % das Spektrum hat die Einheit 1/Hz (z.B. V/Hz, A/Hz, ...)
        xx_t=N/t_max*ifft(XX_f);
    elseif strcmp(modus,'sinus')
        % das Spektrum hat die Einheit 1 (z.B. V, A, ...)
        xx_t=N*ifft(XX_f);
    else
        error(['The modus ',modus,' is unknown.'])
    end

    % Zeitantwort erstellen -> Zeilenvektor(1,2:N)
    x_t(1:2*N)=xx_t(1:2*N);
    
    % Zeitbereich erstellen (in s) -> Zeilenvektor(1,2:N)
    t=linspace(0,t_max*(2*N-1)/N,2*N);
end

% Anmerkung: Eine mehrfache Transformation mitteln fourier und invfourier
% ist nicht umkehrbar. In einem solchen Fall sollte eher direkt mittel fft
% und ifft transformiert werden und dabei der Zeit- bzw. Frequenzvektor
% erhalten bleiben.

