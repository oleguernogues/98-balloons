%	Polyethilyene (PE) Stratospheric Balloon Dimensioning. Quite valid as well for Latex balloons.
%	by Oleguer Nogués, June 2013
%
%	This script computes the required dimensions of a stratospheric baloon (volume and skin surface area) given a certain target altitude. 
% 	The script takes into account the parameters that influence the problem:
%
%	1) pressure (P) and temperature (T) versus altitude (H) (average atmosphere model)
%	2) Molar weight of atmospheric air (Ma) and Helium (Mhe)
%	3) Weight of the Payload (Wp)
%	4) Weight of the balloon (Wb), mainly driven by the surface density (Rb, in g/m^2) of the material used to craft the balloon skin
%	5) Temperature difference between Helium and outer air (dT), which may be induced by greenhouse effect of the ballon, when sun rays impinge on it.
%
%	We assume that the balloon is open thru its base, so that the Helium inside the balloon has the same pressure as that of the air outside.
%	Regarding the Helium temperature we consider two cases: one in which the Helium is at the same temperature (no influence of sun radiation)
%	and another in which the helium is at higher temperature (up to 50 degrees higher, as reported in some web articles).
%	At ground level, the balloon is partially filled, only with enough Helium so that it provides a lift that is a bit more than the weight, just enough to push up.
%	As the balloon climbs up the pressure decreases and the helium expands, and fills more of the available balloon volume. At a certain altitude the Helim fills the whole
%	volume, and starts to spill thru the lower neck of the ballon. At this moment the ballon will loose helium if it goes higher (as the pressure keeps dcreasing), and this
%	is thus the altitude in which it reaches equilibrium (lift equal to weight). For a Latex balloon the situation is not exactly as this one, as the Latex may infer some pressure 
%	differential between the inside and the outside of the balloon, but probably this difference can be neglected for first approach dimensioning estimations? (TBC)
%
%	The advantage of a Latex balloon is that it will climb as far as the Latex resists. One could even think of carrying big payloads with many latex balloons.
%	The disadvantage is that the latex balloon can be used only once, as it will end up exploting.
%
%	The advantage of polyethilene balloons is that they reach an altitude limit and they do not explote, thus enabling long-term missions, and even opening the possibility to control
%	ballon altitudes, and making controlled descents. The disadvantage is that construction of such big balloons might be not stright-forward (at the beginning). Though learning it
%	may provide a competitive advantage and --maybe-- open a business opportunity?

function stratoballoon(Wp,Rb,dT)

% clear all
% close all

% 0.- USER PARAMETERS INPUT

% Wp = [0.1 0.2 0.5 1 2 5 10 20 50 100]* 1e3;		% Payload weight [g]
% Rb = 8;						% Balloon skin density [g/m^2]. For polyethylene balloons it is a constant, for latex balloons it is the density as accounted when the ballon explodes. 
% dT = 50;						% Temperature difference [K] between Helium (inside balloon) and outer air

% 1.- PROBLEM CONSTANTS and ATMOSPHERE MODEL

 Mhe = 4;			% Molar weight of helium [g/mol]
 Ma = 28.9;			% Molar weight of air [g/mol]		
 R = 8.3144621;			% Molar constant for ideal gases [J/(K*mol)]

 filename='avge_pres_temp';	% Load atmosphere model
 filext='txt';
 eval(sprintf('load %s.%s;',filename,filext));
 eval(sprintf('tmp = %s;',filename)); 
 eval(sprintf('clear %s;',filename));
 H = tmp(:,1);			% Height [m]
 T = tmp(:,2)+273;		% Temperature [K] versus height
 P = tmp(:,3)*1000;		% Pressure [Pa] versus height

% 2.- COMPUTE BALLOON DIMENSTIONS FOR EVERY POSSIBLE HEIGHT

 V = zeros(length(H),length(Wp));  	% Required balloon volume
 Ln = (P/R).*(Ma./T-Mhe./(T+dT));	% Normalized lift per unit volume [g/m^3]
  for n=1:length(Wp)
   % Compute coefficients of equilibrium equation (third order polynomial)
   A = Ln;
   B = -4.836*Rb*ones(length(H),1);  
   C = zeros(length(H),1);
   D = -Wp(n)*ones(length(H),1);
   for p=1:length(H)  % Solve equilibrium equation for each heaight, to work out the maximum volume capacity needed (Total weight = lift at maximum ballon volume inflation)
    c = [A(p) B(p) C(p) D(p)] ;
    r = roots(c);
    V(p,n) = real(r(1))^3;    
   end
  M(:,n) = (V(:,n).*P./(R*(T+dT)))*Mhe;	% Required mass of helium, to fill the balloon and reach the required target altitude
  end

 S = 4.836*(V.^(2/3)); % Required balloon skin surface area (assuming spherical shape). 


% 3.- PLOT RESULTS AND SAVE

  ls = ['k+'; 'k*'; 'ko'; 'kx'; 'k^'; 'r+'; 'r*'; 'ro'; 'rx'; 'r^'; 'g+'; 'g*'; 'go'; 'gx'; 'g^'; 'b+'; 'b*'; 'bo'; 'bx'; 'b^';];
  lg = cell(length(Wp));
  chars=0;
  figure
  for n=1:length(Wp)
   eval(sprintf('plot(H/1000, 10*log10(S(:,n)),''-%s'')',ls(n,:)));
   axis([0 30])
   lg{n}=sprintf('%0.1f kg',Wp(n)./1000);
   chars=chars+length(lg{n})+3;
   strlg(chars-length(lg{n})-2:chars)=sprintf('''%s'',',lg{n});
   hold on
  end
  grid on
  xlabel('Height [km]')
  ylabel('10log_{10}(Surface Area [m^2])')
  title(sprintf('Required balloon skin surface area versus target height, for different payloads weights.\n Conditions: Balloon shape: sphere; Skin density: %0.3g g/m^2; Delta Temperature Helium-Air: %d K; Standard atmosphere;', Rb, dT));
  eval(sprintf('legend(%s''location'',''northwest'')',strlg));
  eval(sprintf('print -dpng balloon-surface-area-Rb%d-dT%d.png',round(Rb),round(dT)));
  close   

  figure
  for n=1:length(Wp)
   eval(sprintf('plot(H/1000, 10*log10(M(:,n)),''-%s'')',ls(n,:)));
   axis([0 30])
   hold on
  end
  grid on
  xlabel('Height [km]')
  ylabel('10log_{10}(Helium Mass[g])')
  title(sprintf('Minimum Helium mass to fill the balloon to reach target height, for different payload weights. \n Conditions: Balloon shape: sphere; Skin density: %0.3g g/m^2; Delta Temperature Helium-Air: %d K; Standard atmosphere;', Rb, dT));
  eval(sprintf('legend(%s''location'',''northwest'')',strlg));
  eval(sprintf('print -dpng balloon-helium-mass-Rb%d-dT%d.png',round(Rb),round(dT)));
  close   

