%% Constants
g = 9.81; % Gravity [m/s^2]

%% Vehicle Parameters
m = 1650; % Mass [kg]
I = 3500; % Yaw Inertia [kgm^2]
L = 2.8;  % Wheelbase [m]
a = 1.1;  % CoG front distance [m]
b = L-a;  % CoG rear distance [m]

%% Aero Parameters
A = 1.80;    % Frontal Area [m^2]
cz = 0.00;   % Downforce Coefficient
rho = 1.225; % Air density [kg/m^3]

%% Front Tyre Parameters
Caf = -1000.00; % Axle Cornering stiffness [N/deg]
Cf = 1.2947;  % Shape Factor
Bf = 0.0813;  % Stiffness Factor
Ef = -8.3966; % Curvature Factor
a1f = -1e-5;  % Peak Value Factor
a2f = 0.95;   % Peak Value Factor

%% Rear Tyre Parameters
Car = -700.00; % Axle Cornering stiffness [N/deg]
Cr = 1.2617;  % Shape Factor
Br = 0.0925;  % Stiffness Factor
Er = -8.7012; % Curvature Factor
a1r = -1e-5;  % Peak Value Factor
a2r = 0.95;   % Peak Value Factor

%% Steering System Parameters
SR = 20; % Steering Ratio [deg/deg]