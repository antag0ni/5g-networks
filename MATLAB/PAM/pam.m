clear all; close all; clc;

%% DATI 
N_bit = 100000;
SNR_dB = 8; % rapporto segnale rumore

%% Sorgente
rng(1); % seed fisso per generare sempre la stessa sequenza
bit_sequenza = randi([0 1], 1,N_bit);

fprintf("Bit da trasmettere:\n");
disp(bit_sequenza(1:10));

%% PAM Binario

% In MATLAB grazie alla vettorizzazione gli operatori aritmetici
% lavorano per default elemento per elemento quindi possiamo
% mappare gli elementi sfruttando la seguente regola:

simboli = 2 * bit_sequenza - 1; % Mappatura antipodale

fprintf("Simboli con modulazione antipodale:\n");
disp(simboli(1:10));

%% Rumore AWGN
SNR = 10^(SNR_dB / 10); % Conversione da dB a scala lineare
sigma = sqrt(1/(2*SNR)); % deviazione standard

rumore = sigma * randn(1, N_bit); % seed fissato a 1

fprintf("Rumore AWGN:\n");
disp(rumore(1:10));

%% Segnale ricevuto
ricevuti = simboli + rumore;

fprintf("Segnale ricevuto:\n");
disp(ricevuti(1:10));

%% Decisore a minima distanza
d0 = abs(ricevuti - (-1));     % distanza da -1
d1 = abs(ricevuti - (+1));     % distanza da 1
bit_ricevuti = d1 < d0;            

fprintf("Bit ricevuti:\n");
disp(bit_ricevuti(1:10));

%% Prestazioni
errori = sum(bit_sequenza ~= bit_ricevuti);
BER_simulato = errori / N_bit;

BER_teorico = qfunc(sqrt(2 * SNR));

%% OUTPUT A VIDEO
fprintf("\n====== DATI ======\n"); 
fprintf("Numero di bit : %d\n", N_bit);
fprintf("SNR_dB : %d\n", SNR_dB);
fprintf("SNR Lineare : %g\n", SNR);
fprintf("\n=== PRESTAZIONI ===\n"); 
fprintf("Numero di errori : %d su %d bit\n", errori, N_bit); 
fprintf("BER Simulato : %g\n", BER_simulato); 
fprintf("BER Teorico : %g\n", BER_teorico);