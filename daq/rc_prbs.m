excitation_type = "mlbs";

A = 0.5; % Signal amplitude
f_bw = 50; % Measurement bandwidth
f_gen = 100; % Generation frequency
f1_max = 1; % Maximum sequence frequency
Fs = 10000; % Sampling frequency

P_extra = 3;
P = 4;

% PRBS generation
[u, N, f1] = generate_mlbs(A, f_gen, f1_max);
n = log2(N+1);

% Repeat the signal for all periods
u = repmat(u, P_extra + P, 1);

% Add initial zero excitation for 10% of the total signal length
num_idle_points = floor(0.1*length(u));
u = [zeros(num_idle_points, 1); u];