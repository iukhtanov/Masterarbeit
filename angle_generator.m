% Funktion zum Erzeugen einer stochastischen Winkelverteilung
% Autor: Mathias Magdowski
% Datum: 2009-09-16
% eMail: mathias.magdowski@ovgu.de

% Optionen:
%   N -> Anzahl der zu überlagernden Wellen pro Randbedingung -> Skalar
%   modus    - Modus für die Berechnung (optional) -> String
%       plane_wave -> Ansatz ebener Wellen im Arbeitsvolumen (Standard)
%       pw_nw_xy   -> Ansatz ebener Wellen nahe einer Wand in der x-y-Ebene bei z=0
%       pw_nw_yz   -> Ansatz ebener Wellen nahe einer Wand in der y-z-Ebene bei x=0
%       pw_nw_xz   -> Ansatz ebener Wellen nahe einer Wand in der x-z-Ebene bei y=0
%       pw_nw_xy_w -> Ansatz ebener Wellen nahe einer Wand in der x-y-Ebene bei z=w
%       pw_nb_z    -> Ansatz ebener Wellen nahe einer Kante in z-Richtung
%       pw_nb_y    -> Ansatz ebener Wellen nahe einer Kante in z-Richtung
%       pw_nc      -> Ansatz ebener Wellen nahe einer Ecke
%       fixed      -> erzeugt feste (nicht stochastische) Winkel (nur zum Testen)
%       tesche     -> Standardanregung wie in [1]
%       1pla2pol   -> erzeugt Winkel in einer Ebene mit 2 Polarisationen

% Ausgabe:
%   alpha - Polarisationswinkel (in rad) -> Zeilenvektor(1,N)
%   beta  - Phasenwinkel (zeitlich, temporal phase angle) (in rad) -> Zeilenvektor(1,N)
%   phi   - Azimutwinkel (in rad) -> Zeilenvektor(1,N)
%   theta - Polarwinkel (in rad) -> Zeilenvektor(1,N)
%   delta - Phasenwinkel (räumlich, spatial phase angle) (in rad) -> Zeilenvektor(1,N)

