%% ============================================================
% VEHICLE DYNAMICS PERFORMANCE COMPARISON
% Formula Vehicle vs Road Vehicle
%
% Required result files:
%   Formula_SteadyState.mat
%   Road_SteadyState.mat
%   Formula_StepSteer.mat
%   Road_StepSteer.mat
%
% The script:
%   1. Loads all four saved simulations
%   2. Plots SWA vs lateral acceleration
%   3. Calculates SWA gradient in the 2-4 m/s^2 linear region
%   4. Calculates understeer gradient
%   5. Plots sideslip vs lateral acceleration and calculates its gradient
%   6. Plots lateral acceleration step response and calculates overshoot
%   7. Plots yaw-rate step response and calculates overshoot
%   8. Calculates 10-90% rise time and 2% settling time
%   9. Prints and saves a summary table
%
% NOTE:
% Magnitudes are used for the steady-state comparison so the results are
% independent of the sign convention used in the Simulink model.
% ============================================================

clear;
clc;
close all;

%% ------------------------------------------------------------
% SETTINGS
% -------------------------------------------------------------

resultsFolder = 'Simulation_Results';
figureFolder  = 'Analysis_Figures';

vehicleSpeed_kph = 120;
vehicleSpeed_ms  = vehicleSpeed_kph / 3.6;

rampSlope = 2;       % SWA ramp slope [deg/s]
linearAyMin = 2;     % Lower bound of fit region [m/s^2]
linearAyMax = 4;     % Upper bound of fit region [m/s^2]

stepTime = 3;        % Step applied at 3 s

if ~exist(figureFolder, 'dir')
    mkdir(figureFolder);
end

%% ------------------------------------------------------------
% LOAD RESULTS
% -------------------------------------------------------------

FormulaSS   = loadResult('Formula_SteadyState.mat', resultsFolder);
RoadSS      = loadResult('Road_SteadyState.mat', resultsFolder);
FormulaStep = loadResult('Formula_StepSteer.mat', resultsFolder);
RoadStep    = loadResult('Road_StepSteer.mat', resultsFolder);

fprintf('\nAll four simulation files loaded successfully.\n');

%% ------------------------------------------------------------
% EXTRACT STEADY-STATE DATA
% -------------------------------------------------------------

tF_SS    = FormulaSS.latacc.Time;
ayF_SS   = squeeze(FormulaSS.latacc.Data);
betaF_SS = squeeze(FormulaSS.sideslip.Data);

tR_SS    = RoadSS.latacc.Time;
ayR_SS   = squeeze(RoadSS.latacc.Data);
betaR_SS = squeeze(RoadSS.sideslip.Data);

% Steering-wheel angle from the imposed 2 deg/s ramp
SWA_F = rampSlope .* tF_SS;
SWA_R = rampSlope .* tR_SS;

% Use magnitudes for comparison irrespective of model sign convention
ayF_mag   = abs(ayF_SS);
ayR_mag   = abs(ayR_SS);
betaF_mag = abs(betaF_SS);
betaR_mag = abs(betaR_SS);

%% ------------------------------------------------------------
% 1. SWA VS LATERAL ACCELERATION
% -------------------------------------------------------------

maskF = ayF_mag >= linearAyMin & ayF_mag <= linearAyMax;
maskR = ayR_mag >= linearAyMin & ayR_mag <= linearAyMax;

if nnz(maskF) < 2 || nnz(maskR) < 2
    error(['Not enough points were found in the 2-4 m/s^2 fitting region. ', ...
           'Inspect the steady-state simulations before continuing.']);
end

% Linear fits: SWA = gradient * ay + intercept
fitSWA_F = polyfit(ayF_mag(maskF), SWA_F(maskF), 1);
fitSWA_R = polyfit(ayR_mag(maskR), SWA_R(maskR), 1);

SWAgradient_F = fitSWA_F(1);      % [deg SWA / (m/s^2)]
SWAgradient_R = fitSWA_R(1);

figure('Name','Steady-State SWA Response','Color','w');
plot(ayF_mag, SWA_F, 'LineWidth', 1.8);
hold on;
plot(ayR_mag, SWA_R, 'LineWidth', 1.8);

% Plot fitted sections
ayFit = linspace(linearAyMin, linearAyMax, 100);
plot(ayFit, polyval(fitSWA_F, ayFit), '--', 'LineWidth', 1.2);
plot(ayFit, polyval(fitSWA_R, ayFit), '--', 'LineWidth', 1.2);

xline(linearAyMin, ':');
xline(linearAyMax, ':');

