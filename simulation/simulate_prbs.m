function simulate_prbs(specs_filename);

    addpath("../utils");

    % Read specifications
    specs = jsondecode(fileread(specs_filename));

    % Reference model definition
    s = tf("s");
    G_ref = 1 / (1 + 5.852e-4 * s);

    switch specs.type
        case "dibs"
            [u, params] = generate_dibs(jsondecode(fileread(specs_filename)));
        otherwise
            [u, params] = generate_prbs(jsondecode(fileread(specs_filename)));
    end

    A = params.seq_amplitude;
    N = params.seq_length;
    f_bw = params.bandwidth;
    f_gen = params.generation_freq;
    Fs = params.sampling_freq;
    n = params.seq_order;
    P = 10;
    P_extra = 1;
    mult = floor(Fs/f_gen);

    % Print excitation parameters
    fprintf("Excitation specifications:\n");
    fprintf(" - Design variables:\n");
    fprintf("   + Amplitude: A = %.4f\n", A);
    fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
    fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
    fprintf(" - Specification variables:\n");
    fprintf("   + Shift-register length: n = %d\n", n);
    fprintf("   + Sequence length: N = %d\n", N);
    fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
    fprintf("   + Frequency resolution: %.4f Hz\n", f_gen/N);
    fprintf("   + Number of applied periods: P = %d\n", P);
    fprintf("   + Number of estimated transient periods: P_extra = %d\n", P_extra);

    if specs.type == "dibs"
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
    
    % Noise level
    noise_power = 1e-5;

    % Excitation variables
    excitation_time_vec = (0:1/f_gen:((P+P_extra)*N - 1)/f_gen)';
    excitation_vec = repmat(u, P+P_extra, 1);
    inp_noise_vec = wgn(length(excitation_vec), 1, noise_power);
    out_noise_vec = wgn(length(excitation_vec), 1, noise_power);
    sim_duration = (P+P_extra)*N/f_gen;

    % Simulate
    options = simset('SrcWorkspace','current');
    sim_out = sim("measurement_setup.slx", [], options);

    % Meaurement result analysis

    % Format the result
    x = inp_vec(1:end-1);
    y = out_vec(1:end-1);

    % Skip the transients
    x = x(P_extra*mult*N+1:end);
    y = y(P_extra*mult*N+1:end);

    % Average DFT
    Nx = zeros(mult*N,P);
    for i=1:P
        X = fft(x((i-1)*mult*N+1:i*mult*N));
        Nx(:,i) = abs(X)/abs(X(2));
    end
    % fprintf("Noise variance: %.2f\n", var(inp_noise_vec));

    % Average
    x = mean(reshape(x,mult*N,P),2);
    y = mean(reshape(y,mult*N,P),2);

    % Noise variances
    var_x = zeros(mult*N,1);
    for i=1:mult*N
        var_x(i) = var(Nx(i,:));
    end
    figure(5), clf();
    stem(var_x);
    title("Input noise variance");
    grid("on");

    % Noise signals
    figure(6), clf();
    semilogx(Nx(:,1));
    title("Input noise PSD");
    grid("on");

    % Plot the signals
    figure(1), clf();
    tv = (1/Fs:1/Fs:1/Fs*length(x))';
    subplot(2,1,1);
    stairs(tv,x), grid on, ylabel("Voltage (V)"), title("Input voltage (V)");
    ylim([-6, 6]);
    subplot(2,1,2);
    plot(tv,y), grid on, ylabel("Voltage (V)"), title("Output voltage (V)");
    xlabel("Time (s)");

    % DFT analysis

    % DFT
    X = fft(x);
    Y = fft(y);
    freq_step = Fs/length(X);
    fv = (0:freq_step:freq_step*(length(X)-1))';

    % ZOH processing
    Hk = @(k) (1 - exp(-1j*k*2*pi/N)) ./ (1j*k*2*pi/N);
    L = length(X);
    idx = (2:floor((L-1)/2)+1)';
    X(idx) = X(idx) .* Hk(idx-1);
    X(L-idx+2) = conj(X(idx));

    % MLBS power spectrum
    figure(2), clf();
    subplot(2,1,1);
    semilogx(fv, db(abs(X)), "LineStyle", "none", "Marker", "o");
    % xlim([freq_step, f_bw]);
    % ylim([0, 1.5*max(db(X_abs(2:end)))]);
    grid("on");
    subplot(2,1,2);
    semilogx(fv, 180/pi*angle(X), "LineStyle", "none", "Marker", "o");
    grid("on");
    title("Excitation power spectrum");

    % Output signal power spectrum
    figure(4), clf();
    subplot(2,1,1);
    semilogx(fv, db(abs(Y)), "LineStyle", "none", "Marker", "o");
    % xlim([freq_step, f_bw]);
    grid("on");
    subplot(2,1,2);
    semilogx(fv, 180/pi*angle(Y), "LineStyle", "none", "Marker", "o");
    grid("on");
    title("Output power spectrum");

    % Reference model
    [mag, phase, ~] = bode(G_ref, 2*pi*fv);
    mag = reshape(mag, numel(mag), 1);
    phase = reshape(phase, numel(phase), 1);

    % Reference bode plot
    figure(3), clf();
    subplot(2,1,1);
    semilogx(fv, db(mag), "LineStyle", "-");
    xlim([freq_step, f_bw]), ylabel("Power (db)"), grid("on");
    subplot(2,1,2);
    semilogx(fv, phase, "LineStyle", "-");
    xlim([freq_step, f_bw]), xlabel("Frequency (Hz)"), ylabel("Phase (deg)"), grid on;
    sgtitle("Bode plot");

    % Estimation bode plot
    G = Y./X;
    if params.type == "dibs"
        idx = params.indicies;
        fv = fv(idx);
        G = G(idx);
    end
    figure(3);
    subplot(2,1,1);
    hold("on");
    plot(fv, db(abs(G)), "LineStyle", "none", "Marker", ".");
    hold("off");
    legend(["Measured", "Reference"]);
    subplot(2,1,2);
    hold("on");
    plot(fv, 180/pi*angle(G), "LineStyle", "none", "Marker", ".");
    hold("off");
end
