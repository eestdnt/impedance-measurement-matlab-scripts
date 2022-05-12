if ~exist("n", "var")
    if excitation_type ~= "sinesweep"
        n = log2(N+1);
    else
        n = 0;
    end
end

% Print excitation parameters
disp("Excitation variables:");
fprintf("   + Amplitude: A = %.4f\n", A);
fprintf("   + Measurement bandwidth: f_bw = %d Hz\n", f_bw);
fprintf("   + Sequence order (shift-register length): n = %d\n", n);
fprintf("   + Sequence length: N = %d\n", N);
fprintf("   + Generation frequency: f_gen = %d Hz\n", f_gen);
fprintf("   + Sampling frequency: Fs = %d Hz\n", Fs);
fprintf("   + Frequency resolution: %.4f Hz\n", f_gen/N);
fprintf("   + Number of applied periods: P = %d\n", P);
fprintf("   + Number of extra periods: P_extra = %d\n", P_extra);