function [alpha,beta,phi,theta,delta]=angle_generator(N,modus)
    % prüfen, ob der Modus gesetzt ist, wenn nicht Standardmodus setzen
    if nargin<=1
        modus='plane_wave';
    end
    if strcmp(modus,'plane_wave')
        % Azimutwinkel in Kugelkoordinaten (in rad) -> Zeilenvektor(1,N)
        phi=2*pi*rand(1,N);

        % Polarwinkel in Kugelkoordinaten (in rad) -> Zeilenvektor(1,N)
        % Gleichverteilung von theta
        %theta=pi*rand(1,N);
        % Nicht-Gleichverteilung von theta
        theta=acos(rand(1,N)*2-1);
        
        % ergibt einen Raumwinkel von 4*pi

        % Polarisationswinkel (in rad) -> Zeilenvektor(1,N)
        alpha=pi*rand(1,N);

        % Phasenwinkel (in rad) -> Zeilenvektor(1,N)
        beta=2*pi*rand(1,N);
    elseif strcmp(modus,'pw_nw_xy') || strcmp(modus,'pw_nw_xy_w')
        % phi von 0 bis 2*pi
        phi=2*pi*rand(1,N);
        % theta von 0 bis pi/2
        theta=acos(rand(1,N));
        % ergibt einen Raumwinkel von 2*pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
    elseif strcmp(modus,'pw_nw_yz')
        % phi von -pi/2 bis pi/2
        phi=pi*rand(1,N)-pi/2;
        % theta von 0 bis pi
        theta=acos(rand(1,N)*2-1);
        % ergibt einen Raumwinkel von 2*pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
    elseif strcmp(modus,'pw_nw_xz')
        % phi von 0 bis pi
        phi=pi*rand(1,N);
        % theta von 0 bis pi
        theta=acos(rand(1,N)*2-1);
        % ergibt einen Raumwinkel von 2*pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
    elseif strcmp(modus,'pw_nb_z')
        % phi von 0 bis pi/2
        phi=pi/2*rand(1,N);
        % theta von 0 bis pi
        theta=acos(rand(1,N)*2-1);
        % ergibt einen Raumwinkel von pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
    elseif strcmp(modus,'pw_nb_y')
        % phi von -pi/2 bis pi/2
        phi=pi*rand(1,N)-pi/2;
        % theta von 0 bis pi/2
        theta=acos(rand(1,N));
        % ergibt einen Raumwinkel von pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
    elseif strcmp(modus,'pw_nb_x')
        % phi von 0 bis pi
        phi=pi*rand(1,N);
        % theta von 0 bis pi/2
        theta=acos(rand(1,N));
        % ergibt einen Raumwinkel von pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
    elseif strcmp(modus,'pw_nc')
        % phi von 0 bis pi/2
        phi=pi/2*rand(1,N);
        % theta von 0 bis pi/2
        theta=acos(rand(1,N));
        % ergibt einen Raumwinkel von pi/2
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
    elseif strcmp(modus,'fixed')
        % Anzahl der Variationen in phi -> Skalar
        N_phi=N(1);
        % Anzahl der Variationen in theta -> Skalar
        N_theta=N(2);
        % Anzahl der Variationen in alpha -> Skalar
        N_alpha=N(3);
        % Anzahl der Variationen in beta -> Skalar
        N_beta=N(4);
        % Azimutwinkel in Kugelkoordinaten (in rad) -> Zeilenvektor(1,N)
        phi_lin=linspace(0,2*pi*(N_phi-1)/N_phi,N_phi);
        % Polarwinkel in Kugelkoordinaten (in rad) -> Zeilenvektor(1,N)
        % Nicht-Gleichverteilung von theta
        theta_lin=acos(linspace(-1,1,N_theta));
        % ergibt einen Raumwinkel von 4*pi
        % Polarisationswinkel (in rad) -> Zeilenvektor(1,N)
        alpha_lin=linspace(0,pi*(N_alpha-1)/N_alpha,N_alpha);
        % Phasenwinkel (in rad) -> Zeilenvektor(1,N)
        beta_lin=linspace(0,2*pi*(N_beta-1)/N_beta,N_beta);
        % Vektoren umschreiben -> Zeilenvektor(1,N_phi*N_theta*N_alpha*N_beta)
        phi=reshape(ones(N_theta*N_alpha*N_beta,1)*phi_lin,1,[]);
        theta=repmat(reshape(ones(N_alpha*N_beta,1)*theta_lin,1,[]),1,N_phi);
        alpha=repmat(reshape(ones(N_beta,1)*alpha_lin,1,[]),1,N_phi*N_theta);
        beta=repmat(beta_lin,1,N_phi*N_theta*N_alpha);
    elseif strcmp(modus,'stand_wave')
        % Ansatz stehender Wellen im Arbeitsvolumen
        % Azimutwinkel in Kugelkoordinaten (in rad) -> Zeilenvektor(1,N)
        phi=2*pi*rand(1,N);

        % Polarwinkel in Kugelkoordinaten (in rad) -> Zeilenvektor(1,N)
        % Gleichverteilung von theta
        %theta=pi*rand(1,N);
        % Nicht-Gleichverteilung von theta
        theta=acos(rand(1,N)*2-1);
        
        % ergibt einen Raumwinkel von 4*pi

        % Polarisationswinkel (in rad) -> Zeilenvektor(1,N)
        alpha=pi*rand(1,N);

        % Phasenwinkel, zeitlich (in rad) -> Zeilenvektor(1,N)
        beta=2*pi*rand(1,N);

        % Phasenwinkel, räumlich (in rad) -> Zeilenvektor(1,N)
        % spatial phase angle
        delta=pi*rand(1,N);
    elseif strcmp(modus,'sw_nw_xz')
        % Ansatz stehender Wellen in der Nähe einer Wand in x-z-Richtung
        % phi von 0 bis pi
        phi=pi*rand(1,N);
        % theta von 0 bis pi
        theta=acos(rand(1,N)*2-1);
        % ergibt einen Raumwinkel von 2*pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);        
        % Phasenwinkel, räumlich (in rad) -> Zeilenvektor(1,N)
        % spatial phase angle
        delta=pi*rand(1,N);
    elseif strcmp(modus,'sw_nw_xy')
        % phi von 0 bis 2*pi
        phi=2*pi*rand(1,N);
        % theta von 0 bis pi/2
        theta=acos(rand(1,N));
        % ergibt einen Raumwinkel von 2*pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
        % Phasenwinkel, räumlich (in rad) -> Zeilenvektor(1,N)
        % spatial phase angle
        delta=pi*rand(1,N);
    elseif strcmp(modus,'sw_nw_yz')
        % phi von -pi/2 bis pi/2
        phi=pi*rand(1,N)-pi/2;
        % theta von 0 bis pi
        theta=acos(rand(1,N)*2-1);
        % ergibt einen Raumwinkel von 2*pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
        % Phasenwinkel, räumlich (in rad) -> Zeilenvektor(1,N)
        % spatial phase angle
        delta=pi*rand(1,N);
    elseif strcmp(modus,'sw_nb_z')
        % phi von 0 bis pi/2
        phi=pi/2*rand(1,N);
        % theta von 0 bis pi
        theta=acos(rand(1,N)*2-1);
        % ergibt einen Raumwinkel von pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
        % Phasenwinkel, räumlich (in rad) -> Zeilenvektor(1,N)
        % spatial phase angle
        delta=pi*rand(1,N);
    elseif strcmp(modus,'sw_nb_y')
        % phi von -pi/2 bis pi/2
        phi=pi*rand(1,N)-pi/2;
        % theta von 0 bis pi/2
        theta=acos(rand(1,N));
        % ergibt einen Raumwinkel von pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
        % Phasenwinkel, räumlich (in rad) -> Zeilenvektor(1,N)
        % spatial phase angle
        delta=pi*rand(1,N);
    elseif strcmp(modus,'sw_nb_x')
        % phi von 0 bis pi
        phi=pi*rand(1,N);
        % theta von 0 bis pi/2
        theta=acos(rand(1,N));
        % ergibt einen Raumwinkel von pi
        alpha=pi*rand(1,N);
        beta=2*pi*rand(1,N);
        % Phasenwinkel, räumlich (in rad) -> Zeilenvektor(1,N)
        % spatial phase angle
        delta=pi*rand(1,N);
    elseif strcmp(modus,'sidefire')
        % Polarisationswinkel (in rad) -> Skalar
        alpha=180*pi/180*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=90*pi/180*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=0*pi/180*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'broadside')
        % Polarisationswinkel (in rad) -> Skalar
        alpha=90*pi/180*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=90*pi/180*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=270*pi/180*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'endfire')
        % Polarisationswinkel (in rad) -> Skalar
        alpha=0*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=0*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=0*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'sidefire_xz')
        % Sidefire Anregung
        % Definition der Kugelkoordinaten/Polarisation: wie bei Magdowski
        % Richtung der Leitung: xz
        % Polarisationswinkel (in rad) -> Skalar
        alpha=0/180*pi*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=0/180*pi*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=0*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'broadside_xz')
        % Broadside Anregung
        % Definition der Kugelkoordinaten/Polarisation: wie bei Magdowski
        % Richtung der Leitung: xz
        % Polarisationswinkel (in rad) -> Skalar
        alpha=180/180*pi*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=90/180*pi*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=90/180*pi*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'endfire_xz')
        % Endfire Anregung
        % Definition der Kugelkoordinaten/Polarisation: wie bei Magdowski
        % Richtung der Leitung: xz
        % Polarisationswinkel (in rad) -> Skalar
        alpha=180/180*pi*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=90/180*pi*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=0*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'tesche')
        % Anregung wie in [1]
        % Polarisationswinkel (in rad) -> Skalar
        alpha=0*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=60/180*pi*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=0*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'tesche_mag_xz')
        % Die typische Tesche-Anregung in der Defintion der
        % Kugelkoordinaten/Polarisation wie bei Magdowski
        % Polarisationswinkel (in rad) -> Skalar
        alpha=180/180*pi*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=150/180*pi*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=0*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'tesche_mag_zx')
        % Die typische Tesche-Anregung in der Defintion der
        % Kugelkoordinaten/Polarisation und der Anordnung der Leitung wie
        % bei Magdowski
        % Polarisationswinkel (in rad) -> Skalar
        alpha=180/180*pi*ones(1,N);
        % Polarwinkel (in rad) -> Skalar
        theta=60/180*pi*ones(1,N);
        % Azimutwinkel (in rad) -> Skalar
        phi=180/180*pi*ones(1,N);
        % Phasenwinkel (in rad) -> Skalar
        beta=0*ones(1,N);
    elseif strcmp(modus,'1pla2pol')
        % erzeugt Einfallsrichtungen in einer Ebene mit 2 Polarisationen
        % N ist die Anzahl der Einfallsrichtungen
        % Speicherplatz vorbelegen
        alpha=zeros(1,N);
        phi=zeros(1,N);
        theta=zeros(1,N);
        % Startrichtung auswürfeln
        % Azimutwinkel in Kugelkoordinaten (in rad) -> Skalar
        phi(1)=2*pi*rand(1,1);
        % Polarwinkel in Kugelkoordinaten, Nicht-Gleichverteilung (in rad) -> Skalar
        theta(1)=acos(rand(1,1)*2-1);
        % ergibt einen Raumwinkel von 4*pi
        % Polarisationswinkel (in rad) -> Skalar
        alpha(1)=pi*rand(1,1);
        % Wellenvektor für Startposition berechnen
        [k_vector,k_x,k_y,k_z]=k_generator(1,theta(1),phi(1));
        % Polarisationsrichtung für Startposition berechnen
        [e_vector,e_x,e_y,e_z]=e_generator(alpha(1),theta(1),phi(1));
        for n=2:N
            % Drehwinkel (in rad) -> Skalar
            gamma=2*pi*(n-1)/N;
            % neue Einfallsrichtung mittels Drehmatrix bestimmen
            k_x_neu=((cos(gamma)+(e_x.^2.*(1-cos(gamma)))).*k_x)+(((e_x.*e_y.*(1-cos(gamma)))-(e_z.*sin(gamma))).*k_y)+(((e_x.*e_z.*(1-cos(gamma)))+(e_y.*sin(gamma))).*k_z);
            k_y_neu=(((e_y.*e_x.*(1-cos(gamma)))+(e_z.*sin(gamma))).*k_x)+((cos(gamma)+(e_y.^2.*(1-cos(gamma)))).*k_y)+(((e_y.*e_z.*(1-cos(gamma)))-(e_x.*sin(gamma))).*k_z);
            k_z_neu=(((e_z.*e_x.*(1-cos(gamma)))-(e_y.*sin(gamma))).*k_x)+(((e_z.*e_y.*(1-cos(gamma)))+(e_x.*sin(gamma))).*k_y)+((cos(gamma)+(e_z.^2.*(1-cos(gamma)))).*k_z);
            % neue Einfallsrichtung in Winkel umrechnen (in rad) -> Zeilenvektor(1,N)
            [r,theta(n),phi(n)]=cart2sphere(k_x_neu,k_y_neu,k_z_neu);
            % neuen Polarisationswinkel bestimmen (in rad) -> Zeilenvektor(1,N)
            % mit acos, Formel liefert nicht in jedem Fall ein korrektes Ergebnis
            %alpha(n)=acos(e_z/sin(theta(n)));
            % mit atan2, Formel sollte stabiler sein
            %alpha(n)=atan2(e_y*cos(theta(n))*cos(phi(n))-e_x*cos(theta(n))*sin(phi(n)),e_y*sin(phi(n))+e_x*cos(phi(n)));
            % mit atan2 und cos(theta) diese Formel ist tatsächlich stabil
            alpha(n)=atan2((e_y*cos(theta(n))*cos(phi(n))-e_x*cos(theta(n))*sin(phi(n)))./cos(theta(n)),(e_y*sin(phi(n))+e_x*cos(phi(n)))./cos(theta(n)));
        end
        % Gesamtwinkel zusammensetzen
        % Azimutwinkel in Kugelkoordinaten (in rad) -> Zeilenvektor(1,2*N)
        phi=[phi,phi];
        % Polarwinkel in Kugelkoordinaten (in rad) -> Zeilenvektor(1,2*N)
        theta=[theta,theta];
        % Polarisationswinkel (in rad) -> Zeilenvektor(1,2*N)
        alpha=[alpha,alpha+pi/2];
        % Phasenwinkel (in rad) -> Zeilenvektor(1,2*N)
        beta=2*pi*rand(1,2*N);        
    else
        error(['The modus ',modus,' is unknown.'])
    end
end

% Quellen:
% [1] Frederic M. Tesche, "Plane Wave Coupling to Cables", 49 pages