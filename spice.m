% Funktion für den Netzwerksimulator SPICE
% Berechung der Einkopplung in eine Leitung im Zeitbereich für 
% mehrere überlagerte Wellen einer elektromagnetischen Randbedingung
% Autor: Mathias Magdowski
% Datum: 2008-10-17
% eMail: mathias.magdowski@ovgu.de

% Netzlisten-Syntax:
%
% Optionen:
% Syntax: Zeitschritte Delta_t
%         Ortsschritte Delta_r
% Zeitschritte --> Anzahl der Zeitschritte
% Delta_t --> Integrationsschritt
% Ortsschritte --> Anzahl der Ortspunkte
% Delta_r --> Länge einer Zelle
%
% Plot-Optionen:
% Syntax: Modus Nummer1 Nummer2 Grid
% Modus --> Wert der geplottet werden soll
%   1 -- U (Quelle)
%   2 -- I (Quelle)
%   3 -- u_K (Knotenspannung)
%   4 -- I_v (Zweigstrom)
%   5 -- U_v (Zweigspannung)
%   6 -- I_v und J (Zweigstrom + Quelle)
%   7 -- Knotenspannungen entlang der Leitung
%       Nummer1 -> Startknoten
%       Nummer2 -> Schrittweite von Knoten zu Knoten
%   8 -- Zweigströme + Quelle entlang der Leitung
%       Nummer1 -> Startzweig
%       Nummer2 -> Schrittweite von Zweig zu Zweig
%       (wird benutzt, wenn die Leitung verlustlos ist)
%   9 -- Zweigströme entlang der Leitung
%       Nummer1 -> Startzweig
%       Nummer2 -> Schrittweite von Zweig zu Zweig
%       (wird benutzt, wenn die Leitung verlustbehaftet ist)
% Nummer1 --> Index
% Nummer2 --> Index
% Grid --> Gitternetz (1 = an, 0 = aus)
%
% U - ideale Spannungsquelle
% Syntax: U Knoten1 Knoten2 Wert1 Form Zeit/Frequenz
% Knoten1 --> positive Pol
% Knoten2 --> negativer Pol, Masse
% Wert1 --> Spitzenwert der Spannung
% Form --> Form der Spannung
%   1 -- Sinus
%   2 -- Trapezförmiger Puls
%   3 -- Rechteckförmiger Puls
%   4 -- Rampenförmiger Puls
%   5 -- tangentiales Feld aus MVK (mit beliebiger Zeitfunktion)
%   6 -- transversales Feld aus MVK (mit beliebiger Zeitfunktion)
% Zeit/Frequenz --> Freqenz oder Zeitkonstante
%   bei 1 -- Frequenz
%   bei 2 -- Breite des Pulses
%   bei 3 -- Breite des Pulses
%   bei 4 -- Anstiegszeit
%   bei 5 und 6 -- Ortsindex der MVK-Feldes
% Spannungspfeil zeigt von Knoten1 zu Knoten2
%
% I - ideale Stromquelle
% Syntax: I Knoten1 Knoten2 Wert Dummy Dummy
% Wert1 --> Spitzenwert der Spannung
% Form --> Form der Spannung
%   1 -- Sinus
%   2 -- Trapezförmiger Puls
%   3 -- Rechteckförmiger Puls
%   4 -- Rampenförmiger Puls
% Zeit/Frequenz --> Freqenz oder Zeitkonstante
%   bei 1 -- Frequenz
%   bei 2 -- Breite des Pulses
%   bei 3 -- Breite des Pulses
%   bei 4 -- Anstiegszeit
% Stromrichtung zeigt von Knoten1 zu Knoten2
%
% J - stromgesteuerte Stromquelle (ohne Verzögerung)
% Syntax: F Knoten1 Knoten2 Bezug Faktor Dummy
% Stromrichtung zeigt von Knoten1 zu Knoten2
% Bezug ist die Nummer des zugehörigen Strommessers
% Faktor gibt den Verstärkungsfaktor F/Bezug an
%
% K - spannungsgesteuerte Stromquelle (ohne Verzögerung)
% Syntax: G Knoten1 Knoten2 Bezugsknoten1 Bezugsknoten2 Faktor
% Stromrichtung zeigt von Knoten1 zu Knoten2
% Bezugsknoten1 gibt die positive Knotenspannung an
% Bezugsknoten2 gibt die negative Knotenspannung/Masse an
% Bezugsspannungspfeil zeigt von Bezugsknoten1 zu Bezugsknoten2
% Faktor gibt den Verstärkungsfaktor G/(Bezugsknoten1-Bezugsknoten2) 
% in S an 
%
% R - Widerstand
% Syntax: R Knoten1 Knoten2 Wert Dummy Dummy
%
% G - Leitwert
% Syntax: G Knoten1 Knoten2 Wert Dummy Dummy
%
% L - Induktivität
% Syntax: L Knoten1 Knoten2 Wert Verfahren Dummy
% Verfahren --> Wahl des Integrationsverfahren
%   0 -- implizite Trapezformel
%   1 -- implizite Eulerformel
%   2 -- explizite Eulerformel (noch nicht fertig implementiert)
%  
% C - Kapazität
% Syntax: C Knoten1 Knoten2 Wert Verfahren Dummy
% Verfahren --> Wahl des Integrationsverfahren
%   0 -- implizite Trapezformel
%   1 -- implizite Eulerformel
%   2 -- explizite Eulerformel (noch nicht fertig implementiert)
%
% S - Skin-Effekt-Modell
% Syntax: S Knoten1 Knoten2 R_0 tau_c Dummy
% R_0 --> Gleichstromwiderstand
% tau_c --> Knickzeitkonstante, tau_c=2/omega_c, omega_c=R_0/L_0,
%
% A - Strommesser
% Syntax: A Knoten1 Knoten2 Bezug Dummy Dummy
% Stromrichtung zeigt von Knoten1 zu Knoten2
% Bezug ist eine frei wählbare Nummer
% Bezug entspricht z.B. beim PEEC-Modell der Nummer der PEEC-Zelle
% (der Strommesser entspricht einer Spannungsquelle mit Spannung U=0)
%
% D - Diode
% Syntax: D Knoten1 Knoten2 I_S U_T Dummy
% Knoten1 -> Eingangsknoten
% Knoten2 -> Ausgangsknoten
% I_S     -> Sättigungssperrstrom (kurz: Sperrstrom) I_S ~ 1e-12 ... 1-e6 A
% U_T     -> Temperaturspannung U_T ~ 25e-3 V bei Raumtemperatur
% Die Stromrichtung zeigt von Knoten1 zu Knoten2.
% Als Modell wird eine ideale Diode (Shockley-Gleichung) verwendet.

