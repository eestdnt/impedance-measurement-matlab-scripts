% This program simulates the frequency-response identification of an LTI system
% using sinesweeps
clear();

% ----------------- Initialization -----------------------------------
% Define an LTI system
f0 = 1000;
sys = tf([1], [1/(2*pi*f0), 1]);

% Sinesweep generation
A = 1;
% f_gen = 3000;
% f1_max = 10;
% fv = [100; 200; 300; 400; 500];
fv = logspace(1, 3);
f_gen = 100*fv(end);
[excitation, seq_len] = generate_sinesweep(A, f_gen, fv);
N = sum(seq_len);

% figure(1), clf();
% stairs(excitation);
% grid("on");

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
excitation = u;
% --------------------------------------------------------------------

% ----------------- Simulate the injection ---------------------------
% Specify sampling frequency
Fs = 4*f_gen;

% Generate the excitation signal at the same rate as the sampling rate
mult = floor(Fs/f_gen);
u = reshape(transpose(repmat(excitation, 1, mult)), mult*length(excitation), 1);

% Generate time vector
tv = transpose(0:1/Fs:(length(u)-1)/Fs);

% Simulate the injection
[v, tv] = lsim(sys, u, tv);
% --------------------------------------------------------------------

% ----------------- Analyze the result -------------------------------
% Skip the transients
Lu = 0;
Lx = 0;
x = zeros(floor(length(u)/P_total)*P, 1);
for k=1:length(fv)

    f = fv(k);
    N = floor(f_gen/f);

    x(Lx+1:Lx+P*mult*N) = u(Lu+P_extra*mult*N+1:Lu+P_total*mult*N);
    y(Lx+1:Lx+P*mult*N) = v(Lu+P_extra*mult*N+1:Lu+P_total*mult*N);
    Lx = Lx + P*mult*N;
    Lu = Lu + P_total*mult*N;
    % Lx = Lx + N;
    % L = L + P_total*N;
end
% u = u(P_extra*N*mult+1:end);
% y = y(P_extra*N*mult+1:end);

[G, fv, X, Y, x, y] = estimate_frf_from_sinesweep_measurement(x, y, fv, f_gen, P, Fs);

% Plot the signals
tv = transpose(1/Fs:1/Fs:length(x)/Fs);
figure(1), clf();
subplot(2, 1, 1);
stairs(tv, x);
ylim([-1.5, 1.5]);
grid("on");
ylabel("Excitation");
subplot(2, 1, 2);
stairs(tv, y);
ylim([1.5*min(y), 1.5*max(y)]);
grid("on");
ylabel("Response");
xlabel("Time (s)");
sgtitle("Averaged signals");

% idx = transpose(1:length(X)/2);
idx = 1:length(X);
f1 = fv(1);
f_bw = fv(end);

% Plot the amplitude spectra
figure(2), clf();
subplot(2, 1, 1);
semilogx(fv(idx), db(abs(X(idx))), "LineStyle", "none", "Marker", "o");
xlim([f1, f_bw]);
grid("on");
ylabel("Amplitude (dB)");
subplot(2, 1, 2);
semilogx(fv(idx), db(abs(Y(idx))), "LineStyle", "none", "Marker", "o");
xlim([f1, f_bw]);
grid("on");
ylabel("Amplitude (dB)");
xlabel("Frequency (Hz)");
sgtitle("Amplitude spectra");

% Plot the frequency-response of target system
[mag_ref, phase_ref, wv_ref] = bode(sys, 2*pi*fv);
fv_ref = reshape(wv_ref, numel(wv_ref), 1)/(2*pi);
mag_ref = reshape(mag_ref, numel(mag_ref), 1);
phase_ref = reshape(phase_ref, numel(phase_ref), 1);

figure(3), clf();
subplot(2, 1, 1);
semilogx(fv_ref, db(mag_ref), "LineStyle", "-", "Color", "r");
hold("on");
semilogx(fv(idx), db(abs(G(idx))), "LineStyle", "none", "Marker", "o", "Color", "b");
hold("off");
grid("on");
xlim([f1, f_bw]);
ylabel("Amplitude (dB)");
subplot(2, 1, 2);
semilogx(fv_ref, phase_ref, "LineStyle", "-", "Color", "r");
hold("on");
semilogx(fv(idx), 180/pi*unwrap(angle(G(idx))), "LineStyle", "none", "Marker", "o", "Color", "b");
hold("off");
grid("on");
xlim([f1, f_bw]);
ylabel("Phase (degrees)");
xlabel("Frequency (Hz)");
legend(["Reference", "Estimation"], "Location", "best");
sgtitle("Bode plot");
% --------------------------------------------------------------------
