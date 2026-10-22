clear all; close all; clc;

%% DATI 
N_bit = 2e6;
SNR_dB = -20:2:50; % Vettore degli SNR in dB

BER_simulato = zeros(size(SNR_dB));
BER_teorico = zeros(size(SNR_dB));

%% Sorgente
% rng(1); % seed fisso per generare sempre la stessa sequenza
bit_sequenza = randi([0 1], 1,N_bit);

%% PAM Binario

simboli = 2 * bit_sequenza - 1; % Mappatura antipodale

%% SWEEP SULL'SNR
for i = 1:length(SNR_dB)
    
    SNR = 10^(SNR_dB(i) / 10); % Conversione da dB a scala lineare per ogni valore di SNR_dB
  
    % Fading: energia di simbolo aleatoria esponenziale (media 1)
    E = exprnd(1, [1, N_bit]);
    a = sqrt(E);                     

    sigma = sqrt(1 / (2*SNR)); % Deviazione standard del rumore

    rumore = sigma .* randn(1, N_bit);

    % Segnale ricevuto
    ricevuti = a .* simboli + rumore;

    % Decisore a minima distanza
    % d0 = abs(ricevuti - (-a));     % distanza da -a
    % d1 = abs(ricevuti - (+a));     % distanza da a
    % bit_ricevuti = d1 < d0;
    bit_ricevuti = ricevuti > 0; % decisore ottimizzato

    % Prestazioni
    errori = sum(bit_sequenza ~= bit_ricevuti);
    BER_simulato(i) = errori / N_bit;
    BER_teorico(i) = 0.5 * (1 - sqrt(SNR / (1 + SNR)));

    % OUTPUT A VIDEO
    fprintf("\n====== SNR_dB: %d ======\n", SNR_dB(i)); 
    fprintf("Numero di bit : %d\n", N_bit);
    fprintf("SNR_dB : %d\n", SNR_dB(i));
    fprintf("SNR Lineare : %g\n", SNR);
    fprintf("Numero di errori : %d su %d bit\n", errori, N_bit); 
    fprintf("v.a. Esponenziale (Energia di simbolo) : %g\n", mean(E)); 
    fprintf("BER Simulato : %g\n", BER_simulato(i)); 
    fprintf("BER Teorico : %g\n", BER_teorico(i));
end

%% Grafico
figure;
semilogy(SNR_dB, BER_simulato, 'o-', SNR_dB, BER_teorico, '-');
grid on;
xlabel('SNR (dB)');
ylabel('BER');
legend('BER simulato', 'BER teorico', 'Location', 'southwest');
title('Prestazioni PAM binario con fading');
ylim([1e-5 1]);