xlabel('Lateral Acceleration, |a_y| [m/s^2]');
ylabel('Steering Wheel Angle [deg]');
title('Steady-State Steering Response at 120 km/h');
legend('Formula Vehicle','Road Vehicle', ...
       'Formula Linear Fit','Road Linear Fit', ...
       'Location','best');
grid on;
box on;

exportgraphics(gcf, fullfile(figureFolder,'01_SWA_vs_LateralAcceleration.png'), ...
               'Resolution',300);

%% ------------------------------------------------------------
% 2. UNDERSTEER GRADIENT
% -------------------------------------------------------------

SR_F = FormulaSS.Parameters.SR;
SR_R = RoadSS.Parameters.SR;

L_F = FormulaSS.Parameters.L;
L_R = RoadSS.Parameters.L;

% Assignment relationship:
% K_US = d(SWA)/d(ay) * 1/SR - L/V^2 * 180/pi

Kus_F = (SWAgradient_F / SR_F) ...
        - (L_F / vehicleSpeed_ms^2) * (180/pi);

Kus_R = (SWAgradient_R / SR_R) ...
        - (L_R / vehicleSpeed_ms^2) * (180/pi);

balanceF = classifyBalance(Kus_F);
balanceR = classifyBalance(Kus_R);

%% ------------------------------------------------------------
% 3. SIDESLIP VS LATERAL ACCELERATION
% -------------------------------------------------------------

fitBeta_F = polyfit(ayF_mag(maskF), betaF_mag(maskF), 1);
fitBeta_R = polyfit(ayR_mag(maskR), betaR_mag(maskR), 1);

BetaGradient_F = fitBeta_F(1);    % [deg / (m/s^2)]
BetaGradient_R = fitBeta_R(1);

figure('Name','Steady-State Sideslip Response','Color','w');
plot(ayF_mag, betaF_mag, 'LineWidth', 1.8);
hold on;
plot(ayR_mag, betaR_mag, 'LineWidth', 1.8);

plot(ayFit, polyval(fitBeta_F, ayFit), '--', 'LineWidth', 1.2);
plot(ayFit, polyval(fitBeta_R, ayFit), '--', 'LineWidth', 1.2);

xline(linearAyMin, ':');
xline(linearAyMax, ':');

xlabel('Lateral Acceleration, |a_y| [m/s^2]');
ylabel('Vehicle Sideslip, |\beta| [deg]');
title('Steady-State Sideslip Response at 120 km/h');
legend('Formula Vehicle','Road Vehicle', ...
       'Formula Linear Fit','Road Linear Fit', ...
       'Location','best');
grid on;
box on;

exportgraphics(gcf, fullfile(figureFolder,'02_Sideslip_vs_LateralAcceleration.png'), ...
               'Resolution',300);

%% ------------------------------------------------------------
% EXTRACT STEP-STEER DATA
% -------------------------------------------------------------

tF_step  = FormulaStep.latacc.Time;
ayF_step = squeeze(FormulaStep.latacc.Data);
rF_step  = squeeze(FormulaStep.yawrate.Data);

tR_step  = RoadStep.latacc.Time;
ayR_step = squeeze(RoadStep.latacc.Data);
rR_step  = squeeze(RoadStep.yawrate.Data);

%% ------------------------------------------------------------
% 4. LATERAL ACCELERATION STEP RESPONSE
% -------------------------------------------------------------

ayMetricsF = responseMetrics(tF_step, ayF_step, stepTime);
ayMetricsR = responseMetrics(tR_step, ayR_step, stepTime);

figure('Name','Lateral Acceleration Step Response','Color','w');
plot(tF_step, ayF_step, 'LineWidth', 1.8);
hold on;
plot(tR_step, ayR_step, 'LineWidth', 1.8);

xline(stepTime, '--', 'Step Input');

% Peak markers
plot(ayMetricsF.PeakTime, ayMetricsF.PeakSigned, 'o', ...
     'HandleVisibility','off');
plot(ayMetricsR.PeakTime, ayMetricsR.PeakSigned, 'o', ...
     'HandleVisibility','off');

xlabel('Time [s]');
ylabel('Lateral Acceleration [m/s^2]');
title('Step-Steer Lateral Acceleration Response at 120 km/h');
legend('Formula Vehicle','Road Vehicle','Location','best');
grid on;
box on;

exportgraphics(gcf, fullfile(figureFolder,'03_LateralAcceleration_StepResponse.png'), ...
               'Resolution',300);

%% ------------------------------------------------------------
% 5. YAW-RATE STEP RESPONSE
% -------------------------------------------------------------

