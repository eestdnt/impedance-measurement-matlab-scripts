excitation_type = "dibs";

A = 0.1; % Signal amplitude
f_bw = 2000; % Measurement bandwidth
f_gen = 6000; % Generation frequency
f1_max = 10; % Maximum sequence frequency
Fs = 498000; % Sampling frequency

Fs = min(100*f_gen, floor(500000/f_gen)*f_gen);
freqs = transpose(logspace(log10(f1_max), log10(f_bw), 20));
psd_arr = [freqs, ones(20,1)/20-0.0001];

P_extra = 5;
P = 10;

% DIBS generation
[u, N, f1, idx] = generate_dibs(A, f_gen, f1_max, psd_arr);
n = log2(N+1);

% Repeat the signal for all periods
u = repmat(u, P_extra + P, 1);

% Add initial zero excitation for 10% of the total signal length
num_idle_points = floor(0.1*length(u));
u = [zeros(num_idle_points, 1); u];