function [Z, fv, X, Y, x_averaged, y_averaged] = estimate_frf_from_broadband_measurement(x, y, P, Fs)
% ESTIMATE_FRF_FROM_BROADBAND_MEASUREMENT Compute frequency-response function.
%   [Z, fv, X, Y, x_averaged, y_averaged] = estimate_frf_from_broadband_measurement(x, y, P, Fs) computes
%   the frequency-response estimation of a broadband measurement from excitation vector <x>, response vector <y>,
%   <P> injection periods and sampling frequency <Fs>.

    arguments
        x (:,1) double
        y (:,1) double
        P uint32
        Fs double
    end

    % Length of one period
    L = floor(length(x)/P);

    % Averaging
    x = mean(reshape(x, L, P), 2);
    y = mean(reshape(y, L, P), 2);

    % DFT analysis
    X = fft(x);
    Y = fft(y);
    L = length(X);
    fv = transpose(0:Fs/L:Fs/L*(L-1));

    % Phase adjustment (due to ZOH effect)
    ZOH = @(w, T) (1.-exp(-1j*w*T))./(1j*w*T); % ZOH transfer function
    idx = transpose(2:floor((L-1)/2)+1);
    X(idx) = X(idx) .* exp(1j*angle(ZOH((idx-1)/L*2*pi*Fs, 1/Fs)));
    X(L-idx+2) = conj(X(idx));

    % Magnitude adjustment (due to ZOH effect)
    Y(idx) = Y(idx) .* abs(ZOH((idx-1)/L*2*pi*Fs, 1/Fs));
    Y(L-idx+2) = conj(Y(idx));

    % Compute frequency response
    Z = Y./X;

    % Obtain the averaged signals
    x_averaged = x;
    y_averaged = y;
end
