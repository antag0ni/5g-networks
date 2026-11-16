clear all; close all; clc;
%% DATI
N_bit = 1e6;
SNR_dB = 20;                    % SNR (E_j/N0) dell'utente desiderato
Lc_vett = [16 32 64 128];       % Lunghezze del codice da confrontare
Utenti_max = 20;
Vettore_Utenti = 1:Utenti_max;

% Energie degli utenti: E(1) = utente desiderato j, E(2:end) = interferenti
E = ones(1, Utenti_max);
% E(2:end) = 4;                 % Esempio near-far
E_j = E(1);

nLc = length(Lc_vett);
BER_simulato = zeros(nLc, Utenti_max);
BER_teorico  = zeros(nLc, Utenti_max);
SIR_teorico  = inf(nLc, Utenti_max);

%% Sorgente (uguale per tutti gli Lc)
rng(1);
bit_sequenza = randi([0 1], 1, N_bit);
simboli = 2 * bit_sequenza - 1;
utile = sqrt(E_j) * simboli;

%% Rumore AWGN (uguale per tutti gli Lc)
SNR_lin = 10^(SNR_dB / 10);
var_rumore = E_j / (2 * SNR_lin);
rumore = sqrt(var_rumore) * randn(1, N_bit);

%% SWEEP SU Lc E SUL NUMERO DI UTENTI (K)
for m = 1:nLc
    Lc = Lc_vett(m);
    I = zeros(1, N_bit);        % interferenza accumulata, azzerata per ogni Lc
    fprintf("\n=== Lc = %d ===\n", Lc);

    for i = 1:Utenti_max
        K = Vettore_Utenti(i);

        if K > 1
            % Aggiungo l'interferente u = K con energia E(K)
            corr_u = (2 * binornd(Lc, 0.5, 1, N_bit) - Lc) / Lc;
            I = I + sqrt(E(K)) * corr_u;
        end

        ricevuti = utile + rumore + I;
        bit_ricevuti = ricevuti > 0;

        errori = sum(bit_sequenza ~= bit_ricevuti);
        BER_simulato(m, i) = errori / N_bit;

        % Teoria (approssimazione gaussiana)
        var_I = sum(E(2:K)) / Lc;               % Var[I] = (1/Lc) * sum_{u~=j} E_u
        var_totale = var_rumore + var_I;
        BER_teorico(m, i) = qfunc(sqrt(E_j) / sqrt(var_totale));

        if K > 1
            SIR_teorico(m, i) = E_j / var_I;    % = Lc * E_j / sum_{u~=j} E_u
        end

        fprintf("Utenti: %2d | SIR teo: %6.2f dB | Errori: %6d | BER Sim: %1.4e | BER Teo: %1.4e\n", ...
                K, 10*log10(SIR_teorico(m, i)), errori, BER_simulato(m, i), BER_teorico(m, i));
    end
end

%% Grafico BER vs numero di utenti, confronto tra Lc
figure;
colori = lines(nLc);
for m = 1:nLc
    semilogy(Vettore_Utenti, BER_simulato(m, :), 'o-', 'Color', colori(m, :), ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', sprintf('Sim, L_c = %d', Lc_vett(m)));
    hold on;
    semilogy(Vettore_Utenti, BER_teorico(m, :), '--', 'Color', colori(m, :), ...
        'LineWidth', 1.5, 'DisplayName', sprintf('Teo, L_c = %d', Lc_vett(m)));
end
grid on;
xlabel('Numero di Utenti attivi nel sistema (K)');
ylabel('Bit Error Rate (BER)');
legend('Location', 'southeast');
title(sprintf('Confronto per diversi L_c (SNR = %d dB)', SNR_dB));
xlim([1 Utenti_max]);
ylim([1e-6 1]);