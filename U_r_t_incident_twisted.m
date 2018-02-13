% Funktion zur Berechnung der einfallenden Spannung über der Zeit entlang
% einer verdrillten Leitung
% Anregung erfolgt durch eine ebene Welle mit beliebiger Zeitfunktion
% Autor: Mathias Magdowski
% Datum: 2012-01-16
% eMail: mathias.magdowski@ovgu.de

% Optionen:
% Allgemeine Konstanten
    % t - Zeit (in s) -> Zeilenvektor(1,T)
    % c - Lichtgeschwindigkeit (in m/s) -> Skalar    
% Daten der Doppelleitung
    % s - Abstand der Leiter (in m) -> Skalar
    % l - Länge der Leitung (in m) -> Skalar
% Daten der einfallenden Welle
    % E_0      - Feldstärke des E-Feldes (in V/m) -> Skalar
    % parameter - Parameter der Funktion
        % bei exppuls    -> Zeitkonstante tau (in s) -> Skalar
        % bei sinuspuls  -> Kreisfrequenz omega (in 1/s) und Anzahl der Perioden n_p -> Vektor(1,2)
        % bei sinus      -> Kreisfrequenz omega (in 1/s) -> Skalar
        % bei dblexppuls -> Parameter alpha und beta (in 1/s) -> Vektor(1,2)
        % bei sqrpuls    -> Pulsbreite tau (in s) -> Skalar
        % bei triangpuls -> Anstiegszeit und Abfallzeit (in s) -> Vektor(1,2)
        % bei trapezpuls -> Anstiegszeit, Haltezeit und Abfallzeit (in s) -> Vektor(1,3)
        % bei ramp       -> Anstiegszeit (in s) -> Skalar
        % bei step       -> leer
    % k_vector - Wellenvektor -> Spaltenvektor(3,1)
    % e_vector - E-Feldvektor -> Spaltenvektor(3,1)
% anregende Zeitfunktion
    % time_func - anregende Zeitfunktion -> String
        % exppuls    -> einfach-exponentieller Puls mit E_0 und tau
        % sinuspuls  -> Sinuspuls mit E_0, omega und n_p
        % sinus      -> eingeschalteter Sinus mit E_0 und omega
        % dblexppuls -> doppelt-exponentieller Puls mit E_0, alpha und beta
        % sqrpuls    -> Rechteckpuls mit E_0 und tau
        % triangpuls -> Dreieckpuls mit E_0, t_rise und t_fall
        % trapezpuls -> Trapezpuls mit E_0, t_rise, t_top und t_fall
        % ramp       -> Rampe mit E_0 und t_rise
        % step       -> Sprung mit E_0
% Art der Spannung/des Stromes:
    % typeof - Art der Spannung/des Stromes -> String
        % scattered -> Streuspannung (scattered voltage) (in V)
        % incident  -> einfallende Spannung (incident voltage) (in V)
        % total     -> Gesamtspannung (total voltage) (in V)
% Geometrie:
    % geometry - Geometrie -> String
        % xy -> Leitung in x-Richtung, Rück- zu Hinleiter in y-Richtung
        % yz -> Leitung in y-Richtung, Rück- zu Hinleiter in z-Richtung
        % zx -> Leitung in z-Richtung, Rück- zu Hinleiter in x-Richtung
% Diskretisierung:
    % d - Anzahl der Zellen pro Wellenlänge (optional, Standard=20) -> Skalar

