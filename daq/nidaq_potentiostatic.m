% The script generates a PRBS, collects the excitation and response signals and saves them to a MATLAB file
%   The following variables are assumed to reside in the MATLAB workspace:
%       f_gen: PRBS generation frequency
%       Fs: Sampling frequency
%       u: Excitation signal
%   The measurement is done with NiDAQ instrument and uses the following channel configuration:
%       + AI1: Measurement of excitation signal (current measurement, 10V/A amplification)
%       + AI2: Measurement of response signal (voltage measurement)
%       + AO0: Generation of excitation signal (current disturbance)

% Check that sampling frequency is a multiple of generation frequency
if mod(int64(Fs), int64(f_gen)) > 0
    disp("Sampling frequency is not a multiple of sequence generation frequency, aborting!");
    return;
end

% Build excitation signal for NiDAQ
mult = floor(Fs/f_gen);
x = repmat(u, 1, mult);
x = reshape(transpose(x), numel(x), 1);
excitation_vec = x;

% Estimate running time
duration = length(excitation_vec) / Fs;
fprintf(" -- Estimated measurement time: %.2f seconds (%.2f minutes)\n", duration, duration/60);

% Setup NiDAQ
disp("Setting up NIDAQ");
device_name = "Dev1";
daqreset();
dq = daq("ni");
dq.Rate = Fs;

% Setup input channels
ai = addinput(dq, device_name, [1, 2], "Voltage");
ai(1).Range = [-10 10]; % Measured current
ai(2).Range = [-10 10]; % Measured voltage

% Setup output channels
ao = addoutput(dq, device_name, [0], "Voltage");
ao(1).Range = [-5 5]; % PRBS voltage perturbation by linear amplifier

% Start the acquisition
disp("Measurement starts now...");
[data, ~, ~] = readwrite(dq, excitation_vec, "OutputFormat", "Matrix");
disp("Measurement stopped!");

% Format the result
measured_excitation_signal = data(:,1);
measured_response_signal = data(:,2);

% Clean unused variables
clear("ai", "ao", "dq", "data", "device_name", "m", "st");
