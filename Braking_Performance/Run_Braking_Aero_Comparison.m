%% ============================================================
%  Aerodynamic Effect on Braking Performance
%
%  Cases:
%  1) 300 -> 180 km/h - Original Aero
%  2) 300 -> 180 km/h - +50% Aero
%  3) 180 -> 100 km/h - Original Aero
%  4) 180 -> 100 km/h - +50% Aero
% ============================================================

clear;
clc;
close all;


%% ============================================================
%  RESULTS FOLDER
% ============================================================

resultsFolder = 'Braking_Assignment_Results';

if ~exist(resultsFolder, 'dir')
    mkdir(resultsFolder);
end


%% ============================================================
%  LOAD VEHICLE PARAMETERS
% ============================================================

run('Longitudinal_Braking_parameters.m');

% Assignment value for front brake balance
balance = 0.65;


%% ============================================================
%  SIMULINK MODEL
% ============================================================

model = 'Braking_dynamics_model';

load_system(model);


%% ============================================================
%  AERODYNAMIC PARAMETERS
% ============================================================

% Original aerodynamic configuration
cd_original = 0.40;
cz_original = 1.00;

% +50% aerodynamic configuration
cd_high = cd_original * 1.50;
cz_high = cz_original * 1.50;


fprintf('\n');
fprintf('==============================================\n');
fprintf(' AERODYNAMIC BRAKING PERFORMANCE ASSIGNMENT\n');
fprintf('==============================================\n');

fprintf('\nOriginal Aero:\n');
fprintf('cd = %.2f\n', cd_original);
fprintf('cz = %.2f\n', cz_original);

fprintf('\n+50%% Aero:\n');
fprintf('cd = %.2f\n', cd_high);
fprintf('cz = %.2f\n', cz_high);


%% ============================================================
%  HIGH-SPEED TEST
%  300 -> 180 km/h
% ============================================================

fprintf('\n');
fprintf('==============================================\n');
fprintf(' HIGH-SPEED BRAKING: 300 -> 180 km/h\n');
fprintf('==============================================\n');

% Initial speed slightly above 300 km/h
initialSpeedHigh = 320;

% Full braking
brakeHigh = 1.00;

% Brake application time
brakeStartTime = 1.00;

% Assignment specifies 3 seconds braking
brakeDurationHigh = 3.00;


% ------------------------------------------------------------
% ORIGINAL AERO
% ------------------------------------------------------------

high_original = runBrakingCase( ...
    model, ...
    initialSpeedHigh, ...
    brakeHigh, ...
    brakeStartTime, ...
    brakeDurationHigh, ...
    cd_original, ...
    cz_original, ...
    300, ...
    180);


% ------------------------------------------------------------
% +50% AERO
% ------------------------------------------------------------

high_aero = runBrakingCase( ...
    model, ...
    initialSpeedHigh, ...
    brakeHigh, ...
    brakeStartTime, ...
    brakeDurationHigh, ...
    cd_high, ...
    cz_high, ...
    300, ...
    180);



%% ============================================================
%  LOW-SPEED TEST
%  180 -> 100 km/h
% ============================================================

fprintf('\n');
fprintf('==============================================\n');
fprintf(' LOW-SPEED BRAKING: 180 -> 100 km/h\n');
fprintf('==============================================\n');

% Initial speed slightly above 180 km/h
initialSpeedLow = 190;

% Almost maximum braking
brakeLow = 0.85;

% Assignment specifies 2.5 seconds braking
brakeDurationLow = 2.50;


% ------------------------------------------------------------
% ORIGINAL AERO
% ------------------------------------------------------------

low_original = runBrakingCase( ...
    model, ...
    initialSpeedLow, ...
    brakeLow, ...
    brakeStartTime, ...
    brakeDurationLow, ...
    cd_original, ...
    cz_original, ...
    180, ...
    100);


% ------------------------------------------------------------
% +50% AERO
% ------------------------------------------------------------

low_aero = runBrakingCase( ...
    model, ...
    initialSpeedLow, ...
    brakeLow, ...
    brakeStartTime, ...
    brakeDurationLow, ...
    cd_high, ...
    cz_high, ...
    180, ...
    100);



