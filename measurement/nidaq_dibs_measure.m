function nidaq_dibs_measure(specs_filename, output_filename)

    % Design variables
    specs = jsondecode(fileread(specs_filename));

    % Generate the excitation signal
    [u, params] = generate_dibs(specs);
    A = params.seq_amplitude;
    N = params.seq_length;
    f_bw = params.bandwidth;
    f_gen = params.generation_freq;
    Fs = params.sampling_freq;
    n = floor(log2(N+1));
    P = 5;
    P_extra = 3;
    mult = floor(Fs/f_gen);

    % Print excitation parameters
    disp('Excitation variables:');
    fprintf('   + Amplitude: A = %.4f\n', A);
    fprintf('   + Measurement bandwidth: f_bw = %d Hz\n', f_bw);
    fprintf('   + Sequence order (shift-register length): n = %d\n', n);
    fprintf('   + Sequence length: N = %d\n', N);
    fprintf('   + Generation frequency: f_gen = %d Hz\n', f_gen);
    fprintf('   + Sampling frequency: Fs = %d Hz\n', Fs);
    fprintf('   + Number of applied periods: P = %d\n', P);
    fprintf('   + Number of extra (transient) periods: P_extra = %d\n', P_extra);

    % Build excitation signal for NiDAQ
    x = repmat(u, P+P_extra, 1);
    x = repmat(x, 1, mult);
    x = reshape(x', mult*N*(P+P_extra), 1);
    excitation_vec = x;

    % tvec = (1/Fs:1/Fs:1/Fs*length(excitation_vec))';
    % figure(1), clf();
    % stairs(tvec, excitation_vec);
    % title('Excitation signal');
    % xlabel('Time (s)');
    % grid('on');

    % Estimate running time
    duration = N * (P + P_extra) / f_gen;
    fprintf(' -- Estimated measurement time: %.4f seconds (%.4f minutes)\n', duration, duration/60);
    st = sprintf(' Measurement time is %.2f seconds (or %.2f minutes), do we continue? (Y/N [Y])\n', duration, duration/60);
    
    m = input(st, 's');
    if m ~= "" && m ~= "Y"
        return;
    end

    % Setup NiDAQ
    disp('Setting up NIDAQ');

    device_name = 'Dev1';
    daqreset();
    dq = daq('ni');
    dq.Rate = Fs;
    
    % Setup input channels
    ai = addinput(dq, device_name, 1:2, 'Voltage');
    ai(1).Range = [-1 1]; % Output current
    ai(2).Range = [-5 5]; % Output voltage
    
    % Setup output channels
    ao = addoutput(dq, device_name, 0:0, 'Voltage');
    ao(1).Range = [-5 5]; % PRBS voltage perturbation by linear amplifier
    
    % Start the acquisition
    disp('Measurement starting...');
    [data, ~, ~] = readwrite(dq, excitation_vec, 'OutputFormat', 'Matrix');
    disp('Measurement stopped!');
    
    % Format the result
    inp_vec = 10*data(:,1);  % 10A/V amplification
    out_vec = data(:,2);

    % Save the raw measurement data
    clear('ai', 'ao', 'dq', 'data');
    % filename = datestr(datetime(), 'yyyy.mm.dd__HH.MM.SS');
    % filename = sprintf('./blob/dibs_%s.mat', filename);
    disp('Saving to file...');
    % save(filename);
    save(output_filename);
    disp('Finished!');
end
