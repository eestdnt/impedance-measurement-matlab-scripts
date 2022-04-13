function [frf, freq_vec, sampling_freq, signals, dfts, excitation_params] = estimate_frf_from_measurement(measurement_data_filename)

    % ZOH
    Hw = @(w,w0) (1.-exp(-1j*w*2*pi/w0)) ./ (1j*w*2*pi/w0);
    Hk = @(k,N,Fz,Fs) Hw(k/N*2*pi*Fs,2*pi*Fz);
    % % Hk = @(k,L) (1 - exp(-1j*k*2*pi/L)) ./ (1j*k*2*pi/L);

    % Load measurement data
    load(measurement_data_filename);

    % DFT analysis
    f_vec = params.freq_vec;
    start_idx = params.freq_start_idx;
    seq_len = params.freq_sampled_seq_len;

    Z_vec = zeros(length(f_vec), 1);
    X_vec = zeros(length(f_vec), 1);
    Y_vec = zeros(length(f_vec), 1);

    inp_vec = measured_excitation_signal;
    out_vec = measured_response_signal;

    x_averaged = zeros(length(inp_vec)/(P+P_extra), 1);
    y_averaged = zeros(length(out_vec)/(P+P_extra), 1);

    for k = 1:length(f_vec)

        f = f_vec(k);
        
        i = start_idx(k);
        N = seq_len(k);

        % Extract signal vectors
        x = inp_vec((P+P_extra)*mult*(start_idx(k)-1)+1:(P+P_extra)*mult*(start_idx(k)-1+seq_len(k)));
        y = out_vec((P+P_extra)*mult*(start_idx(k)-1)+1:(P+P_extra)*mult*(start_idx(k)-1+seq_len(k)));

        % Skip transients
        x = x(P_extra*mult*seq_len(k)+1:end);
        y = y(P_extra*mult*seq_len(k)+1:end);

        % Average the signals
        x = mean(reshape(x, mult*N, P), 2);
        y = mean(reshape(y, mult*N, P), 2);
        x_averaged(mult*(start_idx(k)-1)+1:mult*(start_idx(k)-1+seq_len(k))) = x;
        y_averaged(mult*(start_idx(k)-1)+1:mult*(start_idx(k)-1+seq_len(k))) = y;

        % DFT
        X = fft(x);
        Y = fft(y);
        freq_step = Fs/length(X);
        fv = (0:freq_step:freq_step*(length(X)-1))';
        
        % Phase compensation
        L = length(X);
        idx = (2:floor((L-1)/2)+1)';
        X(idx) = X(idx) .* Hk(idx-1, L, f_gen*mult, Fs);
        X(L-idx+2) = conj(X(idx));

        % Compute target system frequency response
        Z = Y./X;

        % Select the correct sinewave frequency
        idx = find(fv > 0 & f-freq_step < fv & fv < f+freq_step, 1);
        fv = fv(idx);
        X = X(idx);
        Y = Y(idx);
        Z = Z(idx);

        Z_vec(k) = Z(1);
        X_vec(k) = X(1);
        Y_vec(k) = Y(1);
    end

    % Save output variables
    frf = Z_vec;
    freq_vec = f_vec;
    sampling_freq = Fs;

    signals = struct();
    signals.inp_vec = inp_vec;
    signals.out_vec = out_vec;
    signals.averaged_inp_vec = x_averaged;
    signals.averaged_out_vec = y_averaged;
    
    dfts = struct();
    dfts.inp_dft_vec = X_vec;
    dfts.out_dft_vec = Y_vec;
    
    excitation_params = params;
    excitation_params.start_idx = start_idx;
    excitation_params.seq_len = seq_len;
    excitation_params.P = P;
    excitation_params.P_extra = P_extra;
end
