excitation_type = "sinesweep";

A = 0.5;
f_bw = 1000;
fv = logspace(1, 3); % 50 logarithmically equally spaced points between 10 and 1000
f_gen = 100*fv(end);
[excitation, seq_len] = generate_sinesweep(A, f_gen, fv);
N = sum(seq_len);
Fs = 10*f_gen; % Sampling frequency

P_extra = 0; % Extra periods in the beginning
P = 1000; % Injection periods (included in Fourier analysis)
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

figure(1), clf();
plot(u, "LineStyle", "stairs");
grid("on");