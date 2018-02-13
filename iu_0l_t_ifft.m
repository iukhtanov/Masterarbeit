% Funktion zur Berechnung der Zeitbereichslösung für die Einkopplung in 
% eine Leitung mittels inverse Fouriertransformation aus der 
% Frequenzbereichslösung für eine ebene Welle
% Autor: Mathias Magdowski
% Datum: 2009-03-09
% eMail: mathias.magdowski@ovgu.de

% Optionen:
% Allgemeine Konstanten
    % t - Zeitbereich (in s) -> Zeilenvektor(1,T)
    % c - Lichtgeschwindigkeit (in m/s) -> Skalar
% Daten der Doppelleitung
    % s - Abstand der Leiter (in m) -> Skalar
    % l - Länge der Leitung (in m) -> Skalar
    % Z_1_n - Abschlusswiderstand am Anfang, normiert auf Z_c -> Skalar
    % Z_2_n - Abschlusswiderstand am Ende, normiert auf Z_c -> Skalar
% Daten der einfallenden Welle
    % E_0       - Feldstärke des E-Feldes (in V/m) -> Skalar
    % parameter - Parameter der Funktion
        % bei exppuls    -> Zeitkonstante tau (in s) -> Skalar
        % bei sinuspuls  -> Kreisfrequenz omega (in 1/s) -> Skalar
        % bei sinus      -> Kreisfrequenz omega (in 1/s) -> Skalar
        % bei dblexppuls -> Parameter alpha und beta (in 1/s) -> Vektor(1,2)
    % t_beta    - zusätzliche Zeitverschiebung (in s) -> Skalar
    % k_vector  - Wellenvektor -> Spaltenvektor(3,1)
    % e_vector  - E-Feldvektor -> Spaltenvektor(3,1)
% Zeitfunktion
    % time_func - Zeitfunktion -> String
        % exppuls    -> einfach-exponentieller Puls mit E_0 und tau
        % sinuspuls  -> einfacher Sinuspuls mit E_0 und omega
        % sinus      -> eingeschalteter Sinus mit E_0 und omega
        % dblexppuls -> doppelt-exponentieller Puls mit E_0, alpha und beta
% Modus
    % modus - Modus -> String
        % beta_in_spectrum -> zusätzliche Phasenverschiebung im anregenden Spektrum berücksichtigen
        % beta_in_fdsolu   -> zusätzliche Phasenverschiebung in der Lösung der Leitungsgleichungen berücksichtigen
        % direct_mult      -> direkte Multiplikation des Spektrums mit der Frequenzbereichslösung

% Ausgabe:
    % output - Lösung im Zeitbereich -> Zeilenvektor(1,T)

function output=iu_0l_t_ifft(t,c,s,l,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,fd_func,modus,z,typeof,geometry,mu,epsilon,r_0,P,alpha,theta,phi)
    % prüfen, ob der Zeitvektor t=0 startet
    if t(1)~=0
        error('The time must start with t=0.')
    end

    % Anzahl der (positiven) Testfrequenzen -> Skalar
    F=length(t);
    
    % prüfen, ob der Zeitvektor eine Potenz von 2 lang ist    
    if log2(F)~=round(log2(F))
        disp('The number of time steps should be a power of 2.')
    end

    % (positive) Endfrequenz (in Hz) -> Skalar
    f_max=1/2/t(2);

    % zu untersuchende Frequenzen (in Hz) -> Spaltenvektor(F,1)
    f=linspace(0,f_max,F)';

    % zu untersuchende Kreisfrequenzen (in 1/s) -> Spaltenvektor(F,1)
    omega=2*pi*f;
    
    if strcmp(modus,'beta_in_spectrum') || strcmp(modus,'direct_mult')
        % anregendes Spektrum berechnen (in Vs/m) -> Spaltenvektor(F,1)
        E_spektrum=spectrum_t_beta(omega,E_0,parameter,t_beta,time_func);
    elseif strcmp(modus,'beta_in_fdsolu')
        % anregendes Spektrum berechnen (in Vs/m) -> Spaltenvektor(F,1)
        E_spektrum=spectrum(omega,E_0,parameter,time_func);
        % Phasenwinkel (in rad) -> Spaltenvektor(F,1)
        beta=t_beta*omega;
    else
        error(['The modus ',modus,' is unknown.']);
    end
    
    % Frequenzbereichsfunktion -> Function-Handle
    func_fd=str2func(fd_func);

    % Frequenzantwort erstellen (in V/m) -> Spaltenvektor(F,1)
    if strfind(fd_func,'U_')
        if strcmp(modus,'beta_in_spectrum')
            IU_0l_f=func_fd(f,c,s,l,E_spektrum,0,k_vector,e_vector,Z_1_n,Z_2_n,z,typeof,geometry);
        elseif strcmp(modus,'beta_in_fdsolu')
            IU_0l_f=func_fd(f,c,s,l,E_spektrum,beta,k_vector,e_vector,Z_1_n,Z_2_n,z,typeof,geometry);
        elseif strcmp(modus,'direct_mult')
            if strfind(fd_func,'twisted')
                IU_0l_f=func_fd(f,mu,epsilon,s,l,P,1,0,k_vector,e_vector,Z_1_n,Z_2_n).'.*E_spektrum;
            else
                %IU_0l_f=func_fd(f,mu,epsilon,s,r_0,l,1,0,k_vector,e_vector,Z_1_n,Z_2_n,z,typeof,geometry).*E_spektrum;
                IU_0l_f=func_fd(f,c,s,l,1,0,k_vector,e_vector,Z_1_n,Z_2_n,z,typeof,geometry).*E_spektrum;
            end
        end
    elseif strfind(fd_func,'I_')
        if strcmp(modus,'beta_in_spectrum')
            IU_0l_f=func_fd(f,mu,epsilon,s,r_0,l,E_spektrum,0,k_vector,e_vector,Z_1_n,Z_2_n,z,typeof,geometry);
        elseif strcmp(modus,'beta_in_fdsolu')
            IU_0l_f=func_fd(f,mu,epsilon,s,r_0,l,E_spektrum,beta,k_vector,e_vector,Z_1_n,Z_2_n,z,typeof,geometry);
        elseif strcmp(modus,'direct_mult')
            if strfind(fd_func,'nec')
                IU_0l_f=func_fd(f,mu,epsilon,s,r_0,l,P,1,0,alpha,theta,phi,Z_1_n,Z_2_n).'.*E_spektrum;
            elseif strfind(fd_func,'twisted')
                IU_0l_f=func_fd(f,mu,epsilon,s,r_0,l,P,1,0,k_vector,e_vector,Z_1_n,Z_2_n).'.*E_spektrum;           
            else
                IU_0l_f=func_fd(f,mu,epsilon,s,r_0,l,1,0,k_vector,e_vector,Z_1_n,Z_2_n,z,typeof,geometry).*E_spektrum;
            end
        end
    end

    % Lösung bei der Frequenz Null auf 0 setzen
    [t,output]=invfourier(f,IU_0l_f);
end