clear all; close all; clc;

%% DATI 
N_bit = 100000;
SNR_dB = 8; % rapporto segnale rumore

%% Sorgente
rng(1); % seed fisso per generare sempre la stessa sequenza
bit_sequenza = randi([0 1], 1,N_bit);

fprintf("Bit da trasmettere:\n");
disp(bit_sequenza(1:10));

%% PPM Binario (2-PPM Ortogonale)
% Ogni simbolo è rappresentato da 2 slot ortogonali (matrice 2 x N_bit):
% Bit 0 -> [1; 0]
% Bit 1 -> [0; 1]
simboli = zeros(2, N_bit);
simboli(1, bit_sequenza == 0) = 1;
simboli(2, bit_sequenza == 1) = 1;

fprintf("Simboli con modulazione ortogonale:\n");
disp(simboli(:, 1:10));

%% Rumore AWGN
SNR = 10^(SNR_dB / 10); % Conversione da dB a scala lineare
sigma = sqrt(1/(2*SNR)); % deviazione standard

rumore = sigma * randn(2, N_bit); % seed fissato a 1

fprintf("Rumore AWGN:\n");
disp(rumore(:, 1:10));

%% Segnale ricevuto
ricevuti = simboli + rumore;

fprintf("Segnale ricevuto:\n");
disp(ricevuti(:, 1:10));

%% Decisore a minima distanza
bit_ricevuti = ricevuti(2, :) > ricevuti(1, :);           

fprintf("Bit ricevuti:\n");
disp(bit_ricevuti(1:10));

%% Prestazioni
errori = sum(bit_sequenza ~= bit_ricevuti);
BER_simulato = errori / N_bit;

BER_teorico = qfunc(sqrt(SNR));

%% OUTPUT A VIDEO
fprintf("\n====== DATI ======\n"); 
fprintf("Numero di bit : %d\n", N_bit);
fprintf("SNR_dB : %d\n", SNR_dB);
fprintf("SNR Lineare : %g\n", SNR);
fprintf("\n=== PRESTAZIONI ===\n"); 
fprintf("Numero di errori : %d su %d bit\n", errori, N_bit); 
fprintf("BER Simulato : %g\n", BER_simulato); 
fprintf("BER Teorico : %g\n", BER_teorico);