yawMetricsF = responseMetrics(tF_step, rF_step, stepTime);
yawMetricsR = responseMetrics(tR_step, rR_step, stepTime);

figure('Name','Yaw Rate Step Response','Color','w');
plot(tF_step, rF_step, 'LineWidth', 1.8);
hold on;
plot(tR_step, rR_step, 'LineWidth', 1.8);

xline(stepTime, '--', 'Step Input');

plot(yawMetricsF.PeakTime, yawMetricsF.PeakSigned, 'o', ...
     'HandleVisibility','off');
plot(yawMetricsR.PeakTime, yawMetricsR.PeakSigned, 'o', ...
     'HandleVisibility','off');

xlabel('Time [s]');
ylabel('Yaw Rate [deg/s]');
title('Step-Steer Yaw Rate Response at 120 km/h');
legend('Formula Vehicle','Road Vehicle','Location','best');
grid on;
box on;

exportgraphics(gcf, fullfile(figureFolder,'04_YawRate_StepResponse.png'), ...
               'Resolution',300);

%% ------------------------------------------------------------
% RESULTS SUMMARY
% -------------------------------------------------------------

Vehicle = ["Formula"; "Road"];

SWA_Gradient_deg_per_ms2 = [SWAgradient_F; SWAgradient_R];
Understeer_Gradient_deg_per_ms2 = [Kus_F; Kus_R];
Balance = [string(balanceF); string(balanceR)];
Sideslip_Gradient_deg_per_ms2 = [BetaGradient_F; BetaGradient_R];

LatAcc_SteadyState_ms2 = [ayMetricsF.SteadySigned; ayMetricsR.SteadySigned];
LatAcc_Peak_ms2        = [ayMetricsF.PeakSigned; ayMetricsR.PeakSigned];
LatAcc_Overshoot_pct   = [ayMetricsF.OvershootPercent; ayMetricsR.OvershootPercent];
LatAcc_RiseTime_s      = [ayMetricsF.RiseTime; ayMetricsR.RiseTime];
LatAcc_SettlingTime_s  = [ayMetricsF.SettlingTime; ayMetricsR.SettlingTime];

YawRate_SteadyState_deg_s = [yawMetricsF.SteadySigned; yawMetricsR.SteadySigned];
YawRate_Peak_deg_s        = [yawMetricsF.PeakSigned; yawMetricsR.PeakSigned];
YawRate_Overshoot_pct     = [yawMetricsF.OvershootPercent; yawMetricsR.OvershootPercent];
YawRate_RiseTime_s        = [yawMetricsF.RiseTime; yawMetricsR.RiseTime];
YawRate_SettlingTime_s    = [yawMetricsF.SettlingTime; yawMetricsR.SettlingTime];

Summary = table( ...
    Vehicle, ...
    SWA_Gradient_deg_per_ms2, ...
    Understeer_Gradient_deg_per_ms2, ...
    Balance, ...
    Sideslip_Gradient_deg_per_ms2, ...
    LatAcc_SteadyState_ms2, ...
    LatAcc_Peak_ms2, ...
    LatAcc_Overshoot_pct, ...
    LatAcc_RiseTime_s, ...
    LatAcc_SettlingTime_s, ...
    YawRate_SteadyState_deg_s, ...
    YawRate_Peak_deg_s, ...
    YawRate_Overshoot_pct, ...
    YawRate_RiseTime_s, ...
    YawRate_SettlingTime_s);

fprintf('\n==============================================================\n');
fprintf(' VEHICLE PERFORMANCE COMPARISON - RESULTS SUMMARY\n');
fprintf('==============================================================\n\n');
disp(Summary);

writetable(Summary, 'Vehicle_Performance_Results.csv');

%% ------------------------------------------------------------
% SHORT ASSIGNMENT-FOCUSED OUTPUT
% -------------------------------------------------------------

fprintf('\n---------------- STEADY-STATE ----------------\n');
fprintf('Formula SWA gradient: %.4f deg/(m/s^2)\n', SWAgradient_F);
fprintf('Road    SWA gradient: %.4f deg/(m/s^2)\n', SWAgradient_R);

fprintf('\nFormula understeer gradient: %.4f deg/(m/s^2) -> %s\n', ...
        Kus_F, balanceF);
fprintf('Road    understeer gradient: %.4f deg/(m/s^2) -> %s\n', ...
        Kus_R, balanceR);

fprintf('\nFormula sideslip gradient: %.4f deg/(m/s^2)\n', BetaGradient_F);
fprintf('Road    sideslip gradient: %.4f deg/(m/s^2)\n', BetaGradient_R);

