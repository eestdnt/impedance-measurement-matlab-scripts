excitation_type = "sinesweep";

A = 1;
f_bw = 50;
fv = [
    % 0.1,
    % 0.1259,
    % 0.1585,
    % 0.1995,
    % 0.2512,
    % 0.3162,
    % 0.3981,
    % 0.5012,
    % 0.631,
    % 0.7944,
    1,
    1.259,
    1.585,
    1.995,
    2.512,
    3.162,
    3.981,
    5.012,
    6.31,
    7.944,
    10,
    12.59,
    15.85,
    19.95,
    25.12,
    31.62,
    39.81,
    50
];

f_gen = 100*fv(end);
[excitation, seq_len] = generate_sinesweep(A, f_gen, fv);
N = sum(seq_len);
Fs = 500000; % Sampling frequency

P_extra = 1; % Extra periods for transient
P = 2; % Injection periods (included in Fourier analysis)
P_total = P_extra + P;

% Repeat each sinewave for P_total periods
u = zeros(P_total*length(excitation), 1);
len = 0;
L = 0;
for k=1:length(fv)

    f = fv(k);
    N = floor(f_gen/f);

    u(L+1:L+P_total*N) = repmat(excitation(len+1:len+N), P_total, 1);
    len = len + N;
    L = L + P_total*N;
end