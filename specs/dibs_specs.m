excitation_type = "dibs";

A = 0.1;
f_bw = 2000;
f_gen = 6000;
f_min = 1;
Fs = 500000;

freq_content = [freq_segment_class()];
freq_content(1).f_min = 1;
freq_content(1).f_max = 2000;
freq_content(1).power_ratio = 1;
freq_content(1).scale = "log";
freq_content(1).count = 20;

P_idle = 1;
P_extra_periods = 5;
P = 3;
