function [u, N, f1] = generate_mlbs(A, f_gen, f1_max)
% GENERATE_PRBS Generate an MLBS based on the specified parameters.
%   [u, N, f1] = generate_mlbs(A, f_gen, f1_max) generates an MLBS sequence with amplitude <A>, generation frequency <f_gen> Hz and sequence fundamental frequency at most <f1_max> Hz.

    arguments
        A double
        f_gen double
        f1_max double
    end

    % Design parameters
    n = ceil(log2(f_gen/f1_max + 1));
    N = 2^n - 1;
    f1 = f_gen/N;

    % Generate MLBS
    u = A*idinput(N, "prbs");
end
