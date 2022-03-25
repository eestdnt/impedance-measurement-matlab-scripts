% This program simulates the frequency-response identification of an LTI system
% using DIBS
clear();

% ----------------- Initialization -----------------------------------
% Define an LTI system
f0 = 1000;
sys = tf([1], [1/(2*pi*f0), 1]);

% DIBS generation
f_bw = 2000; % Measurement bandwidth
A = 1; % Excitation amplitude
f_gen = 3000; % Generation frequency
f_min = 10; % Maximum sequence frequency
freq_specs = [freq_segment_class()];
freq_specs(1).f_min = 0;
freq_specs(1).f_max = 2000;
freq_specs(1).power_ratio = 1;
freq_specs(1).count = 20;
freq_specs(1).scale = "log";
[excitation, N, f_min, idx] = generate_dibs(A, f_gen, f_min, freq_specs);

P_extra = 1; % Extra periods for transient
P = 2; % Injection periods (included in Fourier analysis)
P_total = P_extra + P;
excitation = repmat(excitation, P_total, 1);
% --------------------------------------------------------------------

% ----------------- Simulate the injection ---------------------------
% Specify sampling frequency
Fs = 4*f_gen;

% Generate the excitation signal at the same rate as the sampling rate
mult = floor(Fs/f_gen);
u = reshape(transpose(repmat(excitation, 1, mult)), P_total*N*mult, 1);

% Generate time vector
tv = transpose(0:1/Fs:(P_total*N*mult-1)/Fs);

% Simulate the injection
y = lsim(sys, u, tv);
% --------------------------------------------------------------------

% ----------------- Analyze the result -------------------------------
% Skip the transients
u = u(P_extra*N*mult+1:end);
y = y(P_extra*N*mult+1:end);
tv = transpose(1/Fs:1/Fs:N*mult/Fs);

[G, fv, U, Y, u, y] = estimate_frf_from_broadband_measurement(u, y, P, Fs);

fv = fv(idx);
G = G(idx);
U = U(idx);
Y = Y(idx);

% Plot the signals
figure(1), clf();
subplot(2, 1, 1);
stairs(tv, u);
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

idx = transpose(1:length(G)/2);

% Plot the amplitude spectra
figure(2), clf();
subplot(2, 1, 1);
semilogx(fv(idx), db(abs(U(idx))), "LineStyle", "none", "Marker", "o");
xlim([fv(1), f_bw]);
grid("on");
ylabel("Amplitude (dB)");
subplot(2, 1, 2);
semilogx(fv(idx), db(abs(Y(idx))), "LineStyle", "none", "Marker", "o");
xlim([fv(1), f_bw]);
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
xlim([fv(2), f_bw]);
ylabel("Amplitude (dB)");
subplot(2, 1, 2);
semilogx(fv_ref, phase_ref, "LineStyle", "-", "Color", "r");
hold("on");
semilogx(fv(idx), 180/pi*unwrap(angle(G(idx))), "LineStyle", "none", "Marker", "o", "Color", "b");
hold("off");
grid("on");
xlim([fv(2), f_bw]);
ylabel("Phase (degrees)");
xlabel("Frequency (Hz)");
legend(["Reference", "Estimation"], "Location", "best");
sgtitle("System");
% --------------------------------------------------------------------