% Funktion zur Berechnung der Spektren verschiedener Zeitfunktionen
% mit einer zusätzlichen Zeitverschiebung
% Autor: Mathias Magdowski
% Datum: 2009-03-10
% eMail: mathias.magdowski@ovgu.de

% Optionen:
    % omega     - Kreisfrequenzen (in 1/s) -> Vektor
    % E_0       - Amplitude des Pulses (in V/m) -> Skalar
    % parameter - weitere Parameter
        % bei exppuls    -> Zeitkonstante tau (in s) -> Skalar
        % bei sinuspuls  -> Kreisfrequenz omega (in 1/s) -> Skalar
        % bei dblexppuls -> Parameter alpha und beta (in 1/s) -> Vektor(1,2)
        % bei sqrpuls    -> Pulsbreite tau (in s) -> Skalar
        % bei triangpuls -> Anstiegszeit und Abfallzeit (in s) -> Vektor(1,2)
        % bei trapezpuls -> Anstiegszeit, Haltezeit und Abfallzeit (in s) -> Vektor(1,3)
    % t_beta    - zusätzliche Zeitverschiebung (in s) -> Skalar        
    % time_func - Zeitfunktion -> String
        % exppuls -> einfach exponentieller Puls
        % sinuspuls -> einzelner Sinuspulses
        % dblexppuls -> doppelt exponentieller Puls
        % sqrpuls    -> Rechteckpuls
        % triangpuls -> Dreieckpuls
        % trapezpuls -> Trapezpuls mit E_0, t_rise, t_top und t_fall

% exppuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*Heaviside(t)*exp(-(t+t_beta)/tau)
    % beschrieben
    
% sinuspuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*(Heaviside(t+t_beta)-Heaviside(t+t_beta-2*Pi/omega_0))*sin(omega_0*(t+t_beta));
    % beschrieben

% dblexppuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*(exp(-alpha*(t+t_beta))-exp(-beta*(t+t_beta)))*Heaviside(t+t_beta);
    % beschrieben

% sqrpuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*(Heaviside(t+t_beta)-Heaviside(t+t_beta-tau));
    % beschrieben

% triangpuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*(Heaviside(t+t_beta)*(t+t_beta)/t_rise-(1/t_rise+1/t_fall)*Heaviside(t+t_beta-t_rise)*(t+t_beta-t_rise)+1/t_fall*Heaviside(t+t_beta-t_rise-t_fall)*(t+t_beta-t_rise-t_fall));
    % beschrieben

% trapezpuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*((Heaviside(t+t_beta)*(t+t_beta)-Heaviside(t+t_beta-t_rise)*(t+t_beta-t_rise))/t_rise-(Heaviside(t+t_beta-t_rise-t_top)*(t+t_beta-t_rise-t_top)-Heaviside(t+t_beta-t_rise-t_top-t_fall)*(t+t_beta-t_rise-t_top-t_fall))/t_fall);
    % beschrieben

function output=spectrum_t_beta(omega,E_0,parameter,t_beta,time_func)
    % normales Spektrum berechnen (in Vs/m) -> Vektor
    output=spectrum(omega,E_0,parameter,time_func);
    % Phasenverschiebung hinzufügen
    output=output.*exp(j*t_beta*omega);
end