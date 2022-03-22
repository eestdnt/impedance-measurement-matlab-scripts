function [u, params] = generate_mlbs(specs)
% GENERATE_PRBS Generate an MLBS based on the specifications
%   u = generate_mlbs(specs) generates an MLBS sequence.
%   [u, params] = generate_mlbs(specs) generates an MLBS sequence and its design variables

    % Specified variables
    A = specs.amplitude;
    f_bw = specs.bandwidth;
    f_resolution = specs.resolution;
    sampling_freq = specs.max_sampling_freq;

    % Generated variables
    f_gen = 3*f_bw;
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
