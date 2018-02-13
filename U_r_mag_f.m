% Funktion zur Berechnung der Spannung entlang der Leitung für mehrere Frequenzen
% Anregung erfolgt durch eine Welle
% basiert auf:
% Lösung der Leitungsgleichung im Frequenzbereich
% eigene Lösung der Randbedingungen
% Autor: Mathias Magdowski
% Datum: 2009-03-11
% eMail: mathias.magdowski@ovgu.de

% Änderungen:
% 2009-03-03 -> Eliminieren der Abhängigkeit von Z_c und r_0

% Leitung zeigt in tl-Richtung
% der Hinleiter ist bei tr=s/2, to=0
% der Rückleiter ist bei tr=-s/2, to=0
% der Anfang ist bei tl=0
% das Ende ist bei tl=l

% Optionen:
% allgemeine Konstanten:
    % f - Frequenz (in Hz) -> Spaltenvektor(F,1)
    % c - Lichtgeschwindigkeit (in m/s) -> Skalar
% Daten der Doppelleitung
    % s   - Abstand der Leiter (in m) -> Skalar
    % l   - Länge der Leitung (in m) -> Skalar
% Daten der einfallenden Welle
    % E_0      - Feldstärke des E-Feldes (in V/m) -> Spaltenvektor(F,1)
    % beta     - Phasenwinkel (in rad) -> Spaltenvektor(F,1)
    % k_vector - normierter Wellenvektor -> Spaltenvektor(3,1)
    % e_vector - normierter E-Feld-Vektor -> Spaltenvektor(3,1)
% Abschlusswiderstände
    % Z_1_n - Abschlusswiderstand am Anfang (normiert auf Z_c) -> Skalar
    % Z_2_n - Abschlusswiderstand am Ende (normiert auf Z_c) -> Skalar
% Diskretisierung
    % z - Bereich für die Auswertung (in m) -> Zeilenvektor(1,R)
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

% Anmerkung: Im Fall der einfallenden Spannung werden die Größen l, Z_1_n
% und Z_2_n nicht benötigt.