fprintf('\n---------------- STEP STEER ------------------\n');
fprintf('Formula lateral acceleration overshoot: %.2f %%\n', ...
        ayMetricsF.OvershootPercent);
fprintf('Road    lateral acceleration overshoot: %.2f %%\n', ...
        ayMetricsR.OvershootPercent);

fprintf('\nFormula yaw-rate overshoot: %.2f %%\n', ...
        yawMetricsF.OvershootPercent);
fprintf('Road    yaw-rate overshoot: %.2f %%\n', ...
        yawMetricsR.OvershootPercent);

fprintf('\nFormula yaw-rate rise time: %.3f s\n', yawMetricsF.RiseTime);
fprintf('Road    yaw-rate rise time: %.3f s\n', yawMetricsR.RiseTime);

fprintf('\nFormula yaw-rate settling time: %.3f s\n', yawMetricsF.SettlingTime);
fprintf('Road    yaw-rate settling time: %.3f s\n', yawMetricsR.SettlingTime);

fprintf('\nFigures saved in: %s\n', figureFolder);
fprintf('Summary table saved as: Vehicle_Performance_Results.csv\n\n');

%% ============================================================
% LOCAL FUNCTIONS
% ============================================================

function Results = loadResult(fileName, resultsFolder)

    folderFile = fullfile(resultsFolder, fileName);

    if isfile(folderFile)
        filePath = folderFile;
    elseif isfile(fileName)
        filePath = fileName;
    else
        error('Could not find %s in the current folder or %s.', ...
              fileName, resultsFolder);
    end

    loaded = load(filePath);

    if ~isfield(loaded, 'Results')
        error('%s does not contain a variable called Results.', filePath);
    end

    Results = loaded.Results;
end


function balance = classifyBalance(Kus)

    tolerance = 1e-3;

    if abs(Kus) <= tolerance
        balance = 'Neutral steer';
    elseif Kus > 0
        balance = 'Understeer';
    else
        balance = 'Oversteer';
    end
end


function M = responseMetrics(t, y, stepTime)
% Calculates:
%   steady-state value
%   peak value
%   percentage overshoot
%   10-90% rise time
%   2% settling time
%
% The response is internally aligned to a positive direction so the
% calculation is robust to Simulink sign convention.

    t = t(:);
    y = y(:);

    postMask = t >= stepTime;

    if ~any(postMask)
        error('No samples found after the step time.');
    end

    tPost = t(postMask);
    yPost = y(postMask);

    % Estimate steady state from the final 10% of the post-step samples
    nTail = max(5, round(0.10 * numel(yPost)));
    steadySigned = mean(yPost(end-nTail+1:end));

    direction = sign(steadySigned);

    if direction == 0
        direction = 1;
    end

    yAligned = direction .* yPost;
    steady = abs(steadySigned);

    [peak, peakIndex] = max(yAligned);
    peakTime = tPost(peakIndex);

    peakSigned = direction .* peak;

    if steady > eps
        overshoot = max(0, (peak - steady) / steady * 100);
    else
        overshoot = NaN;
    end

    % Pre-step baseline
    preMask = t < stepTime;

    if any(preMask)
        baselineSigned = mean(y(preMask));
    else
        baselineSigned = y(1);
    end

    baseline = direction .* baselineSigned;

    amplitude = steady - baseline;

    % 10-90% rise time
    level10 = baseline + 0.10 * amplitude;
    level90 = baseline + 0.90 * amplitude;

    idx10 = find(yAligned >= level10, 1, 'first');
    idx90 = find(yAligned >= level90, 1, 'first');

    if isempty(idx10) || isempty(idx90)
        riseTime = NaN;
    else
        riseTime = tPost(idx90) - tPost(idx10);
    end

    % 2% settling time relative to steady-state amplitude
    settlingBand = 0.02 * max(abs(amplitude), eps);
    outsideBand = abs(yAligned - steady) > settlingBand;

    lastOutside = find(outsideBand, 1, 'last');

    if isempty(lastOutside)
        settlingTime = 0;
    elseif lastOutside == numel(tPost)
        settlingTime = NaN;
    else
        settlingTime = tPost(lastOutside + 1) - stepTime;
    end

    M.SteadySigned = steadySigned;
    M.PeakSigned = peakSigned;
    M.PeakTime = peakTime;
    M.OvershootPercent = overshoot;
    M.RiseTime = riseTime;
    M.SettlingTime = settlingTime;
end