%% ============================================================
%  CALCULATE PERFORMANCE DIFFERENCE
% ============================================================

high_time_difference = ...
    high_original.brakingTime - high_aero.brakingTime;

high_percentage_improvement = ...
    (high_time_difference / high_original.brakingTime) * 100;


low_time_difference = ...
    low_original.brakingTime - low_aero.brakingTime;

low_percentage_improvement = ...
    (low_time_difference / low_original.brakingTime) * 100;



%% ============================================================
%  DISPLAY RESULTS
% ============================================================

fprintf('\n\n');
fprintf('==============================================\n');
fprintf(' FINAL RESULTS\n');
fprintf('==============================================\n');


fprintf('\nHIGH SPEED: 300 -> 180 km/h\n');
fprintf('----------------------------------------------\n');

fprintf('Original Aero braking time : %.4f s\n', ...
    high_original.brakingTime);

fprintf('+50%% Aero braking time      : %.4f s\n', ...
    high_aero.brakingTime);

fprintf('Time improvement           : %.4f s\n', ...
    high_time_difference);

fprintf('Percentage improvement     : %.2f %%\n', ...
    high_percentage_improvement);


fprintf('\nLOW SPEED: 180 -> 100 km/h\n');
fprintf('----------------------------------------------\n');

fprintf('Original Aero braking time : %.4f s\n', ...
    low_original.brakingTime);

fprintf('+50%% Aero braking time      : %.4f s\n', ...
    low_aero.brakingTime);

fprintf('Time improvement           : %.4f s\n', ...
    low_time_difference);

fprintf('Percentage improvement     : %.2f %%\n', ...
    low_percentage_improvement);



%% ============================================================
%  HIGH-SPEED VELOCITY PLOT
% ============================================================

fig1 = figure;

plot( ...
    high_original.time, ...
    high_original.velocity, ...
    'LineWidth', 1.6);

hold on;

plot( ...
    high_aero.time, ...
    high_aero.velocity, ...
    'LineWidth', 1.6);

yline(300, '--', '300 km/h');
yline(180, '--', '180 km/h');

xlabel('Time [s]');
ylabel('Vehicle Speed [km/h]');

title('High-Speed Braking: 300 to 180 km/h');

legend( ...
    'Original Aero', ...
    '+50% Aero', ...
    'Location', ...
    'best');

grid on;
box on;

% Save PNG
exportgraphics( ...
    fig1, ...
    fullfile(resultsFolder, ...
    'High_Speed_Braking_300_180.png'), ...
    'Resolution', ...
    300);

% Save editable MATLAB figure
savefig( ...
    fig1, ...
    fullfile(resultsFolder, ...
    'High_Speed_Braking_300_180.fig'));



%% ============================================================
%  LOW-SPEED VELOCITY PLOT
% ============================================================

fig2 = figure;

plot( ...
    low_original.time, ...
    low_original.velocity, ...
    'LineWidth', 1.6);

hold on;

plot( ...
    low_aero.time, ...
    low_aero.velocity, ...
    'LineWidth', 1.6);

yline(180, '--', '180 km/h');
yline(100, '--', '100 km/h');

xlabel('Time [s]');
ylabel('Vehicle Speed [km/h]');

title('Low-Speed Braking: 180 to 100 km/h');

legend( ...
    'Original Aero', ...
    '+50% Aero', ...
    'Location', ...
    'best');

grid on;
box on;

% Save PNG
exportgraphics( ...
    fig2, ...
    fullfile(resultsFolder, ...
    'Low_Speed_Braking_180_100.png'), ...
    'Resolution', ...
    300);

% Save editable MATLAB figure
savefig( ...
    fig2, ...
    fullfile(resultsFolder, ...
    'Low_Speed_Braking_180_100.fig'));



%% ============================================================
%  COMPARISON OF AERO BENEFIT
% ============================================================

fig3 = figure;

bar([ ...
    high_percentage_improvement, ...
    low_percentage_improvement]);

set(gca, ...
    'XTick', ...
    [1 2], ...
    'XTickLabel', ...
    {'300-180 km/h', '180-100 km/h'});

