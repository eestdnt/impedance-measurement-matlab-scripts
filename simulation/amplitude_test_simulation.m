% This program simulates the frequency-response identification of an LTI system
% by optimally selecting an excitation amplitude for PRBS injection
clear();

% ----------------- Initialization ------------------------
% Define an LTI system
f0 = 1000;
sys = tf([1], [1/(2*pi*f0), 1]);

% Specified maximum deviation
sd_max = 0.1;

% Find an optimal amplitude
% A = 1;

amplitude_arr = [];

amp_low = 0.1;
amp_high = 2;
A = amp_high;
amp_prev = amp_low;
epsilon = 0.0005;

% for A=0.5:0.1:2
while abs(A-amp_prev) > epsilon

    amp_prev = A;
    A = (amp_low+amp_high)/2;

    fprintf("---------- A = %.3f ----------\n", A);

    % PRBS generation
    f_bw = 2000;
    f_gen = 6000;
    f_min = 10;
    [excitation, N, f_min] = generate_mlbs(A, f_gen, f_min);

    P_extra = 1; % Extra periods for transient
    P = 10; % Injection periods (included in Fourier analysis)
    P_total = P_extra + P;
    excitation = repmat(excitation, P_total, 1);
    % ----------------------------------------------------------

    % ----------------- Simulate the injection -----------------
    % Specify sampling frequency
    Fs = 4*f_gen;

    % Generate the excitation signal at the same rate as the sampling rate
    mult = floor(Fs/f_gen);
    u = reshape(transpose(repmat(excitation, 1, mult)), P_total*N*mult, 1);

    % Simulate the excitation signal measurement noise
    sigmax = 0.2;
    nx = zeros(size(u));
    for k=1:P
        nx((k-1)*N*mult+1:k*N*mult) = sigmax*randn(N*mult, 1);
    end
    u = u+nx;

    % Generate time vector
    tv = transpose(0:1/Fs:(P_total*N*mult-1)/Fs);

    % Simulate the injection
    y = lsim(sys, u, tv);

    % Simulate the response signal measurement noise
    sigmay = 0.1;
    ny = zeros(size(y));
    for k=1:P
        ny((k-1)*N*mult+1:k*N*mult) = sigmay*randn(N*mult, 1);
    end
    y = y+ny;
    % ----------------------------------------------------------

    % ----------------- Analyze the result ---------------------
    % Skip the transients
    u = u(P_extra*N*mult+1:end);
    y = y(P_extra*N*mult+1:end);
    tv = transpose(1/Fs:1/Fs:N*mult/Fs);

    % Fourier analysis
    [Xs, ~, x_mean, x_var] = dfts_over_periods(u, P, Fs);
    [Ys, ~, y_mean, y_var] = dfts_over_periods(y, P, Fs);
    [G, fv, U, Y, u, y] = estimate_frf_from_broadband_measurement(u, y, P, Fs);

    % Compute target frequency-response over multiple periods
    L = length(G);
    Gs = zeros(L, P);
    for k=1:P
        Gs(:,k) = Ys(:,k) ./ Xs(:,k);
    end

    % Calculate amplitude and phase variances
    X_mag_var = zeros(size(x_var));
    Y_mag_var = zeros(size(y_var));
    G_mag_var = zeros(size(x_var));
    G_phase_var = zeros(size(x_var));
    for i=1:length(X_mag_var)
        X_mag_var(i) = var(abs(Xs(i,:)));
        Y_mag_var(i) = var(abs(Ys(i,:)));
        G_mag_var(i) = var(abs(Gs(i,:)));
        G_phase_var(i) = var(unwrap(angle(Gs(i,:))));
    end
    fprintf("Excitation variance: %.2f\n", mean(x_var));
    fprintf("Response variance: %.2f\n", mean(y_var));
    fprintf("Estimation deviation: %.2f\n", mean(sqrt(G_mag_var(find(~isnan(G_mag_var))))));
    fprintf("Estimation phase deviation: %.2f rads\n", mean(sqrt(G_phase_var(find(~isnan(G_phase_var))))));

    % Selecting the indices
    idx = 2:N*mult/2;

    cxy = mscohere(u, y);
    % ----------------------------------------------------------

    % ---------------- Plotting --------------------------------
    % Plot the signals
    figure(2), clf();
    subplot(2, 1, 1);
    stairs(tv, u);
    grid("on");
    ylabel("Excitation");
    subplot(2, 1, 2);
    stairs(tv, y);
    grid("on");
    ylabel("Response");
    xlabel("Time (s)");
    sgtitle("Averaged signals");

    % Plot the amplitude spectra
    figure(3), clf();
    subplot(2, 1, 1);
    % hold("on");
    errorbar(fv(idx), abs(U(idx)), sqrt(X_mag_var(idx)), "LineStyle", "none", "Marker", ".", "MarkerFaceColor", "blue", "Color", "blue");
    % hold("off");
    xlim([f_min, f_bw]);
    grid("on");
    ylabel("Amplitude");
    subplot(2, 1, 2);
    errorbar(fv(idx), abs(Y(idx)), sqrt(Y_mag_var(idx)), "LineStyle", "none", "Marker", ".", "MarkerFaceColor", "blue", "Color", "blue");
    xlim([f_min, f_bw]);
    grid("on");
    ylabel("Amplitude");
    xlabel("Frequency (Hz)");
    sgtitle("Amplitude spectra");

    % Plot the frequency-response of target system
    [mag_ref, phase_ref, wv_ref] = bode(sys, 2*pi*fv);
    fv_ref = reshape(wv_ref, numel(wv_ref), 1)/(2*pi);
    mag_ref = reshape(mag_ref, numel(mag_ref), 1);
    phase_ref = reshape(phase_ref, numel(phase_ref), 1);

    figure(1), clf();
    subplot(2, 1, 1);
    semilogx(fv_ref, mag_ref, "LineStyle", "-", "Color", "r");
    hold("on");
    errorbar(fv(idx), abs(G(idx)), sqrt(G_mag_var(idx)), "LineStyle", "none", "Marker", ".", "MarkerFaceColor", "blue", "Color", "blue");
    semilogx(fv(idx), abs(G(idx))*(1+sd_max), "LineStyle", "-", "Color", "g");
    semilogx(fv(idx), abs(G(idx))*(1-sd_max), "LineStyle", "-", "Color", "g");
    hold("off");
    grid("on");
    xlim([f_min, f_bw]);
    ylabel("Amplitude");
    subplot(2, 1, 2);
    semilogx(fv_ref, phase_ref, "LineStyle", "-", "Color", "r");
    hold("on");
    errorbar(fv(idx), 180/pi*unwrap(angle(G(idx))), 180/pi*sqrt(G_phase_var(idx)), "LineStyle", "none", "Marker", ".", "MarkerFaceColor", "blue", "Color", "blue");
    hold("off");
    grid("on");
    xlim([f_min, f_bw]);
    ylabel("Phase (degrees)");
    xlabel("Frequency (Hz)");
    sgtitle("System");

    % Plot the coherence vector
    figure(4), clf();
    stem(cxy);
    grid("on");
    title("Coherence vector");
    fprintf("Mean value of coherence: %.2f\n", mean(cxy));

    % Evaluation
    idx = (fv >= f_min) & (fv <= f_bw);
    fv = fv(idx);
    G_mag = abs(G(idx));
    % G_phase = unwrap(angle(G));
    % G_phase = G_phase(idx);

    G_mag_sd = sqrt(G_mag_var(idx));
    % G_phase_sd = sqrt(G_phase_var(idx));

    [passed, idx_failed] = check_deviation_limits(G_mag, G_mag_sd, sd_max);
    % [phase_precision_passed, phase_idx_failed] = check_deviation_limits(G_phase, G_phase_sd, sd_max);
    figure(1);
    subplot(2, 1, 1);
    if length(idx_failed) > 0
        hold("on");
        xline(fv(idx_failed), "Color", "y");
        hold("off");
    end
    % subplot(2, 1, 2);
    % if length(phase_idx_failed) > 0
    %     hold("on");
    %     xline(fv(phase_idx_failed), "Color", "y");
    %     hold("off");
    % end
    legend(["Reference", "Estimation"], "Location", "best");
    % ----------------------------------------------------------
    %

    figure(5), clf();
    amplitude_arr = [amplitude_arr; A];
    st = sprintf("A = %.2f", A);
    plot(amplitude_arr, "LineStyle", "-", "Marker", "o");
    title("Amplitude");
    grid("on");

    if ~passed
        amp_low = A;
        disp("Precision test failed!");
        disp("----------------------------------------------------------");
    else
        amp_high = A;
        disp("Precision test passed!");
        disp("----------------------------------------------------------");
    end

    pause(0.5);
end

fprintf("Optimal amplitude: %.3f\n", A);
