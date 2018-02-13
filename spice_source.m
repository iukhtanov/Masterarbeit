% Netlister für eine Doppelleitung
% Autor: Mathias Magdowski
% Datum: 2009-03-13
% eMail: mathias.magdowski@ovgu.de

% Optionen:
    % filename - Dateiname -> String
    %   wenn der Dateiname das Schlüsselwort 'twisted' enthält, wie eine
    %   Netzliste für eine verdrillte Leitung erstellt
    % t        - Zeitschritte (in s) -> Zeilenvektor(1,T)
    % mu       - magnetische Feldkonstante (in Vs/Am) -> Skalar
    % epsilon  - elektrische Feldkonstante (in As/Vm) -> Skalar
    % s        - Abstand der Leiter (in m) -> Skalar
    % r_0      - Radius der Leiter (in m) -> Skalar
    % l        - Länge der Leitung (in m) -> Skalar
    % Z_1_n    - Lastwiderstand am Anfang (normiert auf Z_c) -> Skalar
    % Z_2_n    - Lastwiderstand am Ende (normiert auf Z_c) -> Skalar
    % quantity - physikalische Größe -> String
        % U -> Spannung (in V)
        % I -> Strom (in A)
        % U_along -> Spannung entlang der Leitung (in V)
        % I_along -> Strom entlang der Leitung (in A)
    % typeof   - Art der Spannung/des Stromes -> String
        % total     -> Gesamtspannung (in V)/Gesamtstrom (in A)
        % scattered -> Streuspannung (in V)
        % incident  -> einfallende Spannung (in V)
    % d        - Anzahl der Zellen pro Wellenlänge (optional, Standard=20) -> Skalar
    % losses   - Berücksichtigung von Verlusten (optional, Standard=lossless) -> String
        % lossless -> verlustlos        
        % DC       -> Gleichstromverluste
        % max_f    -> Verluste bei der maximalen Frequenz

