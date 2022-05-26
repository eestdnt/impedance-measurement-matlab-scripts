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
    sgtitle("Bode plot");

    figure(2), clf();
    xlabel("Re");
    ylabel("-Im");
    title("Nyquist plot");
    grid("on");

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
            ft = ls(f);
            if class(ft) ~= "cell"
                ft = split(ft);
            end
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
        disp("-------------  Load file " + p + " ----------------------");

        % Obtain the excitation specification from the measurement metadata
        load(p, "excitation_type");
        disp(" + Excitation type: " + excitation_type);

        switch excitation_type
            case {"mlbs", "dibs"}
                load(p, "measured_excitation_signal", "measured_response_signal", "P_extra", "N", "P", "Fs", "f_bw", "f1", "f_gen", "idx", "dibs_idx");
                % [Z, fv, sampling_freq, signals, dfts, params] = estimate_frf_from_pbs_measurement(p);
                mult = floor(Fs/f_gen);
                % Skip transients
                x = measured_excitation_signal(end-P*mult*N+1:end);
                y = measured_response_signal(end-P*mult*N+1:end);
                [Z, fv, ~, ~, ~, ~] = estimate_frf_from_broadband_measurement(x, y, P, Fs);
                if excitation_type == "dibs"
                    fv = fv(dibs_idx);
                    Z = Z(dibs_idx);
                end
                idx = (f1 <= fv) & (fv <= f_bw);
                fv = fv(idx);
                Z = Z(idx);
                mag = abs(Z);
                phase = unwrap(angle(Z));
            case "sinesweep"
                load(p, "measured_excitation_signal", "measured_response_signal", "P_extra", "P", "Fs", "f_bw", "fv", "f_gen");
                f1 = fv(1);
                mult = floor(Fs/f_gen);
                P_total = P + P_extra;
                % Skip the transients
                Lu = 0;
                Lx = 0;
                x = zeros(floor(length(measured_excitation_signal)/P_total)*P, 1);
                for i=1:length(fv)

                    f = fv(i);
                    N = floor(f_gen/f);

                    x(Lx+1:Lx+P*mult*N) = measured_excitation_signal(Lu+P_extra*mult*N+1:Lu+P_total*mult*N);
                    y(Lx+1:Lx+P*mult*N) = measured_response_signal(Lu+P_extra*mult*N+1:Lu+P_total*mult*N);
                    Lx = Lx + P*mult*N;
                    Lu = Lu + P_total*mult*N;
                end
                [Z, fv, ~, ~, ~, ~] = estimate_frf_from_sinesweep_measurement(x, y, fv, f_gen, P, Fs);
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

        % Nyquist plot
        figure(2);
        idx = f_min < fv & fv <= f_bw;
        zv = mag(idx).*exp(1j*phase(idx));
        hold("on");
        plot(real(zv), -imag(zv), "LineStyle", "-", "Marker", "x");
        hold("off");

        % Capacitance plot
        figure(3);
        subplot(2, 1, 1);
        semilogx(fv, 1 ./ (2*pi*fv*abs(zv)), "LineStyle", "-", "Marker", "x");
        xlim([fv(1), f_bw]), ylabel("Capacitance (F)"), grid("on");
        subplot(2, 1, 2);
        semilogx(fv, 180/pi*unwrap(angle(zv)), "LineStyle", "-", "Marker", "x");
        xlim([fv(1), f_bw]), ylabel("Phase (deg)"), grid("on"), xlabel("Frequency (Hz)");
        sgtitle("Impedance Bode plot");
    end

    if length(filepaths)>0
        figure(1);
        subplot(2, 1, 1);
        xlim([f_min, f_max]);
        subplot(2, 1, 2);
        xlim([f_min, f_max]);
        % legend_str_arr = ["", legend_str_arr];
        legend(legend_str_arr, "Location", "best");
    end
end
