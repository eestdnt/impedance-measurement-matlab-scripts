%% BATTERY IMPEDANCE MEASUREMENT DATA ANALYSIS WITH DIBS, PRBS AND SINESWEEP REFERENCE (VENABLE MODEL 3120)
% AUTHOR: MINH TRAN

%% CLEAR ALL VARIABLES
clear();

%% LOAD REFERENCE MODEL DATA
ref_dat = readtable("./blob/sinesweep_bat_3_imp.dat");

fv_ref = ref_dat{:,1};
mag_ref = 10.^(ref_dat{:,2}/20);
phase_ref = pi/180*ref_dat{:,3};

%% LOAD PRBS
prbs_dat = readtable("./blob/prbs_frf_latest.dat");

fv_prbs = prbs_dat{:,1};
mag_prbs = 10.^(prbs_dat{:,2}/20);
phase_prbs = pi/180*prbs_dat{:,3};

%% LOAD DIBS
dibs_dat = readtable("./blob/dibs_frf_latest.dat");

fv_dibs = dibs_dat{:,1};
mag_dibs = 10.^(dibs_dat{:,2}/20);
phase_dibs = pi/180*dibs_dat{:,3};

%% Plot properties
f_min = min([fv_ref(2), fv_dibs(2), fv_prbs(2)]);
% f_max = max([fv_ref(end), fv_dibs(end), fv_prbs(end)]);
f_max = 1000;
legend_str_arr = ["Venable", "DIBS", "PRBS"];

%% BODE PLOT
figure(1), clf();
subplot(2,1,1);
semilogx(fv_ref, db(mag_ref), "LineStyle", "-");
hold("on");
plot(fv_dibs, db(mag_dibs), "LineStyle", "none", "Marker", "o");
plot(fv_prbs, db(mag_prbs), "LineStyle", "none", "Marker", ".", "Color", "green");
hold("off");
xlim([f_min, f_max]);
xlabel("Frequency (Hz)"), ylabel("Power (db)"), grid("on");
subplot(2,1,2);
semilogx(fv_ref, 180/pi*phase_ref, "LineStyle", "-");
hold("on");
plot(fv_dibs, 180/pi*phase_dibs, "LineStyle", "none", "Marker", "o");
plot(fv_prbs, 180/pi*phase_prbs, "LineStyle", "none", "Marker", ".", "Color", "green");
hold("off");
legend(legend_str_arr);
xlim([f_min, f_max]);
xlabel("Frequency (Hz)"), ylabel("Phase (deg)"), grid("on");
sgtitle("Battery impedance Bode plot");

%% NYQUIST PLOT

zv_ref = mag_ref .* exp(1j*phase_ref);
zv_dibs = mag_dibs .* exp(1j*phase_dibs);
zv_prbs = mag_prbs .* exp(1j*phase_prbs);

figure(2), clf();
plot(real(zv_prbs), imag(zv_prbs), "LineStyle", "none", "Marker", ".", "Color", "blue");
hold("on");
plot(real(zv_dibs), imag(zv_dibs), "LineStyle", "none", "Marker", "o", "Color", "red");
plot(real(zv_ref), imag(zv_ref), "LineStyle", "-", "Color", "black");
hold("off");
xlabel("Re(Z)");
ylabel("Im(Z)");
title("Battery impedance Nyquist plot"), grid("on");
legend(legend_str_arr);

% %% CALCULATE NRMSE
% err_dibs = nrmse(fv_dibs, mag_dibs, fv_ref, mag_ref);
% err_prbs = nrmse(fv_prbs, mag_prbs, fv_ref, mag_ref);
% 
% fprintf("NRMSE(|Z_dibs|, |Z_ref|) = %.4f %%\n", 100*err_dibs);
% fprintf("NRMSE(|Z_prbs|, |Z_ref|) = %.4f %%\n", 100*err_prbs);
