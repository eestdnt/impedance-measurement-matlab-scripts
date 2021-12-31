function simulate_sinesweep(specs_filename);

    % Excitation parameters
    specs = jsondecode(fileread(specs_filename));

    % SYSTEM DEFINITION
    s = tf("s");
    G_ref = 1 / (1 + 5.852e-4 * s);

    % Generate a sinesweep
    [u, params] = generate_sinesweep(specs_filename);
    A = params.amplitude;
    f_bw = params.bandwidth;
    Fs = params.sampling_freq;
    f_gen = params.generation_freq;
    mult = floor(Fs/f_gen);
    P = 5;
    L = sum(params.freq_sampled_seq_len);

    %% Print excitation parameters
    fprintf("Excitation specifications:\n");
    fprintf(" - Design variables:\n");
    fprintf("   + Amplitude: A = %.4f\n", A);
    fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
    fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
    fprintf(" - Specification variables:\n");
    fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
    fprintf("   + Number of applied periods: P = %d\n", P);
    % fprintf("   + Number of estimated transient periods: P_extra = %d\n", P_extra);

    % fprintf(" - Frequency content:\n");
    % freq_specs = params.freq_content;
    % for k = 1:length(freq_specs)
    %     f_min = freq_specs(k).f_min;
    %     f_max = freq_specs(k).f_max;
    %     power = A^2 * N^2 * freq_specs(k).power_ratio;
    %     count = freq_specs(k).count;

    %     fprintf("   + f_start: %.2f Hz, f_end: %2.f Hz, count: %d, power: %.2f dB\n", f_min, f_max, count, db(power));
    % end
    
    %% Noise level
    noise_power = 1e-5;

    %% Simulation variables
    excitation_time_vec = (0:1/f_gen:(P*L - 1)/f_gen)';
    excitation_vec = zeros(L*P, 1);
    f_vec = params.freq_vec;
    for k = 1:length(f_vec)
        f = f_vec(k);
        start_idx = params.freq_start_idx;
        seq_len = params.freq_sampled_seq_len;
        i = start_idx(k);
        N = seq_len(k);
        excitation_vec((i-1)*P+1:(i-1)*P+P*N) = repmat(u(i:i+N-1), P, 1);
        % size(repmat(u(i:i+N-1), P, 1));
    end
    inp_noise_vec = wgn(length(excitation_vec), 1, noise_power);
    out_noise_vec = wgn(length(excitation_vec), 1, noise_power);
    sim_duration = P*L/f_gen;

    % figure(1), clf();
    % stairs(excitation_time_vec, excitation_vec);
    % grid("on");
    % return;

    %% Simulate
    options = simset('SrcWorkspace','current');
    sim_out = sim("measurement_setup.slx", [], options);

    % Plot the signals
    figure(1), clf();
    tv = (1/Fs:1/Fs:1/Fs*(length(inp_vec)-1))';
    subplot(2, 1, 1);
    stairs(tv, inp_vec(1:end-1)), grid on, title("Input signal");
    ylim([-6, 6]);
    subplot(2, 1, 2);
    plot(tv, out_vec(1:end-1)), grid on, title("Output signal");
    xlabel("Time (s)");

    figure(2), clf();
    subplot(2, 1, 1);
    semilogx(NaN, NaN);
    grid("on");
    subplot(2, 1, 2);
    semilogx(NaN, NaN);
    grid("on");
    sgtitle("Signal power spectra");


    % Analytical model
    fv = (0:Fs/(mult*L):(mult*L-1)*Fs/(mult*L))';
    [mag, phase, ~] = bode(G_ref, 2*pi*fv);
    mag = reshape(mag, numel(mag), 1);
    phase = reshape(phase, numel(phase), 1);

    figure(3), clf();
    subplot(2, 1, 1);
    semilogx(fv, db(mag));
    xlim([fv(2), f_bw]);
    ylabel("Power (db)");
    grid("on");
    subplot(2, 1, 2);
    semilogx(fv, phase);
    xlim([fv(2), f_bw]);
    ylabel("Phase (deg)");
    xlabel("Frequency (Hz)");
    grid("on");
    sgtitle("Bode plot");

    %% DFT analysis
    %
    f_vec = params.freq_vec;
    start_idx = params.freq_start_idx;
    seq_len = params.freq_sampled_seq_len;
    for k = 1:length(f_vec)

        f = f_vec(k);
        
        i = start_idx(k);
        N = seq_len(k);

        % Extract signal vectors
        x = inp_vec(P*mult*(start_idx(k)-1)+1:P*mult*(start_idx(k)-1+seq_len(k)));
        y = out_vec(P*mult*(start_idx(k)-1)+1:P*mult*(start_idx(k)-1+seq_len(k)));

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
    end

    % % Power spectrum
    % figure(2), clf();
    % subplot(2, 1, 1);
    % semilogx(fv, db(abs(X)), "LineStyle", "none", "Marker", "o");
    % grid("on");
    % subplot(2, 1, 2);
    % semilogx(fv, 180/pi*angle(X), "LineStyle", "none", "Marker", "o");
    % grid("on");
    % sgtitle("Excitation power and angle spectra");

    % % Output signal power spectrum
    % figure(4), clf();
    % subplot(2,1,1);
    % semilogx(fv, db(abs(Y)), "LineStyle", "none", "Marker", "o");
    % grid("on");
    % subplot(2,1,2);
    % semilogx(fv, 180/pi*angle(Y), "LineStyle", "none", "Marker", "o");
    % grid("on");
    % title("Output power spectrum");

    % figure(3), clf();
    % subplot(2,1,1);
    % semilogx(fv, db(mag), "LineStyle", "-");
    % xlim([freq_step, f_bw]), ylabel("Power (db)"), grid("on");
    % subplot(2,1,2);
    % semilogx(fv, phase, "LineStyle", "-");
    % xlim([freq_step, f_bw]), xlabel("Frequency (Hz)"), ylabel("Phase (deg)"), grid on;
    % sgtitle("Bode plot");

    % % Estimation
    % G = Y./X;

    % figure(3);
    % subplot(2,1,1);
    % hold("on");
    % plot(fv, db(abs(G)), "LineStyle", "none", "Marker", ".");
    % hold("off");
    % legend(["Measured", "Reference"]);
    % subplot(2,1,2);
    % hold("on");
    % plot(fv, 180/pi*angle(G), "LineStyle", "none", "Marker", ".");
    % hold("off");
end
