%% Frequency-domain measurement noise signal demonstration
%
% Clear workspace
clear();

N = 2^6-1; % PRBS sequence length
P = 10; % Number of averaging periods
noise_power = 0; % Noise power

x = zeros(N,P); % Synthesized signal
u = zeros(N,P); % True signal
nx = zeros(N,P); % Noise signal
X = zeros(N,P); % DFT of the synthesized signal
U = zeros(N,P); % DFT of the PRBS
Nx = zeros(N,P); % DFT of the noise signal

% Generate signals
for i=1:P
    tv = linspace(0, 1, N)';

    % Generate PRBS of length N
    u(:,i) = idinput(N, "prbs");

    % Generate gaussian noise
    nx(:,i) = wgn(N, 1, noise_power);
    % nx(:,i) = zeros(N, 1);

    % Synthesize the signal
    x(:,i) = u(:,i) + nx(:,i);

    % Obtain DFT of the signals
    X(:,i) = fft(x(:,i));
    U(:,i) = fft(u(:,i));
    Nx(:,i) = fft(nx(:,i));
end

% figure(2), clf();
% semilogx(0:length(Z)-1, abs(Z).^2/N, "LineStyle", "none", "Marker", ".");
% grid("on");

% fprintf("DFT variance: %.4f\n", var(abs(X(2,:)).^2/N));
%
% figure(3), clf();
% h = histogram(x(:,i));
% grid("on");

% psd = abs(X(5,:)).^2 / N;
x_avg = mean(x, 2);

% Plot the averaged signal
figure(1), clf();
% stairs(x(:,1));
stairs(x_avg);

hold("on");
stairs(u(:,1));
stairs(nx(:,1));
hold("off");

ylim([-2, 2]);
title("Signals");
grid("on");
legend(["x(t)", "u(t)", "nx(t)"]);

% Obtain DFT of the averaged signal
X_avg = fft(x_avg);
figure(2), clf();
semilogx(0:N-1, abs(X_avg), "LineStyle", "none", "Marker", ".");
title("Averaged signal DFT");
grid("on");

psdx_var = zeros(N, 1);
psdu_var = zeros(N, 1);
psdnx_var = zeros(N, 1);
psdx_mean = zeros(N, 1);
psdu_mean = zeros(N, 1);
psdnx_mean = zeros(N, 1);

for i=1:N
    psdx = abs(X(i,:)).^2 / N;
    psdu = abs(U(i,:)).^2 / N;
    psdnx = abs(Nx(i,:)).^2 / N;
    psdx_var(i) = var(psdx);
    psdu_var(i) = var(psdu);
    psdnx_var(i) = var(psdnx);
    psdx_mean(i) = mean(psdx);
    psdu_mean(i) = mean(psdu);
    psdnx_mean(i) = mean(psdnx);
end

% Plot the PSD variance
figure(3), clf();
plot(psdx_var, "Marker", "o");
hold("on");
plot(psdu_var, "Marker", ".");
plot(psdnx_var, "Marker", "x");
hold("off");
ylim([0, 1.5*max(psdx_var)]);
title("PSD variance");
grid("on");
legend(["Var[X]", "Var[U]", "Var[Nx]"]);

% Plot the PSD mean
figure(4), clf();
plot(psdx_mean, "Marker", "o");
hold("on");
plot(psdu_mean, "Marker", ".");
plot(psdnx_mean, "Marker", "x");
hold("off");
ylim([0, 1.5*max(psdx_mean)]);
title("PSD mean");
grid("on");
legend(["E[X]", "E[U]", "E[Nx]"]);
