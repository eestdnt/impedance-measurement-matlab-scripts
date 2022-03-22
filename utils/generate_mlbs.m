function [u, N, f_min] = generate_mlbs(A, f_gen, f_min)
% GENERATE_PRBS Generate an MLBS based on the specified parameters.
%   [u, N] = generate_mlbs(A, f_gen, f_min) generates an MLBS sequence with
%   amplitude A, generation frequency f_gen Hz and frequency resolution at least f_min Hz.

    arguments
        A double
        f_gen double
        f_min double
    end

    % Design parameters
    n = ceil(log2(f_gen/f_min + 1));
    N = 2^n - 1;
    f_min = f_gen/N;

    % Generate MLBS
    u = A*idinput(N, "prbs");
end
