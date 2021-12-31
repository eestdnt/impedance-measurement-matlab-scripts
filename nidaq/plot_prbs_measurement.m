function plot_prbs_measurement(measurement_data_filename, reference_frf_filename)

    % Load reference model data
    ref_dat = readtable(reference_frf_filename);

    fv_ref = ref_dat{:,1};
    mag_ref = ref_dat{:,2};
    phase_ref = ref_dat{:,3};

    % Estimate FRF from measurement data
    [Z, fv, Fs, signals, dfts, params] = estimate_frf_from_measurement(measurement_data_filename);
    A = params.seq_amplitude;
    n = params.seq_order;
    N = params.seq_length;
    f_bw = params.bandwidth;
    f_gen = params.generation_freq;
    f_resolution = f_gen/N;
    P = params.P;
    P_extra = params.P_extra;
    mult = floor(Fs/f_gen);
    inp_vec = signals.inp_vec;
    out_vec = signals.out_vec;
    x = signals.averaged_inp_vec;
    y = signals.averaged_out_vec;
    X = dfts.inp_dft_vec;
    Y = dfts.out_dft_vec;

    % Print excitation parameters
    disp("Excitation variables:");
    fprintf("   + Amplitude: A = %.4f\n", A);
    fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
    fprintf("   + Desired frequency resolution: f_res = %.2f Hz\n", f_resolution); 
    fprintf("   + Sequence order (shift-register length): n = %d\n", n);
    fprintf("   + Sequence length: N = %d\n", N);
    fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
    fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
    fprintf("   + Frequency resolution: resolution = %.4f Hz\n", f_gen/N);
    fprintf("   + Number of applied periods: P = %d\n", P);
    fprintf("   + Number of estimated transient periods: P_extra = %d\n", P_extra);

    if params.type == "dibs"
        fprintf(" - Frequency content:\n");
        freq_specs = params.freq_content;
        for k = 1:length(freq_specs)
            f_min = freq_specs(k).f_min;
            f_max = freq_specs(k).f_max;
            power = A^2 * N^2 * freq_specs(k).power_ratio;
            count = freq_specs(k).count;
            fprintf("   + f_start: %.2f Hz, f_end: %2.f Hz, count: %d, power: %.2f dB\n", f_min, f_max, count, db(power));
        end
    end

    % Raw data plot
    figure(1), clf();
    tv = (1/Fs:1/Fs:1/Fs*length(inp_vec))';
    subplot(2, 1, 1);
    stairs(tv, inp_vec), grid("on"), ylabel("Current (A)"), title("Input");
    hold("on"), xline(1/Fs*N*mult*P_extra, "Color", "red"), hold("off");
    subplot(2, 1, 2);
    plot(tv, out_vec), grid("on"), ylabel("Voltage (V)"), title("Output");
    hold("on"), xline(1/Fs*N*mult*P_extra, "Color", "red"), hold("off");
    xlabel("Time (s)");
    sgtitle("Raw signals");

    % Free up memory
    clear("inp_vec", "out_vec");

    %% DFT-window plot
    figure(2), clf();
    tv = (1/Fs:1/Fs:1/Fs*length(x))';
    subplot(2, 1, 1);
    stairs(tv, x), grid("on"), ylabel("Current (A)"), title("Input");
    subplot(2, 1, 2);
    stairs(tv, y), grid("on"), ylabel("Voltage (V)"), title("Output");
    xlabel("Time (s)");
    sgtitle("Averaged signals");

    % Plot averaged signal power spectra
    figure(3), clf();
    subplot(2, 1, 1);
    semilogx(fv, db(abs(X)), "LineStyle", "none", "Marker", "o"), grid on, ylabel("Input power (db)");
    xlim([fv(1), f_bw]);
    subplot(2, 1, 2);
    semilogx(fv, db(abs(Y)), "LineStyle", "none", "Marker", "o"), grid on, ylabel("Output power (db)");
    xlim([fv(1), f_bw]);
    xlabel("Frequency (Hz)");
    sgtitle("Signal power spectra");

    % Bode plot
    figure(4), clf();
    subplot(2, 1, 1);
    semilogx(fv, db(abs(Z)), "LineStyle", "none", "Marker", "o");
    hold("on"), semilogx(fv_ref, db(mag_ref), "LineStyle", "-", "Color", "black"), hold("off");
    xlim([fv(1), f_bw]), ylabel("Power (db)"), grid("on");
    legend(["Estimation", "Reference"]);
    subplot(2, 1, 2);
    semilogx(fv, 180/pi*angle(Z), "LineStyle", "none", "Marker", "o");
    hold("on"), semilogx(fv_ref, 180/pi*phase_ref, "LineStyle", "-", "Color", "black"), hold("off");
    xlim([fv(1), f_bw]), xlabel("Frequency (Hz)"), ylabel("Phase (deg)"), grid("on");
    sgtitle("Bode plot");

    % Nyquist plot
    figure(5), clf();
    idx = 0 < fv & fv <= f_bw;
    zv = abs(Z(idx)) .* exp(1j*angle(Z(idx)));
    zv_ref =mag_ref .* exp(1j*phase_ref);
    plot(real(zv), imag(zv), "LineStyle", "none", "Marker", "o");
    hold("on"), plot(real(zv_ref), imag(zv_ref), "LineStyle", "-", "Color", "black"), hold("off");
    xlabel("Re(Z)");
    ylabel("Im(Z)");
    title("Polar plot"), grid("on");
    legend(["Estimation", "Reference"]);
end
