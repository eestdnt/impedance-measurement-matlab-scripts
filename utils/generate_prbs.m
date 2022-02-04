function [u, params] = generate_prbs(specs)

    % PRBS design variables
    A = specs.amplitude;
    f_bw = specs.bandwidth;
    f_resolution = specs.resolution;
    sampling_freq = specs.sampling_freq;

    % PRBS specification variables
    f_gen = 3*f_bw;
    n = ceil(log2(f_gen/f_resolution + 1));
    N = 2^n - 1;
    mult = floor(sampling_freq/f_gen);
    Fs = mult*f_gen;

    %% Design DIBS based on an MLBS
    u = A*idinput(N, "prbs");

    params = struct();
    params.type = "mlbs";
    params.seq_amplitude = A;
    params.bandwidth = f_bw;
    params.sampling_freq = Fs;
    params.seq_order = n;
    params.seq_length = N;
    params.generation_freq = f_gen;
    params.freq_resolution = f_gen/N;

    % %% Print DIBS parameters
    % fprintf("PRBS specifications:\n");
    % fprintf(" - Design variables:\n");
    % fprintf("   + Amplitude: A = %.4f\n", A);
    % fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
    % fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
    % fprintf(" - Specification variables:\n");
    % fprintf("   + Shift-register length: n = %d\n", n);
    % fprintf("   + Sequence length: N = %d\n", N);
    % fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
    % fprintf("   + Frequency resolution: %.4f Hz\n", f_gen/N);
    % fprintf("   + Number of applied periods: P = %d\n", P);
    % fprintf("   + Number of estimated transient periods: P_tr = %d\n", P_tr);
end
