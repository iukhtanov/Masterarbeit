% Funktion zum Erstellen von Movies mit allen Formatierungen
% es werden zwei Filme nebeneinander erstellt
% links l�uft der Film der Welle entlang der Leitung 
% rechts erscheint das Ergebnis am Anfang und Ende �ber der Zeit
% Autor: Mathias Magdowski
% Datum: 2009-04-16
% eMail: mathias.magdowski@ovgu.de

% Optionen:
%   t        - Zeitschritte -> Vektor(1,T)
%   x        - Definitionsbereich -> Vektor(1,R)
%   y_t      - Wertebereich �ber der Zeit -> Matrix(R,T)
%   label    - Titel (optional) -> String
%   x_label  - Achsenbeschriftung x-Achse (optional) -> String
%   y_label  - Achsenbeschriftung y-Achse (optional) -> String
%   legends  - Legende (optional) -> Zeilenvektor(1,N) aus Strings
%   limits   - Achsengrenzen (optional) -> Vektor(1,4)
%   pathname - Pfadname, unter dem gespeichert werden soll (optional) -> String
%   filename - Dateiname, unter dem gespeichert werden soll (optional) -> String
%   fig      - Nummer der Figure (optional) -> Skalar
%   modus    - Modus (optional) -> String
%       'plot'   -> normale Skalenteilung
%       'loglog' -> doppelt-logarithmische Skalenteilung
%   ratio    - Achsenverh�ltnis und Gr��e -> String
%       'normal' -> wie in der Diplomarbeit
%       'video'  -> geringere Aufl�sung f�r ein Video
%       'beamer' -> geringere Aufl�sung f�r Pr�sentationen
%       'wide'   -> schmaler f�r mehr Plots pro Seite
%   location - Ort, an dem die Legende angezeigt werden soll -> String
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

function dual_movie_plot(t,x,y_t,label,x_label,y_label,legends,limits,pathname,filename,fig,modus,ratio,location)
    % pr�fen, ob location gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=13
        location='Best';
    end
    % pr�fen, ob modus gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=12
        ratio='dual_video';
    end
    % pr�fen, ob modus gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=11
        modus='plot';
    end
    % pr�fen, ob fig gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=10
        fig=3;
    end
    % pr�fen, ob filename gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=9
        filename='';
    end
    % pr�fen, ob pathname gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=8
        pathname='';
    end
    % pr�fen, ob limits gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=7
        limits=[];
    end
    % pr�fen, ob legends gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=6
        legends={};
    end
    % pr�fen, ob y_label gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=5
        y_label='';
    end
    % pr�fen, ob x_label gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=4
        x_label='';
    end
    % pr�fen, ob label gesetzt wurde, wenn nicht auf Standardwert setzen
    if nargin<=3
        label='';
    end

    % Ortsabh�ngigkeit aus der Achsenbeschriftung des reinen Zeitverlaufs
    % entfernen
    y_label_right=strrep(y_label,'z,','');

    % Anzahl der Zeitschritte -> Skalar
    T=length(t);

    % Speicherplatz vorbelegen -> Cell Array
    movie=struct('cdata',cell(1,T),'colormap',cell(1,T));
     
    % Figure anlegen
    figure(fig);
          
    % Zeitpunkte als Schleife durchlaufen
    for n=1:T
        % linke Seite plotten
        subplot(1,2,1)
        
        % Zeitpunkt an x-Achse anh�ngen
        %x_label_t=[x_label,' bei t = ',num2str(t(n)*1e9,'%1.2f'),' ns'];
        x_label_t=[x_label,' bei t = ',num2str(t(n)*1e9,'%1.0f'),' ns'];
                
        % einen Zeitpunkt plotten
        handle_to_lineseries=diploma_plot(x,y_t(:,n),label,x_label_t,y_label,legends,limits,'','',fig,modus,ratio,location);
        set(handle_to_lineseries(1),'LineWidth',1)

        % linke Seite plotten
        subplot(1,2,2)
        
        % Zeitverlauf plotten
        %if n==1
            % erstes Bild separat speichern (als Vorschaubild f�r den Film)
            %diploma_plot(t(1:n)*1e9,[y_t(1,1:n);y_t(end,1:n)],'','an den Enden �ber t (in ns)',y_label_right,{'am Anfang','am Ende'},[0 t(end)*1e9 limits(3) limits(4)],pathname,filename,fig,modus,ratio,'NorthEast');
        %else
            % andere Bilder nicht einzeln speichern
            handle_to_lineseries=diploma_plot(t(1:n)*1e9,[y_t(1,1:n);y_t(end,1:n)],'','an den Enden �ber t (in ns)',y_label_right,{'am Anfang','am Ende'},[0 t(end)*1e9 limits(3) limits(4)],'','',fig,modus,ratio,'NorthEast');
            set(handle_to_lineseries(1),'LineWidth',1)
            set(handle_to_lineseries(2),'LineWidth',1)
        %end
        
        
        % nur Plot-Area, ohne Achsenbeschriftung und Titel
        %movie(n)=getframe;
        % komplette Plot-Area
        movie(n)=getframe(gcf);
    end
            
    if not(strcmp(pathname,'')) && not(strcmp(filename,'')) 
        % pr�fen, ob der angegebene Pfad existiert
        if not(fileattrib(pathname))
            % Pfad anlegen
            mkdir(pathname)
        end

        % pr�fen, ob der Pfad ein \ am Ende hat
        if not(strcmp(pathname(end),'\'))
            pathname=[pathname,'\'];
        end

        % pr�fen, ob die Datei schon existiert, wenn ja, nicht �berschreiben
        if not(fileattrib([pathname,filename,'.avi']))
            %movie2avi(Movie,[pathname,filename,'.avi'],'fps',24,'compression','None')
            movie2avi(movie,[pathname,filename,'.avi'],'fps',24)
        end
    end
end    