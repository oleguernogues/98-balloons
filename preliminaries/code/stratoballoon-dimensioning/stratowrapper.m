%
%	This routine just launches the "stratoballoon.m" routine many times, for different values of its Rb and dT parameters
%

clear all
close all


 Wp = [0.1 0.2 0.5 1 2 5 10 20 50 100]* 1e3;		% Payload weight [g]
 Rb = [4 8 17 23];					% Balloon skin density [g/m^2]. For polyethylene balloons it is a constant, for latex balloons it is the density as accounted when the ballon explodes. 
 dT = [0 50];						% Temperature difference [K] between Helium (inside balloon) and outer air

 for k=1:length(Rb)
  for m=1:length(dT)
   stratoballoon(Wp,Rb(k),dT(m));
  end
 end
