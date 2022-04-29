% Plot multiple FRF estimations from multiple measurements
function save_impedance_curves(varargin)

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
    sgtitle("Bode plot");

    % figure(2), clf();
    % xlabel("Re(Z)");
    % ylabel("-Im(Z)");
    % title("Nyquist plot");
    % grid("on");

    f_min = Inf;
    f_max = 0;
    legend_str_arr = strings(nargin, 1);

    filepaths = strings(0);
    filenames = strings(0);
    c = 0;
    % Scan for .mat files in the input filenames and one level down into the directory tree if a provided file is a directory
    for k=1:nargin
        f = varargin{k};
        if isfolder(f)
%             ft = split(ls(f));
            ft = ls(f);
            ft = string(ft);
            for i=1:length(ft)
                p = strcat(f, strcat("/", ft{i}));
                if isfile(p) && contains(p, ".mat")
                    c = c+1;
                    filepaths(c) = p;
                    [~, filenames(c), ~] = fileparts(ft{i});
                end
            end
        else
            c = c+1;
            filepaths(c) = f;
            [~, filenames(c), ~] = fileparts(f);
        end
    end
    disp(filepaths);
    disp(size(filenames));

    for k=1:length(filepaths)
        p = filepaths(k);
        disp(p);

        % Obtain the excitation specification from the measurement metadata
        load(p, "specs");
        if exist("specs", "var")
            excitation_type = specs.type;
        else
            load(p, "excitation_type");
            if ~exist("excitation_type", "var")
                excitation_type = "mlbs";
            end
        end
        disp(" + Excitation type: " + excitation_type);

        switch excitation_type
            case {"mlbs", "dibs"}
                load(p, "measured_excitation_signal", "measured_response_signal", "P_extra", "N", "P", "Fs", "f_bw", "P_idle", "f1", "f_gen", "idx", "dibs_idx");
                % [Z, fv, sampling_freq, signals, dfts, params] = estimate_frf_from_pbs_measurement(p);
                mult = floor(Fs/f_gen);
                % Skip transients
                if exist("P_idle", "var")
                    x = measured_excitation_signal(end-P*mult*N+1:end);
                    y = measured_response_signal(end-P*mult*N+1:end);
                else
                    x = measured_excitation_signal(end-P*mult*N+1:end);
                    y = measured_response_signal(end-P*mult*N+1:end);
                end
                [Z, fv, ~, ~, ~, ~] = estimate_frf_from_broadband_measurement(x, y, P, Fs);
                if excitation_type == "dibs"
                    if exist("idx", "var")
                        fv = fv(idx);
                        Z = Z(idx);
                    elseif exist("dibs_idx", "var")
                        fv = fv(dibs_idx);
                        Z = Z(dibs_idx);
                    end
                end
                idx = (f1 <= fv) & (fv <= f_bw);
                fv = fv(idx);
                Z = Z(idx);
                mag = abs(Z);
                phase = unwrap(angle(Z));
            case "sinesweep"
                % load(p);
                [Z, fv, ~, ~, ~, ~] = estimate_frf_from_sinesweep_measurement(p);
                mag = abs(Z);
                phase = unwrap(angle(Z));
        end
        
        % Update frequency range
        f_min = min([f_min, f1]);
        f_max = max([f_max, f_bw]);

        figure(1);
        subplot(2, 1, 1);
        hold("on");
        semilogx(fv, db(mag), "LineStyle", "-", "Marker", ".");
        xlim([f_min, f_max]);
        hold("off");
        subplot(2, 1, 2);
        hold("on");
        semilogx(fv, 180/pi*phase, "LineStyle", "-", "Marker", ".");
        xlim([f_min, f_max]);
        hold("off");

        % Update legend
        % legend_str_arr(k) = string(k);
        legend_str_arr(k) = filenames(k);

        data_filepath = p;
        save_impedance_to_csv_file;
        clear("csv_filepath");

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
    end
end
