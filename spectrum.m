% Funktion zur Berechnung der Spektren verschiedener Zeitfunktionen
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
    % time_func - Zeitfunktion -> String
        % exppuls    -> einfach exponentieller Puls
        % sinuspuls  -> einzelner Sinuspulses
        % dblexppuls -> doppelt exponentieller Puls
        % sqrpuls    -> Rechteckpuls
        % triangpuls -> Dreieckpuls
        % trapezpuls -> Trapezpuls mit E_0, t_rise, t_top und t_fall
        
% exppuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*Heaviside(t)*exp(-t/tau)
    % beschrieben

% sinuspuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*(Heaviside(omega_0*t)-Heaviside(omega_0*t-2*Pi))*sin(omega_0*t);
    % beschrieben

% dblexppuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*(exp(-alpha*t)-exp(-beta*t))*Heaviside(t);
    % beschrieben
    
% sqrpuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*(Heaviside(t)-Heaviside(t-tau));
    % beschrieben

% triangpuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*(Heaviside(t)*t/t_rise-(1/t_rise+1/t_fall)*Heaviside(t-t_rise)*(t-t_rise)+1/t_fall*Heaviside(t-t_rise-t_fall)*(t-t_rise-t_fall));
    % beschrieben

% trapezpuls:
    % der Puls wird durch die Zeitfunktion
    % x:=t->E_0*((Heaviside(t)*t-Heaviside(t-t_rise)*(t-t_rise))/t_rise-(Heaviside(t-t_rise-t_top)*(t-t_rise-t_top)-Heaviside(t-t_rise-t_top-t_fall)*(t-t_rise-t_top-t_fall))/t_fall);
    % beschrieben

function output=spectrum(omega,E_0,parameter,time_func)
    if strcmp(time_func,'exppuls')
        % Zeitkonstante tau (in s) -> Skalar
        tau=parameter;
        % Spektrum berechnen (in Vs/m) -> Vektor
        output=tau./(1+omega*tau*j);
    elseif strcmp(time_func,'sinuspuls')
        % Kreisfrequenz des Pulses (in 1/s) -> Skalar
        omega_0=parameter;
        % prüfen, wann omega=omega_0 ist -> Zeilenvektor
        omega_0_in_omega=find(omega==omega_0);
        % prüfen, wann omega=-omega_0 ist -> Zeilenvektor
        minus_omega_0_in_omega=find(omega==-omega_0);
        % omega an diesen Stellen auf 2*omega_0 setzen
        omega(omega_0_in_omega)=2*omega_0;
        % omega an diesen Stellen auf 2*omega_0 setzen
        omega(minus_omega_0_in_omega)=2*omega_0;
        % Spektrum berechnen (in Vs/m) -> Vektor
        output=omega_0*(exp(-2*i*pi*omega/omega_0)-1)./(omega.^2-omega_0^2);
        % Stellen mit Grenzwert überschreiben, an denen omega=omega_0 war
        output(omega_0_in_omega)=-j*pi/omega_0;
        % Stellen mit Grenzwert überschreiben, an denen omega=-omega_0 war
        output(minus_omega_0_in_omega)=j*pi/omega_0;
    elseif strcmp(time_func,'dblexppuls')
        % Parameter des Pulses (in 1/s) -> Skalar
        alpha=parameter(1);
        beta=parameter(2);
        % Spektrum berechnen (in Vs/m) -> Vektor
        output=(beta-alpha)./((alpha+j*omega).*(beta+j*omega));
    elseif strcmp(time_func,'sqrpuls')
        % Pulsbreite (in s) -> Skalar
        tau=parameter;
        % prüfen, wann omega Null ist -> Zeilenvektor
        zeros_in_omega=find(omega==0);
        % omega an diesen Stellen auf 1 setzen
        omega(zeros_in_omega)=1;
        % Spektrum berechnen (in Vs/m) -> Vektor
        output=(1-exp(-j*tau*omega))./omega/j;
        % Stellen mit Grenzwert überschreiben, an denen omega=omega_0 war
        output(zeros_in_omega)=tau;
    elseif strcmp(time_func,'triangpuls')
        % Anstiegszeit (in s) -> Skalar
        t_rise=parameter(1);
        % Abfallszeit (in s) -> Skalar
        t_fall=parameter(2);
        % prüfen, wann omega Null ist -> Zeilenvektor
        zeros_in_omega=find(omega==0);
        % omega an diesen Stellen auf 1 setzen
        omega(zeros_in_omega)=1;
        % Spektrum berechnen (in Vs/m) -> Vektor
        output=1./omega.^2.*(-1/t_rise+(1/t_rise+1/t_fall)*exp(-j*omega*t_rise)-1/t_fall*exp(-j*omega*(t_rise+t_fall)));
        % Stellen mit Grenzwert überschreiben, an denen omega=omega_0 war
        output(zeros_in_omega)=1/2*(t_rise+t_fall);
    elseif strcmp(time_func,'trapezpuls')
        % Anstiegszeit (in s) -> Skalar
        t_rise=parameter(1);
        % Haltezeit (in s) -> Skalar
        t_top=parameter(2);
        % Abfallszeit (in s) -> Skalar
        t_fall=parameter(3);
        % prüfen, wann omega Null ist -> Zeilenvektor
        zeros_in_omega=find(omega==0);
        % omega an diesen Stellen auf 1 setzen
        omega(zeros_in_omega)=1;
        % Spektrum berechnen (in Vs/m) -> Vektor
        output=1./omega.^2.*((exp(-j*omega*t_rise)-1)/t_rise+(exp(-j*omega*(t_rise+t_top))-exp(-j*omega*(t_rise+t_top+t_fall)))/t_fall);
        % Stellen mit Grenzwert überschreiben, an denen omega=omega_0 war
        output(zeros_in_omega)=1/2*(t_rise+t_fall)+t_top;
    else
        error(['The time function ',time_func,' is unknown.'])
    end
    % mit Amplitude skalieren
    output=E_0*output;
end