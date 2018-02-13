% Funktion zum Komprimieren von "verrauschten" Messdaten für das Plotten
% mit TikZ/pgfplots
% Autor: Mathias Magdowski
% Datum: 2013-01-07
% eMail: mathias.magdowski@ovgu.de

% Optionen:
%   csv_data  - Daten -> Matrix(N,Y)
%   N         - Anzahl der Punkte -> Skalar
%   modus     - Modus (optional)
%       plot (Standard)
%       semilogx
%       semilogy
%       loglog
%   N_start   - Anzahl der äquidistanten Punkte, die direkt übernommen
%   werden -> Skalar
%       Standardwert ist 2 (Anfangs- und Endpunkt werden übernommen)

function csv_data_comp=compress_csv_data2(csv_data,N,modus,N_start)
    % prüfen, ob modus gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=2
        modus='plot';
    end
    % prüfen, ob N_start gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=3
        N_start=2;
        % Meldung ausgeben
        disp('Standardeinstellung: Es werden zunächst nur der Anfangs- und Endpunkt übernommen.');
    end
    
    % prüfen, ob eine Kompression überhaupt nötig ist
    if length(csv_data)<=N
        % Daten übernehmen
        csv_data_comp=csv_data;
        % Meldung ausgeben
        disp('keine Kompression nötig');
        % Funktion abbrechen
        return
    end
    
    % doppelte Einträge entfernen
    while any(diff(csv_data(:,1))==0)
       % ersten doppelten Eintrag finden
       n=find(diff(csv_data(:,1))==0,1,'first');
       % Mittelwert der Funktionswerte ausrechnen
       csv_data(n,2)=(csv_data(n,2)+csv_data(n+1,2))/2;
       % doppelte Zeile löschen
       csv_data(n+1,:)=[];
       % Meldung ausgeben
       disp(['doppelten Wert ',num2str(n),' entfernt'])
    end
    
    % Modus überprüfen
    if strcmp(modus,'semilogx')
        csv_data(:,1)=log(csv_data(:,1));
    elseif strcmp(modus,'semilogy')
        csv_data(:,2:end)=log(csv_data(:,2:end));
    elseif strcmp(modus,'loglog')
        csv_data=log(csv_data);
    end

    % Indizes der zu übernehmenden Werte
    x_index=round(linspace(1,length(csv_data),N_start));

    % mindestens jeden x-ten Wert übernehmen
    csv_data_comp=csv_data(x_index,:);
                
    % mindestens jeden x-ten Wert übernehmen, vorher interpolieren
%     x_int=linspace(csv_data(1,1),csv_data(end,1),length(csv_data));
%     csv_data_int=interp1(csv_data(:,1),csv_data(:,2),x_int);
%     csv_data_comp(:,1)=x_int(x_index);
%     csv_data_comp(:,2)=csv_data_int(x_index);

    % Statusbar anzeigen
    wb=waitbar(0,'Rohdaten werden komprimiert ...');

    % Schleife über die Anzahl der Punkte
    for n=length(csv_data_comp)+1:N    
        % neuen Verlauf interpolieren
        csv_data_int=interp1(csv_data_comp(:,1),csv_data_comp(:,2:end),csv_data(:,1));

        % neuen Wert hinzufügen
        % diese Variante fuehrt bei glatten Funktionen zu Fehlern, da die
        % Bedingung auf mehrere Werte gleichzeitig zutreffen kann
        %csv_data_comp(n,:)=csv_data(max(abs(csv_data(:,2:end)-csv_data_int))==abs(csv_data(:,2:end)-csv_data_int),:);
        % diese Variante ist robuster, weil stets nur ein Wert gefunden wird
        csv_data_comp(n,:)=csv_data(find(max(abs(csv_data(:,2:end)-csv_data_int))==abs(csv_data(:,2:end)-csv_data_int),1,'first'),:);
        
        % sortieren
        csv_data_comp=sortrows(csv_data_comp);
        
        % Statusbar aktualisieren
        waitbar(n/N,wb);
    end
    
    % Statusbar schließen
    close(wb);
    
    % Modus überprüfen
    if strcmp(modus,'semilogx')
    	csv_data_comp(:,1)=exp(csv_data_comp(:,1));
    elseif strcmp(modus,'semilogy')
        csv_data_comp(:,2:end)=exp(csv_data_comp(:,2:end));
    elseif strcmp(modus,'loglog')
        csv_data_comp=exp(csv_data_comp);
    end
end