function plots=U_r_t_incident_twisted(t,c,s,l,P,E_0,parameter,k_vector,e_vector,time_func,geometry,d)
    % prüfen, ob d gesetzt wurden, wenn nicht auf Standardwert setzen
    if nargin<=10
        d=1;
    end

    % Anzahl der überlagerten Wellen -> Skalar
    N=size(k_vector,2);
    
    % Feldstärke des E-Feldes normieren (in V/m) -> Skalar
    E=E_0/sqrt(N);
    
    % Anteile des normierten E-Feldvektors -> Skalar
    [e_tl,e_tr,e_or]=change_geometry(geometry,e_vector);

    % Verdrillungswinkel (in rad) -> Skalar
    delta=atan(P/(pi*s));
    % delta liegt zwischen 0 und 90°
    % wenn delta=90° -> keine Verdrillung
    % wenn delta=0° -> totale Verdrillung
    
    % neue Länge der verdrillten Leiter (in m) -> Skalar
    l_twisted=l/sin(delta);
    
    % Anzahl der Zeitschritte -> Skalar
    T=length(t);

    % Zeitschritt (in s) -> Skalar
    Delta_t=t(2)-t(1);

    % minimale Wellenlänge (in m) -> Skalar
    lambda_min=c*Delta_t;

    % Anzahl der örtlichen Diskretisierungsschritte -> Skalar
    R=ceil(d*l_twisted/lambda_min)+1;

    % Ortsbereich für die Auswertung -> Matrix(3,2*R+2);
    r_vector=r_vector_tl_twisted(0,l,P,R,geometry,'linspace');
    
    % Richtung tangential zur Leitung -> Vektor(3,R)
    r_tl=change_geometry(geometry,r_vector);    
    
    % anregende Zeitfunktion -> Funktions-Handle
    if strcmp(time_func,'exppuls')
        tau=parameter;
        zeitfunktion=@(t) h(t).*exp(-t.*h(t)/tau);
    elseif strcmp(time_func,'sinuspuls')
        % Sinuspuls
        omega=parameter(1);
        n_p=parameter(2);
        zeitfunktion=@(t) sin(omega*t).*(h(t)-h(t-n_p*2*pi/omega));
    elseif strcmp(time_func,'sinus')
        omega=parameter;
        zeitfunktion=@(t) sin(omega*t).*h(t);
    elseif strcmp(time_func,'dblexppuls')
        alpha=parameter(1);
        beta=parameter(2);        
        zeitfunktion=@(t) h(t).*(exp(-alpha*t.*h(t))-exp(-beta*t.*h(t)));
    elseif strcmp(time_func,'sqrpuls')
        tau=parameter(1);
        zeitfunktion=@(t) h(t)-h(t-tau);
    elseif strcmp(time_func,'triangpuls')
        t_rise=parameter(1);
        t_fall=parameter(2);
        zeitfunktion=@(t) h(t).*t/t_rise-(1/t_rise+1/t_fall)*h(t-t_rise).*(t-t_rise)+1/t_fall*h(t-t_rise-t_fall).*(t-t_rise-t_fall);
    elseif strcmp(time_func,'trapezpuls')
        t_rise=parameter(1);
        t_top=parameter(2);
        t_fall=parameter(3);
        zeitfunktion=@(t) (h(t).*t-h(t-t_rise).*(t-t_rise))/t_rise-(h(t-t_rise-t_top).*(t-t_rise-t_top)-h(t-t_rise-t_top-t_fall).*(t-t_rise-t_top-t_fall))/t_fall;
    elseif strcmp(time_func,'ramp')
        t_rise=parameter;
        zeitfunktion=@(t) (h(t).*t-h(t-t_rise).*(t-t_rise))/t_rise;
    elseif strcmp(time_func,'step')
        zeitfunktion=@(t) h(t);
    else
        error(['The time_func ',time_func,' is unknown.']);
    end
    
    % Speicherplatz vorbelegen -> Matrix(R,T)
    plots=zeros(R,T);
    
    % Ortspunkte entlang der Leitung als Schleife durchlaufen
    for r=1:R
        % Argument der Zeitfunktion -> Matrix(T,N)
        argument=t'*ones(1,N)-ones(T,1)*dot(k_vector,r_vector(1:3,r)*ones(1,N))/c;
        % elektrische Feldstärke (in V/m) -> Matrix(T,N)
        E_or=-E*ones(T,1)*e_or.*zeitfunktion(argument);
        % Anmerkung: Die orthogonale or-Richtung zeigt nach vorn,
        % die y-Richtung bei Tesche aber nach hinten, deshalb kommt
        % es zur Vorzeichenumkehr.
        E_tr=E*ones(T,1)*e_tr.*zeitfunktion(argument);
        % Verdrehwinkel (in rad) -> Skalar
        psi=2*pi*r_tl(r)/P;        
        % transversaler Vektor -> Skalar
        t_or=sin(psi);
        t_tr=cos(psi);
        % Näherung der Integrale U_t1 und U_t2 für k*h<<1 für mehrere Wellen -> Matrix(R,T)
        plots(r,1:T)=-s*sum(+E_or*t_or+E_tr*t_tr,2);
    end
end