ylabel('Reduction in Braking Time [%]');

title('Effect of +50% Aerodynamic Load on Braking');

grid on;
box on;

% Save PNG
exportgraphics( ...
    fig3, ...
    fullfile(resultsFolder, ...
    'Aero_Braking_Performance_Comparison.png'), ...
    'Resolution', ...
    300);

% Save MATLAB figure
savefig( ...
    fig3, ...
    fullfile(resultsFolder, ...
    'Aero_Braking_Performance_Comparison.fig'));



%% ============================================================
%  RESULTS TABLE
% ============================================================

Test = [
    "300-180 km/h"
    "180-100 km/h"
    ];

Original_cd = [
    cd_original
    cd_original
    ];

Original_cz = [
    cz_original
    cz_original
    ];

Increased_cd = [
    cd_high
    cd_high
    ];

Increased_cz = [
    cz_high
    cz_high
    ];

OriginalAeroTime_s = [
    high_original.brakingTime
    low_original.brakingTime
    ];

IncreasedAeroTime_s = [
    high_aero.brakingTime
    low_aero.brakingTime
    ];

TimeImprovement_s = [
    high_time_difference
    low_time_difference
    ];

PercentageImprovement = [
    high_percentage_improvement
    low_percentage_improvement
    ];


Results = table( ...
    Test, ...
    Original_cd, ...
    Original_cz, ...
    Increased_cd, ...
    Increased_cz, ...
    OriginalAeroTime_s, ...
    IncreasedAeroTime_s, ...
    TimeImprovement_s, ...
    PercentageImprovement);


disp(Results);



%% ============================================================
%  SAVE RESULTS TABLE AS CSV
% ============================================================

writetable( ...
    Results, ...
    fullfile(resultsFolder, ...
    'Braking_Aero_Results.csv'));



%% ============================================================
%  SAVE RAW HIGH-SPEED DATA
% ============================================================

HighSpeedOriginal = table( ...
    high_original.time, ...
    high_original.velocity, ...
    'VariableNames', ...
    {'Time_s', 'Velocity_kmh'});

writetable( ...
    HighSpeedOriginal, ...
    fullfile(resultsFolder, ...
    'High_Speed_Original_Aero.csv'));


HighSpeedIncreasedAero = table( ...
    high_aero.time, ...
    high_aero.velocity, ...
    'VariableNames', ...
    {'Time_s', 'Velocity_kmh'});

writetable( ...
    HighSpeedIncreasedAero, ...
    fullfile(resultsFolder, ...
    'High_Speed_50pct_Aero.csv'));



%% ============================================================
%  SAVE RAW LOW-SPEED DATA
% ============================================================

LowSpeedOriginal = table( ...
    low_original.time, ...
    low_original.velocity, ...
    'VariableNames', ...
    {'Time_s', 'Velocity_kmh'});

writetable( ...
    LowSpeedOriginal, ...
    fullfile(resultsFolder, ...
    'Low_Speed_Original_Aero.csv'));


LowSpeedIncreasedAero = table( ...
    low_aero.time, ...
    low_aero.velocity, ...
    'VariableNames', ...
    {'Time_s', 'Velocity_kmh'});

writetable( ...
    LowSpeedIncreasedAero, ...
    fullfile(resultsFolder, ...
    'Low_Speed_50pct_Aero.csv'));



%% ============================================================
%  FINISHED
% ============================================================

fprintf('\n');
fprintf('==============================================\n');
fprintf(' ANALYSIS COMPLETE\n');
fprintf('==============================================\n');

fprintf('\nAll results saved in:\n');
fprintf('%s\n\n', fullfile(pwd, resultsFolder));



%% ============================================================
%  LOCAL FUNCTION
%  RUN ONE BRAKING CASE
% ============================================================

