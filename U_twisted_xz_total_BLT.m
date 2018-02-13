% Funktion zur Berechnung der Terminal Responses einer Twisted-Pair-Leitung
% mit Hilfe der BLT-Gleichung
% Anregung erfolgt durch eine ebene Welle
% basiert auf:
% "Plane Wave Coupling to Cables" von Frederic M. Tesche 
% Autor: Mathias Magdowski
% Datum: 2009-02-03
% eMail: mathias.magdowski@ovgu.de

% die Leitung zeigt in x-Richtung
% der Hinleiter beginnt bei z=s/2, y=0
% der Rückleiter beginnt bei z=-s/2, y=0
% der Anfang bei x=0
% das Ende ist bei x=l

% Optionen:
% allgemeine Konstanten:
    % f       - Frequenz (in Hz) -> Skalar
    % mu      - Permeabilität (in Vs/Am) -> Skalar
    % epsilon - Permittivität (in As/Vm) -> Skalar
% Daten der Doppelleitung
    % s   - Abstand der Leiter (in m) -> Skalar
    % l   - Länge der Leitung (in m) -> Skalar
    % P   - Länge einer Verdrillung (in m) -> Skalar
% Daten der einfallenden Welle
    % E_0   - Feldstärke des E-Feldes (in V/m) -> Skalar
    % beta  - Phasenwinkel (in rad) -> Skalar
    % k_vector - Wellenvektor, normiert -> Spaltenvektor(3,1)
    % e_vector - E-Feld-Vektor, normiert -> Spaltenvektor(3,1)
% Abschlusswiderstände
    % Z_1_n - Abschlusswiderstand am Anfang (normiert auf Z_c) -> Skalar
    % Z_2_n - Abschlusswiderstand am Ende (normiert auf Z_c) -> Skalar

