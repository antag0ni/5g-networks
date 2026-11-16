clear all; close all; clc;
%% DATI
N_bit = 1e6;
SNR_dB = 20;           
Lc = 64;               % Lunghezza del codice di spreading (Processing Gain)
Utenti_max = 20;       % Numero massimo di utenti da simulare
Vettore_Utenti = 1:Utenti_max; 

BER_simulato = zeros(size(Vettore_Utenti));
BER_teorico = zeros(size(Vettore_Utenti));

%% Sorgente
rng(1); % Seed fisso
bit_sequenza = randi([0 1], 1, N_bit);
simboli = 2 * bit_sequenza - 1; % Mappatura antipodale (+-1)

%% Rumore AWGN (calcolato una volta per il livello di SNR fisso)
SNR_lin = 10^(SNR_dB / 10);
var_rumore = 1 / (2 * SNR_lin);
rumore = sqrt(var_rumore) * randn(1, N_bit);

%% SWEEP SUL NUMERO DI UTENTI (K)
for i = 1:length(Vettore_Utenti)
    K = Vettore_Utenti(i);
    
    % Generazione Interferenza ad Accesso Multiplo
    if K > 1
        % Dalla formula alla lavagna: l'interferenza su un bit è la somma di 
        % (K-1)*Lc prodotti tra chip +-1, divisi per Lc.
        % Generiamo direttamente l'esito della cross-correlazione per velocità
        % interferenze_chips = randi([0 1], (K-1)*Lc, N_bit) * 2 - 1;
        % I = (1/Lc) * sum(interferenze_chips, 1);
        I = (2*binornd((K-1)*Lc, 0.5, 1, N_bit) - (K-1)*Lc) / Lc;
    else
        % Se c'è un solo utente, non c'è interferenza
        I = zeros(1, N_bit);
    end
    
    % Segnale ricevuto: Utente desiderato + Rumore + Interferenza
    ricevuti = simboli + rumore + I;
    
    % Decisore a minima distanza (equivalente a stabilire il segno)
    bit_ricevuti = ricevuti > 0;
    
    % Prestazioni simulate
    errori = sum(bit_sequenza ~= bit_ricevuti);
    BER_simulato(i) = errori / N_bit;
    
    % Prestazioni teoriche (Approssimazione Gaussiana Standard)
    % Varianza Totale = Varianza Rumore + Varianza I
    var_I = (K - 1) / Lc; 
    var_totale = var_rumore + var_I;
    
    % Il Q-argument standard è 1/sqrt(Varianza_Totale)
    BER_teorico(i) = qfunc(1 / sqrt(var_totale));
    
    % OUTPUT A VIDEO
    fprintf("Utenti attivi: %2d | Errori: %6d | BER Sim: %1.4e | BER Teo: %1.4e\n", ...
            K, errori, BER_simulato(i), BER_teorico(i));
end

%% Grafico
figure;
semilogy(Vettore_Utenti, BER_simulato, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
semilogy(Vettore_Utenti, BER_teorico, 's--', 'LineWidth', 1.5, 'MarkerSize', 6);
grid on;
xlabel('Numero di Utenti attivi nel sistema (K)');
ylabel('Bit Error Rate (BER)');
legend('BER simulato', 'BER teorico', 'Location', 'northwest');
title(sprintf('Prestazioni Sistema Multi-Utente (SNR = %d dB, L_c = %d)', SNR_dB, Lc));
xlim([1 Utenti_max]);
ylim([1e-5 1]);