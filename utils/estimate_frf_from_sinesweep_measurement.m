function [Z, fv, X, Y, x_averaged, y_averaged] = estimate_frf_from_sinesweep_measurement(x, y, fv, f_gen, P, Fs)
% ESTIMATE_FRF_FROM_SINESWEEP_MEASUREMENT Compute frequency-response function.
%   [Z, fv, X, Y, x_averaged, y_averaged] = estimate_frf_from_sinesweep_measurement(x, y, fv, f_gen, P, Fs) computes
%   the frequency-response estimation of a sinesweep measurement from excitation vector <x>, response vector <y>,
%   specified frequency vector <fv>, generation frequency <f_gen>, from <P> injection periods and
%   sampling frequency <Fs>.

    arguments
        x (:,1) double
        y (:,1) double
        fv (:,1) double
        f_gen double
        P uint32
        Fs double
    end

    Z_vec = zeros(length(fv), 1);
    X_vec = zeros(length(fv), 1);
    Y_vec = zeros(length(fv), 1);

    x_averaged = zeros(length(x)/P, 1);
    y_averaged = zeros(length(y)/P, 1);

    Lx = 0;
    Lavg = 0;
    mult = floor(Fs/f_gen);

    for k = 1:length(fv)

        f = fv(k);

        N = floor(f_gen/f);

        % Average the signals
        x_avg = mean(reshape(x(Lx+1:Lx+P*mult*N), mult*N, P), 2);
        y_avg = mean(reshape(y(Lx+1:Lx+P*mult*N), mult*N, P), 2);

        x_averaged(Lavg+1:Lavg+mult*N) = x_avg;
        y_averaged(Lavg+1:Lavg+mult*N) = y_avg;

        % DFT
        X = fft(x_avg);
        Y = fft(y_avg);

        % Phase adjustment (due to ZOH effect)
        L = length(X);
        idx = transpose(2:floor((L-1)/2)+1);
        ZOH = @(w, T) (1.-exp(-1j*w*T))./(1j*w*T); % ZOH transfer function
        X(idx) = X(idx) .* exp(1j*angle(ZOH((idx-1)/L*2*pi*Fs, 1/Fs)));
        X(L-idx+2) = conj(X(idx));

        % Magnitude adjustment (due to ZOH effect)
        Y(idx) = Y(idx) .* abs(ZOH((idx-1)/L*2*pi*Fs, 1/Fs));
        Y(L-idx+2) = conj(Y(idx));

        % Compute frequency response
        Z = Y./X;

        Z_vec(k) = Z(2);
        X_vec(k) = X(2);
        Y_vec(k) = Y(2);

        Lavg = Lavg + mult*N;
        Lx = Lx + P*mult*N;
    end

    Z = Z_vec;
    X = X_vec;
    Y = Y_vec;
end
