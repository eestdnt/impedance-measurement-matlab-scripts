% This script saves the impedance data points as real and imaginary numbers (2nd and 3rd column) to a CSV file. Frequency vector is written to the 1st column in Hertz.
% The following variables is assumed to be in MATLAB workspace:
%   fv: column vector of frequencies.
%   f_bw: bandwidth.
%   csv_filepath (optional): path to the output CSV file.
%   Z: column vector of impedance complex numbers.

if ~exist("csv_filepath", "var")
    csv_filepath = sprintf("%s.csv", extractBetween(data_filepath, 1, strlength(data_filepath)-4));
end

idx = 0 < fv & fv <= f_bw;
T = table(fv(idx), real(Z(idx)), imag(Z(idx)));
T.Properties.VariableNames = {'Frequencies', 'Z_real', 'Z_imag'};
% writetable(T, csv_filepath);
writematrix([fv(idx), real(Z(idx)), imag(Z(idx))], csv_filepath);
fprintf("Impedance data is now written to '%s'!\n", csv_filepath);
