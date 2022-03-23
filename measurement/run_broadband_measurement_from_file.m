function run_broadband_measurement_from_file(excitation_specs_filepath, measurement_data_filepath, measurement_func)
% RUN_BROADBAND_MEASUREMENT_FROM_FILE Broadband frequency-response measurement
%   run_broadband_measurement_from_file(excitation_specs_filepath, measurement_data_filepath, measurement_func) Executes
%   @measurement_func to measure the frequency response using specification variables from excitation_specs_filepath and
%   saves the measurement result to *measurement_data_filepath*.

    % Read specifications from file
    specs = jsondecode(fileread(excitation_specs_filepath));

    % Load specification variables
    excitation_type = specs.type;
    A = specs.amplitude;
    f_bw = specs.bandwidth;
    f_gen = specs.generation_frequency;
    f_min = specs.sequence_frequency;
    Fs = specs.sampling_frequency;
    P_idle = specs.num_idle_periods;
    P_extra = specs.num_extra_periods;
    P = specs.num_periods;

    % Execute script
    disp("Experiment script starts now...");
    measurement_func();
    disp("Experiment completed!");

    % Save the raw measurement data
    clear("ai", "ao", "dq", "data", "device_name", "m", "st");
    fprintf("Saving to file %s...\n", measurement_data_filepath);
    save(measurement_data_filepath);
    disp("Finished!");
end
