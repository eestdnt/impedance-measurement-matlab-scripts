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
    n = ceil(log2(f_gen/f1_max + 1)); % PRBS sequence order
    N = 2^n - 1; % Sequence length
    f1 = f_gen/N; % Fundamental frequency
    D = zeros(N, 1); % Specified harmonic spectrum

    mid_idx = floor((N-1)/2); % Obtain frequency index of Nyquist frequency
    kv = transpose(0:mid_idx); % Obtain index array up to the Nyquist frequency
    specified_indices = []; % Indicies from the frequency grid that are specified in the DIBS

    if sum(psd_arr(:,2)) > 1
        disp("Total specified energy is greater than the total sequence energy, aborting!");
        return;
    end

    for i=1:size(psd_arr, 1)
        f = psd_arr(i,1); % Specified frequency
        p = psd_arr(i,2) * A^2 * N^2; % Specified power density

        % Find the closest index from the frequency grid to the specified frequency
        k_best = 0;
        idx = 1;
        for j=1:length(kv)
            k = kv(j);
            if abs(k*f_gen/N - f) < abs(k_best*f_gen/N - f)
                k_best = k;
                idx = j;
            end
        end

        D(idx) = sqrt(p); % Assign the specified power density to the found harmonic
        specified_indices = [specified_indices; idx]; % Add the found harmonic index to the list
    end
    specified_indices = unique(specified_indices);

    % Mirror the DFT sequence values (to conserve the DFT properties)
    idx = transpose(2:floor((N-1)/2)+1);
    D(N-idx+2) = conj(D(idx));

    % VAN DEN BOS algorithm
    disp("Optimization started");

    d = real(ifft(D)); % Obtain the time-domain binary waveform

    J_best = Inf; % Best cost value
    b_best = zeros(size(d)); % Time-domain sequence with the best cost value
    num_tries = 1000; % Number of optimization runs

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

            % Calculate cost function (error between specified and optimized)
            J = sum((abs(B)-abs(D)).^2);
        end

        % Update the best cost value
        if J < J_best
            J_best = J;
            b_best = b;
        end
    end
    disp("Optimization finished");

    u = A*b_best; % Time-domain signal with specified amplitude
    idx = [specified_indices; length(B)-specified_indices+1]; % Full DFT indicies
end
