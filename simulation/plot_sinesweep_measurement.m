clear();
figure(3), clf(), subplot(2,1,1), semilogx([NaN], [NaN]), subplot(2,1,2), semilogx([NaN], [NaN]);
figure(4), clf(), subplot(2,1,1), semilogx([NaN], [NaN]), subplot(2,1,2), semilogx([NaN], [NaN]);
figure(5), clf();

%% LOAD REFERENCE
ref_dat = readtable("../blob/bat_2_imp.dat");

fv_ref = ref_dat{:,1};
mag_ref = 10.^(ref_dat{:,2}/20);
phase_ref = pi/180*ref_dat{:,3};

figure(4), clf();
subplot(2,1,1);
semilogx(fv_ref, mag_ref, "LineStyle", "-", "Marker", "none", "Color", "red");
grid("on");
ylabel("Impedance (Ohm)");
subplot(2,1,2);
semilogx(fv_ref, 180/pi*phase_ref, "LineStyle", "-", "Marker", "none", "Color", "red");
grid("on");
ylabel("Phase (deg)");
xlabel("Frequency (Hz)");
sgtitle("Impedance Bode plot");

figure(5), clf();
z_ref = mag_ref .* exp(1j*phase_ref);
plot(real(z_ref), imag(z_ref), "LineStyle", "-", "Marker", "none", "Color", "red");
xlabel("Re(Z)");
ylabel("Im(Z)");
title("Impedance Nyquist plot"), grid("on");

%% LOAD SINESWEEP PARAMETERS

foldername_in_use = "./blob/latest";
% foldername_in_use = "./blob/sinesweep_bat_2_0.5";
% foldername_in_use = "./blob/sinesweep_bat_2_0.1";
load(foldername_in_use + "/params.mat");
foldername = foldername_in_use;

% PRINT SINESWEEP PARAMETERS
disp("Sinesweep parameters:");
fprintf(" - Amplitude: A = %.4f\n", A);
% fprintf(" - Generation multisampling factor: N = %d\n", N);
fprintf(" - Number of applied periods: P = %d\n", P);
fprintf(" - Number of estimated transient periods: P_tr = %d\n", P_tr);
fprintf(" - Total measurement time: %.2f seconds\n", total_duration);

%% SWEEP THROUGH MULTIPLE FREQUENCIES
Z_vec = zeros(length(f_vec), 1);
Q = 0; % COULOMB COUNT

for k = 1:length(f_vec)
    %% LOAD MEASUREMENT DATA
    f = f_vec(k);
    filename = foldername + "/data_" + string(k) + ".mat";
    load(filename);

    %% PLOT RESULT
    plot_frf();
end

Q_full = 2.850; % ???
fprintf("Total discharge: %.4f Ah (%.4f %%)\n", abs(Q), Q/Q_full);

mat = [f_vec', db(abs(Z_vec)), 180/pi*angle(Z_vec)];

%% SAVE SINESWEEP DATA
csvwrite("./blob/sinesweep_frf_latest.dat", mat);
