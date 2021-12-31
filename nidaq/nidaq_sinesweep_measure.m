function nidaq_sinesweep_measure(specs_filename)
    %% Generate the excitation signal
    [u, params] = generate_sinesweep(specs_filename);
    A = params.amplitude;
    f_bw = params.bandwidth;
    Fs = params.sampling_freq;
    f_gen = params.generation_freq;
    mult = floor(Fs/f_gen);
    P = 3;
    L = sum(params.freq_sampled_seq_len);

    %% Print excitation parameters
    fprintf("Excitation specifications:\n");
    fprintf(" - Design variables:\n");
    fprintf("   + Amplitude: A = %.4f\n", A);
    fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
    fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
    fprintf(" - Specification variables:\n");
    fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
    fprintf("   + Number of applied periods: P = %d\n", P);

    %% Build excitation signal for NiDAQ
    excitation_vec = zeros(mult*L*P, 1);
    f_vec = params.freq_vec;
    start_idx = params.freq_start_idx;
    seq_len = params.freq_sampled_seq_len;
    for k = 1:length(f_vec)
        f = f_vec(k);
        i = start_idx(k);
        N = seq_len(k);
        x = u(i:i+N-1);
        x = repmat(x, 1, mult);
        x = reshape(x', mult*N, 1);
        x = repmat(x, P, 1);
        excitation_vec((i-1)*mult*P+1:mult*P*((i-1)+N)) = x;
    end

    % u = repmat(u, P, 1);
    % u = repmat(u, 1, mult);
    % u = reshape(u', mult * L * P, 1);

    u = excitation_vec;
    tvec = (1/Fs:1/Fs:1/Fs*length(excitation_vec))';
    figure(1), clf();
    stairs(tvec, u);
    % xlim([0, 0.5]);
    grid("on");

    % Estimate running time
    duration = L * P * mult / f_gen;
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
    ao(1).Range = [-5 5]; % sinesweep voltage perturbation by linear amplifier
    
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
    filename = sprintf("./blob/sinesweep_%s.mat", filename);
    disp("Saving to file...");
    save(filename);
    save("./blob/sinesweep_latest.mat");
    disp("Finished!");
end
