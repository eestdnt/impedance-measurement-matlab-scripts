%% Plot the sinesweep measurement results
%
%% Clear all variables
clear();

%% Load reference model data
ref_dat = readtable("./blob/sinesweep_bat_2_imp.dat");

fv_ref = ref_dat{:,1};
mag_ref = 10.^(ref_dat{:,2}/20);
phase_ref = pi/180*ref_dat{:,3};

%% Load measurement data
load("./blob/sinesweep_latest.mat");

%% Print excitation parameters
fprintf("Excitation specifications:\n");
fprintf(" - Design variables:\n");
fprintf("   + Amplitude: A = %.4f\n", A);
fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
fprintf(" - Specification variables:\n");
fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
fprintf("   + Number of applied periods: P = %d\n", P);

% Plot the signals
figure(1), clf();
tv = (1/Fs:1/Fs:1/Fs*(length(current_vec)-1))';
subplot(2, 1, 1);
stairs(tv, current_vec(1:end-1)), grid on, title("Input signal");
ylim([-6, 6]);
subplot(2, 1, 2);
plot(tv, voltage_vec(1:end-1)), grid on, title("Output signal");
xlabel("Time (s)");

figure(2), clf();
subplot(2, 1, 1);
semilogx(NaN, NaN);
grid("on");
subplot(2, 1, 2);
semilogx(NaN, NaN);
grid("on");
sgtitle("Signal power spectra");

figure(3), clf();
subplot(2, 1, 1);
semilogx(fv_ref, db(mag_ref));
xlim([fv_ref(2), f_bw]);
ylabel("Power (db)");
grid("on");
subplot(2, 1, 2);
semilogx(fv_ref, phase_ref);
xlim([fv_ref(2), f_bw]);
ylabel("Phase (deg)");
xlabel("Frequency (Hz)");
grid("on");
sgtitle("Bode plot");

figure(4), clf(), title("Polar plot");

%% DFT analysis
%
f_vec = params.freq_vec;
start_idx = params.freq_start_idx;
seq_len = params.freq_sampled_seq_len;
Z_vec = zeros(length(f_vec), 1);
for k = 1:length(f_vec)

    f = f_vec(k);
    
    i = start_idx(k);
    N = seq_len(k);

    % Extract signal vectors
    x = current_vec(P*mult*(start_idx(k)-1)+1:P*mult*(start_idx(k)-1+seq_len(k)));
    y = voltage_vec(P*mult*(start_idx(k)-1)+1:P*mult*(start_idx(k)-1+seq_len(k)));

    % Average the signals
    x = mean(reshape(x, mult*N, P), 2);
    y = mean(reshape(y, mult*N, P), 2);

    % DFT
    X = fft(x);
    Y = fft(y);
    Z = Y./X;
    freq_step = Fs/length(X);
    fv = (0:freq_step:freq_step*(length(X)-1))';

    idx = find(fv > 0 & f-freq_step < fv & fv < f+freq_step, 1);
    fv = fv(idx);
    X = X(idx);
    Y = Y(idx);
    Z = Z(idx);

    % Signal power spectra
    figure(2);
    subplot(2, 1, 1);
    hold("on");
    semilogx(fv, db(abs(X)), "LineStyle", "none", "Marker", "o", "Color", "red");
    hold("off");
    ylabel("Power (db)");
    subplot(2, 1, 2);
    hold("on");
    semilogx(fv, db(abs(Y)), "LineStyle", "none", "Marker", "o", "Color", "red");
    ylabel("Power (db)");
    xlabel("Frequency (Hz)");
    hold("off");

    % Bode plot
    figure(3);
    subplot(2, 1, 1);
    hold("on");
    semilogx(fv, db(abs(Z)), "LineStyle", "none", "Marker", "o", "Color", "red");
    hold("off");
    ylabel("Power (db)");
    subplot(2, 1, 2);
    hold("on");
    semilogx(fv, 180/pi*unwrap(angle(Z)), "LineStyle", "none", "Marker", "o", "Color", "red");
    ylabel("Phase (deg)");
    xlabel("Frequency (Hz)");
    hold("off");

    % Polar plot
    figure(4);
    zv = abs(Z).*exp(1j*angle(Z));
    hold("on"), plot(real(zv), imag(zv), "LineStyle", "none", "Marker", "x", "Color", "blue"), hold("off");
    grid("on");

    Z_vec(k) = Z(1);
end

mat = [f_vec, db(abs(Z_vec)), 180/pi*angle(Z_vec)];

%% Save sinesweep data
csvwrite("./blob/sinesweep_frf_latest.dat", mat);