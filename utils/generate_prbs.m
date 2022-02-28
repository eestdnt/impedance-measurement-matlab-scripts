function [u, params] = generate_prbs(specs)

    % PRBS design variables
    A = specs.amplitude;
    f_bw = specs.bandwidth;
    f_resolution = specs.resolution;
    sampling_freq = specs.sampling_freq;

    % PRBS specification variables
    f_gen = 4*f_bw;
    n = ceil(log2(f_gen/f_resolution + 1));
    N = 2^n - 1;
    mult = floor(sampling_freq/f_gen);
    Fs = mult*f_gen;

    % Generate MLBS
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
end
