% CDMA_energie.m
% Confronto tra utenti CDMA con energie ricevute diverse.
% Script autonomo: non richiede CDMAsim.m o altre funzioni.

clear all; close all; clc;
%close all;
rng(1); % Stessi numeri casuali a ogni esecuzione: confronto ripetibile.

%% 1. PARAMETRI
% Puoi impostarli nella Command Window prima di eseguire lo script.
if ~exist('N','var'), N = 20; end
if ~exist('Tb','var'), Tb = 64000; end
if ~exist('Tc','var'), Tc = 1000; end
if ~exist('MC','var'), MC = 10000; end
if ~exist('EbN0dB','var'), EbN0dB = 3; end

Lc = Tb/Tc; % Numero di chip per bit: con questi valori e' 64.
assert(N >= 2 && N == floor(N), 'N deve essere un intero >= 2.');
assert(Tc > 0 && Lc >= 1 && Lc == floor(Lc), ...
    'Tb/Tc deve essere un intero positivo.');
assert(MC >= 1 && MC == floor(MC), 'MC deve essere un intero positivo.');

%% 2. ENERGIE CASUALI E RUMORE
% Nel vecchio codice tutti avevano energia Tb (ampiezza unitaria).
% Qui ogni energia e' uniforme tra 0.2*Tb e 2*Tb.
% Si estrae UNA VOLTA: resta fissa per tutti i bit simulati.
E = Tb*(0.2 + 1.8*rand(N,1));

% EbN0dB si riferisce all'energia di riferimento Tb, non a ogni E(j).
% N0 e' uguale per tutti: gli utenti deboli hanno un E(j)/N0 minore.
N0 = Tb/10^(EbN0dB/10); % Per spegnere AWGN usa EbN0dB = Inf.

[~, migliore] = max(E); % Energia massima: migliore BER attesa.
[~, peggiore] = min(E); % Energia minima: peggiore BER attesa.

pMC = zeros(N,1);
pTeoria = zeros(N,1);

%% 3. SIMULAZIONE DELL'USCITA AL CORRELATORE
% Un esperimento Monte Carlo separato per ciascun ricevitore j.
for j = 1:N
    altri = [1:j-1, j+1:N]; % Tutti gli utenti tranne quello osservato.
    errori = 0;

    for prova = 1:MC
        % Un simbolo BPSK per utente e Lc chip casuali per simbolo.
        s = 2*(rand(N,1) < 0.5) - 1;
        C = 2*(rand(N,Lc) < 0.5) - 1;

        utile = s(j)*sqrt(E(j));

        % Ogni interferente pesa con la radice della propria energia.
        pesi = s(altri).*sqrt(E(altri));
        a = pesi.' * C(altri,:); % Somma dei chip pesati degli altri.
        I = (C(j,:) * a.')/Lc;   % Interferenza dopo la correlazione.

        w = sqrt(N0/2)*randn;   % AWGN all'uscita del correlatore.
        y = utile + I + w;
        stimato = 2*(y >= 0) - 1;
        errori = errori + (stimato ~= s(j));
    end

    pMC(j) = errori/MC;

    % Formula degli appunti: var(I) = somma energie interferenti / Lc.
    % La BER teorica usa l'approssimazione gaussiana dell'interferenza.
    varianza = sum(E(altri))/Lc + N0/2;
    pTeoria(j) = 0.5*erfc(sqrt(E(j)/varianza)/sqrt(2));

    fprintf('Utente %2d: E/Tb = %.3f, BER MC = %.5f, teoria = %.5f\n', ...
        j, E(j)/Tb, pMC(j), pTeoria(j));
end

%% 4. GRAFICO: TUTTI GLI UTENTI, MIGLIORE E PEGGIORE EVIDENZIATI
figure;
plot(1:N, pTeoria, '-', 'LineWidth', 1.2);
hold on;
plot(1:N, pMC, 'bo', 'MarkerSize', 5);
plot(migliore, pMC(migliore), 'go', ...
    'MarkerFaceColor', 'g', 'MarkerSize', 10);
plot(peggiore, pMC(peggiore), 'ro', ...
    'MarkerFaceColor', 'r', 'MarkerSize', 10);
grid on;
xlabel('Indice utente j (numero totale di utenti N fisso)');
ylabel('Probabilita di errore sul bit');
title(sprintf('CDMA: %d utenti con energie diverse', N));
legend('Teoria gaussiana', 'Monte Carlo', ...
    'Energia massima: migliore atteso', ...
    'Energia minima: peggiore atteso', 'Location', 'best');
hold off;

fprintf('\nMigliore atteso: utente %d, E/Tb = %.3f\n', migliore, E(migliore)/Tb);
fprintf('Peggiore atteso: utente %d, E/Tb = %.3f\n', peggiore, E(peggiore)/Tb);
% Un punto MC a zero significa zero errori osservati, non BER vera nulla.
