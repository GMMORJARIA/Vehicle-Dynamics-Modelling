%% Constants
g = 9.81; % Gravity

%% Vehicle Parameters 
m = 850 ; % Mass [kg]
I = 1500; % Yaw Inertia [kgm^2]
L = 3.5; % Wheelbase[m]
a = 1.8; % CoG front distance [m]
b = L-a; % CoG rear distance [m]
%% Aero Parameters 
A= 1.25 ; % Frontal Area [m^2]
cz = 1; % DF Coefficient
rho = 1.225;% Air density [kg/m^3]
%% Front Tyre Parameters 
Cf = 1.8391; % Shape Factor  
Bf = 0.2719; % Stiffness Factor 
Ef = -2.5276; % Curvature Factor 
a1f = -1e-5 ; % Peak Value 
a2f = 1.25; % Peak Value 
%% Rear Tyre Parameter 
Cr = 1.7631; % Shape Factor 
Br = 0.3609; % Stiffness Factor 
Er = -1.9890; % Curvature Factor 
a1r = -1e-5 ; % Peak Value 
a2r = 1.25; % Peak Value 
%% Steering System parametrs 
SR = 10; % Streering Ratio [deg/deg]