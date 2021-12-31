function nidaq_dibs_measure(specs_filename)
    %% Excitation design

    % Design variables
    specs = jsondecode(fileread(specs_filename));

    %% Generate the excitation signal
    [u, params] = generate_dibs(specs_filename);
    A = params.seq_amplitude;
    N = params.seq_length;
    f_bw = params.bandwidth;
    f_gen = params.generation_freq;
    Fs = params.sampling_freq;
    P = 5;
    P_extra = 3;
    mult = floor(Fs/f_gen);

    % A = specs.amplitude;
    % f_bw = specs.bandwidth;
    % f_resolution = specs.prbs_resolution;
    
    % % Specification variables
    % f_gen = 3*f_bw;
    % n = ceil(log2(f_gen/f_resolution + 1));
    % N = 2^n - 1;
    % P = 5;
    % P_extra = 3;

    % % Build DIBS
    % [u, indicies] = generate_dibs(specs_filename, 10, 11);
    % N = length(u);
    % mult = floor(specs.sampling_freq/f_gen);
    % Fs = mult*f_gen;
    return;

    %% Build excitation signal for NiDAQ
    u = repmat(u, P+P_extra, 1);
    u = repmat(u, 1, mult);
    u = reshape(u', mult * N * (P+P_extra), 1);

    % Estimate running time
    duration = N * (P + P_extra) / f_gen;
    fprintf(" -- Estimated measurement time: %.4f seconds (%.4f minutes)\n", duration, duration/60);
    st = sprintf(" Measurement time is %.2f seconds (or %.2f minutes), do we continue? (Y/N [Y])\n", duration, duration/60);
    
    m = input(st, "s");
    disp(m);
    if m ~= "" && m ~= "Y"
        return;
    end

    %% Setup NiDAQ
    disp("Setting up NIDAQ");

    device_name = "Dev1";
    daqreset();
    dq = daq("ni");
    dq.Rate = Fs;
    
    % Setup input channels
    ai = addinput(dq, device_name, 1:2, "Voltage");
    ai(1).Range = [-1 1]; % Output current
    ai(2).Range = [-5 5]; % Output voltage
    
    % Setup output channels
    ao = addoutput(dq, device_name, 0:0, "Voltage");
    ao(1).Range = [-5 5]; % PRBS voltage perturbation by linear amplifier
    
    % Start the acquisition
    disp("Measurement starting...");
    [data, ~, ~] = readwrite(dq, u, "OutputFormat", "Matrix");
    disp("Measurement stopped!");
    
    % Format the result
    current_vec = 10*data(:,1);  % 10A/V amplification
    voltage_vec = data(:,2);

    %% Save the raw measurement data
    clear("ai", "ao", "dq", "data");
    filename = datestr(datetime(), "yyyy.mm.dd__HH.MM.SS");
    filename = sprintf("./blob/dibs_%s.mat", filename);
    disp("Saving to file...");
    save(filename);
    save("./blob/dibs_latest.mat");
    disp("Finished!");
end
