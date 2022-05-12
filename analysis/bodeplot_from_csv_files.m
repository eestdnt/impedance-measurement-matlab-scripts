filepaths = ["./files/RC_freq_response.dat", "./files/prbs-rc-circuit.csv"];
% filepaths = ["./files/RC_freq_response.dat", "./files/prbs-rc-circuit.csv"];
% filepaths = ["./files/RC_freq_response.dat", "./files/prbs-rc-circuit-10.csv"];
% filepaths = ["./files/RC_freq_response.dat", "./files/prbs-rc-circuit-grounded.csv"];
legend_str_arr = ["", "Venable", "PRBS"];

figure(1), clf();
subplot(2, 1, 1);
semilogx(NaN, NaN);
ylabel("Magnitude (db)");
grid("on");
subplot(2, 1, 2);
semilogx(NaN, NaN);
xlabel("Frequency (Hz)");
ylabel("Phase (deg)");
grid("on");
sgtitle("Bode plot");

for k = 1:length(filepaths)

    filepath = filepaths(k);

    csv_dat = readtable(filepath);
    disp(filepath);

    fv = csv_dat{:,1};
    G_real = csv_dat{:,2};
    G_imag = csv_dat{:,3};
    G_mag = abs(complex(G_real, G_imag));
    G_phase = angle(complex(G_real, G_imag));
    if endsWith(filepath, ".dat")
        G_mag = 10.^(csv_dat{:,2}/20);
        G_phase = pi/180*csv_dat{:,3};
    end

    f_min = fv(1);
    f_max = fv(end);

    figure(1);
    subplot(2, 1, 1);
    hold("on");
    semilogx(fv, db(G_mag), "LineStyle", "-", "Marker", ".");
    xlim([f_min, f_max]);
    hold("off");
    subplot(2, 1, 2);
    hold("on");
    semilogx(fv, 180/pi*G_phase, "LineStyle", "-", "Marker", ".");
    xlim([f_min, f_max]);
    hold("off");
end

figure(1);
subplot(2, 1, 1);
xlim([f_min, f_max]);
subplot(2, 1, 2);
xlim([f_min, f_max]);
legend(legend_str_arr, "Location", "best");

