function [u, N, f1, idx] = generate_dibs(A, f_gen, f1_max, psd_arr)
% GENERATE_DIBS Generate a DIBS based on the specifications.                                      
%   [u, N, f1, idx] = generate_dibs(A, f_gen, f1_max, psd_arr) generates a DIBS sequence with    
%   amplitude <A>, generation frequency <f_gen> Hz, signal frequency at most <f1_max> Hz, and with frequency content specified by <psd_arr>. <psd_arr> is a matrix with two columns: 1st column contains the specified frequencies and 2nd column contains the corresponding power as a ratio of the total sequence power. If any of the specified frequencies do not match the computed frequency grid, the closest frequency in the grid is selected instead.

    arguments
        A double
        f_gen double
        f1_max double
        psd_arr (:,2) double
    end

    % Design DIBS based on an MLBS
    n = ceil(log2(f_gen/f1_max + 1));
    N = 2^n - 1;
    f1 = f_gen/N;
    D = zeros(N, 1);

    mid_idx = floor((N-1)/2);
    kv = transpose(0:mid_idx);
    specified_indices = [];

    if sum(psd_arr(:,2)) > 1
        disp("Total specified energy is greater than the total sequence energy, aborting!");
        return;
    end

    for i=1:size(psd_arr, 1)
        f = psd_arr(i,1);
        p = psd_arr(i,2) * A^2 * N^2;
        k_best = 0;
        idx = 1;
        for j=1:length(kv)
            k = kv(j);
            if abs(k*f_gen/N - f) < abs(k_best*f_gen/N - f)
                k_best = k;
                idx = j;
            end
        end
        D(idx) = sqrt(p);
        specified_indices = [specified_indices; idx];
    end
    specified_indices = unique(specified_indices);

    % for k = 1:length(freq_segments)
    %     f_min = freq_segments(k).f_min;
    %     f_max = freq_segments(k).f_max;
    %     power = A^2 * N^2 * freq_segments(k).power_ratio;
    %     count = freq_segments(k).count;

    %     selected_idx = kv((kv*f_gen/N > f_min) & (kv*f_gen/N <= f_max))+1;

    %     if freq_segments(k).scale == "log"
    %         specified_idx = transpose(floor(logspace(log10(selected_idx(1)), log10(selected_idx(end)), count)));
    %     else
    %         specified_idx = transpose(floor(linspace(selected_idx(1), selected_idx(end), count))); % Linear scale
    %     end
    %     specified_idx = unique(specified_idx);
    %     specified_indices = [specified_indices; specified_idx];

    %     D(selected_idx) = 0;
    %     D(specified_idx) = sqrt(power);
    % end

    % Mirror the DFT sequence values
    idx = transpose(2:floor((N-1)/2)+1);
    D(N-idx+2) = conj(D(idx));

    % VAN DEN BOS algorithm
    disp("Optimization started");

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
    disp("Optimization finished");

    u = A*b_best;
    idx = [specified_indices; length(B)-specified_indices+1];
end
