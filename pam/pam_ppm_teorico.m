clear; close all; clc;

EbN0_dB = -20:0.5:20;              % asse x [dB]
EbN0    = 10.^(EbN0_dB/10);      % lineare

% Pb teoriche (canale AWGN, rivelatore ottimo)
Pb_PAM = qfunc(sqrt(2*EbN0));    % PAM binaria antipodale
Pb_PPM = qfunc(sqrt(EbN0));      % PPM binaria (segnali ortogonali)

% grafico
figure;
semilogy(EbN0_dB, Pb_PAM, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 5); hold on;
semilogy(EbN0_dB, Pb_PPM, 'r-s', 'LineWidth', 1.5, 'MarkerSize', 5);
grid on;
xlabel('E_b/N_0 [dB]');
ylabel('Probabilità di errore di bit P_b');
title('Confronto teorico PAM vs PPM binarie (canale AWGN)');
legend('PAM binaria', 'PPM binaria', 'Location', 'southwest');
ylim([1e-6 1]);