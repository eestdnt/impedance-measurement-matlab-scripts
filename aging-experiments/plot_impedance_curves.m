% tbl = readtable("./blob/aging-tests/cell-2/cycle-7-low.csv");

cycle_numbers = [2, 3, 4, 6, 7, 8, 9, 10, 11];
% cycle_numbers = [1, 2, 3, 4, 5, 6, 7, 8];
% test_dir = "./aging-experiments/files/cell-1";
test_dir = "./aging-experiments/files/cell-2";

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

figure(2), clf();

for k = 1:length(cycle_numbers)

    cycle = cycle_numbers(k);

    csv_filepath_low = test_dir + "/cycle-" + cycle + "-low.csv";
    csv_filepath_high = test_dir + "/cycle-" + cycle + "-high.csv";

    tbl_low = readtable(csv_filepath_low);
    tbl_high = readtable(csv_filepath_high);

    fv = [tbl_low{:,1}; tbl_high{:,1}];
    Z_real = [tbl_low{:,2}; tbl_high{:,2}];
    Z_imag = [tbl_low{:,3}; tbl_high{:,3}];

    Z = complex(Z_real, Z_imag);

    mag = abs(Z);
    phase = angle(Z);
    f_min = fv(1);
    f_max = fv(end);

    figure(1);
    subplot(2, 1, 1);
    hold("on");
    semilogx(fv, db(mag), "LineStyle", "-", "Marker", ".");
    xlim([f_min, f_max]);
    hold("off");
    subplot(2, 1, 2);
    hold("on");
    semilogx(fv, 180/pi*phase, "LineStyle", "-", "Marker", ".");
    xlim([f_min, f_max]);
    hold("off");

    % Nyquist plot
    figure(2);
    % idx = (f_min <= fv_ref) & (fv_ref <= f_max);
    % zv_ref = mag_ref(idx) .* exp(1j*phase_ref(idx));
    % idx = (f_min <= fv_prbs) & (fv_prbs <= f_max);
    % zv_prbs = mag_prbs(idx) .* exp(1j*phase_prbs(idx));
    % idx = (f_min <= fv_dibs) & (fv_dibs <= f_max);
    % zv_dibs = mag_dibs(idx) .* exp(1j*phase_dibs(idx));
    hold("on");
    plot(Z_real, -Z_imag, "LineStyle", "-", "Marker", "o");
    hold("off");
    xlabel("Re(Z)");
    ylabel("-Im(Z)");
    title("Nyquist plot");
    grid("on");

    legend_str_arr(k) = "cycle-" + cycle;
end

figure(1);
subplot(2, 1, 1);
xlim([f_min, f_max]);
subplot(2, 1, 2);
xlim([f_min, f_max]);
legend_str_arr = ["", legend_str_arr];
legend(legend_str_arr, "Location", "best");

figure(2);
grid("on");
legend(legend_str_arr, "Location", "best");
