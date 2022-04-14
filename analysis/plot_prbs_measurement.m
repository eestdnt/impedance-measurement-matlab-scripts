% The script plots a frequency-response function estimated using the measurement data
% in MATLAB workspace.
% The following variables are assumed to reside in the workspace:
%   excitation_type: Type of the excitation, e.g. "mlbs", "dibs"
%   A: Excitation amplitude
%   measured_excitation_signal: Excitation signal
%   measured_response_signal: Response signal
%   P: Number of injection periods
%   Fs: Sampling frequency
%   f_gen: Excitation generation frequency
%   N: Number of data points in the discrete form of the excitation waveform

mult = floor(Fs/f_gen);
n = log2(N+1);

% Skip extra injection periods
x = measured_excitation_signal(end-P*mult*N+1:end);
y = measured_response_signal(end-P*mult*N+1:end);

% Estimate the frequency response
[Z, fv, X, Y, x, y] = estimate_frf_from_broadband_measurement(x, y, P, Fs);

% Print excitation parameters
disp("Excitation variables:");
fprintf("   + Excitation type: %s\n", excitation_type);
fprintf("   + Amplitude: A = %.4f\n", A);
fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
fprintf("   + Sequence order (shift-register length): n = %d\n", n);
fprintf("   + Sequence length: N = %d\n", N);
fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
fprintf("   + Frequency resolution: %.4f Hz\n", f_gen/N);
fprintf("   + Number of applied periods: %d\n", P);
fprintf("   + Number of estimated transient periods: %d\n", P_extra);

if excitation_type == "dibs"
    if exist("psd_arr", "var")
        fprintf(" - Frequency content:\n");
        for k = 1:length(psd_arr)
            fprintf(" + Frequency = %.4f Hz, power (percentage) = %.2f %%\n", psd_arr(k,1), psd_arr(k,2)*100);
        end
    end
    if exist("dibs_idx", "var")
        fv = fv(dibs_idx);
        Z = Z(dibs_idx);
        X = X(dibs_idx);
        Y = Y(dibs_idx);
    else
        fv = fv(idx);
        Z = Z(idx);
        X = X(idx);
        Y = Y(idx);
    end
end

% Raw data plot
figure(1), clf();
tv = transpose(1/Fs:1/Fs:1/Fs*length(measured_excitation_signal));
subplot(2, 1, 1);
stairs(tv, measured_excitation_signal), grid("on"), ylabel("Current (A)"), title("Input");
hold("on"), xline(1/Fs*(length(measured_excitation_signal) - N*mult*P), "Color", "red"), hold("off");
subplot(2, 1, 2);
plot(tv, measured_response_signal), grid("on"), ylabel("Voltage (V)"), title("Output");
hold("on"), xline(1/Fs*(length(measured_excitation_signal) - N*mult*P), "Color", "red"), hold("off");
xlabel("Time (s)");
sgtitle("Raw signals");

% Free up memory
clear("measured_excitation_signal", "measured_response_signal");

% DFT-window plot
figure(2), clf();
tv = transpose(1/Fs:1/Fs:1/Fs*length(x));
subplot(2, 1, 1);
stairs(tv, x), grid("on"), ylabel("Current (A)"), title("Input");
subplot(2, 1, 2);
stairs(tv, y), grid("on"), ylabel("Voltage (V)"), title("Output");
xlabel("Time (s)");
sgtitle("Averaged signals");

% Plot averaged signal power spectra
if ~exist("f1", "var")
    f1 = fv(2);
end
figure(3), clf();
subplot(2, 1, 1);
semilogx(fv, db(abs(X)), "LineStyle", "none", "Marker", "o"), grid("on"), ylabel("Amplitude (db)");
xlim([f1, f_bw]);
subplot(2, 1, 2);
semilogx(fv, db(abs(Y)), "LineStyle", "none", "Marker", "o"), grid("on"), ylabel("Amplitude (db)");
xlim([f1, f_bw]);
xlabel("Frequency (Hz)");
sgtitle("Amplitude spectra");

% Bode plot
figure(4), clf();
subplot(2, 1, 1);
semilogx(fv, db(abs(Z)), "LineStyle", "none", "Marker", "x");
xlim([f1, f_bw]), ylabel("Amplitude (db)"), grid("on");
subplot(2, 1, 2);
semilogx(fv, 180/pi*unwrap(angle(Z)), "LineStyle", "none", "Marker", "x");
xlim([f1, f_bw]), ylabel("Phase (deg)"), grid("on"), xlabel("Frequency (Hz)");
sgtitle("Impedance Bode plot");

% Nyquist plot
figure(5), clf();
idx = 0 < fv & fv <= f_bw;
zv = abs(Z(idx)).*exp(1j*angle(Z(idx)));
plot(real(zv), -imag(zv), "LineStyle", "none", "Marker", "x");
xlabel("Re(Z)");
ylabel("-Im(Z)");
title("Impedance nyquist plot"), grid("on");
