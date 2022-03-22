function [Z, fv, X, Y, x_averaged, y_averaged] = estimate_frf_from_broadband_measurement(x, y, P, Fs)
% ESTIMATE_FRF_FROM_BROADBAND_MEASUREMENT Compute the frequency-response function from the measured excitation and response signals of the system.
%   [Z, fv, X, Y, x_averaged, y_averaged] = estimate_frf_from_broadband_measurement(x, y, P, Fs) computes the frequency-response estimation of a broadband measurement with excitation vector x, response vector y, P injection periods and sampling frequency Fs.

    arguments
        x (:,1) double
        y (:,1) double
        P uint32
        Fs double
    end

    % Load measurement data
    % load(measurement_data_filename);

    % Extract raw signals
    % x = inp_vec;
    % y = out_vec;

    % % Skip transients
    % x = x(P_extra*mult*N+1:end);
    % y = y(P_extra*mult*N+1:end);

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
    ZOH = @(w, T) (1.-exp(-1j*w*T)) ./ (1j*w*T); % ZOH transfer function
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

    % if params.type == "dibs"
    %     idx = params.indicies;
    %     wv = wv(idx);
    %     Z = Z(idx);
    %     X = X(idx);
    %     Y = Y(idx);
    % end

    % % Save output variables
    % frf = Z;
    % sampling_freq = Fs;

    % signals = struct();
    % signals.inp_vec = inp_vec;
    % signals.out_vec = out_vec;
    % signals.averaged_inp_vec = x;
    % signals.averaged_out_vec = y;

    % dfts = struct();
    % dfts.inp_dft_vec = X;
    % dfts.out_dft_vec = Y;

    % excitation_params = params;
    % excitation_params.P = P;
    % excitation_params.P_extra = P_extra;
end
