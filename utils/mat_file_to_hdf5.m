function mat_file_to_hdf5(filepath, output_filepath)
    arguments
        filepath string;
        output_filepath string;
    end

    disp("Input file: " + filepath);
    disp("Output file: " + output_filepath);

    load(filepath)

    if isfile(output_filepath)
        error("Output file exists! Aborting.");
    end

    if excitation_type == "prbs" || excitation_type == "dibs"
        excitation_length = N;
    else
        excitation_length = seq_len(1);
    end

    h5create(output_filepath, "/measured_signals", [length(measured_excitation_signal), 2], DataType="double");
    h5create(output_filepath, "/gen_freq", 1, DataType="uint32");
    h5create(output_filepath, "/sampling_freq", 1, DataType="uint32");
    h5create(output_filepath, "/num_periods", 1, DataType="uint32");
    h5create(output_filepath, "/num_extra_points", 1, DataType="uint32");
    h5create(output_filepath, "/measurement_bandwidth", 1, DataType="uint32");
    h5create(output_filepath, "/excitation/amplitude", 1, DataType="double");
    h5create(output_filepath, "/excitation/type", 1, DataType="string");
    h5create(output_filepath, "/excitation/waveform_datapoints", excitation_length, DataType="double");
    if excitation_type == "dibs"
        h5create(output_filepath, "/excitation/specified_freqs", length(psd_arr), DataType = "double")
        h5create(output_filepath, "/excitation/specified_psds", length(psd_arr), DataType="double");
        h5create(output_filepath, "/excitation/dibs_idx", length(dibs_idx), DataType="double");
    elseif excitation_type == "sinesweep"
        h5create(output_filepath, "/excitation/specified_freqs", length(freqs), DataType = "double")
    end

    h5write(output_filepath, "/measured_signals", [measured_excitation_signal, measured_response_signal]);
    h5write(output_filepath, "/gen_freq", f_gen);
    h5write(output_filepath, "/sampling_freq", Fs);
    h5write(output_filepath, "/num_periods", P);
    if exist("num_idle_points", "var")
        h5write(output_filepath, "/num_extra_points", num_idle_points + P*N*mult);
    else
        h5write(output_filepath, "/num_extra_points", P*N*mult);
    end
    h5write(output_filepath, "/measurement_bandwidth", f_bw);
    h5write(output_filepath, "/excitation/amplitude", A);
    h5write(output_filepath, "/excitation/type", excitation_type);
    if length(u) == excitation_length
        h5write(output_filepath, "/excitation/waveform_datapoints", u);
    else
        h5write(output_filepath, "/excitation/waveform_datapoints", u(1:excitation_length));
    end
    if excitation_type == "dibs"
        h5write(output_filepath, "/excitation/specified_freqs", psd_arr(:,1));
        h5write(output_filepath, "/excitation/specified_psds", psd_arr(:,2));
        h5write(output_filepath, "/excitation/dibs_idx", dibs_idx);
    elseif excitation_type == "sinesweep"
        h5write(output_filepath, "/excitation/specified_freqs", freqs);
    end
end
