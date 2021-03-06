% L�sung f�r die Einkopplung in eine Leitung im Zeitbereich
% f�r eine ebene Welle, die aus einem doppelt-exponentiellen Puls besteht
% Autor: Mathias Magdowski
% Datum: 2011-10-13
% eMail: mathias.magdowski@ovgu.de

% alles l�schen
clear all

% alle Abbildungen schlie�en
close all

% mit Diode am Ende der Leitung
%diode=false;
diode=true;

% Konstanten festlegen
% Lichtgeschwindigkeit (in m/s) -> Skalar
c=299792458;
% Permeabilit�t (in Vs/Am) -> Skalar
mu=4*pi*1e-7;
% Permittivit�t (in As/Vm) -> Skalar
epsilon=1/(mu*c^2);

% Daten der Doppelleitung
[s,r_0,l]=tl_dimensions('twisted');
% Wellenwiderstand (in Ohm) -> Skalar
Z_c=sqrt(mu/epsilon)/pi*acosh(s/(2*r_0));
% Anzahl der Verdrillungen -> Skalar
%twists=1e-6;
%twists=1;
%twists=1.5;
twists=3;
%twists=5;
%twists=10;
% Schlagl�nge (in m) -> Skalar
P=l/twists;
% Abschlussimpedanz am Anfang, normiert auf Z_c -> Skalar
Z_1_n=1/2;
% Abschlussimpedanz am Ende, normiert auf Z_c -> Skalar
Z_2_n=1/2;
% Geomtrie -> String
geometry='xz';

% Daten der einfallenden Welle
% Feldst�rke des E-Feldes (in V/m) -> Skalar
%E_0=52.5e3;
E_0=2e3;
% Pulsbreitenkonstante (in 1/s) -> Skalar
alpha_hemp=4e6;
% Pulsanstiegskonstante (in 1/s) -> Skalar
beta_hemp=4.76e8;
% anregende Zeitfunktion -> String
time_func='dblexppuls';
% Zeitverschiebung (in s) -> Skalar
t_beta=0;
% Parameter der Zeitfunktion -> Vektor
parameter=[alpha_hemp,beta_hemp];

% Zeitfunktion plotten
%t_plot=linspace(-0.05e-6,0.5e-6,1000);
%diploma_plot(t_plot*1e9,1e-3*E_0*K_factor(alpha_hemp,beta_hemp)*h(t_plot).*(exp(-alpha_hemp*t_plot)-exp(-beta_hemp*t_plot)),'','Zeit, t (in ns)','Feldst�rke, E(t) (in kV/m)',{},[-50 500 0 2.5],'../Bilder/EMV2012/','dblexppulse',1,'plot','video');

% Richtung der Welle
%excitation='tesche';
excitation='tesche_mag_xz';
%excitation='sidefire_xz';
%excitation='broadside_xz';
%excitation='endfire_xz';
% Winkel in Kugelkoordinaten (in rad) -> Skalar
[alpha,beta,phi,theta]=angle_generator(1,excitation);
% Modus, nach dem k_vector und e_vector berechnet werden
%k_modus='tesche';
k_modus='normal';
% max. E-Feldvektor -> Spaltenvektor(3,1)
e_vector=e_generator(alpha,theta,phi,k_modus);
% Wellenvektor (in 1/m) -> Spaltenvektor(3,1)
k_vector=k_generator(1,theta,phi,k_modus);
% zus�tzliche Zeitverschiebung aufgrund der Leitungsgeometrie (in s) -> Zeilenvektor(1,N)
t_beta=t_beta_tl(c,k_vector,s,l,geometry)-t_beta;

% physikalische Gr��e -> String
quantity='U';
%quantity='U_along';
% Art der Spannung/des Stromes -> String
typeof='total';
%typeof='scattered';
%typeof='incident';

% Zeitpunkte der Simulation
% maximale Zeit (in s) -> Skalar
t_max=1e-6;
% Anzahl der Zeitpunkte -> Skalar
N_t=2501;
% Zeitpunkte (in s) -> Zeilenvektor(1,N_t)
t=linspace(0,t_max,N_t);

% Zeitverlauf berechnen
% unverdrillte Leitung
%plots=iu_0l_t_spice(t,mu,epsilon,s,r_0,l,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,quantity,typeof,geometry);
% verdrillte Leitung
if strcmp(quantity,'U')
    if diode
        [plots,comptime]=iu_0l_t_twisted_spice(t,mu,epsilon,s,r_0,l,P,Z_1_n,{Z_2_n,'D'},E_0,parameter,t_beta,k_vector,e_vector,time_func,quantity,typeof,geometry);
    else
        [plots,comptime]=iu_0l_t_twisted_spice(t,mu,epsilon,s,r_0,l,P,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,quantity,typeof,geometry);
    end
elseif strcmp(quantity,'U_along')
    if diode
        [plots,comptime]=iu_r_t_twisted_spice(t,mu,epsilon,s,r_0,l,P,Z_1_n,{Z_2_n,'D'},E_0,parameter,t_beta,k_vector,e_vector,time_func,'U',typeof,geometry);
    else
        [plots,comptime]=iu_r_t_twisted_spice(t,mu,epsilon,s,r_0,l,P,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,'U',typeof,geometry);
    end
