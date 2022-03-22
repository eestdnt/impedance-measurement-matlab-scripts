function simulate_sinesweep(specs_filename);

    % Simulation settings
    noise_enabled = 1;

    % ZOH
    Hw = @(w,w0) (1 - exp(-1j*w*2*pi/w0)) ./ (1j*w*2*pi/w0);
    Hk = @(k,N,Fz,Fs) Hw(k/N*2*pi*Fs,2*pi*Fz);

    % System definition
    s = tf('s');
    G_ref = 1 / (1 + 5.852e-4 * s);

    % Obtain specifications
    specs = jsondecode(fileread(specs_filename));

    % Generate a sinesweep
    [u, params] = generate_sinesweep(specs);
    A = params.amplitude;
    f_bw = params.bandwidth;
    Fs = params.sampling_freq;
    f_gen = params.generation_freq;
    mult = floor(Fs/f_gen);
    P = 5;
    P_extra = 50;
    L = sum(params.freq_sampled_seq_len);

    % Print excitation parameters
    fprintf('Excitation specifications:\n');
    fprintf(' - Design variables:\n');
    fprintf('   + Amplitude: A = %.4f\n', A);
    fprintf('   + Measurement bandwidth: f_bw = %d Hz\n', f_bw);
    fprintf('   + Sampling frequency: Fs = %d Hz\n', Fs);
    fprintf(' - Specification variables:\n');
    fprintf('   + Generation frequency: f_gen = %d Hz\n', f_gen);
    fprintf('   + Number of applied periods: P = %d\n', P);
    fprintf('   + Number of estimated transient periods: P_extra = %d\n', P_extra);
    
    % Noise level
    noise_power = 1e-5;

    % Simulation variables
    excitation_time_vec = (0:1/f_gen:((P+P_extra)*L - 1)/f_gen)';
    excitation_vec = zeros(L*(P+P_extra), 1);
    f_vec = params.freq_vec;
    for k = 1:length(f_vec)
        f = f_vec(k);
        start_idx = params.freq_start_idx;
        seq_len = params.freq_sampled_seq_len;
        i = start_idx(k);
        N = seq_len(k);
        excitation_vec((i-1)*(P+P_extra)+1:(i-1)*(P+P_extra)+(P+P_extra)*N) = repmat(u(i:i+N-1), P+P_extra, 1);
        % size(repmat(u(i:i+N-1), P, 1));
    end
    inp_noise_vec = wgn(length(excitation_vec), 1, noise_power);
    out_noise_vec = wgn(length(excitation_vec), 1, noise_power);
    if noise_enabled == false
        inp_noise_vec = zeros(size(inp_noise_vec));
        out_noise_vec = zeros(size(out_noise_vec));
    end
    sim_duration = (P+P_extra)*L/f_gen;

    % figure(1), clf();
    % stairs(excitation_time_vec, excitation_vec);
    % grid('on');
    % return;

    % Simulate
    options = simset('SrcWorkspace','current');
    sim_out = sim('measurement_setup.slx', [], options);

    % Plot the signals
    figure(1), clf();
    tvec = (0:1/Fs:1/Fs*(length(inp_vec)-1))';
    subplot(2, 1, 1);
    stairs(tvec, inp_vec), grid('on'), title('Input signal');
    ylim([-6, 6]);
    subplot(2, 1, 2);
    plot(tvec, out_vec), grid('on'), title('Output signal');
    xlabel('Time (s)');

    % Initialize signal power spectra
    figure(2), clf();
    subplot(2, 1, 1);
    semilogx(NaN, NaN);
    ylabel('Input amplitude (db)');
    grid('on');
    subplot(2, 1, 2);
    semilogx(NaN, NaN);
    ylabel('Output amplitude (db)');
    xlabel('Frequency (Hz)');
    grid('on');
    sgtitle('Signal power spectra');

    % Analytical model
    fv = (0:Fs/(mult*L):(mult*L-1)*Fs/(mult*L))';
    [mag, phase, ~] = bode(G_ref, 2*pi*fv);
    mag = reshape(mag, numel(mag), 1);
    phase = reshape(phase, numel(phase), 1);

    % Initialize target system frequency response Bode plot
    figure(3), clf();
    subplot(2, 1, 1);
    semilogx(fv, db(mag));
    xlim([fv(2), f_bw]);
    ylabel('Amplitude (db)');
    grid('on');
    subplot(2, 1, 2);
    semilogx(fv, phase);
    xlim([fv(2), f_bw]);
    ylabel('Phase (deg)');
    xlabel('Frequency (Hz)');
    grid('on');
    sgtitle('Bode plot');

    % Initialize averaged signals plot
    figure(4), clf();
    subplot(2,1,1);
    plot(NaN, NaN);
    ylabel('Input signal');
    grid('on');
    subplot(2,1,2);
    plot(NaN, NaN);
    xlabel('Time (s)');
    ylabel('Output signal');
    grid('on');
    sgtitle('Averaged signals');

    % DFT analysis
    f_vec = params.freq_vec;
    start_idx = params.freq_start_idx;
    seq_len = params.freq_sampled_seq_len;
    for k = 1:length(f_vec)

        f = f_vec(k);
        
        i = start_idx(k);
        N = seq_len(k);

        % Extract signal vectors
        x = inp_vec((P+P_extra)*mult*(start_idx(k)-1)+1:(P+P_extra)*mult*(start_idx(k)-1+seq_len(k)));
        y = out_vec((P+P_extra)*mult*(start_idx(k)-1)+1:(P+P_extra)*mult*(start_idx(k)-1+seq_len(k)));
        tv = tvec((P+P_extra)*mult*(start_idx(k)-1)+1:(P+P_extra)*mult*(start_idx(k)-1+seq_len(k)));

        % Skip transients
        x = x(P_extra*mult*seq_len(k)+1:end);
        y = y(P_extra*mult*seq_len(k)+1:end);
        tv = tv(P_extra*mult*seq_len(k)+1:end);

        % Average the signals
        x_full = x;
        y_full = y;
        x = mean(reshape(x, mult*N, P), 2);
        y = mean(reshape(y, mult*N, P), 2);

        % DFT
        X = fft(x);
        Y = fft(y);
        freq_step = Fs/length(X);
        fv = (0:freq_step:freq_step*(length(X)-1))';

        % Phase compensation
        L = length(X);
        idx = (2:floor((L-1)/2)+1)';
        X(idx) = X(idx) .* Hk(idx-1,L,f_gen*mult,Fs);
        X(L-idx+2) = conj(X(idx));

        % Compute target system frequency response
        Z = Y./X;

        % Extract data for plotting
        idx = find(fv > 0 & f-freq_step < fv & fv < f+freq_step, 1);
        fv = fv(idx);
        X = X(idx);
        Y = Y(idx);
        Z = Z(idx);

        % Mark transient bookmark on signal plots
        figure(1);
        subplot(2,1,1);
        hold('on'), xline(tvec((P+P_extra)*mult*(start_idx(k)-1)+P_extra*mult*seq_len(k)), 'Color', 'red'), hold('off');
        subplot(2,1,2);
        hold('on'), xline(tvec((P+P_extra)*mult*(start_idx(k)-1)+P_extra*mult*seq_len(k)), 'Color', 'red'), hold('off');

        % Signal power spectra
        figure(2);
        subplot(2, 1, 1);
        hold('on');
        semilogx(fv, db(abs(X)), 'LineStyle', '-', 'Marker', 'o', 'Color', 'red');
        hold('off');
        subplot(2, 1, 2);
        hold('on');
        semilogx(fv, db(abs(Y)), 'LineStyle', '-', 'Marker', 'o', 'Color', 'red');
        hold('off');

        % Target system spectra Bode plot
        figure(3);
        subplot(2, 1, 1);
        hold('on');
        semilogx(fv, db(abs(Z)), 'LineStyle', 'none', 'Marker', 'o', 'Color', 'red');
        hold('off');
        ylabel('Amplitude (db)');
        subplot(2, 1, 2);
        hold('on');
        semilogx(fv, 180/pi*unwrap(angle(Z)), 'LineStyle', 'none', 'Marker', 'o', 'Color', 'red');
        ylabel('Phase (deg)');
        xlabel('Frequency (Hz)');
        hold('off');

        % Averaged signals
        figure(4);
        subplot(2,1,1);
        hold('on');
        plot(tv, x_full);
        hold('off');
        subplot(2,1,2);
        hold('on');
        plot(tv, y_full);
        hold('off');
    end
end
