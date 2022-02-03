function [u, params] = generate_dibs(specs)

    % PRBS design variables
    A = specs.amplitude;
    f_bw = specs.bandwidth;
    f_resolution = specs.prbs_resolution;
    sampling_freq = specs.sampling_freq;

    % DIBS specification variables
    f_gen = 3*f_bw;
    n = ceil(log2(f_gen/f_resolution + 1));
    N = 2^n - 1;
    P = 5;
    P_tr = 3;
    mult = floor(sampling_freq/f_gen);
    Fs = mult*f_gen;

    %% Desigb DIBS based on an MLBS
    mlbs = A*idinput(N, "prbs");
    D = fft(mlbs);

    mid_idx = floor((N-1)/2);
    kv = (0:mid_idx)';
    D(1) = 0;
    D(kv+1) = 0;
    specified_indices = [];

    freq_specs = specs.content;
    for k = 1:length(freq_specs)
        f_min = freq_specs(k).f_min;
        f_max = freq_specs(k).f_max;
        power = A^2 * N^2 * freq_specs(k).power_ratio;
        count = freq_specs(k).count;

        selected_idx = kv((kv*f_gen/N > f_min) & (kv*f_gen/N <= f_max))+1;

        if freq_specs(k).scale == "log"
            specified_idx = floor(logspace(log10(selected_idx(1)), log10(selected_idx(end)), count))';
        else
            specified_idx = floor(linspace(selected_idx(1), selected_idx(end), count))'; % Linear scale
        end
        specified_idx = unique(specified_idx);
        specified_indices = [specified_indices; specified_idx];

        D(selected_idx) = 0;
        D(specified_idx) = sqrt(power);
    end

    % Mirror the DFT sequence values
    % D(mid_idx+2:N) = conj(flip(D(2:mid_idx+1)));
    idx = (2:floor((N-1)/2)+1)';
    D(N-idx+2) = conj(D(idx));

    %% VAN DEN BOS algorithm
    disp("Optimization started");

    d = real(ifft(D));

    J_best = Inf;
    b_best = zeros(size(d));
    num_tries = 1000;

    for t=1:num_tries

        if t == 1
            b = signum(d);
        else
            b = signum(rand(1,length(D))'-0.5); % Initial design (random phase angles)
        end
        B = fft(b);
        phi = angle(B);
        prev_phi = zeros(size(phi));
        J = Inf;

        while prev_phi ~= phi

            prev_phi = phi;
            
            C = abs(D).*exp(1j*phi);
            c = real(ifft(C));
            b = signum(c);
            B = fft(b);
            phi = angle(B);

            % Calculate error
            J = sum((abs(B)-abs(D)).^2);
        end

        if J < J_best
            J_best = J;
            b_best = b;
        end
    end
    disp("Optimization finished");

    b = A*b_best;
    B = fft(b);
    Q = fft(mlbs);
    % fv = (0:N-1)' * f_gen/N;
    u = b;

    params = struct();
    params.type = "dibs";
    params.seq_amplitude = A;
    params.bandwidth = f_bw;
    params.sampling_freq = Fs;
    params.seq_order = n;
    params.seq_length = N;
    params.generation_freq = f_gen;
    params.freq_resolution = f_gen/N;
    params.freq_content = freq_specs;
    params.indicies = [specified_indices; length(B)-specified_indices+1];
    params.prbs = mlbs;

    % %% Print DIBS parameters
    % fprintf("DIBS specifications:\n");
    % fprintf(" - Design variables:\n");
    % fprintf("   + Amplitude: A = %.4f\n", A);
    % fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
    % fprintf(" - Specification variables:\n");
    % fprintf("   + Shift-register length: n = %d\n", n);
    % fprintf("   + Sequence length: N = %d\n", N);
    % fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
    % fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
    % fprintf("   + Frequency resolution: resolution = %.4f Hz\n", f_gen/N);
    % fprintf("   + Number of applied periods: P = %d\n", P);
    % fprintf("   + Number of estimated transient periods: P_tr = %d\n", P_tr);

    % fprintf(" - Frequency content:\n");
    % for k = 1:length(freq_specs)
    %     f_min = freq_specs(k).f_min;
    %     f_max = freq_specs(k).f_max;
    %     power = A^2 * N^2 * freq_specs(k).power_ratio;
    %     count = freq_specs(k).count;

    %     fprintf("   + f_start: %.2f Hz, f_end: %2.f Hz, count: %d, power: %.2f dB\n", f_min, f_max, count, db(power));
    % end

    % disp("Finished!");
end
