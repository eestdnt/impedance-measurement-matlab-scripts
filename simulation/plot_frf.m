%% BATTERY IMPEDANCE MEASUREMENT DATA ANALYSIS AND PLOTTING FOR SINESWEEP
% AUTHOR: MINH TRAN

%% COULOMB COUNTING
Q = Q + sum(current_vec)/Fs/3600;

%% AVERAGING THE SIGNALS AND PLOT

% EXTRACT THE OUTPUTS
x = current_vec;
y = voltage_vec;

% SKIPPING TRANSIENTS
x = x(P_tr*mult*N+1:end);
y = y(P_tr*mult*N+1:end);

% AVERAGING
x = mean(reshape(x,mult*N,P),2);
y = mean(reshape(y,mult*N,P),2);

%% PLOT THE SIGNALS

% RAW DATA
figure(1), clf();
tv = (1/Fs:1/Fs:1/Fs*length(current_vec))';
subplot(2,1,1);
stairs(tv,current_vec), grid("on"), ylabel("Current (A)"), title("Output current");
hold("on"), xline(1/Fs*N*mult*P_tr, "Color", "red"), hold("off");
subplot(2,1,2);
plot(tv,voltage_vec), grid("on"), ylabel("Voltage (V)"), title("Output voltage");
hold("on"), xline(1/Fs*N*mult*P_tr, "Color", "red"), hold("off");
xlabel("Time (s)");
sgtitle("Raw time-domain signals");

% 1-PERIOD PLOT
figure(2), clf();
tv = (1/Fs:1/Fs:1/Fs*length(x))';
subplot(2,1,1);
stairs(tv,x), grid("on"), ylabel("Current (A)"), title("Output current");
subplot(2,1,2);
plot(tv,y), grid("on"), ylabel("Voltage (V)"), title("Output voltage");
xlabel("Time (s)");
sgtitle("Time-domain signals (1 excitation period)");

%% FFT ANALYSIS

% FFT
X = fft(x);
Y = fft(y);

%% COMPENSATION

% ZOH
Hk = @(k,L) (1 - exp(-1j*k*2*pi/L)) ./ (1j*k*2*pi/L);
L = length(X);
idx = (2:floor((L-1)/2)+1)';
% X(idx) = X(idx) .* Hk(idx-1, L);
X(L-idx+2) = conj(X(idx));

%% DFT
freq_step = Fs/length(X);
fv = (0:freq_step:freq_step*(length(X)-1))';
% Z = 1.0393 * Y./X;
Z = Y./X;

idx = find(fv > 0 & f-freq_step < fv & fv < f+freq_step, 1);
% idx = 1:length(fv)/2;
% fprintf(" k = %d, f = %.2f, fv = %.2f, idx = %d\n", k, f, fv(idx), nnz(idx));
fv = fv(idx);
Z = Z(idx);
X = X(idx);
Y = Y(idx);
% fprintf(" - Content: %.5f %.5f %.5f\n", db(abs(Z)), db(abs(X)), db(abs(Y)));

% SAVE Z VALUE TO Z_VEC
Z_vec(k) = Z(1);

% SIGNAL POWER SPECTRA
figure(3);
subplot(2,1,1);
hold("on"), plot(fv, db(abs(X)), "LineStyle", "none", "Marker", "o", "Color", "blue"), hold("off");
% hold("on"), plot(fv, db(abs(X)), "LineStyle", "none", "Marker", "o"), hold("off");
title("Input signal");
grid("on");
subplot(2,1,2);
hold("on"), plot(fv, db(abs(Y)), "LineStyle", "none", "Marker", "o", "Color", "blue"), hold("off");
grid("on");
title("Output signal");
sgtitle("Signal power spectra");

% IMPEDANCE BODE PLOT
figure(4);
subplot(2,1,1);
hold("on"), plot(fv, abs(Z), "LineStyle", "none", "Marker", "x", "Color", "blue"), hold("off");
% set(gca, "XScale", "log"), grid("on");
ylabel("Impedance (Ohm)");
subplot(2,1,2);
hold("on"), plot(fv, 180/pi*angle(Z), "LineStyle", "none", "Marker", "x", "Color", "blue"), hold("off");
% set(gca, "XScale", "log"), grid("on");
ylabel("Phase (deg)");
xlabel("Frequency (Hz)");
sgtitle("Impedance Bode plot");

% IMPEDANCE NYQUIST PLOT
figure(5);
zv = abs(Z).*exp(1j*angle(Z));
hold("on"), plot(real(zv), imag(zv), "LineStyle", "none", "Marker", "x", "Color", "blue"), hold("off");
grid("on");
