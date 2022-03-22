function [u, N, f_min, idx] = generate_dibs(A, f_gen, f_min, freq_segments)
% GENERATE_DIBS Generate a DIBS based on the specifications.                                      
%   [u, params] = generate_dibs(A, f_bw, f_min, f_sampling_max) generates a DIBS sequence with    
%   amplitude A, generation frequency f_gen Hz and frequency resolution at least f_min Hz and also     returns the design parameters.

    arguments
        A double
        f_gen double
        f_min double
        freq_segments (:,1) freq_segment_class
    end

    % Design DIBS based on an MLBS
    n = ceil(log2(f_gen/f_min + 1));
    N = 2^n - 1;
    f_min = f_gen/N;
    mlbs = A*idinput(N, "prbs");
    D = fft(mlbs);

    mid_idx = floor((N-1)/2);
    kv = transpose(0:mid_idx);
    D(1) = 0;
    D(kv+1) = 0;
    specified_indices = [];

    for k = 1:length(freq_segments)
        f_min = freq_segments(k).f_min;
        f_max = freq_segments(k).f_max;
        power = A^2 * N^2 * freq_segments(k).power_ratio;
        count = freq_segments(k).count;

        selected_idx = kv((kv*f_gen/N > f_min) & (kv*f_gen/N <= f_max))+1;

        if freq_segments(k).scale == "log"
            specified_idx = transpose(floor(logspace(log10(selected_idx(1)), log10(selected_idx(end)), count)));
        else
            specified_idx = transpose(floor(linspace(selected_idx(1), selected_idx(end), count))); % Linear scale
        end
        specified_idx = unique(specified_idx);
        specified_indices = [specified_indices; specified_idx];

        D(selected_idx) = 0;
        D(specified_idx) = sqrt(power);
    end

    % Mirror the DFT sequence values
    idx = transpose(2:floor((N-1)/2)+1);
    D(N-idx+2) = conj(D(idx));

    % VAN DEN BOS algorithm
    % disp("Optimization started");

    d = real(ifft(D));

    J_best = Inf;
    b_best = zeros(size(d));
    num_tries = 1000;

    for t=1:num_tries

        if t == 1
            b = signum(d);
        else
            b = signum(transpose(rand(1,length(D)))-0.5); % Initial design (random phase angles)
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
    % disp("Optimization finished");

    b = A*b_best;
    B = fft(b);
    Q = fft(mlbs);
    u = b;
    idx = [specified_indices; length(B)-specified_indices+1];
end
