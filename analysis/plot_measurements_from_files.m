% Plot multiple FRF estimations from multiple measurements
function plot_measurements_from_files(varargin)

    figure(1), clf();
    subplot(2, 1, 1);
    semilogx(NaN, NaN);
    ylabel("Magnitude (db)");
    grid("on");
    subplot(2, 1, 2);
    semilogx(NaN, NaN);
    xlabel("Frequency (Hz)");
    ylabel("Phase (deg)");
    grid("on");
    sgtitle("System");

    % figure(2), clf();
    % xlabel("Re(Z)");
    % ylabel("-Im(Z)");
    % title("Nyquist plot");
    % grid("on");

    f_min = 0;
    f_max = Inf;
    legend_str_arr = strings(nargin, 1);

    filepaths = strings(0);
    c = 0;
    % Scan for .mat files in the input filenames and one level down into the directory tree if a provided file is a directory
    for k=1:nargin
        f = varargin{k};
        if isfolder(f)
            ft = split(ls(f));
            ft = string(ft);
            for i=1:length(ft)
                p = strcat(f, strcat("/", ft{i}));
                if isfile(p) && contains(p, ".mat")
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
        load(p, "specs");
        excitation_type = specs.type;

        switch specs.type
            case {"mlbs", "dibs"}
                load(p, "measured_excitation_signal", "measured_response_signal", "P_extra", "mult", "N", "P", "Fs", "f_bw");
                % [Z, fv, sampling_freq, signals, dfts, params] = estimate_frf_from_pbs_measurement(p);
                % Skip transients
                x = measured_excitation_signal(P_extra*mult*N+1:end);
                y = measured_response_signal(P_extra*mult*N+1:end);
                [Z, fv, ~, ~, ~, ~] = estimate_frf_from_broadband_measurement(x, y, P, Fs);
                mag = abs(Z);
                phase = unwrap(angle(Z));
            case "sinesweep"
                % load(p);
                [Z, fv, ~, ~, ~, params] = estimate_frf_from_sinesweep_measurement(p);
                mag = abs(Z);
                phase = unwrap(angle(Z));
        end

        figure(1);
        subplot(2, 1, 1);
        hold("on");
        semilogx(fv, db(mag), "LineStyle", "-", "Marker", ".");
        hold("off");
        subplot(2, 1, 2);
        hold("on");
        semilogx(fv, 180/pi*phase, "LineStyle", "-", "Marker", ".");
        hold("off");

        % Update frequency range
        f_min = max([f_min, fv(2)]);
        f_max = min([f_max, f_bw]);

        % Update legend
        legend_str_arr(k) = string(k);

        % % Nyquist plot
        % figure(2), clf();
        % idx = (f_min <= fv_ref) & (fv_ref <= f_max);
        % zv_ref = mag_ref(idx) .* exp(1j*phase_ref(idx));
        % idx = (f_min <= fv_prbs) & (fv_prbs <= f_max);
        % zv_prbs = mag_prbs(idx) .* exp(1j*phase_prbs(idx));
        % idx = (f_min <= fv_dibs) & (fv_dibs <= f_max);
        % zv_dibs = mag_dibs(idx) .* exp(1j*phase_dibs(idx));
        % plot(real(zv_prbs), -imag(zv_prbs), "LineStyle", "none", "Marker", ".", "Color", "blue");
        % hold("on");
        % plot(real(zv_dibs), -imag(zv_dibs), "LineStyle", "none", "Marker", "x", "Color", "red");
        % plot(real(zv_ref), -imag(zv_ref), "LineStyle", "none", "Marker", "o", "Color", "black");
        % hold("off");
        % xlabel("Re(Z)");
        % ylabel("-Im(Z)");
        % title("Polar plot");
        % grid("on");
        % legend(legend_str_arr);
    end

    if length(filepaths)>0
        figure(1);
        subplot(2, 1, 1);
        xlim([f_min, f_max]);
        subplot(2, 1, 2);
        xlim([f_min, f_max]);
        legend_str_arr = ["", legend_str_arr];
        legend(legend_str_arr, "Location", "best");
        disp(legend_str_arr);
    end
end
