% The script plots a frequency-response function estimated using the measurement data
% in MATLAB workspace.
% The following variables are assumed to reside in the workspace:
%   A: Excitation amplitude
%   measured_excitation_signal: Excitation signal
%   measured_response_signal: Response signal
%   P_idle: Number of extra injection periods that generate zero excitation
%   P_extra: Number of extra injection periods
%   P: Number of injection periods to be analyzed
%   Fs: Sampling frequency
%   f_gen: Excitation generation frequency
%   N: Number of data points in the discrete form of the excitation waveform

    mult = floor(Fs/f_gen);
    n = log2(N+1);

    % Skip extra injection periods
    x = measured_excitation_signal((P_idle+P_extra)*mult*N+1:end);
    y = measured_response_signal((P_idle+P_extra)*mult*N+1:end);

    % Estimate the frequency response
    [Z, fv, X, Y, x, y] = estimate_frf_from_broadband_measurement(x, y, P, Fs);

    % Print excitation parameters
    disp("Excitation variables:");
    fprintf("   + Amplitude: A = %.4f\n", A);
    fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
    fprintf("   + Sequence order (shift-register length): n = %d\n", n);
    fprintf("   + Sequence length: N = %d\n", N);
    fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
    fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
    fprintf("   + Frequency resolution: %.4f Hz\n", f_gen/N);
    fprintf("   + Number of applied periods: %d\n", P);
    fprintf("   + Number of estimated transient periods: %d\n", P_idle+P_extra);

    if excitation_type == "dibs"
        fprintf(" - Frequency content:\n");
        % for k = 1:length(freq_specs)
        %     f_min = freq_specs(k).f_min;
        %     f_max = freq_specs(k).f_max;
        %     power = A^2 * N^2 * freq_specs(k).power_ratio;
        %     count = freq_specs(k).count;
        %     fprintf("   + f_start: %.2f Hz, f_end: %2.f Hz, count: %d, power: %.2f dB\n", f_min, f_max, count, db(power));
        % end
        fv = fv(idx);
        Z = Z(idx);
        X = X(idx);
        Y = Y(idx);
    end

    % Raw data plot
    figure(1), clf();
    tv = transpose(1/Fs:1/Fs:1/Fs*length(measured_excitation_signal));
    subplot(2, 1, 1);
    stairs(tv, measured_excitation_signal), grid("on"), ylabel("Current (A)"), title("Input");
    hold("on"), xline(1/Fs*N*mult*(P_idle+P_extra), "Color", "red"), hold("off");
    subplot(2, 1, 2);
    plot(tv, measured_response_signal), grid("on"), ylabel("Voltage (V)"), title("Output");
    hold("on"), xline(1/Fs*N*mult*(P_idle+P_extra), "Color", "red"), hold("off");
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
    figure(3), clf();
    subplot(2, 1, 1);
    semilogx(fv, db(abs(X)), "LineStyle", "none", "Marker", "o"), grid("on"), ylabel("Amplitude (db)");
    xlim([fv(1), f_bw]);
    subplot(2, 1, 2);
    semilogx(fv, db(abs(Y)), "LineStyle", "none", "Marker", "o"), grid("on"), ylabel("Amplitude (db)");
    xlim([fv(1), f_bw]);
    xlabel("Frequency (Hz)");
    sgtitle("Amplitude spectra");

    % Bode plot
    figure(4), clf();
    subplot(2, 1, 1);
    semilogx(fv, db(abs(Z)), "LineStyle", "none", "Marker", "x");
    xlim([fv(1), f_bw]), ylabel("Amplitude (db)"), grid("on");
    subplot(2, 1, 2);
    semilogx(fv, 180/pi*unwrap(angle(Z)), "LineStyle", "none", "Marker", "x");
    xlim([fv(1), f_bw]), ylabel("Phase (deg)"), grid("on"), xlabel("Frequency (Hz)");
    sgtitle("System");

    % Nyquist plot
    figure(5), clf();
    idx = 0 < fv & fv <= f_bw;
    zv = abs(Z(idx)).*exp(1j*angle(Z(idx)));
    plot(real(zv), -imag(zv), "LineStyle", "none", "Marker", "x");
    xlabel("Re(Z)");
    ylabel("-Im(Z)");
    title("System"), grid("on");