end
% Rechenzeit anzeigen
disp(['Rechenzeit: ',num2str(comptime),' s']);

% Modus -> String
% direkte Multiplikation des Spektrums mit der Frequenzbereichsl�sung
modus='direct_mult';

% Zeitverlauf analytisch im Frequenzbereich berechnen und per ifft in den Zeitbereich transformieren
if twists~=1e-6
    % verdrillte Leitung
    ifft_l_twisted_BLT=iu_0l_t_ifft(t,c,s,l,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,[quantity(1),'_twisted_xzl_total_BLT_f'],modus,l,typeof,geometry,mu,epsilon,r_0,P);
    ifft_0_twisted_BLT=iu_0l_t_ifft(t,c,s,l,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,[quantity(1),'_twisted_xz0_total_BLT_f'],modus,l,typeof,geometry,mu,epsilon,r_0,P);
else
    % unverdrillte Leitung
    ifft_0_twisted_BLT=iu_0l_t_ifft(t,c,s,l,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,[quantity(1),'_r_mag_f'],modus,0,typeof,geometry,mu,epsilon,r_0);
    ifft_l_twisted_BLT=iu_0l_t_ifft(t,c,s,l,Z_1_n,Z_2_n,E_0,parameter,t_beta,k_vector,e_vector,time_func,[quantity(1),'_r_mag_f'],modus,l,typeof,geometry,mu,epsilon,r_0);    
end

% Ergebnisse plotten
% Titel -> String
label='';
% Achsenbeschriftung x-Achse -> String
x_label='Zeit, t (in �s)';
% Achsenbeschriftung y-Achse -> String
y_label='Spannung, u(t) (in V)';
% Legende -> Cell Array aus Strings
if diode
    legends={'Widerstand und Diode','nur Widerstand'};
else
    legends={'transiente Simulation','L�sung per iFFT'};
end
% Achsengrenzen -> Vektor(1,2)
if diode
    limits=[0,0.6*t_max*1e6,-8,8];    
else
    if twists==5
        limits=[0,0.6*t_max*1e6,-4.5,4.5];
    else
        limits=[0,0.6*t_max*1e6];
    end
end
% Ort der Legende -> String
location='NE';
% Pfadname -> String
pathname='./abbildungen/';
% Dateiname -> String
if diode
    filename=['u_l_t_twisted_diode_',num2str(twists),'_',excitation];
else
    filename=['u_l_t_twisted_resistance_',num2str(twists),'_',excitation];
end
% plotten
diploma_plot(t*1e6,[plots(end,:);ifft_l_twisted_BLT(1:N_t)],label,x_label,y_label,legends,limits,pathname,filename,1,'plot','beamer',location);
% Rohdaten des Diagramms abspeichern (f�r pgfplots)
csv_data=[(t*1e6).',plots(end,:).'];
csv_data=compress_csv_data2(csv_data,1000);
save([pathname,filename,'_td.dat'],'csv_data','-ascii');
csv_data=[(t*1e6).',ifft_l_twisted_BLT(1:N_t).'];
csv_data=compress_csv_data2(csv_data,1000);
save([pathname,filename,'_ifft.dat'],'csv_data','-ascii');
% Dateiname -> String
if diode
    filename=['u_0_t_twisted_diode_',num2str(twists),'_',excitation];
else
    filename=['u_0_t_twisted_resistance_',num2str(twists),'_',excitation];
end
% plotten
diploma_plot(t*1e6,[plots(1,:);ifft_0_twisted_BLT(1:N_t)],label,x_label,y_label,legends,limits,pathname,filename,2,'plot','beamer',location);
% Rohdaten des Diagramms abspeichern (f�r pgfplots)
csv_data=[(t*1e6).',plots(1,:).'];
csv_data=compress_csv_data2(csv_data,1000);
save([pathname,filename,'_td.dat'],'csv_data','-ascii');
csv_data=[(t*1e6).',ifft_0_twisted_BLT(1:N_t).'];
csv_data=compress_csv_data2(csv_data,1000);
save([pathname,filename,'_ifft.dat'],'csv_data','-ascii');

if strcmp(quantity,'U_along')
    % Anzahl der Ortspunkte -> Skalar
    R=size(plots,1);    
    % Ort entlang der Leitung -> Zeilenvektor(1,R)
    r=linspace(0,l,R);    
    label='';
    x_label='entlang der Leitung (in m)';
    y_label='u(z,t) (in V)';
    legends={};
    limits=[0 l -E_0*s*3/4 E_0*s*3/4];
    pathname='./videos/';
    if diode
        filename=['u_z_t_twisted_diode_',num2str(twists),'_',excitation];
    else
        filename=['u_z_t_twisted_',num2str(twists),'_',excitation];
    end
    n_max=find(t<=0.6*t_max,1,'last');
    t_step=5;
    dual_movie_plot(t(1:t_step:n_max),r,plots(:,1:t_step:n_max),label,x_label,y_label,legends,limits,[pathname,'Dual'],filename,3,'plot','dual_video_small')
end
