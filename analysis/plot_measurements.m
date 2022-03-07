% Plot multiple FRF estimations from multiple measurements
function plot_measurements(varargin)

    figure(1), clf();
    subplot(2, 1, 1);
    semilogx(NaN, NaN);
    ylabel('Magnitude (db)');
    grid('on');
    subplot(2, 1, 2);
    semilogx(NaN, NaN);
    xlabel('Frequency (Hz)');
    ylabel('Phase (deg)');
    grid('on');
    sgtitle('Bode plot');

    % figure(2), clf();
    % xlabel('Re(Z)');
    % ylabel('-Im(Z)');
    % title('Nyquist plot');
    % grid('on');

    f_min = Inf;
    f_max = 0;
    legend_str_arr = strings(nargin, 1);

    filepaths = strings(0);
    c = 0;
    for k=1:nargin
        f = varargin{k};
        if isfolder(f)
            % r = scan_for_mat_files(pwd(), path);
            ft = split(ls(f));
            for i=1:length(ft)
                p = strcat(f, strcat('/', ft{i}));
                if isfile(p) && contains(p, '.mat')
                    c = c+1;
                    filepaths(c) = p;
                end
            end
        else
            c = c+1;
            filepaths(c) = f;
        end
    end
    disp(filepaths);

    for k=1:length(filepaths)
        p = filepaths(k);

        % Obtain the excitation specification from the measurement metadata
        load(p, 'specs');
        excitation_type = specs.type;

        switch specs.type
            case 'mlbs'
                [Z, fv, sampling_freq, signals, dfts, params] = estimate_frf_from_pbs_measurement(p);
                mag = abs(Z);
                phase = unwrap(angle(Z));
            case 'dibs'
                [Z, fv, sampling_freq, signals, dfts, params] = estimate_frf_from_pbs_measurement(p);
                mag = abs(Z);
                phase = unwrap(angle(Z));
            case 'sinesweep'
                [Z, fv, ~, ~, ~, params] = estimate_frf_from_sinesweep_measurement(p);
                mag = abs(Z);
                phase = unwrap(angle(Z));
        end

        figure(1);
        subplot(2, 1, 1);
        hold('on');
        semilogx(fv, db(mag), 'LineStyle', '-', 'Marker', '.');
        hold('off');
        subplot(2, 1, 2);
        hold('on');
        semilogx(fv, 180/pi*phase, 'LineStyle', '-', 'Marker', '.');
        hold('off');

        % Update frequency range
        f_min = min([f_min, fv(2)]);
        f_max = max([f_max, fv(end)]);

        % Update legend
        legend_str_arr(k) = p;

        % % Nyquist plot
        % figure(2), clf();
        % idx = (f_min <= fv_ref) & (fv_ref <= f_max);
        % zv_ref = mag_ref(idx) .* exp(1j*phase_ref(idx));
        % idx = (f_min <= fv_prbs) & (fv_prbs <= f_max);
        % zv_prbs = mag_prbs(idx) .* exp(1j*phase_prbs(idx));
        % idx = (f_min <= fv_dibs) & (fv_dibs <= f_max);
        % zv_dibs = mag_dibs(idx) .* exp(1j*phase_dibs(idx));
        % plot(real(zv_prbs), -imag(zv_prbs), 'LineStyle', 'none', 'Marker', '.', 'Color', 'blue');
        % hold('on');
        % plot(real(zv_dibs), -imag(zv_dibs), 'LineStyle', 'none', 'Marker', 'x', 'Color', 'red');
        % plot(real(zv_ref), -imag(zv_ref), 'LineStyle', 'none', 'Marker', 'o', 'Color', 'black');
        % hold('off');
        % xlabel('Re(Z)');
        % ylabel('-Im(Z)');
        % title('Polar plot');
        % grid('on');
        % legend(legend_str_arr);
    end

    if length(filepaths)>0
        figure(1);
        subplot(2, 1, 1);
        xlim([f_min, f_max]);
        subplot(2, 1, 2);
        xlim([f_min, f_max]);
        legend(legend_str_arr);
    end
end
