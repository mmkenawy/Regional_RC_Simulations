function [xsd,xsv,xsa] = integrate(per,delt,npnts,beta,gacc)
% Integrate the equation of motion for a SDOF system subjected to a
% piece-wise linear forcing function exactly
% this algorithm is based on the fortran script by David McCallen (1991)

% -----Variable list
% -----LIST OF VARIABLES AND ARRAYS PASSED INTO ROUTINE AS INPUT...
% -----------------------------------------------------------------
% -----omega=natural frequency of the SDOF system  (radians/second)
% -----delt=time increment in acceleration time history record
% -----npnts=number of time steps in the time history record
% -----beta=percent critical damping in the SDOF system
% -----gacc(i)=vector containing ground acceleration values
% 
% -----LIST OF VARIABLES PASSED OUT OF ROUTINE AS OUPUT...
% --------------------------------------------------------
% -----xsa=spectral acceleration ordinate
% -----xsv=spectral velocity ordinate
% -----xsd=spectral displacement ordinate

% frequency corresponding to period of interest
omega = 8.*atan(1.)/per;

% Set integration time step
stepsize = 0.002;
nsubinc = delt/stepsize;

%initial variable values
xsd = 0.;
xsv = 0.;
xsa = 0.;
olddisp = 0.;
oldvel = 0.;
oldgrnd = 0.;

% Calculate constants in the integration
omegdelt = omega*stepsize;
decay = exp(-beta*omega*stepsize);

a1 = decay*(cos(omegdelt)+beta*sin(omegdelt));
a2 = decay*(sin(omegdelt)/omega);
a3 = (1./(omega^2))*(decay*(cos(omegdelt)+beta*sin(omegdelt))-1.);
a4 = -(1./(omega^2))*((stepsize-(2.*beta)/(omega))+...
     decay*((((2.*beta)/(omega))*cos(omegdelt))+...
     ((1./omega)*(2.*(beta^2)-1.)*sin(omegdelt))));

b1 = -omega*decay*(1.+(beta^2))*sin(omegdelt);
b2 = decay*(cos(omegdelt)-(beta*sin(omegdelt)));
b3 = -(decay/omega)*(1.+(beta^2))*sin(omegdelt);
b4 = (decay/(omega^2))*(cos(omegdelt)+(beta*(1.+2.*(beta^2)))...
    *sin(omegdelt))-(1./(omega^2));

for i = 1:npnts
    xnewgnd = gacc(i);
    slope = (xnewgnd - oldgrnd)/delt;
    xoldgrnd = oldgrnd;
    
    for j = 1:nsubinc
        xnewdsp = a1*olddisp + a2*oldvel + a3*xoldgrnd + a4*slope;
        xnewvel = b1*olddisp + b2*oldvel + b3*xoldgrnd + b4*slope;
        xnewacc = -2.*beta*omega*xnewvel - (omega^2)*xnewdsp;

        if abs(xnewdsp) > xsd
             xsd = abs(xnewdsp);
        end
        if abs(xnewvel) > xsv
             xsv = abs(xnewvel);
        end
        if abs(xnewacc) > xsa
             xsa = abs(xnewacc);
        end
 
        olddisp = xnewdsp;
        oldvel = xnewvel;
        xoldgrnd = oldgrnd +(j*stepsize*slope);
    end

    oldgrnd = xnewgnd;
end
end



