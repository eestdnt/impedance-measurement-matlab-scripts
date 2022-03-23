% The script generates a PRBS, collects the excitation and response signals and saves them to a MATLAB file
% The following variables are assumed to reside in the MATLAB workspace:
%   A: Excitation amplitude
%   f_bw: Measurement bandwidth
%   f_gen: PRBS generation frequency
%   f_min: PRBS frequency
%   Fs: Sampling frequency
%   P_idle: Number of initial injection periods that generates a zero signal
%   P_extra: Number of extra injection periods to cover the transients
%   P: Number of injection periods

%   measured_excitation_signal: Excitation signal
%   measured_response_signal: Response signal
%   N: Number of data points in the discrete form of the excitation waveform

% function nidaq_prbs_measure(specs_filename, output_filename)
    % PRBS specifications
    % specs = jsondecode(fileread(specs_filename));


% PRBS generation
% A = 1;
% f_gen = 3000;
% f_min = 10;
[u, N, f_min] = generate_mlbs(A, f_gen, f_min);

% % Generate the excitation signal
% [u, params] = generate_prbs(specs);
% A = params.seq_amplitude;
% N = params.seq_length;
% f_bw = params.bandwidth;
% f_gen = params.generation_freq;
% Fs = params.sampling_freq;
% f_resolution = f_gen/N;
% n = floor(log2(N+1));
% P = 5;
% P_extra = 3;
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

% tvec = (1/Fs:1/Fs:1/Fs*length(excitation_vec))";
% figure(1), clf();
% stairs(tvec, excitation_vec);
% title("Excitation signal");
% xlabel("Time (s)");
% grid("on");

% Estimate running time
duration = N * P_total / f_gen;
fprintf(" -- Estimated measurement time: %.4f seconds (%.4f minutes)\n", duration, duration/60);
st = sprintf(" Measurement time is %.2f seconds (or %.2f minutes), do we continue? (Y/N [Y])\n", duration, duration/60);

m = input(st, "s");
if m ~= "" && m ~= "Y"
    return;
end

% Setup NiDAQ
disp("Setting up NIDAQ");

device_name = "Dev1";
daqreset();
dq = daq("ni");
dq.Rate = Fs;

% Setup input channels
ai = addinput(dq, device_name, 1:2, "Voltage");
ai(1).Range = [-1 1]; % Output current
ai(2).Range = [-5 5]; % Output voltage

% Setup output channels
ao = addoutput(dq, device_name, 0:0, "Voltage");
ao(1).Range = [-5 5]; % PRBS voltage perturbation by linear amplifier

% Start the acquisition
disp("Measurement starts now...");
[data, ~, ~] = readwrite(dq, excitation_vec, "OutputFormat", "Matrix");
disp("Measurement stopped!");

% Format the result
measured_excitation_signal = 10*data(:,1);  % 10A/V amplification
measured_response_signal = data(:,2);

% % Save the raw measurement data
% clear("ai", "ao", "dq", "data", "device_name", "m", "st", "output_filename");
% % filename = datestr(datetime(), "yyyy.mm.dd__HH.MM.SS");
% % filename = sprintf("../blob/prbs_%s.mat", filename);
% disp("Saving to file...");
% save(output_filename);
% disp("Finished!");