% Optionen:
    % netlist_name - Dateiname der Netzliste -> String
    % E_0          - kammerspezifische Konstante (in V/m) -> Skalar
    % e_vector     - normierter E-Feldvektor in x,y,z-Koordinaten -> Matrix(3,N)
    % k_vector     - normierter Wellenvektor in x,y,z-Koordinaten -> Matrix(3,N)
    % r_vector     - Ortsbereich für die Auswertung (in m) -> Matrix(3,R)
    % t_beta       - Zeitverschiebung (in s) -> Zeilenvektor(1,N)
    % time_func    - anregende Zeitfunktion -> String
        % exppuls    -> einfach-exponentieller Puls mit E_0 und tau
        % sinuspuls  -> Sinuspuls mit E_0, omega und n_p
        % sinus      -> eingeschalteter Sinus mit E_0 und omega
        % dblexppuls -> doppelt-exponentieller Puls mit E_0, alpha und beta
        % sqrpuls    -> Rechteckpuls mit E_0 und tau
        % triangpuls -> Dreieckpuls mit E_0, t_rise und t_fall
        % trapezpuls -> Trapezpuls mit E_0, t_rise, t_top und t_fall
        % ramp       -> Rampe mit E_0 und t_rise
        % step       -> Sprung mit E_0
    % parameter    - Parameter der Zeitfunktion
        % bei exppuls    -> Zeitkonstante tau (in s) -> Skalar
        % bei sinuspuls  -> Kreisfrequenz omega (in 1/s) und Anzahl der Perioden n_p -> Vektor(1,2)
        % bei sinus      -> Kreisfrequenz omega (in 1/s) -> Skalar
        % bei dblexppuls -> Parameter alpha und beta (in 1/s) -> Vektor(1,2)
        % bei sqrpuls    -> Pulsbreite tau (in s) -> Skalar
        % bei triangpuls -> Anstiegszeit und Abfallzeit (in s) -> Vektor(1,2)
        % bei trapezpuls -> Anstiegszeit, Haltezeit und Abfallzeit (in s) -> Vektor(1,3)
        % bei ramp       -> Anstiegszeit (in s) -> Skalar
        % bei step       -> leer
    % geometry     - Geometrie der Leitung -> String
        % xy -> Leitung in x-Richtung, Rück- zu Hinleiter in y-Richtung
        % yz -> Leitung in y-Richtung, Rück- zu Hinleiter in z-Richtung
        % zx -> Leitung in z-Richtung, Rück- zu Hinleiter in x-Richtung
    % abortable    - Script ist abbrechbar durch eine globale Variable 'cancel' -> Boolean

% Ausgabe:
    % t        -> Vektor mit Zeitschritten -> Zeilenvektor(1,N_t)
    % plots    -> Lösung über der Zeit -> Matrix(X,T)
    % comptime -> benötigte Zeit zur Berechnung (in s) -> Skalar
        
