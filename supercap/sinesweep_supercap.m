excitation_type = "sinesweep";

A = 10; % Amperes
f_bw = 2000; % Hertz
fv = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000]; % Frequencies of the sweep
% fv = [10, 100, 500, 2000]; % Frequencies of the sweep
% fv = [1, 10, 100, 500, 2000]; % Frequencies of the sweep
% fv = [0.1, 1, 10, 100, 500, 2000]; % Frequencies of the sweep

f_gen = 10*fv(end);
[excitation, seq_len] = generate_sinesweep(A, f_gen, fv);
N = sum(seq_len);
Fs = 10*f_gen; % Sampling frequency

P_extra = 0; % Extra periods for transient
P = 1; % Injection periods (included in Fourier analysis)
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

figure(10), clf();
plot(u);