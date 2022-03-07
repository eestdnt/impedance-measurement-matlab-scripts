function plot_sinesweep_measurement(measurement_data_file)

    % Estimate FRF from measurement data
    [Z, fv, Fs, signals, dfts, params] = estimate_frf_from_sinesweep_measurement(measurement_data_file);
    A = params.amplitude;
    f_bw = params.bandwidth;
    f_gen = params.generation_freq;
    L = sum(params.freq_sampled_seq_len);
    P = params.P;
    P_extra = params.P_extra;
    mult = floor(Fs/f_gen);
    inp_vec = signals.inp_vec;
    out_vec = signals.out_vec;
    x = signals.averaged_inp_vec;
    y = signals.averaged_out_vec;
    X = dfts.inp_dft_vec;
    Y = dfts.out_dft_vec;
    start_idx = params.start_idx;
    seq_len = params.seq_len;

    % Print excitation parameters
    fprintf('Excitation variables:\n');
    fprintf('   + Amplitude: A = %.4f\n', A);
    fprintf('   + Measurement bandwidth: f_bw = %d Hz\n', f_bw);
    fprintf('   + Sampling frequency: Fs = %d Hz\n', Fs);
    fprintf('   + Generation frequency: f_gen = %d Hz\n', f_gen);
    fprintf('   + Number of applied periods: P = %d\n', P);
    fprintf('   + Number of extra applied periods: P_extra = %d\n', P_extra);

    % Raw data plot
    figure(1), clf();
    tv = (0:1/Fs:1/Fs*(length(inp_vec)-1))';
    subplot(2, 1, 1);
    stairs(tv, inp_vec), grid('on'), ylabel('Current (A)'), title('Input');
    hold('on'), xline(tv((P+P_extra)*mult*(start_idx-1)+P_extra*mult*seq_len+1), 'Color', 'red'), hold('off');
    subplot(2, 1, 2);
    plot(tv, out_vec), grid('on'), ylabel('Voltage (V)'), title('Output');
    hold('on'), xline(tv((P+P_extra)*mult*(start_idx-1)+P_extra*mult*seq_len+1), 'Color', 'red'), hold('off');
    xlabel('Time (s)');
    sgtitle('Raw signals');
    % % Raw data plot
    % figure(1), clf();
    % tv = (0:1/Fs:1/Fs*(length(inp_vec)-1))';
    % idx = ((P+P_extra)*mult*(start_idx(end-1)-1))';
    % subplot(2, 1, 1);
    % stairs(tv(idx), inp_vec(idx)), grid('on'), ylabel('Current (A)'), title('Input');
    % hold('on'), xline(tv((P+P_extra)*mult*(start_idx(end-1)-1)+1), 'Color', 'red'), hold('off');
    % ylim([-0.05, 0.05]);
    % subplot(2, 1, 2);
    % plot(tv(idx), out_vec(idx)), grid('on'), ylabel('Voltage (V)'), title('Output');
    % hold('on'), xline(tv((P+P_extra)*mult*(start_idx(end-1)-1)+1), 'Color', 'red'), hold('off');
    % xlabel('Time (s)');
    % sgtitle('Raw signals');

    % Free up memory
    clear('inp_vec', 'out_vec');

    % DFT-window plot
    figure(2), clf();
    tv = (1/Fs:1/Fs:1/Fs*length(x))';
    subplot(2, 1, 1);
    stairs(tv, x), grid('on'), ylabel('Current (A)'), title('Input');
    subplot(2, 1, 2);
    stairs(tv, y), grid('on'), ylabel('Voltage (V)'), title('Output');
    xlabel('Time (s)');
    sgtitle('Averaged signals');

    % Plot averaged signal power spectra
    figure(3), clf();
    subplot(2, 1, 1);
    semilogx(fv, db(abs(X)), 'LineStyle', 'none', 'Marker', 'x'), grid on, ylabel('Input power (db)');
    xlim([fv(1), f_bw]);
    subplot(2, 1, 2);
    semilogx(fv, db(abs(Y)), 'LineStyle', 'none', 'Marker', 'x'), grid on, ylabel('Output power (db)');
    xlim([fv(1), f_bw]);
    xlabel('Frequency (Hz)');
    sgtitle('Signal power spectra');

    % Bode plot
    figure(4), clf();
    subplot(2, 1, 1);
    semilogx(fv, db(abs(Z)), 'LineStyle', 'none', 'Marker', 'x');
    xlim([fv(1), f_bw]), ylabel('Amplitude (db)'), grid('on');
    subplot(2, 1, 2);
    semilogx(fv, 180/pi*unwrap(angle(Z)), 'LineStyle', 'none', 'Marker', 'x');
    xlim([fv(1), f_bw]), xlabel('Frequency (Hz)'), ylabel('Phase (deg)'), grid('on');
    sgtitle('Bode plot');

    % Nyquist plot
    figure(5), clf();
    idx = 0 < fv & fv <= f_bw;
    zv = abs(Z(idx)) .* exp(1j*angle(Z(idx)));
    plot(real(zv), -imag(zv), 'LineStyle', 'none', 'Marker', 'x');
    xlabel('Re(Z)');
    ylabel('-Im(Z)');
    title('Polar plot'), grid('on');
end