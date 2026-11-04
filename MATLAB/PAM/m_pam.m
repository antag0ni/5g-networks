clear all; close all; clc;

%% DATI 
M = 64;
assert(mod(log2(M),1) == 0, 'M deve essere una potenza di 2');
k = log2(M);
N_simboli = 1e6;
N_bit = N_simboli * k;
SNR_dB = -20:1:50;

% Costellazione M-PAM: [..., -5, -3, -1, +1, +3, +5, ...] 
livelli = 2*(1:M) - 1 - M;

% Codifica di Gray a k bit (riga i -> livello i)
n = (0:M-1)';
gray_dec = bitxor(n, bitshift(n, -1));                  % M x 1, valori decimali Gray
gray_code = mod(floor(gray_dec ./ 2.^(k-1:-1:0)), 2);   % M x k, MSB a sinistra

BER_simulato = zeros(size(SNR_dB));
BER_teorico = zeros(size(SNR_dB));

%% Sorgente
rng(1); % seed fisso per generare sempre la stessa sequenza
bit_sequenza = randi([0 1], 1, N_bit);

%% MODULAZIONE M-PAM
bit_gruppi = reshape(bit_sequenza, k, N_simboli)'; % matrice N_simboli x k

% MAPPATURA
[~, idx] = ismember(bit_gruppi, gray_code, 'rows');
simboli = livelli(idx).';                 % N_simboli x 1

%% SWEEP SULL'SNR
fprintf("=== SIMULAZIONE %d-PAM (k = %d bit/simbolo) ===\n", M, k);

% Energia media dei simboli M-PAM
E_avg = (M^2 - 1) / 3;

for i = 1:length(SNR_dB)
    % Rumore AWGN
    SNR = 10^(SNR_dB(i) / 10); % Conversione da dB a scala lineare per ogni valore di SNR_dB
    sigma = sqrt(E_avg / (2 * k * SNR)); % deviazione standard

    rumore = sigma * randn(N_simboli, 1); % seed fissato a 1

    % Segnale ricevuto
    ricevuti = simboli + rumore;

    % Decisore a minima distanza (Matrice N\_simboli x M)
    distanze = abs(ricevuti - livelli).^2;
    [~, idx_ricevuti] = min(distanze, [], 2);

    % DE-MAPPATURA GRAY
    bit_ricevuti_mat = gray_code(idx_ricevuti, :);
    bit_ricevuti = bit_ricevuti_mat';
    bit_ricevuti = bit_ricevuti(:)'; % Vettore riga 1 x N_bit

    % Prestazioni
    errori = sum(bit_sequenza ~= bit_ricevuti);
    BER_simulato(i) = errori / N_bit;

    P_s = (2 * (M - 1) / M) * qfunc(sqrt((6 * k * SNR) / (M^2 - 1))); 
    BER_teorico(i) = P_s / k;

    fprintf('SNR: %2d dB | Errori: %6d | BER Simulato: %e | BER Teorico: %e\n', SNR_dB(i), errori, BER_simulato(i), BER_teorico(i));
end

%% Grafico
figure('Name', sprintf('Prestazioni %d-PAM su AWGN', M));
semilogy(SNR_dB, BER_teorico, 'r-', 'LineWidth', 2); hold on;
semilogy(SNR_dB, BER_simulato, 'bo-- ', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
grid on;
title(sprintf('Prestazioni Modulazione %d-PAM su Canale AWGN (k = %d bit/simbolo)', M, k));
xlabel('SNR [dB]');
ylabel('Bit Error Rate (BER)');
legend('BER Teorico', 'BER Simulato', 'Location', 'southwest');
ylim([1e-10 1]);