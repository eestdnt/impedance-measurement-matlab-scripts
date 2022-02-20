clear();

addpath("../utils");

% s = tf("s");
% G_ref = 1 / (1 + 5.852e-4 * s);
% [u, params] = generate_prbs(specs);

% ZOH
Hw = @(w,w0) (1.-exp(-1j*w*2*pi/w0)) ./ (1j*w*2*pi/w0);
Hk = @(k,N,Fz,Fs) (Hw(k/N*2*pi*Fs,2*pi*Fz));

A = 1;
n = 10;
N = 2^n-1;
u = A*idinput(N, "prbs");

f_gen = 1000;
mult = 10;
Fs = f_gen*mult;
x = repmat(u, 1, mult);
x = reshape(x', N*mult, 1);

% % Phase compensation
% L = length(X);
% % Hk = @(k,L) (1 - exp(-1j*k*2*pi/L)) ./ (1j*k*2*pi/L);
% idx = (2:floor((L-1)/2)+1)';
% % X(idx) = X(idx) .* Hk(idx-1, L);
% X(idx) = X(idx) .* Hk(idx-1);
% X(L-idx+2) = conj(X(idx));

% Plot signal
figure(1), clf();
stairs((0/f_gen:1/f_gen:(N-1)/f_gen)', u);
hold('on');
plot((0:1/Fs:(N*mult-1)/Fs)', x, "Marker", "o", "LineStyle", "none");
hold('off');
ylim([-2, 2]);
grid('on');
xlabel('Time (s)');
ylabel('Signal value');
title('PRBS signal');

U = fft(u);
X = fft(x);

% Add ZOH
L = length(U);
idx = (2:floor((L-1)/2)+1)';
V(idx) = U(idx) .* Hk(idx-1,L,f_gen,Fs);
V(L-idx+2) = conj(V(idx));

% Phase compensation
L = length(X);
idx = (2:floor((L-1)/2)+1)';
X(idx) = X(idx) .* Hk(idx-1,L,f_gen*mult,Fs);
X(L-idx+2) = conj(X(idx));

% Normalize DFT
U = U / abs(U(2));
V = V / abs(V(2));
X = X / abs(X(2));

idx = (1:mult:N*mult)';

% Plot DFT
% fv = (0:f_gen/N:(N-1)*f_gen);
fv = (0:Fs/N:(N-1)*Fs/N)';
fv_mult = (0:Fs/(N*mult):(N*mult-1)*Fs/(N*mult))';
figure(2), clf();

subplot(2,1,1);
% stem(fv, abs(U), "Marker", "None");
stem(fv, abs(V));
hold('on');
plot(fv, abs(X(idx)), "LineStyle", "none", "Marker", "x");
% plot(fv_mult, abs(X), "LineStyle", "none", "Marker", "x");
hold('off');
ylabel('Amplitude');
grid('on');
xlim([fv(2), fv((N+1)/2)]);

subplot(2,1,2);
% stem(fv, angle(U));
stem(fv, 180/pi*angle(V));
hold('on');
plot(fv, 180/pi*angle(X(idx)), "LineStyle", "none", "Marker", "x");
hold('off');
grid('on');
ylabel('Phase (rad)');
xlim([fv(2), fv((N+1)/2)]);
sgtitle("DFT");
