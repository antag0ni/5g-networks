clear all; close all; clc;

%% DATI 
N_bit = 1e6;
SNR_dB = 0:1:9; 

BER_simulato = zeros(size(SNR_dB));
BER_teorico = zeros(size(SNR_dB));

%% Sorgente
rng(1); % seed fisso per generare sempre la stessa sequenza
bit_sequenza = randi([0 1], 1, N_bit);

%% PPM Binario (2-PPM Ortogonale)
% Ogni simbolo è rappresentato da 2 slot ortogonali (matrice 2 x N_bit):
% Bit 0 -> [1; 0]
% Bit 1 -> [0; 1]
simboli = zeros(2, N_bit);
simboli(1, bit_sequenza == 0) = 1;
simboli(2, bit_sequenza == 1) = 1;

%% SWEEP SU SNR
for i = 1:length(SNR_dB)
    % Rumore AWGN
    SNR = 10^(SNR_dB(i) / 10); % Conversione da dB a scala lineare
    sigma = sqrt(1/(2*SNR)); % deviazione standard

    rumore = sigma * randn(2, N_bit); % seed fissato a 1

    % Segnale ricevuto
    ricevuti = simboli + rumore;

    % Decisore a minima distanza
    bit_ricevuti = ricevuti(2, :) > ricevuti(1, :);

    % Prestazioni
    errori = sum(bit_sequenza ~= bit_ricevuti);
    BER_simulato(i) = errori / N_bit;

    BER_teorico(i) = qfunc(sqrt(SNR));

    % OUTPUT A VIDEO
    fprintf("\n====== SNR_dB: %d ======\n", SNR_dB(i)); 
    fprintf("Numero di bit : %d\n", N_bit);
    fprintf("SNR_dB : %d\n", SNR_dB(i));
    fprintf("SNR Lineare : %g\n", SNR);
    fprintf("Numero di errori : %d su %d bit\n", errori, N_bit); 
    fprintf("BER Simulato : %g\n", BER_simulato(i)); 
    fprintf("BER Teorico : %g\n", BER_teorico(i));
end

%% Grafico
figure;
semilogy(SNR_dB, BER_simulato, 'o-', SNR_dB, BER_teorico, 's--');
grid on;
xlabel('SNR (dB)');
ylabel('BER');
legend('BER simulato', 'BER teorico', 'Location', 'southwest');
title('Prestazioni PPM binario Su canale AWGN');
ylim([1e-6 1]);