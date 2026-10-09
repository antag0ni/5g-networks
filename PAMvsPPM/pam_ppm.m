clear all; 
close all; 
clc; 

%% 1. DATI DI SIMULAZIONE
N_bit = 1e6;       % 1 milione di bit per elevata precisione
SNR_dB = -20:1:20;   % Vettore SNR per bit in dB

% Vettori per memorizzare i risultati
BER_sim_PAM = zeros(size(SNR_dB));
BER_teo_PAM = zeros(size(SNR_dB));
BER_sim_PPM = zeros(size(SNR_dB));
BER_teo_PPM = zeros(size(SNR_dB));

%% 2. SORGENTE
rng(1); % seed fisso per riproducibilità
bit_sequenza = randi([0, 1], 1, N_bit);

%% 3. MAPPATURA DEI SEGNALI
% 2-PAM (Antipodale 1D): Bit 0 -> -1, Bit 1 -> +1
simboli_PAM = 2 * bit_sequenza - 1;

% 2-PPM (Ortogonale 2D): Bit 0 -> [1; 0], Bit 1 -> [0; 1]
simboli_PPM = zeros(2, N_bit);
simboli_PPM(1, bit_sequenza == 0) = 1;
simboli_PPM(2, bit_sequenza == 1) = 1;

fprintf("=== SIMULAZIONE COMPARATIVA: 2-PAM vs 2-PPM ===\n");
fprintf("Numero di bit trasmessi: %d\n\n", N_bit);

%% 4. SWEEP SULL'SNR (CICLO MONTE CARLO)
for i = 1:length(SNR_dB)
    SNR_lin = 10^(SNR_dB(i) / 10);
    sigma = sqrt(1 / (2 * SNR_lin));

    % --- CANALE E DECISORE 2-PAM ---
    rumore_PAM = sigma * randn(1, N_bit);
    ricevuti_PAM = simboli_PAM + rumore_PAM;

    bit_ricevuti_PAM = ricevuti_PAM > 0; % Soglia a 0
    errori_PAM = sum(bit_sequenza ~= bit_ricevuti_PAM);

    BER_sim_PAM(i) = errori_PAM / N_bit;
    BER_teo_PAM(i) = qfunc(sqrt(2 * SNR_lin)); % Pb = Q(sqrt(2*SNR))

    % --- CANALE E DECISORE 2-PPM ---
    rumore_PPM = sigma * randn(2, N_bit);
    ricevuti_PPM = simboli_PPM + rumore_PPM;

    bit_ricevuti_PPM = ricevuti_PPM(2, :) > ricevuti_PPM(1, :); % Massimo correlazione
    errori_PPM = sum(bit_sequenza ~= bit_ricevuti_PPM);

    BER_sim_PPM(i) = errori_PPM / N_bit;
    BER_teo_PPM(i) = qfunc(sqrt(SNR_lin)); % Pb = Q(sqrt(SNR))

    % Output di sintesi
    fprintf('SNR: %2d dB | BER 2-PAM: %e | BER 2-PPM: %e\n', ...
        SNR_dB(i), BER_sim_PAM(i), BER_sim_PPM(i));
end

%% 5. GRAFICO DEL CONFRONTO (semilogy)
figure('Name', 'Confronto Prestazioni 2-PAM vs 2-PPM');

% 2-PAM (Rosso)
semilogy(SNR_dB, BER_teo_PAM, 'r -- ', 'LineWidth', 2, 'DisplayName', '2-PAM Teorico'); hold on;
semilogy(SNR_dB, BER_sim_PAM, 'ro-', 'LineWidth', 1.2, 'MarkerFaceColor', 'r', 'DisplayName', '2-PAM Simulato');

% 2-PPM (Blu)
semilogy(SNR_dB, BER_teo_PPM, 'b -- ', 'LineWidth', 2, 'DisplayName', '2-PPM Teorico');
semilogy(SNR_dB, BER_sim_PPM, 'bo-', 'LineWidth', 1.2, 'MarkerFaceColor', 'b', 'DisplayName', '2-PPM Simulato');

grid on;
title('Confronto Prestazioni: 2-PAM (Antipodale) vs 2-PPM (Ortogonale)');
xlabel('Rapporto Segnale/Rumore per bit E_b/N_0 [dB]');
ylabel('Bit Error Rate (BER)');
legend('Location', 'southwest');
ylim([1e-6 1]);
xlim([min(SNR_dB) max(SNR_dB)]);