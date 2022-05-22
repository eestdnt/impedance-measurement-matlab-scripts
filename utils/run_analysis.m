function run_analysis(data_filepath, operations)
% RUN_ANALYSIS Process the experiment data.
%   run_analysis(data_filepath, operations) loads experiment data from <data_filepath> into MATLAB workspace and executes a sequence of operations specified by <operations>.
%
%   See also run_experiment.

    arguments
        data_filepath string;
        operations (:,1) cell;
    end

    % Load experiment data
    fprintf("---------------- Step #1 ---------------\n");
    fprintf("Loading data from file %s...\n", data_filepath);

    if endsWith(data_filepath, ".mat")
        load(data_filepath);
    elseif endsWith(data_filepath, ".hdf5")
        measured_signals = h5read(data_filepath, "/measured_signals");
        measured_excitation_signal = measured_signals(:,1);
        measured_response_signal = measured_signals(:,2);

        f_gen = double(h5read(data_filepath, "/gen_freq"));
        Fs = double(h5read(data_filepath, "/sampling_freq"));
        P = double(h5read(data_filepath, "/num_periods"));
        num_idle_points = double(h5read(data_filepath, "/num_extra_points"));
        f_bw = double(h5read(data_filepath, "/measurement_bandwidth"));
        A = double(h5read(data_filepath, "/excitation/amplitude"));
        excitation_type = h5read(data_filepath, "/excitation/type");
        N = double(h5read(data_filepath, "/excitation/length"));
        u = double(h5read(data_filepath, "/excitation/waveform_datapoints"));
        if excitation_type == "dibs"
            specified_freqs = h5read(data_filepath, "/excitation/specified_freqs");
            specified_psd = h5read(data_filepath, "/excitation/specified_psd");
            psd_arr = [specified_freqs, specified_psd];
            dibs_idx = h5read(data_filepath, "/excitation/dibs_idx");
        elseif excitation_type == "sinesweep"
            freqs = h5read(data_filepath, "/excitation/specified_freqs");
        end
    end

    % Execute the sequence
    for i=1:length(operations)
        f = operations{i};
        fprintf("---------------- Step #%d ---------------\n", i+1);
        disp(f);
        f();
    end
    fprintf("---------------- Finished! ---------------\n");
end
