%% =========================================================
% VEHICLE DYNAMICS - RUN AND SAVE SIMULATION
% Formula Vehicle vs Road Vehicle
%
% This script:
%   1. Selects Formula or Road vehicle parameters
%   2. Selects Steady-State or Step-Steer manoeuvre
%   3. Sets the required simulation duration
%   4. Runs Bicycle_Model.slx
%   5. Reads signals from the Simulink SimulationOutput object "out"
%   6. Saves each run to a separate .mat file
%
% IMPORTANT:
%   Configure the steering input block manually before running:
%
%   Steady-State:
%       Ramp slope    = 2 deg/s
%       Start time    = 0 s
%       Initial output = 0 deg
%
%   Step-Steer:
%       Step time = 3 s
%       Formula SWA = 11 deg
%       Road SWA    = 18 deg
%
% Vehicle speed should be set to 120 km/h.
% ==========================================================

clear;
clc;

%% -----------------------------
% MODEL NAME
% ------------------------------

model = 'Bicycle_Model';

%% -----------------------------
% SELECT VEHICLE
% ------------------------------

fprintf('\n========================================\n');
fprintf(' VEHICLE SELECTION\n');
fprintf('========================================\n');
fprintf('1 = Formula Vehicle\n');
fprintf('2 = Road Vehicle\n\n');

vehicle = input('Select vehicle: ');

switch vehicle

    case 1
        vehicleName = 'Formula';
        parameterFile = 'Bicycle_model_parameters_formula.m';

    case 2
        vehicleName = 'Road';
        parameterFile = 'Bicycle_model_parameters_road.m';

    otherwise
        error('Invalid vehicle selection. Enter 1 or 2.');

end

%% -----------------------------
% LOAD VEHICLE PARAMETERS
% -----------------------------

if ~isfile(parameterFile)
    error('Parameter file not found: %s', parameterFile);
end

run(parameterFile);

fprintf('\nLoaded parameter file: %s\n', parameterFile);

%% -----------------------------
% SELECT MANOEUVRE
% ------------------------------

fprintf('\n========================================\n');
fprintf(' MANOEUVRE SELECTION\n');
fprintf('========================================\n');
fprintf('1 = Steady-State Cornering\n');
fprintf('2 = Step-Steer\n\n');

test = input('Select manoeuvre: ');

switch test

    case 1
        testName = 'SteadyState';

        if vehicle == 1
            stopTime = 20;   % Formula vehicle
        else
            stopTime = 40;   % Road vehicle
        end

        fprintf('\nSteady-State setup required:\n');
        fprintf('  Vehicle speed = 120 km/h\n');
        fprintf('  Ramp slope    = 2 deg/s\n');
        fprintf('  Start time    = 0 s\n');
        fprintf('  Initial output = 0 deg\n');

    case 2
        testName = 'StepSteer';
        stopTime = 10;

        fprintf('\nStep-Steer setup required:\n');
        fprintf('  Vehicle speed = 120 km/h\n');
        fprintf('  Step time     = 3 s\n');

        if vehicle == 1
            fprintf('  Step size     = 11 deg SWA\n');
        else
            fprintf('  Step size     = 18 deg SWA\n');
        end

    otherwise
        error('Invalid manoeuvre selection. Enter 1 or 2.');

end

%% -----------------------------
% LOAD MODEL
% -----------------------------

if ~bdIsLoaded(model)
    load_system(model);
end

%% -----------------------------
% SET SIMULATION STOP TIME
% -----------------------------

set_param(model, 'StopTime', num2str(stopTime));

fprintf('\nSimulation stop time set to %.1f s\n', stopTime);

%% -----------------------------
% RUN SIMULATION
% -----------------------------

fprintf('\n========================================\n');
fprintf(' RUNNING SIMULATION\n');
fprintf('========================================\n');
fprintf('Vehicle   : %s\n', vehicleName);
fprintf('Manoeuvre : %s\n', testName);
fprintf('Stop time : %.1f s\n\n', stopTime);

out = sim(model);

fprintf('Simulation complete.\n');

%% -----------------------------
% CHECK REQUIRED OUTPUT SIGNALS
% -----------------------------

requiredSignals = {'sideslip','yawrate','latacc','X','Y','tout'};

for i = 1:numel(requiredSignals)

    signalName = requiredSignals{i};

    if ~isprop(out, signalName) && ~ismember(signalName, out.who)
        error('Expected simulation output "%s" was not found in out.', ...
              signalName);
    end

end

%% -----------------------------
% STORE RESULTS
% -----------------------------

Results = struct;

Results.Vehicle   = vehicleName;
Results.Test      = testName;
Results.ParameterFile = parameterFile;

% Simulation outputs
Results.sideslip = out.sideslip;
Results.yawrate  = out.yawrate;
Results.latacc   = out.latacc;
Results.X        = out.X;
Results.Y        = out.Y;
Results.tout     = out.tout;

%% -----------------------------
% STORE VEHICLE PARAMETERS
% -----------------------------

Results.Parameters.m   = m;
Results.Parameters.I   = I;
Results.Parameters.L   = L;
Results.Parameters.a   = a;
Results.Parameters.b   = b;
Results.Parameters.SR  = SR;

Results.Parameters.A   = A;
Results.Parameters.cz  = cz;
Results.Parameters.rho = rho;

Results.Parameters.Cf  = Cf;
Results.Parameters.Bf  = Bf;
Results.Parameters.Ef  = Ef;
Results.Parameters.a1f = a1f;
Results.Parameters.a2f = a2f;

Results.Parameters.Cr  = Cr;
Results.Parameters.Br  = Br;
Results.Parameters.Er  = Er;
Results.Parameters.a1r = a1r;
Results.Parameters.a2r = a2r;

%% -----------------------------
% STORE SIMULATION INFORMATION
% -----------------------------

Results.Simulation.VehicleSpeed_kph = 120;
Results.Simulation.StopTime_s       = stopTime;

if test == 1
    Results.Simulation.SteeringInput = 'Ramp';
    Results.Simulation.RampSlope_deg_s = 2;
    Results.Simulation.RampStartTime_s = 0;
else
    Results.Simulation.SteeringInput = 'Step';
    Results.Simulation.StepTime_s = 3;

    if vehicle == 1
        Results.Simulation.StepSize_SWA_deg = 11;
    else
        Results.Simulation.StepSize_SWA_deg = 18;
    end
end

%% -----------------------------
% CREATE OUTPUT FOLDER
% -----------------------------

outputFolder = 'Simulation_Results';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% -----------------------------
% SAVE RESULTS
% -----------------------------

fileName = fullfile( ...
    outputFolder, ...
    [vehicleName '_' testName '.mat']);

save(fileName, 'Results');

fprintf('\n========================================\n');
fprintf(' RESULTS SAVED\n');
fprintf('========================================\n');
fprintf('%s\n', fileName);

%% -----------------------------
% DISPLAY SAVED CONTENT
% -----------------------------

fprintf('\nSaved signals:\n');
fprintf('  Results.sideslip\n');
fprintf('  Results.yawrate\n');
fprintf('  Results.latacc\n');
fprintf('  Results.X\n');
fprintf('  Results.Y\n');
fprintf('  Results.tout\n');

fprintf('\nRun complete.\n');
