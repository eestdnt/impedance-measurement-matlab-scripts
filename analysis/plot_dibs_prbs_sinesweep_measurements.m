% Plot multiple FRF estimations from multiple measurements
function plot_dibs_prbs_sinesweep_measurements(sinesweep_filename, prbs_filename, dibs_filename)

    % Obtain sinesweep measurement
    [Z_ref, fv_ref, ~, ~, ~, prbs_params] = estimate_frf_from_sinesweep_measurement(sinesweep_filename);
    mag_ref = abs(Z_ref);
    phase_ref = unwrap(angle(Z_ref));

    % Obtain PRBS measurement
    [Z_prbs, fv_prbs, prbs_sampling_freq, prbs_signals, prbs_dfts, prbs_params] = estimate_frf_from_pbs_measurement(prbs_filename);
    mag_prbs = abs(Z_prbs);
    phase_prbs = unwrap(angle(Z_prbs));

    % Obtain DIBS measurement
    [Z_dibs, fv_dibs, dibs_sampling_freq, dibs_signals, dibs_dfts, dibs_params] = estimate_frf_from_pbs_measurement(dibs_filename);
    mag_dibs = abs(Z_dibs);
    phase_dibs = unwrap(angle(Z_dibs));

    % Plot properties
    f_min = max([fv_ref(2), fv_dibs(2), fv_prbs(2)]);
    f_max = min([fv_ref(end), fv_dibs(end), fv_prbs(end)]);
    legend_str_arr = ['PRBS estimation', 'DIBS estimation', 'Reference'];

    % Bode plot
    figure(1), clf();
    subplot(2, 1, 1);
    semilogx(fv_prbs, db(mag_prbs), 'LineStyle', 'none', 'Marker', '.', 'Color', 'blue');
    hold('on');
    plot(fv_dibs, db(mag_dibs), 'LineStyle', 'none', 'Marker', 'x', 'Color', 'red');
    plot(fv_ref, db(mag_ref), 'LineStyle', '-', 'Marker', 'o', 'Color', 'black');
    hold('off');
    xlim([f_min, f_max]);
    xlabel('Frequency (Hz)'), ylabel('Amplitude (db)'), grid('on');
    legend(legend_str_arr);
    subplot(2, 1, 2);
    semilogx(fv_prbs, 180/pi*phase_prbs, 'LineStyle', 'none', 'Marker', '.', 'Color', 'blue');
    hold('on');
    plot(fv_dibs, 180/pi*phase_dibs, 'LineStyle', 'none', 'Marker', 'x', 'Color', 'red');
    plot(fv_ref, 180/pi*phase_ref, 'LineStyle', '-', 'Marker', 'o', 'Color', 'black');
    hold('off');
    xlim([f_min, f_max]);
    xlabel('Frequency (Hz)'), ylabel('Phase (deg)'), grid('on');
    sgtitle('Bode plot');

    % Nyquist plot
    figure(2), clf();
    idx = (f_min <= fv_ref) & (fv_ref <= f_max);
    zv_ref = mag_ref(idx) .* exp(1j*phase_ref(idx));
    idx = (f_min <= fv_prbs) & (fv_prbs <= f_max);
    zv_prbs = mag_prbs(idx) .* exp(1j*phase_prbs(idx));
    idx = (f_min <= fv_dibs) & (fv_dibs <= f_max);
    zv_dibs = mag_dibs(idx) .* exp(1j*phase_dibs(idx));
    plot(real(zv_prbs), -imag(zv_prbs), 'LineStyle', 'none', 'Marker', '.', 'Color', 'blue');
    hold('on');
    plot(real(zv_dibs), -imag(zv_dibs), 'LineStyle', 'none', 'Marker', 'x', 'Color', 'red');
    plot(real(zv_ref), -imag(zv_ref), 'LineStyle', 'none', 'Marker', 'o', 'Color', 'black');
    hold('off');
    xlabel('Re(Z)');
    ylabel('-Im(Z)');
    title('Polar plot');
    grid('on');
    legend(legend_str_arr);
end
