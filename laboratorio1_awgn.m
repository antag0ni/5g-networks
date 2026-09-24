%% LABORATORIO 1: Trasmissione PAM Binaria su Canale AWGN

clear all; close all; clc;

% --- 1. CONFIGURAZIONE DEI PARAMETRI ---
% Definiamo quanti bit trasmettere. Nella simulazione Monte Carlo, più bit 
% trasmettiamo, più la stima del tasso di errore sarà precisa e vicina alla teoria.
N_bit = 100000; 

% Definiamo il Rapporto Segnale/Rumore (SNR) per bit in decibel (dB)
SNR_dB = 8; 

% Convertiamo il SNR da scala logaritmica (dB) a scala naturale (lineare)
% La formula di conversione per le potenze è: X_lineare = 10^(X_dB / 10)
SNR_lineare = 10^(SNR_dB / 10);

% --- 2. LA SORGENTE (Generazione dei dati) ---
% Generiamo un vettore colonna di N bit casuali. Ogni elemento può essere 0 o 1.
% La funzione randi([min, max], righe, colonne) genera interi uniformi.
bit_trasmessi = randi([0, 1], N_bit, 1);

% --- 3. IL MODULATORE (Modulazione PAM Binaria / BPSK) ---
% Trasformiamo i bit logici (0, 1) in segnali fisici (ampiezze di tensione).
% Usiamo la segnalazione antipodale (PAM binaria):
% Il bit 1 diventa +1 Volt, il bit 0 diventa -1 Volt.
% Formula matematica di mappatura: s = 2*b - 1
simboli_trasmessi = 2 * bit_trasmessi - 1; 

% --- 4. IL CANALE NEMICO (Aggiunta del Rumore Termico AWGN) ---
% Il rumore termico nei circuiti elettronici è modellato come rumore Gaussiano [4].
% Calcoliamo la deviazione standard (sigma) del rumore in base al SNR desiderato.
% Poiché l'energia dei nostri simboli (+1 e -1) al quadrato è pari a 1,
% la varianza del rumore deve essere: sigma^2 = 1 / (2 * SNR_lineare)
sigma = sqrt(1 / (2 * SNR_lineare));

% Generiamo rumore Gaussiano a media zero e varianza unitaria (randn) 
% e lo scaliamo per la nostra deviazione standard (sigma)
rumore = sigma * randn(N_bit, 1);

% Il segnale ricevuto r è la somma dei simboli trasmessi e del rumore: r = s + n [4]
segnale_ricevuto = simboli_trasmessi + rumore;

% --- 5. IL RICEVITORE (Fase di Decisione) ---
% Il ricevitore deve decidere se è stato trasmesso uno '0' o un '1'.
% Poiché abbiamo trasmesso +1 e -1, la soglia ottima di decisione è lo 0.
% Se il valore ricevuto è > 0, decidiamo per 1; altrimenti decidiamo per 0 [5].
bit_ricevuti = zeros(N_bit, 1); 
bit_ricevuti(segnale_ricevuto > 0) = 1;

% --- 6. CALCOLO DELLE PRESTAZIONI ---
% Contiamo quanti bit ricevuti sono diversi da quelli trasmessi
errori = sum(bit_trasmessi ~= bit_ricevuti);

% Calcoliamo il Bit Error Rate (BER) simulato
BER_simulato = errori / N_bit;

% Calcoliamo la probabilità d'errore teorica usando la Funzione Q [6]
% La formula teorica per la segnalazione antipodale è Pb = Q( sqrt(2 * SNR) ) [6]
BER_teorico = qfunc(sqrt(2 * SNR_lineare));

% --- 7. VISUALIZZAZIONE RISULTATI ---
fprintf('=== RISULTATI SIMULAZIONE AWGN ===\n');
fprintf('SNR impostato      : %d dB\n', SNR_dB);
fprintf('Bit trasmessi      : %d\n', N_bit);
fprintf('Errori rilevati    : %d\n', errori);
fprintf('BER Simulato (BER) : %e\n', BER_simulato);
fprintf('BER Teorico (Pb)   : %e\n', BER_teorico);


%% Visualizzazione 

% Istogramma del segnale ricevuto
figure;
histogram(segnale_ricevuto, 100);
hold on;
xline(0, 'r--', 'LineWidth', 2, 'Label', 'Soglia decisione');
xline(1, 'g--', 'LineWidth', 1.5, 'Label', 'Simbolo +1 ideale');
xline(-1, 'g--', 'LineWidth', 1.5, 'Label', 'Simbolo -1 ideale');
title('Distribuzione del segnale ricevuto');
xlabel('Ampiezza');
ylabel('Occorrenze');
grid on;

% Primi N campioni nel tempo (segnale trasmesso vs ricevuto)
N_plot = 50; % primi 50 simboli
figure;
stem(simboli_trasmessi(1:N_plot), 'b', 'LineWidth', 1.5, 'DisplayName', 'Trasmesso');
hold on;
plot(segnale_ricevuto(1:N_plot), 'ro', 'DisplayName', 'Ricevuto');
yline(0, 'k--', 'Soglia');
legend;
title('Simboli trasmessi vs ricevuti (primi 50)');
xlabel('Indice simbolo');
ylabel('Ampiezza');
grid on;

% La curva BER vs SNR
SNR_dB_range = 0:1:10;
BER_sim = zeros(size(SNR_dB_range));
BER_theo = zeros(size(SNR_dB_range));

for i = 1:length(SNR_dB_range)
    SNR_lin = 10^(SNR_dB_range(i)/10);
    bit_tx = randi([0,1], N_bit, 1);
    simb_tx = 2*bit_tx - 1;
    sigma = sqrt(1/(2*SNR_lin));
    r = simb_tx + sigma*randn(N_bit,1);
    bit_rx = double(r > 0);
    BER_sim(i) = sum(bit_tx ~= bit_rx) / N_bit;
    BER_theo(i) = qfunc(sqrt(2*SNR_lin));
end

figure;
semilogy(SNR_dB_range, BER_sim, 'bo-', 'LineWidth', 1.5, 'DisplayName', 'Simulato');
hold on;
semilogy(SNR_dB_range, BER_theo, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Teorico');
xlabel('SNR (dB)');
ylabel('BER');
title('BER vs SNR - PAM Binaria su AWGN');
legend;
grid on;