function output=U_twisted_xz_total_BLT(f,mu,epsilon,s,l,P,E_0,beta,k_vector,e_vector,Z_1_n,Z_2_n)
    % prüfen, ob die f ungleich Null ist
    if f==0
        output=0;
    else
        % Konstanten festlegen
        c=1/sqrt(mu*epsilon);   % Ausbreitungsgeschwindigkeit (in m/s) -> Skalar
        k=2*pi*f/c;             % Wellenzahl (in 1/m) -> Skalar
        
        % Verdrillungswinkel (in rad) -> Skalar
        delta=atan(P/(pi*s));
        % delta liegt zwischen 0 und 90°
        % wenn delta=90° -> keine Verdrillung
        % wenn delta=0° -> totale Verdrillung
        
        % Verdrillung am Ende (in rad) -> Skalar
        psi_L=2*pi*l/P;

        % dimensionslosen Wellenvektor skalieren (in 1/m) -> Spaltenvektor(3,1)
        k_vector=k_vector*k;

        % Anteile des Wellenvektor (in 1/m) -> Skalar
        k_x=k_vector(1);
        k_y=k_vector(2);
        k_z=k_vector(3);

        % Anteile der Richtung des E-Feldes -> Skalar
        e_x=e_vector(1);
        e_y=e_vector(2);
        e_z=e_vector(3);

        % Daten der Doppelleitung
        h=s/2;                  % halber Abstand, Abstand zwischen Leiter und gedachter Masseebene (in m) -> Skalar

        % Daten der einfallenden Welle
        E_i=E_0*exp(j*beta);    % einfallende Welle als komplexer Zeiger (in V/m) -> Skalar

        % Reflektionsfaktoren
        rho_1=(Z_1_n-1)/(Z_1_n+1);                    % Reflektionsfaktor am Anfang -> Skalar
        rho_2=(Z_2_n-1)/(Z_2_n+1);                    % Reflektionsfaktor am Ende -> Skalar

        % transversale Spannung am Anfang (in V) -> Skalar
        if k_z==0
            U_t1=2*E_i*e_z*h;
        else
            U_t1=2*E_i*e_z/k_z*sin(k_z*h);
        end
        
        % transversale Spannung am Ende (in V) -> Skalar
        if k_z==0 && k_y==0
            U_t2=2*E_i*(cos(psi_L)*e_z+sin(psi_L)*e_y)*h;
        elseif k_z==0 && k_y~=0
            U_t2=2*E_i*(cos(psi_L)*e_z*h+sin(psi_L)*e_y/k_y*sin(k_y*h));
        elseif k_z~=0 && k_y==0
            U_t2=2*E_i*(cos(psi_L)*e_z/k_z*sin(k_z*h)+sin(psi_L)*e_y*h);
        else
            U_t2=2*E_i*(cos(psi_L)*e_z/k_z*sin(k_z*h)+sin(psi_L)*e_y/k_y*sin(k_y*h));
        end
        
        % Spannungsbelag entlang der Leitung (in V/m) -> Skalar
        % Achtung, bei Tesche steht kein Minus vor dem ersten Summanden,
        % das liegt daran, das bei Tesche das k_y und k_z mit anderem
        % Vorzeichen definiert ist. Das ist aber inkonsequent zu den
        % Abbildungen
        Gamma_1=-j*k_y*s*E_i*e_x*sin(delta)-2*E_i*e_z*cos(delta);
        Gamma_2=-j*k_z*s*E_i*e_x*sin(delta)+2*E_i*e_y*cos(delta);
        
        % Ausbreitungskonstante der Welle (in 1/m) -> Skalar
        gamma=j*k;
        
        % modizifierte Ausbreitungskonstante (in 1/m) -> Skalar
        gamma_primed=gamma/sin(delta);
        
        % Hilfsgrößen (in 1/m) -> Skalar
        gamma_primed_p=gamma_primed+j*k_x;
        gamma_primed_m=gamma_primed-j*k_x;
                       
        % Term für Voltage Response -> Matrix(2,2)
        U_response=[1+rho_1,0;0,1+rho_2];
        
        % Term für Transmission Lines Resonances -> Matrix(2,2)
        % richtig
        resonanz=[-rho_1,exp(gamma_primed*l);exp(gamma_primed*l),-rho_2];
        % eigentlich falsch
        %resonanz=[-rho_1,exp(gamma*l);exp(gamma*l),-rho_2];
        
        % Anteil der konzentrierten Quellen (Lumped Sources)
        S_1_LS=1/2*(U_t1-U_t2*exp(gamma_primed_m*l));
        S_2_LS=-1/2*exp(gamma_primed*l)*(U_t1-U_t2*exp(-gamma_primed_p*l));
        % Anteil der verteilten Quellen entlang der Leitung (Distributed Sources)
        S_1_DS=P/(4*pi*sin(delta))/((P*gamma_primed_m/(2*pi))^2+1)*(Gamma_1*(exp(gamma_primed_m*l)*(P*gamma_primed_m/(2*pi)*sin(psi_L)-cos(psi_L))+1)+Gamma_2*(exp(gamma_primed_m*l)*(P*gamma_primed_m/(2*pi)*cos(psi_L)+sin(psi_L))-P*gamma_primed_m/(2*pi)));
        S_2_DS=P/(4*pi*sin(delta))*exp(gamma_primed*l)/((P*gamma_primed_p/(2*pi))^2+1)*(Gamma_1*(exp(-gamma_primed_p*l)*(P*gamma_primed_p/(2*pi)*sin(psi_L)+cos(psi_L))-1)+Gamma_2*(exp(-gamma_primed_p*l)*(P*gamma_primed_p/(2*pi)*cos(psi_L)-sin(psi_L))-P*gamma_primed_p/(2*pi)));

        % Quellvektor (in V) -> Spaltenvektor(1,2)
        source=[S_1_LS+S_1_DS;S_2_LS+S_2_DS];

        % Stromvektor (in A) -> Spaltenvektor(1,2)
        % Formel (52) aus [1]
        output=U_response*inv(resonanz)*source;
        
        % Debug
        %[rho_1,rho_2]
    end
end

% [1] Frederic M. Tesche, "Plane Wave Coupling to Cables", 49 pages
