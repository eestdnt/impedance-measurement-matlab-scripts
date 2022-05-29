% The script simply injects a current disturbance
%   The following variables are assumed to reside in the MATLAB workspace:
%       f_gen: PRBS generation frequency
%       Fs: Sampling frequency
%       u: Excitation signal
%   The measurement is done with NiDAQ instrument and uses the following channel configuration:
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

% Setup output channels
ao = addoutput(dq, device_name, [0], "Voltage");
ao(1).Range = [-10 10]; % Voltage perturbation by linear amplifier

% Start the acquisition
disp("Injection starts now...");
write(dq, excitation_vec);
disp("Injection stopped!");

% Clean unused variables
clear("ai", "ao", "dq", "device_name", "m", "st");