function result = runBrakingCase( ...
    model, ...
    initialSpeed, ...
    brakePedal, ...
    brakeStartTime, ...
    brakeDuration, ...
    cd_value, ...
    cz_value, ...
    upperSpeed, ...
    lowerSpeed)

    %% --------------------------------------------------------
    % Update aerodynamic parameters
    % ---------------------------------------------------------

    assignin('base', 'cd', cd_value);
    assignin('base', 'cz', cz_value);


    %% --------------------------------------------------------
    % Set initial vehicle speed
    %
    % The supplied Simulink model uses the root-level
    % Constant block as the Initial Velocity [km/h] input.
    % ---------------------------------------------------------

    set_param( ...
        [model '/Constant'], ...
        'Value', ...
        num2str(initialSpeed));


    %% --------------------------------------------------------
    % Set brake step
    % ---------------------------------------------------------

    set_param( ...
        [model '/Step'], ...
        'Time', ...
        num2str(brakeStartTime));

    set_param( ...
        [model '/Step'], ...
        'Before', ...
        '0');

    set_param( ...
        [model '/Step'], ...
        'After', ...
        num2str(brakePedal));


    %% --------------------------------------------------------
    % Simulation time
    % ---------------------------------------------------------

    stopTime = brakeStartTime + brakeDuration;


    %% --------------------------------------------------------
    % Run simulation
    % ---------------------------------------------------------

    simOut = sim( ...
        model, ...
        'StopTime', ...
        num2str(stopTime), ...
        'ReturnWorkspaceOutputs', ...
        'on');


    %% --------------------------------------------------------
    % Get vehicle velocity output
    %
    % The supplied model saves Velocity [km/h]
    % to workspace variable V.
    % ---------------------------------------------------------

    try

        Vout = simOut.get('V');

    catch

        Vout = evalin('base', 'V');

    end


    time = Vout.Time;

    velocity = squeeze(Vout.Data);


    %% --------------------------------------------------------
    % Find speed crossings
    % ---------------------------------------------------------

    idxUpper = find( ...
        velocity <= upperSpeed, ...
        1, ...
        'first');

    idxLower = find( ...
        velocity <= lowerSpeed, ...
        1, ...
        'first');


    if isempty(idxUpper)

        error( ...
            ['Vehicle never crossed %.1f km/h. ' ...
             'Increase initial velocity or simulation time.'], ...
            upperSpeed);

    end


    if isempty(idxLower)

        error( ...
            ['Vehicle never reached %.1f km/h. ' ...
             'Increase braking duration or simulation time.'], ...
            lowerSpeed);

    end


    %% --------------------------------------------------------
    % Interpolate speed crossing times
    % ---------------------------------------------------------

    tUpper = interpolateCrossing( ...
        time, ...
        velocity, ...
        idxUpper, ...
        upperSpeed);


    tLower = interpolateCrossing( ...
        time, ...
        velocity, ...
        idxLower, ...
        lowerSpeed);


    %% --------------------------------------------------------
    % Calculate braking time
    % ---------------------------------------------------------

    brakingTime = tLower - tUpper;


    %% --------------------------------------------------------
    % Store outputs
    % ---------------------------------------------------------

    result.time = time;

    result.velocity = velocity;

    result.tUpper = tUpper;

    result.tLower = tLower;

    result.brakingTime = brakingTime;

    result.cd = cd_value;

    result.cz = cz_value;


    %% --------------------------------------------------------
    % Display case results
    % ---------------------------------------------------------

    fprintf('\n');

    fprintf( ...
        'cd = %.3f | cz = %.3f\n', ...
        cd_value, ...
        cz_value);

    fprintf( ...
        'Time at %.0f km/h = %.4f s\n', ...
        upperSpeed, ...
        tUpper);

    fprintf( ...
        'Time at %.0f km/h = %.4f s\n', ...
        lowerSpeed, ...
        tLower);

    fprintf( ...
        'Braking time       = %.4f s\n', ...
        brakingTime);

end



%% ============================================================
%  LOCAL FUNCTION
%  LINEAR INTERPOLATION FOR SPEED CROSSING
% ============================================================

function tcross = interpolateCrossing( ...
    time, ...
    velocity, ...
    index, ...
    targetSpeed)

    if index <= 1

        tcross = time(index);

        return;

    end


    t1 = time(index - 1);
    t2 = time(index);

    v1 = velocity(index - 1);
    v2 = velocity(index);


    tcross = ...
        t1 + ...
        (targetSpeed - v1) ...
        * (t2 - t1) ...
        / (v2 - v1);

end