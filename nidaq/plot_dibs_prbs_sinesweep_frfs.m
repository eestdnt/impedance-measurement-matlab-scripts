%% BATTERY IMPEDANCE MEASUREMENT DATA ANALYSIS WITH DIBS, PRBS AND SINESWEEP REFERENCE (VENABLE MODEL 3120)
clear();

% Load sinesweep
[Z_ref, fv_ref, ~, ~, ~, prbs_params] = estimate_frf_from_sinesweep_measurement("../blob/sinesweep_latest.mat");
mag_ref = abs(Z_ref);
phase_ref = angle(Z_ref);

% Load PRBS
[Z_prbs, fv_prbs, ~, ~, ~, prbs_params] = estimate_frf_from_pbs_measurement("../blob/prbs_latest.mat");
mag_prbs = abs(Z_prbs);
phase_prbs = angle(Z_prbs);

% Load DIBS
[Z_dibs, fv_dibs, ~, ~, ~, dibs_params] = estimate_frf_from_pbs_measurement("../blob/dibs_latest.mat");
mag_dibs = abs(Z_dibs);
phase_dibs = angle(Z_dibs);

% Plot properties
f_min = max([fv_ref(2), fv_dibs(2), fv_prbs(2)]);
f_max = min([fv_ref(end), fv_dibs(end), fv_prbs(end)]);
legend_str_arr = ["PRBS estimation", "DIBS estimation", "Reference"];

% Bode plot
figure(1), clf();
subplot(2,1,1);
semilogx(fv_prbs, db(mag_prbs), "LineStyle", "none", "Marker", ".", "Color", "blue");
hold("on");
plot(fv_dibs, db(mag_dibs), "LineStyle", "none", "Marker", "x", "Color", "red");
plot(fv_ref, db(mag_ref), "LineStyle", "-", "Color", "black");
hold("off");
xlim([f_min, f_max]);
xlabel("Frequency (Hz)"), ylabel("Power (db)"), grid("on");
legend(legend_str_arr);
subplot(2,1,2);
semilogx(fv_prbs, 180/pi*phase_prbs, "LineStyle", "none", "Marker", ".", "Color", "blue");
hold("on");
plot(fv_dibs, 180/pi*phase_dibs, "LineStyle", "none", "Marker", "x", "Color", "red");
plot(fv_ref, 180/pi*phase_ref, "LineStyle", "-", "Color", "black");
hold("off");
xlim([f_min, f_max]);
xlabel("Frequency (Hz)"), ylabel("Phase (deg)"), grid("on");
sgtitle("Bode plot");
