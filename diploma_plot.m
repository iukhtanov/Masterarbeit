% Funktion zum Plotten mit allen Formatierungen für die Diplomarbeit
% Autor: Mathias Magdowski
% Datum: 2008-08-06
% eMail: mathias.magdowski@ovgu.de

% Änderungen:
%   2008-12-10 - Umstellung auf optionale Argumente

% Optionen:
%   x        - Definitionsbereich -> Matrix(N,X)
%       beim Modus plotyy -> Cell-Array aus zwei Matrizen(N,X)
%   y        - Wertebereich -> Matrix(N,X)
%       beim Modus plotyy -> Cell-Array aus zwei Matrizen(N,X)
%   label    - Titel (optional) -> String
%   x_label  - Achsenbeschriftung x-Achse (optional) -> String
%   y_label  - Achsenbeschriftung y-Achse (optional) -> String
%   legends  - Legende (optional) -> Zeilenvektor(1,N) aus Strings
%   limits   - Achsengrenzen (optional) -> Vektor(1,4)
%   pathname - Pfadname, unter dem gespeichert werden soll (optional) -> String
%   filename - Dateiname, unter dem gespeichert werden soll (optional) -> String
%   fig      - Nummer der Figure (optional) -> Skalar
%   modus    - Modus (optional) -> String
%       'plot'     -> normale Skalenteilung (Standard)
%       'plotyy'   -> normale Skalenteilung, zwei y-Achsen
%       'loglog'   -> doppelt-logarithmische Skalenteilung
%       'semilogx' -> logarithmisch skalierte x-Achse
%       'semilogy' -> logarithmisch skalierte y-Achse
%       'scatter'  -> Scatter-Plot
%       'hist'     -> Histogramm
%   ratio    - Achsenverhältnis und Größe (optional) -> String
%       'normal' -> wie in der Diplomarbeit (Standard)
%       'video'  -> geringere Auflösung für ein Video
%       'beamer' -> geringere Auflösung für Präsentationen
%       'wide'   -> schmaler für mehr Plots pro Seite
%   location - Ort, an dem die Legende angezeigt werden soll (optional) -> String
%       'North'             -> Inside plot box near top
%       'South'             -> Inside bottom
%       'East'              -> Inside right
%       'West'              -> Inside left
%       'NorthEast'         -> Inside top right (default)
%       'NorthWest'         -> Inside top left
%       'SouthEast'         -> Inside bottom right
%       'SouthWest'         -> Inside bottom left
%       'NorthOutside'      -> Outside plot box near top
%       'SouthOutside'      -> Outside bottom
%       'EastOutside'       -> Outside right
%       'WestOutside'       -> Outside left
%       'NorthEastOutside'  -> Outside top right
%       'NorthWestOutside'  -> Outside top left
%       'SouthEastOutside'  -> Outside bottom right
%       'SouthWestOutside'  -> Outside bottom left
%       'Best'              -> Least conflict with data in plot
%       'BestOutside'       -> Least unused space outside plot
%  orientation - Orientierung der Legende (optional) -> String
%       'vertical'   -> vertikale Orientierung (Standard)
%       'horizontal' -> horizontale Orientierung
%  interpreter - Interpreter für den Titel, die Achsenbeschriftung und die Legende (optional) -> String
%       'tex'   -> Plain TeX (Standard)
%       'latex' -> LaTeX

% Ausgabe:
%   handle_to_lineseries - Handle zu allen Linien-Objekten

