%% Plot the PRBS measurement results
%
%% Clear all variables
clear();

%% Load reference model data
ref_dat = readtable("./blob/sinesweep_bat_3_imp.dat");

fv_ref = ref_dat{:,1};
mag_ref = 10.^(ref_dat{:,2}/20);
phase_ref = pi/180*ref_dat{:,3};

%% Load measurement data
load("./blob/dibs_latest.mat");
specs = jsondecode(fileread(specs_filename));

%% Print DIBS parameters
fprintf("DIBS specifications:\n");
fprintf(" - Design variables:\n");
fprintf("   + Amplitude: A = %.4f\n", A);
fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
fprintf(" - Specification variables:\n");
% fprintf("   + Shift-register length: n = %d\n", n);
fprintf("   + Sequence length: N = %d\n", N);
fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
fprintf("   + Frequency resolution: %.4f Hz\n", f_gen/N);
fprintf("   + Number of applied periods: P = %d\n", P);
fprintf("   + Number of estimated transient periods: P_extra = %d\n", P_extra);

fprintf(" - Frequency content:\n");
freq_specs = specs.content;
for k = 1:length(freq_specs)
    f_min = freq_specs(k).f_min;
    f_max = freq_specs(k).f_max;
    power = A^2 * N^2 * freq_specs(k).power_ratio;
    count = freq_specs(k).count;

    fprintf("   + f_start: %.2f Hz, f_end: %2.f Hz, count: %d, power: %.2f dB\n", f_min, f_max, count, db(power));
end

%% Raw data plot
figure(1), clf();
tv = (1/Fs:1/Fs:1/Fs*length(current_vec))';
subplot(2, 1, 1);
stairs(tv, current_vec), grid("on"), ylabel("Current (A)"), title("Output current");
hold("on"), xline(1/Fs*N*mult*P_extra, "Color", "red"), hold("off");
subplot(2, 1, 2);
plot(tv, voltage_vec), grid("on"), ylabel("Voltage (V)"), title("Output voltage");
hold("on"), xline(1/Fs*N*mult*P_extra, "Color", "red"), hold("off");
xlabel("Time (s)");
sgtitle("Raw time-domain signals");

%% Average the signals

x = current_vec;
y = voltage_vec;

% Skip transients
x = x(P_extra*mult*N+1:end);
y = y(P_extra*mult*N+1:end);

% Averaging
x = mean(reshape(x, mult*N, P), 2);
y = mean(reshape(y, mult*N, P), 2);

% Free up memory
clear("current_vec", "voltage_vec");

%% FFT-window plot
figure(2), clf();
tv = (1/Fs:1/Fs:1/Fs*length(x))';
subplot(2, 1, 1);
stairs(tv, x), grid("on"), ylabel("Current (A)"), title("Output current");
subplot(2, 1, 2);
stairs(tv, y), grid("on"), ylabel("Voltage (V)"), title("Output voltage");
xlabel("Time (s)");
sgtitle("FFT-window time signals");

%% DFT analysis
X = fft(x);
Y = fft(y);
Z = Y./X;

freq_step = Fs/length(X);
fv = (0:freq_step:freq_step*(length(X)-1))';

% Select frequency content as specified
idx = params.indicies;
fv = fv(idx);
Z = Z(idx);
X = X(idx);
Y = Y(idx);

%% Plot measured signal power spectra
figure(3), clf();
subplot(2, 1, 1);
semilogx(fv, db(abs(X)), "LineStyle", "none", "Marker", "o"), grid on, ylabel("Input power (db)");
xlim([fv(1), f_bw]);
subplot(2, 1, 2);
semilogx(fv, db(abs(Y)), "LineStyle", "none", "Marker", "o"), grid on, ylabel("Output power (db)");
xlim([fv(1), f_bw]);
xlabel("Frequency (Hz)");
sgtitle("Signal power spectra");

%% Bode plot
figure(4), clf();
subplot(2, 1, 1);
semilogx(fv, db(abs(Z)), "LineStyle", "-", "Marker", "o");
hold("on"), semilogx(fv_ref, db(mag_ref), "LineStyle", "-"), hold("off");
xlim([fv(1), f_bw]), xlabel("Frequency (Hz)"), ylabel("Power (db)"), grid("on");
subplot(2, 1, 2);
semilogx(fv, 180/pi*angle(Z), "LineStyle", "-", "Marker", "o");
hold("on"), semilogx(fv_ref, 180/pi*phase_ref, "LineStyle", "-"), hold("off");
legend(["DIBS", "Reference"]);
xlim([fv(1), f_bw]), xlabel("Frequency (Hz)"), ylabel("Phase (deg)"), grid("on");
sgtitle("Battery impedance Bode plot");

%% Nyquist plot
figure(5), clf();
idx = 0 < fv & fv <= f_bw;
zv = abs(Z(idx)) .* exp(1j*angle(Z(idx)));
zv_ref = abs(mag_ref).*exp(1j*phase_ref);
plot(real(zv), -imag(zv), "LineStyle", "-", "Marker", "o");
hold("on"), plot(real(zv_ref), -imag(zv_ref), "LineStyle", "-"), hold("off");
xlabel("Re(Z)");
ylabel("Im(Z)");
title("Battery impedance Nyquist plot"), grid("on");
legend(["DIBS", "Reference"]);

%% Save FRF estimation result
mat = [fv, db(abs(Z)), 180/pi*angle(Z)];
csvwrite("./blob/dibs_frf_latest.dat", mat);