function R=spice_source(filename,t,mu,epsilon,s,r_0,l,Z_1_n,Z_2_n,quantity,typeof,d,losses)
    % prüfen, ob d gesetzt wurden, wenn nicht auf Standardwert setzen
    if nargin<=11
        d=20;
    end
    % prüfen, ob losses gesetzt wurden, wenn nicht auf Standardwert setzen
    if nargin<=12
        losses='lossless';
    end
    
    % prüfen, ob der Dateiname das Schlüsselwort 'twisted' enthält
    if strfind(filename,'twisted')
        % Index der tangentialen Spannungsquellen -> Skalar
        U_tl_index=7;
        % Index der transversalen Spannungsquellen -> Skalar
        U_tr_index=8;
    else
        % Index der tangentialen Spannungsquellen -> Skalar
        U_tl_index=5;
        % Index der transversalen Spannungsquellen -> Skalar
        U_tr_index=6;
    end

    % Konstanten
    c=1/sqrt(mu*epsilon);	% Lichtgeschwindigkeit (in m/s) -> Skalar
    sigma=58e6;             % Leitfähigkeit (Kupfer) in S/m

    % Zeitschritt (in s) -> Skalar
    Delta_t=t(2)-t(1);

    % minimale Wellenlänge (in m) -> Skalar
    lambda_min=c*Delta_t;

    % Anzahl der örtlichen Diskretisierungsschritte
    R=ceil(d*l/lambda_min);

    % Anzahl der Zeitschritte -> Skalar
    T=length(t);

    % örtliche Diskretisierung (in m) -> Skalar
    h=l/R;

    % Leitungsparamter
    Z_c=sqrt(mu/epsilon)/pi*acosh(s/(2*r_0));   % Wellenwiderstand (in Ohm) -> Skalar
    C=pi*epsilon*h/acosh(s/(2*r_0));            % Kapazität (in F) -> Skalar
    L=mu*h/pi*acosh(s/(2*r_0));                 % Induktivität (in H) -> Skalar
    if strcmp(losses,'DC')
        R_DC=2*h/(sigma*pi*r_0^2);              % Gleichstromwiderstand (in Ohm) -> Skalar
    elseif strcmp(losses,'max_f')
        % maximale auftretende Frequenz (in Hz)
        f_max=1e9;
        % Widerstand bei maximal auftretender Frequenz (in Ohm) -> Skalar        
        R_max=2*real(Z_exact(2*pi*f_max,sigma,mu,r_0,h));
    end

    % Generator und Last
    if iscell(Z_1_n)
        % Z_1_n ist ein Cell-Array
        Z_1=Z_1_n{1}*Z_c;                              % Lastwiderstand am Anfang (in Ohm) -> Skalar
        if Z_1_n{2}=='D'
            diode_1=true;
        end
    else
        Z_1=Z_1_n*Z_c;                              % Lastwiderstand am Anfang (in Ohm) -> Skalar
        diode_1=false;
    end
    if iscell(Z_2_n)
        % Z_2_n ist ein Cell-Array
        Z_2=Z_2_n{1}*Z_c;                              % Lastwiderstand am Ende (in Ohm) -> Skalar
        if Z_2_n{2}=='D'
            diode_2=true;
        end
    else
        Z_2=Z_2_n*Z_c;                              % Lastwiderstand am Ende (in Ohm) -> Skalar
        diode_2=false;
    end

    % Netzliste öffnen
    netlist=fopen(filename,'wt');    % Datei öffnen

    % Netzliste ausgeben
    fprintf(netlist,'%g %g\n',T,Delta_t);       % Optionen ausgeben (Anzahl Zeitschritte, Zeitschritt)
    fprintf(netlist,'%g %g\n',R,h);             % Optionen ausgeben (Anzahl Ortspunkte, Ortsschritt)
    % was soll geplottet werden
    if strcmp(losses,'lossless')
        % im verlustlosen Fall, nur LC-Glieder
        if strcmp(quantity,'U')
            % für die Spannung am Anfang und Ende der Leitung
            if strcmp(typeof,'total')
                fprintf(netlist,'%d %d %d %d\n',3,1,0,1);       % Gesamtspannung (total voltage) am Anfang plotten
                fprintf(netlist,'%d %d %d %d\n',3,2*R+3,0,1);   % Gesamtspannung (total voltage) am Ende plotten
            elseif strcmp(typeof,'scattered')
                fprintf(netlist,'%d %d %d %d\n',3,2,0,1);       % Streuspannung (scattered voltage) am Anfang plotten
                fprintf(netlist,'%d %d %d %d\n',3,2*R+2,0,1);   % Streuspannung (scattered voltage) am Ende plotten
            elseif strcmp(typeof,'incident')
                fprintf(netlist,'%d %d %d %d\n',1,-1,0,1);      % einfallende Spannung (incident voltage) am Anfang plotten
                fprintf(netlist,'%d %d %d %d\n',1,-(R+2),0,1);	% einfallende Spannung (incident voltage) am Ende plotten
            else
                error(['The ',typeof,'-type for the voltage is unknown.']);
            end
        elseif strcmp(quantity,'I')
            % für den Strom am Anfang und Ende der Leitung
            if strcmp(typeof,'total')
                fprintf(netlist,'%d %d %d %d\n',4,-1,0,1);  % Gesamtstrom (total current) am Anfang plotten
                fprintf(netlist,'%d %d %d %d\n',4,2,0,1);   % Gesamtstrom (total current) am Ende plotten
            else
                error(['The ',typeof,'-type for the current is unknown.']);
            end
        elseif strcmp(quantity,'U_along')
            % für die Spannung entlang der Leitung
            if strcmp(typeof,'scattered')
                fprintf(netlist,'%d %d %d %d\n',7,2,2,1);       % Streuspannung (scattered voltage) entlang der Leitung plotten
            else
                error(['The ',typeof,'-type for the voltage is unknown.']);
            end
        elseif strcmp(quantity,'I_along')
            % für den Strom entlang der Leitung
            if strcmp(typeof,'total')
                fprintf(netlist,'%d %d %d %d\n',8,3,1,1);       % Gesamtstrom (total current) entlang der Leitung
            else
                error(['The ',typeof,'-type for the current is unknown.']);
            end
        else
            error(['The quantity ',quantity,' for the lossless case is unknown.']);
        end
        % eigentliche Netzliste (Bauelement, Knoten 1, Knoten 2, Wert1, Wert2, Wert3), 6 Spalten
        fprintf(netlist,'R 1 0 %g 0 0\n',Z_1);          % Lastwiderstand am Anfang
        if diode_1
            % Diode parallel zum Lastwiderstand am Anfang
            fprintf(netlist,'D 1 0 %g %g 0\n',1e-6,25e-3);        
        end
        fprintf(netlist,'U 2 1 1 %d %d\n',U_tr_index,2*R+1);        % Spannungsquelle U_t1 am Anfang
        for n=1:R % für Diskretisierungszelle n
            fprintf(netlist,'L %d %d %g 0 0\n',2*n,2*n+1,L);      % Längsinduktivität
            fprintf(netlist,'U %d %d 1 %d %d\n',2*n+2,2*n+1,U_tl_index,n);    % Spannungsquelle E_tan
            fprintf(netlist,'C %d %d %g 0 0\n',2*n+2,0,C);        % Querkapazität
        end
        fprintf(netlist,'U %d %d 1 %d %d\n',2*R+2,2*R+3,U_tr_index,2*R+2);      % Spannungsquelle U_t2 am Ende
        fprintf(netlist,'R %d 0 %g 0 0\n',2*R+3,Z_2);               % Lastwiderstand am Ende
        if diode_2
            % Diode parallel zum Lastwiderstand am Ende
            fprintf(netlist,'D %d 0 %g %g 0\n',2*R+3,1e-6,25e-3);
        end
    elseif strcmp(losses,'DC') || strcmp(losses,'max_f')
        % im verlustbehafteten Fall, RLC-Glieder
        if strcmp(quantity,'U')
            % für die Spannung am Anfang und Ende der Leitung
            if strcmp(typeof,'total')
                fprintf(netlist,'%d %d %d %d\n',3,1,0,1);       % Gesamtspannung (total voltage) am Anfang plotten
                fprintf(netlist,'%d %d %d %d\n',3,3*R+3,0,1);   % Gesamtspannung (total voltage) am Ende plotten
            elseif strcmp(typeof,'scattered')
                fprintf(netlist,'%d %d %d %d\n',3,2,0,1);       % Streuspannung (scattered voltage) am Anfang plotten
                fprintf(netlist,'%d %d %d %d\n',3,3*R+2,0,1);   % Streuspannung (scattered voltage) am Ende plotten
            elseif strcmp(typeof,'incident')
                fprintf(netlist,'%d %d %d %d\n',1,-1,0,1);      % einfallende Spannung (incident voltage) am Anfang plotten
                fprintf(netlist,'%d %d %d %d\n',1,-(R+2),0,1);	% einfallende Spannung (incident voltage) am Ende plotten
            else
                error(['The ',typeof,'-type for the voltage is unknown.']);
            end
        elseif strcmp(quantity,'I')
            % für den Strom am Anfang und Ende der Leitung
            if strcmp(typeof,'total')
                fprintf(netlist,'%d %d %d %d\n',4,-1,0,1);  % Gesamtstrom (total current) am Anfang plotten
                fprintf(netlist,'%d %d %d %d\n',4,R+2,0,1);   % Gesamtstrom (total current) am Ende plotten
            else
                error(['The ',typeof,'-type for the current is unknown.']);
            end
        elseif strcmp(quantity,'U_along')
            % für die Spannung entlang der Leitung
            if strcmp(typeof,'scattered')
                fprintf(netlist,'%d %d %d %d\n',7,2,3,1);       % Streuspannung (scattered voltage) entlang der Leitung plotten
            else
                error(['The ',typeof,'-type for the voltage is unknown.']);
            end
        elseif strcmp(quantity,'I_along')
            % für den Strom entlang der Leitung
            if strcmp(typeof,'total')
                fprintf(netlist,'%d %d %d %d\n',9,2,1,1);       % Gesamtstrom (total current) entlang der Leitung
            else
                error(['The ',typeof,'-type for the current is unknown.']);
            end
        else
            error(['The quantity ',quantity,' for the case with losses is unknown.']);
        end
        % eigentliche Netzliste (Bauelement, Knoten 1, Knoten 2, Wert1, Wert2, Wert3), 6 Spalten
        fprintf(netlist,'R 1 0 %g 0 0\n',Z_1);          % Lastwiderstand am Anfang
        fprintf(netlist,'U 2 1 1 %d %d\n',U_tr_index,2*R+1);        % Spannungsquelle U_t1 am Anfang
        for n=1:R % für Diskretisierungszelle n
            if strcmp(losses,'DC')
                fprintf(netlist,'R %d %d %g 0 0\n',3*n-1,3*n,R_DC);   % Längswiderstand
            elseif strcmp(losses,'max_f')
                fprintf(netlist,'R %d %d %g 0 0\n',3*n-1,3*n,R_max);   % Längswiderstand
            end
            fprintf(netlist,'L %d %d %g 0 0\n',3*n,3*n+1,L);      % Längsinduktivität
            fprintf(netlist,'U %d %d 1 %d %d\n',3*n+2,3*n+1,U_tl_index,n);    % Spannungsquelle E_tan
            fprintf(netlist,'C %d %d %g 0 0\n',3*n+2,0,C);        % Querkapazität
        end
        fprintf(netlist,'U %d %d 1 %d %d\n',3*R+2,3*R+3,U_tr_index,2*R+2);      % Spannungsquelle U_t2 am Ende
        fprintf(netlist,'R %d 0 %g 0 0\n',3*R+3,Z_2);               % Lastwiderstand am Ende
    else
        error(['The losses-type ',losses,' is unknown.']);
    end
    fclose(netlist);  % Datei schließen
end
