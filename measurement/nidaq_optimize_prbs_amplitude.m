% The script finds an optimal excitation amplitude for a broadband frequency-response measurement
% The following variables are assumed to reside in the MATLAB workspace:
%   sd_max_relative (double): Maximum relative deviation from the mean FRF estimation magnitude at each frequency
%   epsilon (double): Minimum accuracy (decimal resolution) of the optimal amplitude
%   excitation_type (string): Type of the broadband excitation
%   f_bw (double): Measurement bandwidth
%   f_gen: PRBS generation frequency
%   f_min: Sequence frequency
%   Fs: Sampling frequency
%   P_idle: Number of initial injection periods that generates a zero signal
%   P_extra: Number of extra injection periods to cover the transients
%   P: Number of injection periods

% Find an optimal amplitude
amplitude_arr = [];

amp_low = 0.1;
amp_high = 2;
amp_best = amp_high;
amp_prev = amp_low;

while abs(amp_best-amp_prev) > epsilon

    amp_prev = amp_best;
    amp_best = (amp_low+amp_high)/2;

    A = amp_best;

    fprintf("---------- A = %.3f ----------\n", A);

    % Execute script
    disp("Experiment script starts now...");
    nidaq_prbs_impedance_measurement();
    disp("Experiment completed!");

    % ----------------- Analyze the result ---------------------
    % Skip extra injection periods
    x = measured_excitation_signal((P_idle+P_extra)*mult*N+1:end);
    y = measured_response_signal((P_idle+P_extra)*mult*N+1:end);
    tv = transpose(1/Fs:1/Fs:N*mult/Fs);

    % Fourier analysis
    [Xs, ~, x_mean, x_var] = dfts_over_periods(x, P, Fs);
    [Ys, ~, y_mean, y_var] = dfts_over_periods(y, P, Fs);
    [G, fv, U, Y, x, y] = estimate_frf_from_broadband_measurement(x, y, P, Fs);

    % Compute target frequency-response over multiple periods
    L = length(G);
    Gs = zeros(L, P);
    for k=1:P
        Gs(:,k) = Ys(:,k) ./ Xs(:,k);
    end

    % Calculate amplitude and phase variances
    G_mag_var = zeros(size(x_var));
    for i=1:length(G_mag_var)
        G_mag_var(i) = var(abs(Gs(i,:)));
    end
    % ----------------------------------------------------------

    % ---------------- Plotting --------------------------------
    % Plot the signals
    figure(1), clf();
    subplot(2, 1, 1);
    stairs(tv, x);
    grid("on");
    ylabel("Excitation");
    subplot(2, 1, 2);
    stairs(tv, y);
    grid("on");
    ylabel("Response");
    xlabel("Time (s)");
    sgtitle("Averaged signals");

    % Plot the amplitude spectra
    idx = 2:N*mult/2;
    figure(2), clf();
    subplot(2, 1, 1);
    semilogx(fv(idx), abs(U(idx)), "LineStyle", "none", "Marker", "o", "Color", "blue");
    xlim([f_min, f_bw]);
    grid("on");
    ylabel("Amplitude");
    subplot(2, 1, 2);
    semilogx(fv(idx), abs(Y(idx)), "LineStyle", "none", "Marker", "o", "Color", "blue");
    xlim([f_min, f_bw]);
    grid("on");
    ylabel("Amplitude");
    xlabel("Frequency (Hz)");
    sgtitle("Amplitude spectra");

    % Plot the frequency-response of target system
    figure(3), clf();
    subplot(2, 1, 1);
    errorbar(fv(idx), abs(G(idx)), sqrt(G_mag_var(idx)), "LineStyle", "none", "Marker", ".", "Color", "blue");
    hold("on");
    semilogx(fv(idx), abs(G(idx))*(1+sd_max_relative), "LineStyle", "-", "Color", "g");
    semilogx(fv(idx), abs(G(idx))*(1-sd_max_relative), "LineStyle", "-", "Color", "g");
    hold("off");
    grid("on");
    xlim([f_min, f_bw]);
    ylabel("Amplitude (\Omega)");
    legend(["Reference", "Estimation"], "Location", "best");
    subplot(2, 1, 2);
    semilogx(fv(idx), 180/pi*unwrap(angle(G(idx))), "LineStyle", "none", "Marker", ".", "Color", "blue");
    grid("on");
    xlim([f_min, f_bw]);
    ylabel("Phase (degrees)");
    xlabel("Frequency (Hz)");
    sgtitle("System");

    % Evaluation
    idx = (fv >= f_min) & (fv <= f_bw);
    fv = fv(idx);
    G_mag = abs(G(idx));
    G_mag_sd = sqrt(G_mag_var(idx));

    [passed, idx_failed] = check_deviation_limits(G_mag, G_mag_sd, sd_max_relative);
    figure(1);
    subplot(2, 1, 1);
    if length(idx_failed) > 0
        hold("on");
        xline(fv(idx_failed), "Color", "y");
        hold("off");
    end

    figure(5), clf();
    amplitude_arr = [amplitude_arr; A];
    st = sprintf("A = %.2f", A);
    plot(amplitude_arr, "LineStyle", "-", "Marker", "o");
    title("Amplitude");
    grid("on");

    if ~passed
        amp_low = amp_best;
        disp("Precision test failed!");
        disp("----------------------------------------------------------");
    else
        amp_high = amp_best;
        disp("Precision test passed!");
        disp("----------------------------------------------------------");
    end

    pause(0.5);
end