function output=U_r_mag_f(f,c,s,l,E_0,beta,k_vector,e_vector,Z_1_n,Z_2_n,z,typeof,geometry)
    % prüfen, wann f Null wird -> Zeilenvektor
    zeros_in_f=colvec(find(f==0));

    % omega an diesen Stellen auf 1 setzen
    f(zeros_in_f)=1;

    % Anzahl der Frequenzen -> Skalar
    F=length(f);

    % Anzahl der Ortspunkte -> Skalar
    R=length(z);

    % Konstanten festlegen
    k=2*pi*f/c;             % Wellenzahl (in 1/m) -> Spaltenvektor(F,1)

    % Daten der Doppelleitung
    h=s/2;                  % halber Abstand, Abstand zwischen Leiter und gedachter Masseebene (in m) -> Skalar

    % E_0 in Spaltenvektor umwandeln
    if length(E_0)==1
        E_0=E_0*ones(F,1);
    end

    % Daten der einfallenden Welle
    E_i=E_0.*exp(j*beta);    % einfallende Welle als komplexer Zeiger (in V/m) -> Spaltenvektor(F,1)

    % Anteile des normierten Wellenvektors -> Skalar
    [k_tl,k_tr]=change_geometry(geometry,k_vector);
    % Anteile des normierten E-Feldvektors -> Skalar
    [e_tl,e_tr]=change_geometry(geometry,e_vector);

    % Reflektionsfaktoren
    A_1=(Z_1_n-1)/(Z_1_n+1);        % Reflektionsfaktor am Anfang -> Skalar
    A_2=(Z_2_n-1)/(Z_2_n+1);        % Reflektionsfaktor am Ende -> Skalar
    C_1=-(Z_1_n+k_tl)/(1+Z_1_n);     % modifizierter Reflektionsfaktor am Anfang -> Skalar
    C_2=-(Z_2_n-k_tl)/(1+Z_2_n);     % modifizierter Reflektionsfaktor am Ende -> Skalar

    % Faktor für die eingekoppelte Stromwelle multipliziert mit Z_c (in V) -> Spaltenvektor(F,1)
    if 1-k_tl^2==0
        I_0_times_Z_c=zeros(F,1);
        % Interpretation: Den Grenzwert der Funktionen auszurechnen, ist
        % nicht so ganz einfach. Scheinbar ist es aber egal, was man ausrechnet, 
        % da im Grenzfall von grazing incidence die forced wave und die eigenwave 
        % gleich sind, deshalb ist es egal, welches Wert I_0 hat, durch die richtige 
        % Berechnung der Randbedingungen wird I_1 entsprechend angepasst.
    else
        I_0_times_Z_c=-2*E_i*e_tl.*sin(k*k_tr*h)./k/(1-k_tl^2);
    end

    % transversale Spannung am Anfang (in V) -> Spaltenvektor(F,1)
    if k_tr==0
        U_t1=2*h*E_i*e_tr;
    else
        U_t1=2*E_i*e_tr./k/k_tr.*sin(k*k_tr*h);
    end

    % transversale Spannung am Ende (in V) -> Spaltenvektor(F,1)
    U_t2=U_t1.*exp(-j*k*k_tl*l);

    % Faktor für die eingekoppelte Spannungswelle (in V) -> Spaltenvektor(F,1)
    U_0=I_0_times_Z_c*k_tl;

    % Faktor für die hinlaufende Spannungswelle (in V) -> Spaltenvektor(F,1)
    U_1=((I_0_times_Z_c.*(C_1-(C_2*A_1*exp(-j*k*(1+k_tl)*l))))+(U_t1/(Z_1_n+1))+(A_1*U_t2.*exp(-j*k*l)/(Z_2_n+1)))./(1-(A_1*A_2*exp(-2*j*k*l)));

    % Faktor für die rücklaufende Spannungswelle (in V) -> Spaltenvektor(F,1)
    U_2=((I_0_times_Z_c.*((C_1*A_2*exp(-2*j*k*l))-(C_2*exp(-j*k*(1+k_tl)*l))))+(A_2*U_t1.*exp(-2*j*k*l)/(Z_1_n+1))+(U_t2.*exp(-j*k*l)/(Z_2_n+1)))./(1-(A_1*A_2*exp(-2*j*k*l)));

    if strcmp(typeof,'scattered')
        % Streuspannung (scattered voltage) entlang der Leitung (in V) -> Matrix(F,R)
        output=U_0*ones(1,R).*exp(-j*k*k_tl*z)+U_1*ones(1,R).*exp(-j*k*z)+U_2*ones(1,R).*exp(j*k*z);
        % Stellen mit Grenzwert überschreiben, an denen f Null war
        output(zeros_in_f,1:R)=2*h*E_i(zeros_in_f)*e_tr*ones(1,R);
    elseif strcmp(typeof,'incident')
        % einfallende Spannung (incident voltage) entlang der Leitung (in V) -> Matrix(F,R)
        output=-U_t1*ones(1,R).*exp(-j*k*k_tl*z);
        % Stellen mit Grenzwert überschreiben, an denen f Null war
        output(zeros_in_f,1:R)=-2*h*E_i(zeros_in_f)*e_tr*ones(1,R);
    elseif strcmp(typeof,'total')
        % Gesamtspannung (total voltage) entlang der Leitung (in V) -> Matrix(F,R)
        output=(U_0-U_t1)*ones(1,R).*exp(-j*k*k_tl*z)+U_1*ones(1,R).*exp(-j*k*z)+U_2*ones(1,R).*exp(j*k*z);
        % Stellen mit Grenzwert überschreiben, an denen f Null war
        output(zeros_in_f,1:R)=zeros(length(zeros_in_f),R);
    else
        error(['The ',typeof,'-type of the voltage is unknown.']);
    end
end
