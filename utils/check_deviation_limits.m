function [r, idx_failed] = check_deviation_limits(x, x_sd, sd_max_relative)
% CHECK_DEVIATION_LIMITS Check the limits defined by a maximum relative standard deviation value at every value of vector x given a corresponding uncertainty vector.
%   [r, idx_failed] = check_deviation_limits(x, x_sd, sd_max_relative)

    arguments
        x (:,1) double
        x_sd (:,1) double
        sd_max_relative double
    end

    if length(x) ~= length(x_sd)
        disp("Length mismatched!");
        r = false;
        return;
    end

    idx_failed = find(x_sd > abs(x)*sd_max_relative);
    r = nnz(idx_failed) == 0;
end