function handle_to_lineseries=diploma_plot(x,y,label,x_label,y_label,legends,limits,pathname,filename,fig,modus,ratio,location,orientation,interpreter)
    % prüfen, ob orientation gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=14
        interpreter='tex';
    end
    % prüfen, ob orientation gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=13
        orientation='vertical';
    end
    % prüfen, ob location gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=12
        location='Best';
    end
    % prüfen, ob ratio gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=11
        ratio='normal';
    end
    % prüfen, ob modus gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=10
        modus='plot';
    end
    % prüfen, ob fig gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=9
        fig=0;
    end
    % prüfen, ob filename gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=8
        filename='';
    end
    % prüfen, ob pathname gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=7
        pathname='';
    end
    % prüfen, ob limits gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=6
        limits=[];
    end
    % prüfen, ob legends gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=5
        legends={};
    end
    % prüfen, ob y_label gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=4
        y_label='';
    end
    % prüfen, ob x_label gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=3
        x_label='';
    end
    % prüfen, ob label gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=2
        label='';
    end

    % neue figure(1) erstellen oder alte figure(1) weiterverwenden
    if fig~=0
        figure(fig);
    end

    % Desktop-Größe bestimmen
    desktop_size=get(0,'ScreenSize');
    
    % Anzeigegröße festlegen
    if strcmp(ratio,'normal')
        x_width=1050;
        y_width=650;
    elseif strcmp(ratio,'video')
        x_width=640;
        y_width=480;
    elseif strcmp(ratio,'small')
        x_width=480;
        y_width=360;
    elseif strcmp(ratio,'smaller')
        x_width=320;
        y_width=240;
    elseif strcmp(ratio,'dual_video')
        x_width=1280;
        y_width=480;
    elseif strcmp(ratio,'dual_video_small')
        x_width=1024;
        y_width=384;
    elseif strcmp(ratio,'beamer')
        x_width=800;
        y_width=500;
        %x_width=850;
        %y_width=530;
    elseif strcmp(ratio,'beamer_wide')
        x_width=800;
        y_width=425;
        %x_width=850;
        %y_width=530;
    elseif strcmp(ratio,'beamer_outside')
        x_width=1000;
        y_width=500;
    elseif strcmp(ratio,'4perpage')
        x_width=1050;
        y_width=525;        
    elseif strcmp(ratio,'wide')
        x_width=950;
        y_width=390;        
    elseif strcmp(ratio,'twocol')
        x_width=950;
        y_width=585;
    elseif strcmp(ratio,'twocol_wide')
        x_width=950;
        y_width=500;
    else
        error(['The ratio ',ratio,' is unknown.']);
    end
    x_position=(desktop_size(3)-x_width)/2;
    y_position=(desktop_size(4)-y_width)/2;
    set(gcf,'Position',[x_position y_position x_width y_width]);
    
    % Hintergrundfarbe auf weiß setzen
    %set(gcf,'Color',[1 1 1]);
    % Hintergrundfarbe auf transparent setzen
    %set(gcf, 'color', 'none');
    
    % Plotten
    if strcmp(modus,'plot')
        if iscell(x)
            if length(x)==2
                handle_to_lineseries=plot(x{1},y{1},x{2},y{2});
            elseif length(x)==3
                handle_to_lineseries=plot(x{1},y{1},x{2},y{2},x{3},y{3});
            elseif length(x)==4
                handle_to_lineseries=plot(x{1},y{1},x{2},y{2},x{3},y{3},x{4},y{4});
            end
        else
            handle_to_lineseries=plot(x,y);
        end
    elseif strcmp(modus,'plotyy')
        [handle_to_axes,handle_to_lineseries(:,1),handle_to_lineseries(:,2)]=plotyy(x{1},y{1},x{2},y{2},'semilogx');        
    elseif strcmp(modus,'loglog')
        handle_to_lineseries=loglog(x,y);
    elseif strcmp(modus,'semilogy')
        handle_to_lineseries=semilogy(x,y);
    elseif strcmp(modus,'semilogx')
        if iscell(x)
            if length(x)==2
                handle_to_lineseries=semilogx(x{1},y{1},x{2},y{2});
            elseif length(x)==3
                handle_to_lineseries=semilogx(x{1},y{1},x{2},y{2},x{3},y{3});
            elseif length(x)==4
                handle_to_lineseries=semilogx(x{1},y{1},x{2},y{2},x{3},y{3},x{4},y{4});
            end
        else
            handle_to_lineseries=semilogx(x,y);
        end
    elseif strcmp(modus,'scatter')
        handle_to_lineseries=scatter(x,y,'+');
        %axis square
    elseif strcmp(modus,'hist')
        if any(y~=0)
            % irgendein Wert von y ist ungleich 0
            % das Histogramm plotten
            hist(x,y);
            % die Rückgabewerte auslesen, ohne zu plotten
            handle_to_lineseries=hist(x,y);
        else
            % kein Wert von y ist ungleich 0
            % das Histogramm plotten
            hist(x);
            % die Rückgabewerte auslesen, ohne zu plotten
            handle_to_lineseries=hist(x);
        end
    elseif strcmp(modus,'quiver')
        % Plot mit Pfeilen, ohne Skalierung
        handle_to_lineseries=quiver(x,zeros(1,length(x)),zeros(1,length(x)),y,0);
        % Pfeile deaktivieren
        set(handle_to_lineseries,'ShowArrowHead','off')
    elseif strcmp(modus,'stem')
        % Plot von diskreten Sequenzen
        handle_to_lineseries=stem(x,y);
    else
        error(['The modus ',modus,' is unknown.']);
    end

    % Achsenbereich festlegen
    if any(limits~=0)
        % Tickmarks einstellen beim loglog-Plot
        if strcmp(modus,'loglog') && limits(2)/limits(1)<=100
            % Zähler zurücksetzen -> Skalar
            n=0;
            % Exponenten als Schleife durchlaufen
            for exponent=floor(log10(limits(1))):ceil(log10(limits(2)))
                % mögliche Ticks -> Zeilenvektor(1,6)
                x_tick_possible=[1,1.5,2,3,5,7.5];
                % mögliche Ticks als Schleife durchlaufen
                for x_tick_index=1:length(x_tick_possible)
                    % wenn der Tick innerhalb der Achsengrenzen liegt
                    % das *eps dient dazu numerische Fehler auszugleichen
                    % Genauigkeit -> Skalar
                    acc=100;
                    if (limits(1)-acc*eps)<=x_tick_possible(x_tick_index)*10^exponent && x_tick_possible(x_tick_index)*10^exponent<=limits(2)+acc*eps
                        % Zähler weiterzählen -> Skalar
                        n=n+1;
                        % Tickmark merken
                        x_ticks(n)=x_tick_possible(x_tick_index)*10^exponent;
                    end                
                end                    
            end
            % Grenzen neu setzen, damit diese exakt mit den Ticks übereinstimmen        
            limits(1)=x_ticks(1);
            %limits(2)=x_ticks(end);
            % Tickmarks auf die aktuelle Achse übetragen
            set(gca,'XTick',x_ticks);
        end        
        % Tickmarks einstellen beim semilogx-Plot
        if strcmp(modus,'semilogx') && limits(2)/limits(1)<=100
            % Zähler zurücksetzen -> Skalar
            n=0;
            % Exponenten als Schleife durchlaufen
            for exponent=floor(log10(limits(1))):ceil(log10(limits(2)))
                % mögliche Ticks -> Zeilenvektor(1,6)
                x_tick_possible=[1,1.5,2,3,5,7.5];
                % mögliche Ticks als Schleife durchlaufen
                for x_tick_index=1:length(x_tick_possible)
                    % wenn der Tick innerhalb der Achsengrenzen liegt
                    % das *eps dient dazu numerische Fehler auszugleichen
                    % Genauigkeit -> Skalar
                    acc=100;
                    if (limits(1)-acc*eps)<=x_tick_possible(x_tick_index)*10^exponent && x_tick_possible(x_tick_index)*10^exponent<=limits(2)+acc*eps
                        % Zähler weiterzählen -> Skalar
                        n=n+1;
                        % Tickmark merken
                        x_ticks(n)=x_tick_possible(x_tick_index)*10^exponent;
                    end                
                end                    
            end
            % Grenzen neu setzen, damit diese exakt mit den Ticks übereinstimmen        
            %limits(1)=x_ticks(1);
            %limits(2)=x_ticks(end);
            % Tickmarks auf die aktuelle Achse übetragen
            set(gca,'XTick',x_ticks);
            set(gca,'XTickLabelMode','auto')
        end        
        % Tickmarks einstellen beim semilogy-Plot
        if strcmp(modus,'semilogy') && length(limits)==4 && limits(4)/limits(3)<=100 
            % Zähler zurücksetzen -> Skalar
            n=0;
            % Exponenten als Schleife durchlaufen
            for exponent=floor(log10(limits(3))):ceil(log10(limits(4)))
                % mögliche Ticks -> Zeilenvektor(1,6)
                y_tick_possible=[1,1.5,2,3,5,7.5];
                % mögliche Ticks als Schleife durchlaufen
                for y_tick_index=1:length(y_tick_possible)
                    % wenn der Tick innerhalb der Achsengrenzen liegt
                    % das *eps dient dazu numerische Fehler auszugleichen
                    % Genauigkeit -> Skalar
                    acc=100;
                    if (limits(3)-acc*eps)<=y_tick_possible(y_tick_index)*10^exponent && y_tick_possible(y_tick_index)*10^exponent<=limits(4)+acc*eps
                        % Zähler weiterzählen -> Skalar
                        n=n+1;
                        % Tickmark merken
                        y_ticks(n)=y_tick_possible(y_tick_index)*10^exponent;
                    end                
                end                    
            end
            % Grenzen neu setzen, damit diese exakt mit den Ticks übereinstimmen        
            limits(3)=y_ticks(1);
            limits(4)=y_ticks(end);
            % Tickmarks auf die aktuelle Achse übetragen
            set(gca,'YTick',y_ticks);
        end
        % bei sehr kleinen Plots mehr Tickmarks hinzufügen        
        if strcmp(ratio,'smaller')
            % Tickmarks auf die aktuelle Achse übetragen
            set(gca,'XTick',[limits(1),(3*limits(1)+limits(2))/4,(limits(1)+limits(2))/2,(limits(1)+3*limits(2))/4,limits(2)]);
            set(gca,'YTick',[limits(3),(3*limits(3)+limits(4))/4,(limits(3)+limits(4))/2,(limits(3)+3*limits(4))/4,limits(4)]);
        end
        if length(limits)==2
            % nur die x-Achse festlegen
            if strcmp(modus,'plotyy')
                % beim Plot mit zwei y-Achsen beide Achsenpaare skalieren
                for n=1:length(handle_to_axes)
                    xlim(handle_to_axes(n),limits)
                end
            else
                xlim(limits)
            end
        elseif length(limits)==3
            % x-Achse festlegen und unteres Ende der y-Achse festlegen
            xlim(limits(1:2))
            % aktuelles oberes Ende auslesen -> Zeilenvektor(1,2)
            YLim=get(gca,'YLim');
            % y-Achsengrenzen festlegen
            ylim([limits(3),YLim(2)]);
        elseif length(limits)==4
            % x-Achse und y-Achse festlegen
            if strcmp(modus,'plotyy')
                % beim Plot mit zwei y-Achsen beide Achsenpaare skalieren
                for n=1:length(handle_to_axes)
                    axis(handle_to_axes(n),limits)
                    % mehr Tickmarks hinzufügen
                    set(handle_to_axes(n),'YTick',limits(3):(0-limits(3))/round((limits(4)-limits(3))/(0-limits(3))):limits(4))
                end
            else            
                axis(limits)
            end
        elseif length(limits)==6
            if strcmp(modus,'plotyy')
                % beim Plot mit zwei y-Achsen beide Achsenpaare skalieren
                for n=1:length(handle_to_axes)
                    axis(handle_to_axes(n),[limits(1),limits(2),limits(2*n+1),limits(2*n+2)])
                    % mehr Tickmarks hinzufügen
                    upper_limit=limits(2*n+2);
                    lower_limit=limits(2*n+1);
                    %tickstep=(0-lower_limit)/round((upper_limit-lower_limit)/(0-lower_limit));
                    tickstep=(upper_limit-lower_limit)/4;
                    set(handle_to_axes(n),'YTick',lower_limit:tickstep:upper_limit)
                end
            else            
                axis(limits)
            end
        end
    end
    
    % Gitternetzlinien
    grid on
    
    % Titel hinzufügen
    if not(strcmp(label,''))
        title(label,'FontSize',20,'Interpreter',interpreter)
    end
   
    % x-Achse beschriften
    if not(strcmp(x_label,''))
        xlabel(x_label,'FontSize',20,'Interpreter',interpreter)
    end
    
    % y-Achse beschriften
    if not(strcmp(y_label,''))
        if strcmp(modus,'plotyy')
            % beim Plot mit zwei y-Achsen beide Achsen einzeln beschriften
            for n=1:length(handle_to_axes)
                ylabel(handle_to_axes(n),y_label{n},'FontSize',20,'Interpreter',interpreter)
                % die eigentliche Plotfläche etwas verkleinern
                set(handle_to_axes(n),'Position',[0.13,0.11,0.75,0.815])
            end            
        else
            ylabel(y_label,'FontSize',20,'Interpreter',interpreter)
        end
    end
    
    % Schriftart der Teilstrichbeschriftungen der Achsen modifizieren
    if strcmp(interpreter,'latex')
        set(gca,'FontName','Times')
    end
    
    % Tickmarkbeschriftung der y-Achse im semilogy-Plot modifizieren
    if strcmp(modus,'semilogy')
        %set(gca,'YTickLabel',num2str(10.^str2num(get(gca,'YTickLabel'))))
    end
    % Tickmarkbeschriftung der x-Achse im semilogx-Plot modifizieren
    if strcmp(modus,'semilogx')
        %set(gca,'XTickLabel',num2str(10.^str2num(get(gca,'XTickLabel'))))
    end
    
    % Schriftgröße der Achseneinteilung einstellen
    if strcmp(modus,'plotyy')
        % beim Plot mit zwei y-Achsen beide Achsen einzeln einstellen
        for n=1:length(handle_to_axes)
            set(handle_to_axes(n),'FontSize',16)
        end
    else
        set(gca,'FontSize',16);
    end
    
    if not(strcmp(legends,''))
        if strcmp(modus,'plotyy')
            % beim Plot mit zwei y-Achsen beide Legenden einzeln setzen
            %{
            for n=1:length(handle_to_axes)
                % Legende anzeigen
                legend_handle=legend(handle_to_axes(n),legends{n},'Location',location);
                % Schriftgröße der Legende einstellen
                set(legend_handle,'FontSize',16);
                set(legend_handle,'Color','white');
            end
            %}
            % beide Legenden in eine gemeinsame einfügen
            legend(reshape(handle_to_lineseries,1,[]),legends{1}{:},legends{2}{:},'Location',location)
        else
            % Legende anzeigen
            legend_handle=legend(legends,'Location',location);
            % Schriftgröße der Legende einstellen
            set(legend_handle,'FontSize',16);
            % Orientierung der Legende einstellen
            set(legend_handle,'Orientation',orientation);
            % Interpreter einstellen
            set(legend_handle,'Interpreter',interpreter);
        end
    end
    
    % Linienstile beim Histogramm nicht einstellen
    if not(strcmp(modus,'hist'))
        if strcmp(modus,'plotyy')
            % Liniendicke für alle Linien einstellen
            %set(handle_to_lineseries(1),'LineWidth',2)
            %set(handle_to_lineseries(2),'LineWidth',2)
            set(handle_to_lineseries,'LineWidth',2)
        else
            % Liniendicke für alle Linien einstellen
            set(handle_to_lineseries,'LineWidth',2)

            % Anzahl der Linien -> Skalar
            N=length(handle_to_lineseries);

            % verfügbare Linienstile -> Zeilenvektor aus Strings
            if not(strcmp(modus,'scatter'))
                % '-'  -> durchgezogene Linie
                % '--' -> gestrichelte Linie
                % ':'  -> gepunktete Linie (beim pdf-Export schlecht zu erkennen, deshalb vermeiden)
                % '-.' -> Strich-Punkt-Linie
                if mod(N,4)==0
                    linestyles={'--','-'};
                    %linestyles={'--','-','-.',':'};
                else
                    linestyles={'-.','-','--'};
                end
                % verfügbare Styles für die Marker
                markerstyles={'+','o','*','.','x','s','d','^','v','>','<','p','h'};

                % Anzahl der Linienstile -> Skalar
                L=length(linestyles);
                
                % Anzahl der Markerstyle -> Skalar
                M=length(markerstyles);

                % Linienstil für jede Linie anders einstellen
                for n=1:N
                    if length(get(handle_to_lineseries(n),'XData'))<=2
                        % wenn weniger als 10 Werte geplottet wurden
                        % nur Marker plotten
                        set(handle_to_lineseries(n),'LineStyle','none','Marker',markerstyles{mod(n,M)+1})
                    elseif length(get(handle_to_lineseries(n),'XData'))>2 && length(get(handle_to_lineseries(n),'XData'))<=60                        
                        % wenn zwischen 10 und 24 Werte geplottet werden
                        % Marker und Linien plotten
                        set(handle_to_lineseries(n),'LineStyle',linestyles{mod(n,L)+1},'LineWidth',1,'Marker',markerstyles{mod(n,M)+1})
                    else
                        % wenn mehr als 24 Werte geplottet wurden
                        set(handle_to_lineseries(n),'LineStyle',linestyles{mod(n,L)+1})
                    end
                    % Besondere Farben einstellen
                    %{
                    if n==1, set(handle_to_lineseries(n),'Color','blue'), end
                    if n==2, set(handle_to_lineseries(n),'Color','blue'), end
                    if n==3, set(handle_to_lineseries(n),'Color','blue'), end
                    if n==4, set(handle_to_lineseries(n),'Color','red'), end
                    if n==5, set(handle_to_lineseries(n),'Color','red'), end
                    if n==6, set(handle_to_lineseries(n),'Color','red'), end
                    %}
                end
            end
        end
    end

    % Fadenkreuz für Scatter-Plot
    if strcmp(modus,'scatter')
        % gleiche Tickmarks an beiden Achsen
        %set(gca,'xtick',get(gca,'ytick'))
        % senkrechte Linie
        %line([0,0],[limits(3),limits(4)],'Color','black','LineWidth',2)
        %line([limits(1),limits(2)],[0,0],'Color','black','LineWidth',2)
    end
    
    % Papersize für pdf-Export
    % für Version 7.9.0.529 (R2009b)
    %set(gcf,'PaperSize',[x_width y_width]*0.008)
    %set(gcf,'PaperPosition',[0 0 x_width y_width]*0.008)    
    set(gcf,'PaperPosition',[0 0 x_width y_width]*0.02643821)
    %set(gcf,'PaperPosition',[0 0 x_width y_width]*0.024)
    set(gcf,'PaperSize',[x_width y_width]*0.02643821)
    %set(gcf,'PaperSize',[x_width y_width]*0.02)
    
    if strcmp(ratio,'beamer')
        %set(gca,'Position',[0.13,0.13,0.84,0.815])
    end
    
    if strcmp(interpreter,'latex')
        if strcmp(ratio,'beamer_wide')
            %set(gca,'Position',[0.12,0.15,0.80,0.80]) % etwas tiefer
            set(gca,'Position',[0.12,0.16,0.80,0.80]) % etwas höher
        else
            set(gca,'Position',[0.13,0.13,0.80,0.80])
        end
    end

    if not(strcmp(pathname,'')) && not(strcmp(filename,'')) 
        % prüfen, ob der angegebene Pfad existiert
        if not(fileattrib(pathname))
            % Pfad anlegen
            mkdir(pathname)
        end
        
        % prüfen, ob der Pfad ein \ am Ende hat
        if not(strcmp(pathname(end),'\'))
            pathname=[pathname,'\'];
        end
        
        % prüfen, ob die Datei schon existiert, wenn ja, nicht überschreiben
        if not(fileattrib([pathname,filename,'.fig']))
            % als .fig speichern
            saveas(gcf,[pathname,filename,'.fig'],'fig')
        end
        % prüfen, ob die Datei schon existiert, wenn ja, nicht überschreiben
        if not(fileattrib([pathname,filename,'.pdf']))
            % als .pdf speichern
            print('-dpdf',[pathname,filename,'.pdf'])
        end
        % prüfen, ob die Datei schon existiert, wenn ja, nicht überschreiben
        %{
        if not(fileattrib([pathname,filename,'.emf']))
            % als .emf speichern
            print('-dmeta',[pathname,filename,'.emf'])
        end
        %}
        % prüfen, ob die Datei schon existiert, wenn ja, nicht überschreiben
        if not(fileattrib([pathname,filename,'.png']))
            % als .png speichern
            print('-dpng',[pathname,filename,'.png'])
        end
    end
end

% Ticks einstellen
%set(AX(1),'XTick',[1e4 1e5 1e6 1e7 1e8 1e9])
