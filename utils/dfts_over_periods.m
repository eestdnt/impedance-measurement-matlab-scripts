function [X, fv, x_averaged, x_var] = dfts_over_periods(x, P, Fs)

    arguments
        x (:,1) double
        P uint32
        Fs double
    end

    % ZOH transfer function
    ZOH = @(w, T) (1.-exp(-1j*w*T)) ./ (1j*w*T);

    % Length of one period
    L = floor(length(x)/P);

    % Averaging
    x = reshape(x, L, P);
    L = size(x, 1);

    % Obtain averaged signals
    x_averaged = mean(x, 2);

    % Frequency-domain vectors
    fv = transpose(0:Fs/L:Fs/L*(L-1));
    X = zeros(size(x));

    % DFT analysis
    for k=1:P
        X(:,k) = fft(x(:,k));

        % ZOH adjustment
        idx = transpose(2:floor((L-1)/2)+1);
        X(idx,k) = X(idx,k) .* ZOH((idx-1)/L*2*pi*Fs, 1/Fs);
        X(L-idx+2,k) = conj(X(idx,k));
    end

    x_var = zeros(L, 1);
    for k=1:L
        x_var(k) = var(x(k,:));
    end
end
