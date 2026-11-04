clear all; close all; clc;

%% DATI 
N_bit = 1e6;
SNR_dB = 0:1:9; % Vettore degli SNR in dB (0, 1, 2, ..., 9 dB)

BER_simulato = zeros(size(SNR_dB));
BER_teorico = zeros(size(SNR_dB));

%% Sorgente
rng(1); % seed fisso per generare sempre la stessa sequenza
bit_sequenza = randi([0 1], 1,N_bit);

%% PAM Binario

% In MATLAB grazie alla vettorizzazione gli operatori aritmetici
% lavorano per default elemento per elemento quindi possiamo
% mappare gli elementi sfruttando la seguente regola:

simboli = 2 * bit_sequenza - 1; % Mappatura antipodale

%% SWEEP SULL'SNR
for i = 1:length(SNR_dB)
    % Rumore AWGN
    SNR = 10^(SNR_dB(i) / 10); % Conversione da dB a scala lineare per ogni valore di SNR_dB
    sigma = sqrt(1/(2*SNR)); % deviazione standard

    rumore = sigma * randn(1, N_bit); % seed fissato a 1

    % Segnale ricevuto
    ricevuti = simboli + rumore;

    % Decisore a minima distanza
    d0 = abs(ricevuti - (-1));     % distanza da -1
    d1 = abs(ricevuti - (+1));     % distanza da 1
    bit_ricevuti = d1 < d0;

    % Prestazioni
    errori = sum(bit_sequenza ~= bit_ricevuti);
    BER_simulato(i) = errori / N_bit;
    BER_teorico(i) = qfunc(sqrt(2 * SNR));

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
title('Prestazioni PAM binario Su canale AWGN');
ylim([1e-6 1]);