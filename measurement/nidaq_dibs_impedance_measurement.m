% The script generates a DIBS, collects the excitation and response signals and saves them to a MATLAB file
%   The following variables are assumed to reside in the MATLAB workspace:
%       A: Excitation amplitude
%       f_bw: Measurement bandwidth
%       f_gen: DIBS generation frequency
%       f1_max: Maximum DIBS frequency
%       Fs: Sampling frequency
%       P_idle: Number of initial injection periods that generates a zero signal
%       P_extra: Number of extra injection periods to cover the transients
%       P: Number of injection periods
%       psd_arr: User-defined frequency content, see help for generate_dibs().
%   The measurement is done with NiDAQ instrument and uses the following channel configuration:
%       + AI1: Measurement of excitation signal (current measurement, 10V/A amplification)
%       + AI2: Measurement of response signal (voltage measurement)
%       + AO0: Generation of excitation signal (current disturbance)

% Check that sampling frequency is a multiple of generation frequency
if mod(int64(Fs), int64(f_gen)) > 0
    disp("Sampling frequency is not a multiple of sequence generation frequency, aborting!");
    return;
end

% DIBS generation
[u, N, f1, idx] = generate_dibs(A, f_gen, f1_max, psd_arr);
mult = floor(Fs/f_gen);
P_total = P_idle+P_extra+P;
n = log2(N+1);

% Print excitation parameters
disp("Excitation variables:");
fprintf("   + Amplitude: A = %.4f\n", A);
fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
fprintf("   + Sequence order (shift-register length): n = %d\n", n);
fprintf("   + Sequence length: N = %d\n", N);
fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
fprintf("   + Frequency resolution: %.4f Hz\n", f_gen/N);
fprintf("   + Number of applied periods: P = %d\n", P);
fprintf("   + Number of extra periods: P_extra = %d\n", P_idle+P_extra);

% Build excitation signal for NiDAQ
x = repmat(u, P_total, 1);
x = repmat(x, 1, mult);
x = reshape(transpose(x), mult*N*P_total, 1);
x(1:P_idle*N*mult) = 0;
excitation_vec = x;

% Estimate running time
duration = N * P_total / f_gen;
fprintf(" -- Estimated measurement time: %.2f seconds (%.2f minutes)\n", duration, duration/60);

% Setup NiDAQ
disp("Setting up NIDAQ");
device_name = "Dev1";
daqreset();
dq = daq("ni");
dq.Rate = Fs;

% Setup input channels
ai = addinput(dq, device_name, [1, 2], "Voltage");
ai(1).Range = [-1 1]; % Output current
ai(2).Range = [-5 5]; % Output voltage

% Setup output channels
ao = addoutput(dq, device_name, [0], "Voltage");
ao(1).Range = [-5 5]; % PRBS voltage perturbation by linear amplifier

% Start the acquisition
disp("Measurement starts now...");
[data, ~, ~] = readwrite(dq, excitation_vec, "OutputFormat", "Matrix");
disp("Measurement stopped!");

% Format the result
measured_excitation_signal = 10*data(:,1);  % 10A/V amplification for current measurement
measured_response_signal = data(:,2); % Voltage measurement

% Clean unused variables
clear("ai", "ao", "dq", "data", "device_name");