function [t,plots,comptime]=spice(netlist_name,E_0,c,e_vector,k_vector,r_vector,t_beta,time_func,parameter,geometry,abortable,P)
    % prüfen, ob P gesetzt wurde, wenn nicht auf Standardwert setzen
    if (nargin<=11)
        P=Inf;
    end
    
    % prüfen, ob abortable gesetzt wurde, wenn nicht auf Standardwert setzen
    if (nargin<=10)
        abortable=false;
    end
    
    % Starzeit (in s) -> Skalar
    starttime=cputime;
    
    % Abbruchvariable in jedem Fall als globale Variable definieren
    global cancel
    
    % Statusbar anzeigen -> Skalar
    show_status=1;
    
    % Ergebnis plotten
    show_plots=0;

    % Anzahl der überlagerten Wellen
    N=size(k_vector,2);
    
    % Feldstärke des E-Feldes normieren (in V/m) -> Skalar
    E=E_0/sqrt(N);
    
    % Anteile des normierten E-Feldvektors -> Skalar
    [e_tl,e_tr,e_or]=change_geometry(geometry,e_vector);
    
    % anregende Zeitfunktion -> Funktions-Handle
    if strcmp(time_func,'exppuls')
        % einfach-exponentieller Puls
        tau=parameter;
        zeitfunktion=@(t) h(t).*exp(-t.*h(t)/tau);
    elseif strcmp(time_func,'sinuspuls')
        % Sinuspuls
        omega=parameter(1);
        n_p=parameter(2);
        zeitfunktion=@(t) sin(omega*t).*(h(t)-h(t-n_p*2*pi/omega));
    elseif strcmp(time_func,'sinus')
        % eingeschalteter Sinus
        omega=parameter;
        zeitfunktion=@(t) sin(omega*t).*h(t);
    elseif strcmp(time_func,'dblexppuls')
        % doppelt-exponentieller Puls
        alpha=parameter(1);
        beta=parameter(2);        
        zeitfunktion=@(t) h(t).*(exp(-alpha*t.*h(t))-exp(-beta*t.*h(t)));
    elseif strcmp(time_func,'sqrpuls')
        % Rechteck-Puls
        tau=parameter(1);
        zeitfunktion=@(t) h(t)-h(t-tau);
    elseif strcmp(time_func,'triangpuls')
        % Dreieck-Puls
        t_rise=parameter(1);
        t_fall=parameter(2);
        zeitfunktion=@(t) h(t).*t/t_rise-(1/t_rise+1/t_fall)*h(t-t_rise).*(t-t_rise)+1/t_fall*h(t-t_rise-t_fall).*(t-t_rise-t_fall);
    elseif strcmp(time_func,'trapezpuls')
        % Trapezpuls
        t_rise=parameter(1);
        t_top=parameter(2);
        t_fall=parameter(3);
        zeitfunktion=@(t) (h(t).*t-h(t-t_rise).*(t-t_rise))/t_rise-(h(t-t_rise-t_top).*(t-t_rise-t_top)-h(t-t_rise-t_top-t_fall).*(t-t_rise-t_top-t_fall))/t_fall;
    elseif strcmp(time_func,'ramp')
        % Rampe
        t_rise=parameter;
        zeitfunktion=@(t) (h(t).*t-h(t-t_rise).*(t-t_rise))/t_rise;
    elseif strcmp(time_func,'step')
        % Sprung
        zeitfunktion=@(t) h(t);
    else
        error(['The time_func ',time_func,' is unknown.']);
    end

    % Netzliste einlesen
    % Datei öffnen -> Datei
    netlist_file=fopen(netlist_name,'r');
    % allgemeine Optionen einlesen (Zeitschritte, Schrittweite) -> Matrix(3 Zeilen,2 Spalten)
    options=fscanf(netlist_file,'%g %g\n',[2, 2])';
    % Plot-Liste einlesen (Modus Nummer1 Nummer2 Grid) -> Matrix(beliebig viele Zeilen, 4 Spalten)
    plot_liste=fscanf(netlist_file,'%d %d %d %d\n',[4, inf])';
    % Netzliste einlesen (Bauelement, Knoten 1, Knoten 2, Wert1, Wert2, Wert3) -> Matrix(beliebig viele Zeilen, 6 Spalten)
    netlist=fscanf(netlist_file,'%s %d %d %g %g %g\n',[6, inf])';
    fclose(netlist_file);      % Datei schließen
    % größte Knotennummer bestimmen -> Skalar
    highest_node=max(max(netlist(:,2:3)));

    % Netzliste sortieren
    netlist=sortrows(netlist);  

    % Netzliste aufteilen
    % für I - ideale Stromquelle
    I_first=find(netlist(:,1)=='I',1,'first');
    I_last=find(netlist(:,1)=='I',1,'last');
    I_list=netlist(I_first:I_last,:);
    N_I=size(I_list,1);
    % für R - Widerstand
    R_first=find(netlist(:,1)=='R',1,'first');
    R_last=find(netlist(:,1)=='R',1,'last');
    R_list=netlist(R_first:R_last,:);
    % für G - Leitwert
    G_first=find(netlist(:,1)=='G',1,'first');
    G_last=find(netlist(:,1)=='G',1,'last');
    G_list=netlist(G_first:G_last,:);
    % für L - Induktivität
    L_first=find(netlist(:,1)=='L',1,'first');
    L_last=find(netlist(:,1)=='L',1,'last');
    L_list=netlist(L_first:L_last,:);
    N_L=size(L_list,1);
    % für C - Kapazität
    C_first=find(netlist(:,1)=='C',1,'first');
    C_last=find(netlist(:,1)=='C',1,'last');
    C_list=netlist(C_first:C_last,:);
    N_C=size(C_list,1);
    % für S - Skineffekt-Modell
    S_first=find(netlist(:,1)=='S',1,'first');
    S_last=find(netlist(:,1)=='S',1,'last');
    S_list=netlist(S_first:S_last,:);
    N_S=size(S_list,1);
    % für D - Diode
    D_first=find(netlist(:,1)=='D',1,'first');
    D_last=find(netlist(:,1)=='D',1,'last');
    D_list=netlist(D_first:D_last,:);
    N_D=size(D_list,1);    
    % für R,G,L,C,S,D
    RGLCSD_list=[I_list;R_list;G_list;L_list;C_list;S_list;D_list];
    N_RGLCSD=size(RGLCSD_list,1);
    % für A - Strommesser
    A_first=find(netlist(:,1)=='A',1,'first');
    A_last=find(netlist(:,1)=='A',1,'last');
    A_list=netlist(A_first:A_last,:);
    % für U - ideale Spannungsquelle
    U_first=find(netlist(:,1)=='U',1,'first');
    U_last=find(netlist(:,1)=='U',1,'last');
    U_list=netlist(U_first:U_last,:);
    N_U=size(U_list,1);    
    % für K - spannungsgesteuerte Stromquelle (ohne Verzögerung)
    K_first=find(netlist(:,1)=='K',1,'first');
    K_last=find(netlist(:,1)=='K',1,'last');
    K_list=netlist(K_first:K_last,:);
    % für A,U,K
    AUK_list=[U_list;A_list;K_list];
    N_AUK=size(AUK_list,1);
    % für J - stromgesteuerte Stromquelle (ohne Verzögerung)
    J_first=find(netlist(:,1)=='J',1,'first');
    J_last=find(netlist(:,1)=='J',1,'last');
    J_list=netlist(J_first:J_last,:);
    N_J=size(J_list,1);

    % Anzahl der Zeitschritte -> Skalar
    N_t=options(1,1);
    % Integrationsschritt in s -> Skalar
    Delta_t=options(1,2);
    % Anzahl der Zellen -> Skalar
    N_r=options(2,1);
    % Länge einer Zelle im Leitungsmodell (in m) -> Skalar
    Delta_r=options(2,2);
    % Richtung tangential und transversal zur Leitung -> Vektor(3,R)
    [r_tl,r_tr]=change_geometry(geometry,r_vector);
    % Abstand der Leiter (in m) -> Skalar
    s=r_tr(1)-r_tr(N_r+1);
    % Vektor mit Zeitschritten erstellen -> Zeilenvektor(1,N_t)
    t=0:Delta_t:(N_t-1)*Delta_t;
    
    % Verdrillungswinkel einer verdrillten Leitung (in rad) -> Skalar
    delta=atan(P/(pi*s));
    % delta liegt zwischen 0 und 90°
    % wenn delta=90° -> keine Verdrillung
    % wenn delta=0° -> totale Verdrillung

    % leere Admittanzmatrix erstellen
    Y=zeros(highest_node+N_AUK);
    % leere Zweigleitwertmatrix erstellen
    G_v=zeros(N_RGLCSD,N_RGLCSD);
    % leere Inzidenzmatrix erstellen
    B=zeros(N_RGLCSD,highest_node);
    % leeren Bezugsvektor erstellen
    A=zeros(1,max(A_list(:,4)));
    
    % leere Matrix für unabhängige Spannungsquellen erstellen
    U=zeros(N_U,N_t);
    % leere Matrix für unabhängige Stromquellen erstellen
    I=zeros(N_I,N_t);
    
    % Zähler für S (Skineffekt-Modelle) zurücksetzen
    n_S=0;

    % Matrizen füllen
    if show_status==1
        % Statusbar anzeigen
        wb=waitbar(0,'MNA-Matrix wird gefüllt...');
    end
    
    % Schleife über alle R,L,C,G,S,D
    for k=1:N_RGLCSD
        typ=char(RGLCSD_list(k,1));
        node1=RGLCSD_list(k,2);
        node2=RGLCSD_list(k,3);
        value1=RGLCSD_list(k,4);
        value2=RGLCSD_list(k,5);
        if typ=='R'
            % Widerstand
            G=1/value1;
        elseif typ=='G'
            % Leitwert
            G=value1;
        elseif typ=='L'
            % Induktivität
            if value2==0
                % implizite Trapezformel
                G=Delta_t/(2*value1);    
            elseif value2==1
                % implizite Eulerformel
                G=Delta_t/value1;        
            else 
                % explizite Eulerformel
                G=0;
            end
        elseif typ=='C'
            % Kapazität
            if value2==0
                % implizite Trapezformel
                G=2*value1/Delta_t;
            elseif value2==1
                % implizite Eulerformel
                G=value1/Delta_t;
            else
                % explizite Eulerformel
                G=inf;
            end
        elseif typ=='S'
            % Skineffekt-Modell
            % Zähler für S erhöhen
            n_S=n_S+1;
            % nur eine Omega-Matrix erstellen, weil alle Skin-Effekt-Elemente gleich sind
            if n_S==1
                % Omega(k) erstellen
                R_0=value1;      % Gleichstromwiderstand
                tau_c=value2;    % Knickzeitkonstante
                p=1;            % Anfang
                q=N_t;            % Ende
                n=N_t-1;
                % Handle für T erstellen
                T=@(n,l) t(n)-t(l);
                % Handle für Psi erstellen
                Psi=@(n,l) exp(-T(n,l)/tau_c);
                % Handle für Phi erstellen
                Phi=@(n,l) erf(sqrt(T(n,l)/tau_c));
                % Speicherplatz vorbelegen
                Omega=zeros(1,q-p+1);
                for l=p:q        
                    if l==p
                        Omega(n_S,l)=1/(R_0*Delta_t)*(-(sqrt(tau_c*T(n+1,l)/pi)*Psi(n+1,l)) + ((-T(n+1,l)+Delta_t+(tau_c/2))*Phi(n+1,l))  +  (sqrt(tau_c*T(n,l)/pi)*Psi(n,l)) - ((-T(n+1,l)+Delta_t+(tau_c/2))*Phi(n,l)));          
                    elseif l==q
                        Omega(n_S,l)=1/(R_0*Delta_t)*((sqrt(tau_c*T(n+1,l-1)/pi)*Psi(n+1,l-1)) + ((T(n+1,l-1)-(tau_c/2))*Phi(n+1,l-1))  -  (sqrt(tau_c*T(n,l-1)/pi)*Psi(n,l-1)) - ((T(n+1,l-1)-(tau_c/2))*Phi(n,l-1)));
                    else
                        Omega(n_S,l)=1/(R_0*Delta_t)*(-(sqrt(tau_c*T(n+1,l)/pi)*Psi(n+1,l)) + ((-T(n+1,l)+Delta_t+(tau_c/2))*Phi(n+1,l))  +  (sqrt(tau_c*T(n,l)/pi)*Psi(n,l)) - ((-T(n+1,l)+Delta_t+(tau_c/2))*Phi(n,l))   +   (sqrt(tau_c*T(n+1,l-1)/pi)*Psi(n+1,l-1)) + ((T(n+1,l-1)-(tau_c/2))*Phi(n+1,l-1))  -  (sqrt(tau_c*T(n,l-1)/pi)*Psi(n,l-1)) - ((T(n+1,l-1)-(tau_c/2))*Phi(n,l-1)));
                    end
                end   
            elseif n_S>1
                %Omega(n_S,1:N_t)=Omega(1,1:N_t);
            end
            %G=Omega(n_S,q);
            G=Omega(1,q);
        elseif typ=='D'
            % Diode
            G=0;
        end
        % Matrix mit Zweigleitwerten
        G_v(k,k)=G;
        if node1~=0 
            % Admittanzmatrix
            Y(node1,node1)=Y(node1,node1)+G;
            % Inzidenzmatrix
            B(k,node1)=1;
        end
        if node2~=0 
            % Admittanzmatrix
            Y(node2,node2)=Y(node2,node2)+G;
            % Inzidenzmatrix
            B(k,node2)=-1;
        end
        if node1~=0 && node2~=0 
            % Admittanzmatrix
            Y(node1,node2)=Y(node1,node2)-G;
            Y(node2,node1)=Y(node2,node1)-G;
        end
        % Abbruchbedingung prüfen
        if abortable==true && cancel==true
            break;
        end
        if show_status==1
            % Statusbar aktualisieren
            waitbar(k/(N_RGLCSD+N_AUK+N_I+N_J),wb,'MNA-Matrix wird gefüllt (RGLCSD)...');
        end
    end
    % Zähler für U zurücksetzen
    n_U=0;
    % Schleife über alle A,U,K
    for k=1:N_AUK
        typ=char(AUK_list(k,1));
        node1=AUK_list(k,2);
        node2=AUK_list(k,3);
        value1=AUK_list(k,4);
        value2=AUK_list(k,5);
        value3=AUK_list(k,6);
        if typ=='U'
            % ideale Spannungsquelle
            % Zähler für U (unabhängige Quellen) erhöhen
            n_U=n_U+1;
            % Vektor mit Zeitverlauf der anregenden Spannung erstellen
            if value2==1
                % Sinus
                % Amplitude (in V) -> Skalar
                amp=value1;
                % Frequenz (in Hz) -> Skalar
                f=value3;
                % Kreisfrequenz (in 1/s) -> Skalar
                omega=2*pi*f;
                % Handle für Zeitverlauf erstellen
                sinus_t=@(t) amp*sin(omega*t);
                % Eintrag in Zeitverlaufs-Vektor
                U(n_U,1:N_t)=sinus_t(t);
            elseif value2==2
                % Trapezförmiger Puls
                % Höhe (in V) -> Skalar
                amp=value1;
                % Breite (in s) -> Skalar
                t_trapez=value3;
                % Anstiegszeit (in s) -> Skalar
                t_rise=0.25*t_trapez;
                % Spitzenzeit (in s) -> Skalar
                t_top=0.5*t_trapez;
                % Abfallzeit (in s) -> Skalar
                t_fall=0.25*t_trapez;
                % Handle für Zeitverlauf erstellen
                trapez_t=@(t) (amp*t/t_rise.*h(t))-(amp*(t-t_rise)/t_rise.*h(t-t_rise))-(amp*(t-t_rise-t_top)/t_fall.*h(t-t_rise-t_top))+(amp*(t-t_rise-t_top-t_fall)/t_fall.*h(t-t_rise-t_top-t_fall));
                % Eintrag in Zeitverlaufs-Vektor
                U(n_U,1:N_t)=trapez_t(t);
            elseif value2==3
                % Rechteckförmiger Puls
                % Höhe (in V) -> Skalar
                amp=value1;
                % Breite (in s) -> Skalar
                tau_rechteck=value3;
                % Handle für Zeitverlauf erstellen
                rechteck_t=@(t) amp*(h(t)-h(t-tau_rechteck));
                % Eintrag in Zeitverlaufs-Vektor
                U(n_U,1:N_t)=rechteck_t(t);
            elseif value2==4
                % Rampenförmiger Verlauf
                % Höhe (in V) -> Skalar
                amp=value1;
                % Anstiegszeit (in s) -> Skalar
                t_rampe=value3;
                % Handle für Zeitverlauf erstellen
                rampe_t=@(t) (amp*t/t_rampe.*h(t))-(amp*(t-t_rampe)/t_rampe.*h(t-t_rampe));
                % Eintrag in Zeitverlaufs-Vektor
                U(n_U,1:N_t)=rampe_t(t);
            elseif value2==5
                % tangentiales Feld aus der MVK
                % Amplitude
                amp=value1;
                % Ortsindex der MVK-Feldes
                index=value3;
                % Faktor -> Matrix(N_t,N)
                faktor=amp*ones(N_t,1)*E*e_tl*Delta_r;
                % Argument der Zeitfunktion am Hinleiter (in s) -> Matrix(N_t,N)
            	argument1=t'*ones(1,N)-ones(N_t,1)*dot(k_vector,r_vector(1:3,index)*ones(1,N))/c+ones(N_t,1)*t_beta;
                % Argument der Zeitfunktion am Rückleiter (in s) -> Matrix(N_t,N)
                argument2=t'*ones(1,N)-ones(N_t,1)*dot(k_vector,r_vector(1:3,index+N_r)*ones(1,N))/c+ones(N_t,1)*t_beta;
                % Anregung am Hin- und Rückleiter (in V) -> Zeilenvektor(1,N_t)
                U(n_U,1:N_t)=sum(faktor.*(zeitfunktion(argument1)-zeitfunktion(argument2)),2);            
            elseif value2==6
                % transversales Feld aus der MVK
                % Amplitude
                amp=value1;
                % Ortsindex der MVK-Feldes
                index=value3;
                % Faktor -> Matrix(N_t,N)
                faktor=amp*ones(N_t,1)*E*e_tr*s;                
                % Argument der Zeitfunktion (in s) -> Matrix(N_t,N)
            	argument=t'*ones(1,N)-ones(N_t,1)*dot(k_vector,r_vector(1:3,index)*ones(1,N))/c+ones(N_t,1)*t_beta;
                % Näherung der Integrale U_t1 und U_t2 für k*h<<1 für mehrere Wellen (in V) -> Zeilenvektor(1,N_t)
                U(n_U,1:N_t)=sum(faktor.*zeitfunktion(argument),2);
            elseif value2==7
                % tangentiales Feld aus der MVK
                % für eine verdrillte Leitung
                % Amplitude
                amp=value1;
                % Ortsindex der MVK-Feldes
                index=value3;
                % Verdrehwinkel (in rad) -> Skalar
                psi=2*pi*r_tl(index)/P;
                % Argument der Zeitfunktion am Hinleiter (in s) -> Matrix(N_t,N)
            	argument1=t'*ones(1,N)-ones(N_t,1)*dot(k_vector,r_vector(1:3,index)*ones(1,N))/c+ones(N_t,1)*t_beta;
                % Argument der Zeitfunktion am Rückleiter (in s) -> Matrix(N_t,N)
                argument2=t'*ones(1,N)-ones(N_t,1)*dot(k_vector,r_vector(1:3,index+N_r)*ones(1,N))/c+ones(N_t,1)*t_beta;
                % für eine Leitung in xz-Richtung
                %%{
                % elektrische Feldstärke am Hinleiter (in V/m)r -> Matrix(N_t,N)
                E_x_1=E*ones(N_t,1)*e_vector(1,N).*zeitfunktion(argument1);                
                E_y_1=E*ones(N_t,1)*e_vector(2,N).*zeitfunktion(argument1);
                E_z_1=E*ones(N_t,1)*e_vector(3,N).*zeitfunktion(argument1);
                % elektrische Feldstärke am Rückleiter (in V/m) -> Matrix(N_t,N)
                E_x_2=E*ones(N_t,1)*e_vector(1,N).*zeitfunktion(argument2);
                E_y_2=E*ones(N_t,1)*e_vector(2,N).*zeitfunktion(argument2);
                E_z_2=E*ones(N_t,1)*e_vector(3,N).*zeitfunktion(argument2);
                % tangentialer Vektor am Hinleiter -> Skalar
                tan_x_1=sin(delta);
                tan_y_1=cos(delta)*cos(psi);
                tan_z_1=-cos(delta)*sin(psi);
                % tangentialer Vektor am Rückleiter -> Skalar
                tan_x_2=sin(delta);
                tan_y_2=-cos(delta)*cos(psi);
                tan_z_2=cos(delta)*sin(psi);
                % Anregung am Hin- und Rückleiter (in V) -> Zeilenvektor(1,N_t)
                U(n_U,1:N_t)=amp*Delta_r*sum((E_x_1*tan_x_1+E_y_1*tan_y_1+E_z_1*tan_z_1)-(E_x_2*tan_x_2+E_y_2*tan_y_2+E_z_2*tan_z_2),2);
                %}
                % für eine Leitung in eine beliebige Richtung
                %{
                % elektrische Feldstärke am Hinleiter (in V/m)r -> Matrix(N_t,N)
                E_tl_1=E*ones(N_t,1)*e_tl.*zeitfunktion(argument1);                
                E_or_1=-E*ones(N_t,1)*e_or.*zeitfunktion(argument1);
                % Anmerkung: Die orthogonale or-Richtung zeigt nach vorn,
                % die y-Richtung bei Tesche aber nach hinten, deshalb kommt
                % es zur Vorzeichenumkehr.
                E_tr_1=E*ones(N_t,1)*e_tr.*zeitfunktion(argument1);
                % elektrische Feldstärke am Rückleiter (in V/m) -> Matrix(N_t,N)
                E_tl_2=E*ones(N_t,1)*e_tl.*zeitfunktion(argument2);
                E_or_2=-E*ones(N_t,1)*e_or.*zeitfunktion(argument2);
                E_tr_2=E*ones(N_t,1)*e_tr.*zeitfunktion(argument2);
                % tangentialer Vektor am Hinleiter -> Skalar
                tan_tl_1=sin(delta);
                tan_or_1=cos(delta)*cos(psi);
                tan_tr_1=-cos(delta)*sin(psi);
                % tangentialer Vektor am Rückleiter -> Skalar
                tan_tl_2=sin(delta);
                tan_or_2=-cos(delta)*cos(psi);
                tan_tr_2=cos(delta)*sin(psi);
                % Anregung am Hin- und Rückleiter (in V) -> Zeilenvektor(1,N_t)
                U(n_U,1:N_t)=amp*Delta_r*sum((E_tl_1*tan_tl_1+E_or_1*tan_or_1+E_tr_1*tan_tr_1)-(E_tl_2*tan_tl_2+E_or_2*tan_or_2+E_tr_2*tan_tr_2),2);
                %}
            elseif value2==8
                % transversales Feld aus der MVK
                % für eine verdrillte Leitung
                % Amplitude
                amp=value1;
                % Ortsindex der MVK-Feldes
                index=value3;
                % Verdrehwinkel (in rad) -> Skalar
                psi=2*pi*r_tl(index)/P;
                % Argument der Zeitfunktion (in s) -> Matrix(N_t,N)
            	argument=t'*ones(1,N)-ones(N_t,1)*dot(k_vector,r_vector(1:3,index)*ones(1,N))/c+ones(N_t,1)*t_beta;
                % für eine Leitung in xz-Richtung
                %%{
                % elektrische Feldstärke (in V/m) -> Matrix(N_t,N)
                E_y=E*ones(N_t,1)*e_vector(2,N).*zeitfunktion(argument);
                E_z=E*ones(N_t,1)*e_vector(3,N).*zeitfunktion(argument);
                % transversaler Vektor -> Skalar
                t_y=sin(psi);
                t_z=cos(psi);
                % Näherung der Integrale U_t1 und U_t2 für k*h<<1 für mehrere Wellen -> Zeilenvektor(1,N_t)
                U(n_U,1:N_t)=amp*s*sum(E_y*t_y+E_z*t_z,2);
                %}
                % für eine Leitung in eine beliebige Richtung
                %{
                % elektrische Feldstärke (in V/m) -> Matrix(N_t,N)
                E_or=-E*ones(N_t,1)*e_or.*zeitfunktion(argument);
                % Anmerkung: Die orthogonale or-Richtung zeigt nach vorn,
                % die y-Richtung bei Tesche aber nach hinten, deshalb kommt
                % es zur Vorzeichenumkehr.
                E_tr=E*ones(N_t,1)*e_tr.*zeitfunktion(argument);
                % transversaler Vektor -> Skalar
                t_or=sin(psi);
                t_tr=cos(psi);
                % Näherung der Integrale U_t1 und U_t2 für k*h<<1 für mehrere Wellen -> Zeilenvektor(1,N_t)
                U(n_U,1:N_t)=amp*s*sum(E_or*t_or+E_tr*t_tr,2);
                %}
            end
            if node1~=0 
                % Admittanzmatrix
                Y(node1,highest_node+k)=-1;
                Y(highest_node+k,node1)=1;
            end
            if node2~=0 
                % Admittanzmatrix
                Y(node2,highest_node+k)=1;
                Y(highest_node+k,node2)=-1;
            end
        elseif typ=='A'
            % Strommesser
            if node1~=0 
                % Admittanzmatrix
                Y(node1,highest_node+k)=1;
                Y(highest_node+k,node1)=1;
            end
            if node2~=0 
                % Admittanzmatrix
                Y(node2,highest_node+k)=-1;
                Y(highest_node+k,node2)=-1;
            end
            % Bezug in Bezugsmatrix A speichern
            A(value1)=highest_node+k;
        elseif typ=='K'
            % spannungsgesteuerte Stromquelle (ohne Verzögerung)
            if value1~=0 && node1~=0
                % Admittanzmatrix
                Y(node1,value1)=value3;
            end
            if value2~=0 && node1~=0
                % Admittanzmatrix
                Y(node1,value2)=-value3;
            end
            if value1~=0 && node2~=0
                % Admittanzmatrix
                Y(node2,value1)=-value3;
            end
            if value2~=0 && node2~=0
                % Admittanzmatrix
                Y(node2,value2)=value3;
            end
        end
        % Abbruchbedingung prüfen
        if abortable==true && cancel==true
            break;
        end
        if show_status==1
            % Statusbar aktualisieren
            waitbar((N_RGLCSD+k)/(N_RGLCSD+N_AUK+N_I+N_J),wb,'MNA-Matrix wird gefüllt (AUK)...');
        end
    end
    % Schleife über alle I
    for k=1:N_I
        value1=I_list(k,4);
        value2=I_list(k,5);        
        value3=I_list(k,6);        
        % Vektor mit Zeitverlauf des anregenden Stromes erstellen
        if value2==1
            % Sinus
            % Amplitude (in A) -> Skalar
            amp=value1;
            % Frequenz (in Hz) -> Skalar
            f=value3;
            % Kreisfrequenz (in 1/s) -> Skalar
            omega=2*pi*f;
            % Handle für Zeitverlauf erstellen
            sinus_t=@(t) amp*sin(omega*t);
            % Eintrag in Zeitverlaufs-Vektor
            I(k,1:N_t)=sinus_t(t);
        elseif value2==2
            % Trapezförmiger Puls
            % Höhe (in A) -> Skalar
            amp=value1;
            % Breite (in s) -> Skalar
            t_trapez=value3;
            % Anstiegszeit (in s) -> Skalar
            t_rise=0.25*t_trapez;
            % Spitzenzeit (in s) -> Skalar
            t_top=0.5*t_trapez;
            % Abfallzeit (in s) -> Skalar
            t_fall=0.25*t_trapez;
            % Handle für Zeitverlauf erstellen
            trapez_t=@(t) (amp*t/t_rise.*h(t))-(amp*(t-t_rise)/t_rise.*h(t-t_rise))-(amp*(t-t_rise-t_top)/t_fall.*h(t-t_rise-t_top))+(amp*(t-t_rise-t_top-t_fall)/t_fall.*h(t-t_rise-t_top-t_fall));
            % Eintrag in Zeitverlaufs-Vektor
            I(k,1:N_t)=trapez_t(t);
        elseif value2==3
            % Rechteckförmiger Puls
            % Höhe (in A) -> Skalar
            amp=value1;
            % Breite (in s) -> Skalar
            tau_rechteck=value3; 
            % Handle für Zeitverlauf erstellen
            rechteck_t=@(t) amp*(h(t)-h(t-tau_rechteck));
            % Eintrag in Zeitverlaufs-Vektor
            I(k,1:N_t)=rechteck_t(t);
        elseif value2==4
            % Rampenförmiger Verlauf
            % Höhe (in A) -> Skalar
            amp=value1;
            % Anstiegszeit (in s) -> Skalar
            t_rampe=value3;
            % Handle für Zeitverlauf erstellen
            rampe_t=@(t) (amp*t/t_rampe.*h(t))-(amp*(t-t_rampe)/t_rampe.*h(t-t_rampe));
            % Eintrag in Zeitverlaufs-Vektor
            I(k,1:N_t)=rampe_t(t);
        end
        % Abbruchbedingung prüfen
        if abortable==true && cancel==true
            break;
        end
        if show_status==1
            % Statusbar aktualisieren
            waitbar((N_RGLCSD+N_AUK+k)/(N_RGLCSD+N_AUK+N_I+N_J),wb,'MNA-Matrix wird gefüllt (I)...');
        end
    end    
    % Schleife über alle J
    % erzeugt Einträge in der Admittanzmatrix Y
    % greift auf die Bezugsmatrix A zu
    for k=1:N_J
        node1=J_list(k,2);
        node2=J_list(k,3);
        value1=J_list(k,4);
        value2=J_list(k,5);
        spalte=A(value1);
        if node1~=0
            % Admittanzmatrix
            Y(node1,spalte)=Y(node1,spalte)+value2;
        end
        if node2~=0
            % Admittanzmatrix
            Y(node2,spalte)=Y(node2,spalte)-value2;
        end
        % Abbruchbedingung prüfen
        if abortable==true && cancel==true
            break;
        end
        if show_status==1
            % Statusbar aktualisieren
            waitbar((N_RGLCSD+N_AUK+N_I+k)/(N_RGLCSD+N_AUK+N_I+N_J),wb,'MNA-Matrix wird gefüllt (J)...');
        end
    end
    if show_status==1
        close(wb);  % Statusbar schließen
    end

    % Matrizen darstellen, zu Debug-Zwecken
    %surf(U);
    %surf(U(:,1:50));
    
    % prüfen, ob Dioden vorhanden sind
    if N_D~=0
        % lineare Admittanzmatrix zwischenspeichern -> Matrix
        Y_linear=Y;
        % Speicherplatz vorbelegen
        G=zeros(1,N_D);
        old_G=zeros(1,N_D);
        I_D=zeros(1,N_D);
        I_eq=zeros(1,N_D);
    else
        % Y-Matrix einmal invertieren, damit diese Rechenzeit gespart ist
        Z=inv(Y);
    end
    
    % Speicherplatz vorbelegen, um den Schleifendurchlauf zu beschleunigen
    % Spaltenvektor der unabhängigen Quellen
    I_q=zeros(highest_node+N_AUK,N_t);
    % Spaltenvektor der Knotenspannungen
    u_K=zeros(highest_node+N_AUK,N_t);
    % Spaltenvektor der Zweigspannungen
    U_v=zeros(N_RGLCSD,N_t);
    % Spaltenvektor der Zweigströme
    I_v=zeros(N_RGLCSD,N_t);
    % Spaltenvektor der Quellen
    J=zeros(N_I+N_L+N_C+N_S,N_t);
    
    if show_status==1
        wb=waitbar(0,'Zeitverläufe berechnen...');  % Statusbar anzeigen
    end
    for n_t=1:N_t-1
        % Zähler der Iteration zur Simulation nichtlinearer Netzwerke zurücksetzen
        c=0;
        % Abbruchkriterium zurücksetzen
        convergence=false;
        % Konvergenz jeder Diode -> Zeilenvektor(1,N_D)
        D_convergence=zeros(1,N_D);
        % Schleife über alle Iterationen zur Simulation nichtlinearer Netzwerke
        while true
            % Zähler der Iteration zur Simulation nichtlinearer Netzwerke erhöhen
            c=c+1;
            %disp(['c=',int2str(c)]);            
            % Zähler für L,C,S,D zurücksetzen
            n_LCSD=0;
            % Zähler für S zurücksetzen
            n_S=0;
            % prüfen, ob Dioden vorhanden sind
            if N_D~=0
                % Zähler für Dioden zurücksetzen
                n_D=0;
                % Admittanzmatrix auf die lineare Admittanzmatrix zurücksetzen
                Y=Y_linear;
            end
            % Spaltenvektor der unabhängigen Quellen zurücksetzen
            I_q(:,n_t+1)=zeros(highest_node+N_AUK,1);
            % Schleife über alle R,L,C,G,S
            for k=1:N_RGLCSD
                typ=char(RGLCSD_list(k,1));
                node1=RGLCSD_list(k,2);
                node2=RGLCSD_list(k,3);
                value1=RGLCSD_list(k,4);
                value2=RGLCSD_list(k,5);
                if typ=='L'
                    % Induktivität            
                    % Zähler für L,C,S,D weiterzählen
                    n_LCSD=n_LCSD+1;
                    % Eintrag in Stromquellenvektor
                    if value2==0 
                        % implizite Trapezformel
                        J(n_LCSD,n_t+1)=Delta_t/(2*value1)*U_v(k,n_t)+I_v(k,n_t)+J(n_LCSD,n_t);
                    elseif value2==1
                        % implizite Eulerformel
                        J(n_LCSD,n_t+1)=I_v(k,n_t)+J(n_LCSD,n_t);
                    else
                        % explizite Eulerformel
                        J(n_LCSD,n_t+1)=I_v(k,n_t)+J(n_LCSD,n_t);
                    end 
                elseif typ=='C'
                    % Kapazität            
                    % Zähler für L,C,S,D weiterzählen
                    n_LCSD=n_LCSD+1;
                    % Eintrag in Stromquellenvektor
                    if value2==0 
                        % implizite Trapezformel
                        J(n_LCSD,n_t+1)=-2*value1/Delta_t*U_v(k,n_t)-I_v(k,n_t)-J(n_LCSD,n_t);
                    else
                        % implizite Eulerformel
                        J(n_LCSD,n_t+1)=-value1/Delta_t*U_v(k,n_t);
                    end
                    % eine explizite Eulerformel müsste durch eine ideale
                    % Spannungsquelle mit der Formel u(n_t+1)=Delta_t/C*k(n_t)+u(n_t)
                    % erzeugt werden
                elseif typ=='S'
                    % Skineffekt-Modell
                    % Zähler für S weiterzählen
                    n_S=n_S+1;
                    % Zähler für L,C,S,D weiterzählen
                    n_LCSD=n_LCSD+1;
                    % Eintrag in Stromquellenvektor
                    % exakte Lösung
                    J(n_LCSD,n_t+1)=(1/(R_0*Delta_t)*(-(sqrt(tau_c*T(n_t+1,1)/pi)*Psi(n_t+1,1)) + ((-T(n_t+1,1)+Delta_t+(tau_c/2))*Phi(n_t+1,1))  +  (sqrt(tau_c*T(n_t,1)/pi)*Psi(n_t,1)) - ((-T(n_t+1,1)+Delta_t+(tau_c/2))*Phi(n_t,1))))*U_v(i,1);
                    if n_t>1
                        %J(n_LCSD,n_t+1)=J(n_LCSD,n_t+1)+Omega(n_S,N_t-n_t+1:N_t-1)*U_v(i,2:n_t)';
                        J(n_LCSD,n_t+1)=J(n_LCSD,n_t+1)+Omega(1,N_t-n_t+1:N_t-1)*U_v(i,2:n_t)';
                    end
                elseif typ=='D'
                    % Diode
                    % Zähler für L,C,S,D weiterzählen
                    n_LCSD=n_LCSD+1;
                    % Zähler für Dioden weiterzählen
                    n_D=n_D+1;                
                    % Sättigungssperrstrom (in A) -> Skalar
                    I_S=value1;
                    % Temperaturspannung (in V) -> Skalar
                    U_T=value2;
                    % prüfen, ob dieser der erste Durchlauf ist
                    if c==1
                        % Anfangswert für die Iteration setzen
                        if n_t==1
                            U_v(k,n_t+1)=0.5;
                        else
                            U_v(k,n_t+1)=U_v(k,n_t);
                        end
                    else
                        % alten differentiellen Leitwert speichern (in S)
                        old_G(n_D)=G(n_D);
                    end
                    % neuer Leitwert (in S) -> Skalar
                    G(n_D)=I_S/U_T*exp(U_v(k,n_t+1)/U_T);
                    % prüfen, ob schon ein Durchlauf geschehen ist
                    if c>=2            
                        % Abbruchkriterium prüfen
                        if abs((G(n_D)-old_G(n_D))/G(n_D))<1e-6
                            D_convergence(n_D)=true;
                        end
                    end
                    % maximale Anzahl von Durchläufen prüfen
                    if c>=50
                        D_convergence(n_D)=true;
                    end
                    % Strom durch die Diode (in A) -> Skalar
                    I_D(n_D)=I_S*(exp(U_v(k,n_t+1)/U_T)-1);
                    % neuer Ersatzquellstrom (in A) -> Skalar
                    I_eq(n_D)=I_D(n_D)-U_v(k,n_t+1)*G(n_D);
                    % Eintrag in Stromquellenvektor
                    J(n_LCSD,n_t+1)=I_eq(n_D);
                    % Debug-Informationen ausgeben
                    disp(['c=',int2str(c),' U_v(k)=',num2str(U_v(k)),' G=',num2str(G(n_D)),' I_D=',num2str(I_D(n_D)),' I_eq=',num2str(I_eq(n_D))]);
                    % Matrix mit Zweigleitwerten
                    G_v(k,k)=G(n_D);
                    % Admittanzmatrix aktualisieren (ausgehend von der linearen Matrix)
                    if node1~=0 
                        % Admittanzmatrix
                        Y(node1,node1)=Y(node1,node1)+G(n_D);
                    end
                    if node2~=0 
                        % Admittanzmatrix
                        Y(node2,node2)=Y(node2,node2)+G(n_D);
                    end
                    if node1~=0 && node2~=0 
                        % Admittanzmatrix
                        Y(node1,node2)=Y(node1,node2)-G(n_D);
                        Y(node2,node1)=Y(node2,node1)-G(n_D);
                    end
                end
                if typ=='L' || typ=='C' || typ=='S' || typ=='D'
                    % Induktivität, Kapazität, Skineffekt-Modell, Diode
                    if node1~=0 
                        % Spaltenvektor der unabhängigen Quellenströme
                        I_q(node1,n_t+1)=I_q(node1,n_t+1)-J(n_LCSD,n_t+1);
                    end
                    if node2~=0 
                        % Spaltenvektor der unabhängigen Quellenströme
                        I_q(node2,n_t+1)=I_q(node2,n_t+1)+J(n_LCSD,n_t+1);
                    end
                end
            end
            % Schleife über I
            for k=1:N_I
                node1=I_list(k,2);
                node2=I_list(k,3);
                if node1~=0
                    % Spaltenvektor der unabhängigen Quellenströme
                    %I_q(node1,n_t+1)=I_q(node1,n_t+1)-I(k,n_t);
                    % für die implizite Trapezformel
                    I_q(node1,n_t+1)=I_q(node1,n_t+1)-I(k,n_t+1);
                    % für die implizite Eulerformel
                    %I_q(node1,n_t+1)=I_q(node1,n_t+1)-(I(k,n_t)+I(k,n_t+1))/2;
                end
                if node2~=0
                    % Spaltenvektor der unabhängigen Quellenströme
                    %I_q(node2,n_t+1)=I_q(node2,n_t+1)+I(k,n_t);
                    % für die implizite Trapezformel
                    I_q(node2,n_t+1)=I_q(node2,n_t+1)+I(k,n_t+1);
                    % für die implizite Eulerformel
                    %I_q(node2,n_t+1)=I_q(node2,n_t+1)+(I(k,n_t)+I(k,n_t+1))/2;
                end
            end
            % Zähler für U zurücksetzen
            n_U=0;
            % Schleife über alle A,U,K
            for k=1:N_AUK
                typ=char(AUK_list(k,1));
                if typ=='U'
                    % ideale Spannungsquelle
                    % Zähler für U weiterzählen  
                    n_U=n_U+1;
                    % Spaltenvektor der unabhängigen Quellen
                    %I_q(highest_node+k,n_t+1)=U(n_U,n_t);
                    I_q(highest_node+k,n_t+1)=U(n_U,n_t+1);
                    %I_q(highest_node+k,n_t+1)=(U(n_U,n_t)+U(n_U,n_t+1))/2;
                end
            end
            % prüfen, ob (keine) Dioden vorhanden sind
            if N_D==0
                % keine Dioden vorhanden
                % Iteration nur einmal durchführen
                convergence=true;
            else
                % Diode(n) vorhanden
                Z=inv(Y);
                % alle Dioden sind konvergiert
                if all(D_convergence)
                    convergence=true;
                end
            end
            % Spaltenvektor der Knotenspannungen
            u_K(1:highest_node+N_AUK,n_t+1)=Z*I_q(1:highest_node+N_AUK,n_t+1);
            % Spaltenvektor der Zweigspannungen
            U_v(1:N_RGLCSD,n_t+1)=B*u_K(1:highest_node,n_t+1);
            % Spaltenvektor der Zweigströme
            I_v(1:N_RGLCSD,n_t+1)=G_v*U_v(1:N_RGLCSD,n_t+1);
            % Abbruchbedingung prüfen
            if (abortable==true) && (cancel==true)
                break;
            end
            % Konvergenzkriterium prüfen
            if convergence==true
                break;
            end
        end
        if show_status==1
            waitbar(n_t/(N_t-1),wb);            % Statusbar aktualisieren
        end
    end
    if show_status==1
        close(wb);  % Statusbar schließen
    end

    % Antwort plotten
    % Speicherplatz für Plots-Matrix vorbelegen
    plots=zeros(size(plot_liste,1),N_t);
    for k=1:size(plot_liste,1)
        modus=plot_liste(k,1);
        sign1=sign(plot_liste(k,2));
        index1=abs(plot_liste(k,2));
        sign2=sign(plot_liste(k,3));
        index2=abs(plot_liste(k,3));
        if modus==1     % U (Quelle)
            if index1~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign1*U(index1,:));
            end
            if index2~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign2*U(index2,:));
            end
        elseif modus==2 % I (Quelle)
            if index1~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign1*I(index1,:));
            end
            if index2~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign2*I(index2,:));
            end
        elseif modus==3 % u_K (Knotenspannung)
            if index1~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign1*u_K(index1,:));
            end
            if index2~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign2*u_K(index2,:));
            end
        elseif modus==4 % I_v (Zweigstrom)        
            if index1~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign1*I_v(index1,:));
            end
            if index2~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign2*I_v(index2,:));
            end
        elseif modus==5 % U_v (Zweigspannung)
            if index1~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign1*U_v(index1,:));
            end
            if index2~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign2*U_v(index2,:));
            end
        elseif modus==6 % I_v und J (Zweigstrom + Quelle)
            if index1~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign1*I_v(index1,:));
            end
            if index2~=0
                plots(k,1:N_t)=plots(k,1:N_t)+(sign2*J(index2,:));
            end
        elseif modus==7 
            % Knotenspannungen entlang der Leitung
            
            % zu plottende Knoten auswählen -> Zeilenvektor(1,N_r)
            knoten=index1:index2:N_r*index2+index1;
            
            % Knotenspannungen (in V) -> Matrix(N_r,N_t)            
            plots=u_K(knoten,:);
        elseif modus==8 
            % Zweigströme + Quelle entlang der Leitung
            % (wird benutzt, wenn die Leitung verlustlos ist)
            
            % zu plottende Zweige auswählen -> Zeilenvektor(1,N_r)
            zweige=index1:index2:(N_r-1)*index2+index1;
            
            % Zweigströme + Quellen (in A) durch Induktivitäten -> Matrix(N_r,N_t)            
            plots(1:N_r,1:N_t)=I_v(zweige,:)+J(zweige-2,:);
            
            % Zweigstrom am Ende durch Z_2                       
            plots(N_r+1,1:N_t)=I_v(2,:);
        elseif modus==9 
            % Zweigströme entlang der Leitung
            % (wird benutzt, wenn die Leitung verlustbehaftet ist)
            
            % zu plottende Zweige auswählen -> Zeilenvektor(1,N_r)
            zweige=index1:index2:N_r*index2+index1;
            
            % Zweigströme (in A) -> Matrix(N_r,N_t)            
            plots=I_v(zweige,:);
        end        
    end

    % benötigte Rechenzeit (in s) -> Skalar
    comptime=cputime-starttime;

    if show_plots==1
        % Plots ausgeben
        %{
        plot(t*f,plots);
        gridon=plot_liste(k,4);
        if gridon==1
            % Gitternetz anzeigen
            grid on;
            xlabel('t/T_p')
            ylabel('u(t) in V')
            legend('Spannung am Anfang','Spannung am Ende');    
            axis([0,10,-0.01,0.01]);
        end
        %}

        % Grenzen für die Plot-Ordinate -> Skalar
        %min_limit=min(min(plots));
        %max_limit=max(max(plots));

        %% Plots ausgeben mit diploma_plot.m
        %{
        label='';                                           % Titel -> String
        x_label='t (in ns)';                                    % Achsenbeschriftung x-Achse -> String
        y_label='u(t) (in mV)';                             % Achsenbeschriftung x-Achse -> String
        legends={'Spannung am Anfang','Spannung am Ende'};  % Legende -> Zeilenvektor aus Strings
        limits=[t(1)*1e9,t(end)*1e9,min_limit*1.5*1e3,max_limit*1.5*1e3];                               % Achsengrenzen -> Vektor(1,4)
        %limits=[0,10,-10,10];
        pathname='..\Bilder\Zeitbereich\dbl_exp_pulse unmatched\';    % Pfad zum Speichern
        filename='eine Randbedingung aus 100 Wellen c';               % Dateiname zum Speichern
        diploma_plot(t*1e9,plots*1e3,label,x_label,y_label,legends,limits,pathname,filename);
        %}
    end
end