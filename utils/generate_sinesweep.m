function [u, params] = generate_sinesweep(specs)
    % Design variables
    A = specs.amplitude;
    f_bw = specs.bandwidth;
    f_start = specs.start_freq;
    count = specs.count;
    sampling_freq = specs.sampling_freq;
    f_vec = zeros(specs.count, 1);
    if specs.scale == "log"
        f_vec = floor(logspace(log10(f_start), log10(f_bw), count))';
    else
        f_vec = linspace(log10(f_start), log10(f_bw), count)';
    end
    f_vec = unique(f_vec);

    % Specification variables
    f_gen = 100*f_bw;
    mult = floor(sampling_freq/f_gen);
    Fs = mult*f_gen;

    % Generate the sines
    disp("Sinesweep started");
    len = 0;
    start_idx = zeros(length(f_vec), 1);
    seq_len = zeros(length(f_vec), 1);
    for k = 1:length(f_vec)
        f = f_vec(k);
        start_idx(k) = len+1;
        seq_len(k) = floor(f_gen/f);
        len = len + seq_len(k);
    end
    u = zeros(len, 1);
    for k = 1:length(f_vec)

        f = f_vec(k);
        
        i = start_idx(k);
        N = seq_len(k);
        
        % GENERATE SINEWAVE
        tv = (0:1/f_gen:(N-1)/f_gen)';
        u(i:i+N-1) = A*sin(2*pi*f*tv);

        % SAMPLING FREQUENCY
    %     mult = floor(MAX_SAMPLING_FREQ/f_gen);
    %     Fs = mult*f_gen;

        % % BUILD INPUT SIGNAL FOR NIDAQ
        % u = repmat(u, P+P_tr, 1); % REPEAT FOR P+P_extra CYCLES
        % u = repmat(u, 1, mult);
        % u = reshape(u', mult*N*(P+P_tr), 1);
        
        % duration = (P+P_tr)*N/f_gen;
        % total_duration = total_duration + duration;
        % disp("-----------------------------------------");
        % fprintf("Sine frequency: %.2f Hz\n", f);
        % fprintf(" + Estimated measurement time: %.2f seconds (%.2f minutes)\n", duration, duration/60);
        
        % % START THE MEASUREMENT
        % disp(" + Measurement starting...");
        % [data, ~, ~] = readwrite(dq, u, "OutputFormat", "Matrix");
        % disp(" + Measurement stopped!");
        % disp("-----------------------------------------");
        
        % % FORMAT THE RESULT
        % current_vec = 10*data(:,1); % 10A/V AMPLIFICATION
        % voltage_vec = data(:,2);
        
        % % PLOT RESULT
        % plot_frf();
    end
    disp("Sinesweep ended!");

    params = struct();
    params.type = "sinesweep";
    params.amplitude = A;
    params.bandwidth = f_bw;
    params.sampling_freq = Fs;
    params.generation_freq = f_gen;
    params.start_freq = f_start;
    params.freq_vec = f_vec;
    params.freq_start_idx = start_idx;
    params.freq_sampled_seq_len = seq_len;
end
