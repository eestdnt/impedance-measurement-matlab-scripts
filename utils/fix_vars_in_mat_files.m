function fix_vars_in_mat_files(path)

    filepaths = strings(0);
    c = 0;

    if isfolder(path)
        [paths, ~] = obtain_filepaths_from_dir(path);
        for i=1:length(paths)
            if endsWith(paths(i), ".mat")
                c = c+1;
                filepaths(c) = paths(i);
            end
        end
    elseif isfile(path)
        filepaths(1) = path;
    end

    for f = filepaths
        disp("Processing file " + f);
        load(f, "excitation_type");

        if ~exist("excitation_type", "var")
            load(f, "specs");
            excitation_type = "mlbs";
            if exist("specs", "var")
                excitation_type = specs.type;
                save(f, "excitation_type", "-append");
                disp("Saved excitation_type to " + f);
            end
        end

        if excitation_type == "mlbs" || excitation_type == "dibs"
            clear("f1");
            load(f, "f1");
            if ~exist("f1", "var")
                load(f, "f_gen", "N");
                f1 = f_gen / N;
                save(f, "f1", "-append");
                disp("Saved f1 to " + f);
            end
        end
        
        if excitation_type == "dibs"

            % Fix the dibs_idx incompatibility
            clear("dibs_idx", "idx");
            load(f, "dibs_idx", "idx");
            if ~exist("dibs_idx", "var") && exist("idx", "var")
                dibs_idx = idx;
                save(f, "dibs_idx", "-append");
                disp("Saved dibs_idx to " + f);
            end

            % Fix the specs and psd_arr incompatibility
            clear("psd_arr", "specs");
            load(f, "psd_arr", "specs");
            if ~exist("psd_arr", "var") && exist("specs", "var")
                psds = [];
                load(f, "N", "mult", "Fs", "f_gen", "A");
                fv = transpose(0:f_gen/N:(N-1)*f_gen/N);
                mid_idx = floor((N-1)/2);
                kv = transpose(0:mid_idx);
                specified_indicies = [];
                for s = specs.content
                    % disp(s.f_min + " " + s.f_max + " " + s.power_ratio + " " + s.count + " " + s.scale);
                    selected_idx = kv((kv*f_gen/N > s.f_min) & (kv*f_gen/N <= s.f_max))+1;
                    if s.scale == "log"
                        specified_idx = transpose(floor(logspace(log10(selected_idx(1)), log10(selected_idx(end)), s.count)));
                    else
                        specified_idx = transpose(floor(linspace(selected_idx(1), selected_idx(end), s.count)));
                    end
                    specified_idx = unique(specified_idx);
                    specified_indicies = [specified_indicies; specified_idx];
                    psds = [psds; s.power_ratio * ones(length(specified_idx), 1)];
                end
                freqs = fv(specified_indicies);
                psd_arr = [freqs, psds];
                save(f, "psd_arr", "-append");
                disp("Save psd_arr to " + f);
            end
        end

        disp("Finished processing file " + f);
    end
end
