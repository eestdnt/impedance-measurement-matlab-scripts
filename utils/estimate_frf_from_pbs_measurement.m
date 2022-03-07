function [frf, freq_vec, sampling_freq, signals, dfts, excitation_params] = estimate_frf_from_pbs_measurement(measurement_data_filename)

    % ZOH
    Hw = @(w,w0) (1.-exp(-1j*w*2*pi/w0)) ./ (1j*w*2*pi/w0);
    Hk = @(k,N,Fz,Fs) Hw(k/N*2*pi*Fs,2*pi*Fz);

    % Load measurement data
    load(measurement_data_filename);

    % Extract raw signals
    x = inp_vec;
    y = out_vec;

    % Skip transients
    x = x(P_extra*mult*N+1:end);
    y = y(P_extra*mult*N+1:end);

    % Averaging
    x = mean(reshape(x, mult*N, P), 2);
    y = mean(reshape(y, mult*N, P), 2);

    % DFT analysis
    X = fft(x);
    Y = fft(y);
    freq_step = Fs/length(X);
    fv = (0:freq_step:freq_step*(length(X)-1))';

    % Phase compensation (due to DAC)
    L = length(X);
    idx = (2:floor((L-1)/2)+1)';
    X(idx) = X(idx) .* Hk(idx-1, L, f_gen*mult, Fs);
    X(L-idx+2) = conj(X(idx));

    % Compute frequency response
    Z = Y./X;

    if params.type == "dibs"
        idx = params.indicies;
        fv = fv(idx);
        Z = Z(idx);
        X = X(idx);
        Y = Y(idx);
    end

    % Save output variables
    frf = Z;
    freq_vec = fv;
    sampling_freq = Fs;

    signals = struct();
    signals.inp_vec = inp_vec;
    signals.out_vec = out_vec;
    signals.averaged_inp_vec = x;
    signals.averaged_out_vec = y;

    dfts = struct();
    dfts.inp_dft_vec = X;
    dfts.out_dft_vec = Y;

    excitation_params = params;
    excitation_params.P = P;
    excitation_params.P_extra = P_extra;
end
