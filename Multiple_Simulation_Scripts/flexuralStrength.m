function Mn = flexuralStrength(f_c,fyl,b,h,Est,Q,As_vec,d_vec,d)
%flexuralStrength: Compute nomibal flexural strength of an RC section given
%an axial load value, and including up to 4 rows of steel reinforcement

%%%% input parameters
% f_c = compressive strength of concrete (MPa)
% fyh = yield strength of the transverse reinforcement (MPa)
% d = section depth (mm)
% s = spacing between hoops/stirrups (mm)
% Astx = area of steel transverse reinforcement in a single direction (number
% of reinforcement legs * the area of a single bar) (mm^2)


    
% assumed parameters
epsu = 0.003;
beta1 = 0.85;

%%%% 1. Find the depth of the neutral axis c by solving the force
%%%% equilibrium equation graphically

% look through NA depths between 0.0 and d
x = h/100:h/100:h*2;

%initialize
func = zeros(1,length(x));
epss = zeros(4,length(x));
fs = zeros(4,length(x));

% loop over all values of c
for i = 1:length(x)
    % loop over all rows of steel and compute strains and stresses for
    % given c
    for k = 1:4
        epss(k,i) = epsu*(x(i) - d_vec(k))/x(i);
        fs(k,i) = Est.*epss(k,i);
        if abs(fs(k,i)) > fyl
            fs(k,i) = fyl*sign(fs(k,i));
       end
    end
 
    % compute equilibrium function
    func(i) = 0.85*f_c*beta1*x(i)*b + As_vec(1)*fs(1,i) + As_vec(2)*fs(2,i) + ...
        As_vec(3)*fs(3,i) + As_vec(4)*fs(4,i) - Q;
end

% plot the force equilibrium function
%plot(x,func)

% find the root of the force equilibrium function (c is the value that
% results in func = 0.0)
c = interp1(func,x,0.0); %%% NA depth
a = beta1*c;
%corresponding steel stresses
fsf = zeros(1,4);
for k = 1:4
       fsf(k) = Est.*epsu.*(c - d_vec(k))/c;
       if abs(fsf(k)) > fyl
           fsf(k) = fyl*sign(fsf(k));
       end
end

% calculate the nominal moment capacity (take moments about the centroid)
Mn = 0.85*f_c*a*b*(h/2 - a/2) + As_vec(1)*fsf(1)*(h/2 - d_vec(1)) + As_vec(2)*fsf(2)*(h/2 - d_vec(2)) - ...
    As_vec(3)*fsf(3)*(d_vec(3) - h/2) - As_vec(4)*fsf(4)*(d_vec(4) - h/2);
%%% note: make sure the moment signs are consistent with the assumed signs
%%% for forces throughout

% confirm moment capacity by computing moments about another point (the
% bottom fiber)
Mnb = 0.85*f_c*a*b*(h - a/2) + As_vec(1)*fsf(1)*(h - d_vec(1)) + As_vec(2)*fsf(2)*(h - d_vec(2)) + ...
    As_vec(3)*fsf(3)*(h - d_vec(3)) + As_vec(4)*fsf(4)*(h - d_vec(4)) - Q*h/2;
end

