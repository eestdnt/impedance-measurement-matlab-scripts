function [psd_var, phsd_var] = calculate_measurement_dft_variance(inp_vec, out_vec, L, P)

    Z_vec = zeros(L, P);

    for k = 1:P
        x = inp_vec((k-1)*L+1:k*L);
        y = out_vec((k-1)*L+1:k*L);

        X = fft(x);
        Y = fft(y);
        Z = Y./X;

        Z_vec(:,k) = Z;
    end

    psd_var = zeros(L, 1);
    phsd_var = zeros(L, 1);
    for i=1:L
        psd_var(i) = var(abs(Z_vec(i,:)));
        phsd_var(i) = var(angle(Z_vec(i,:)));
    end
end
