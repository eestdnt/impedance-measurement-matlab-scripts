% Experiment for aging analysis of TerraE INR 21700 50E
% at high frequencies

disp("Loading excitation parameters for experiment...");

excitation_type = "dibs";
A = 0.1;
f_bw = 2000;
f_gen = 3*f_bw;
f1_max = 10;
Fs = min(100*f_gen, floor(500000/f_gen)*f_gen);
freqs = transpose(logspace(log10(f1_max), log10(f_bw), 20));
psd_arr = [freqs, ones(20,1)/20-0.0001];

P_extra = 1;
P = 5;

% DIBS generation
[u, N, f1, idx] = generate_dibs(A, f_gen, f1_max, psd_arr);
n = log2(N+1);

% Repeat the signal for all periods
u = repmat(u, P_extra + P, 1);

% Add initial zero excitation for 10% of the total signal length
num_idle_points = floor(0.1*length(u));
u = [zeros(num_idle_points, 1); u];
