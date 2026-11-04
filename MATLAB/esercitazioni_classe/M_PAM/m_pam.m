% Costellazione e Trasmissione M-PAM in Dark Mode
clear; clc; close all;

%% 1. Parametri
M = 4;                      % 4-PAM
num_punti = 400;            % Campioni ricevuti per simbolo
EbN0_dB = 12;               % SNR per bit

% Simboli ideali simmetrici (ampiezze centrate in 0 a passo d)
d = 2;                      % Distanza minima fissata a 2
simboli_ideali = -(M-1):2:(M-1); % [-3, -1, 1, 3] per M=4

% Calcolo energie e rumore
Es = (M^2 - 1) / 12 * d^2;
Eb = Es / log2(M);
EbN0_lin = 10^(EbN0_dB / 10);
N0 = Eb / EbN0_lin;
sigma = sqrt(N0 / 2);       % Rumore unidimensionale (N=1)

%% 2. Generazione Punti Ricevuti (AWGN)
rx_points = zeros(M, num_punti);
for m = 1:M
    rx_points(m, :) = simboli_ideali(m) + sigma * randn(1, num_punti);
end

%% 3. Rendering Grafico (Dark Mode)
fig = figure('Color', [0.12 0.12 0.12]);
ax = axes('Parent', fig);
hold(ax, 'on');

% Configurazione assi e griglia scura
set(ax, 'Color', [0.18 0.18 0.18], ...
    'XColor', [0.90 0.90 0.90], ...
    'YColor', [0.90 0.90 0.90], ...
    'GridColor', [0.60 0.60 0.60], ...
    'GridAlpha', 0.35);
grid(ax, 'on');

% Colori per i livelli di ampiezza
colori = [0.3 0.8 1.0; 0.4 1.0 0.5; 1.0 0.7 0.2; 1.0 0.4 0.4];

% Scatter dei punti ricevuti: l'asse Y e' solo un piccolo jitter per dare spessore alla nuvola
for m = 1:M
    jitter_y = 0.08 * randn(1, num_punti);
    scatter(ax, rx_points(m, :), jitter_y, 16, colori(m, :), ...
        'filled', 'MarkerFaceAlpha', 0.45);
    % Simbolo ideale al centro
    plot(ax, simboli_ideali(m), 0, 's', 'MarkerSize', 11, ...
        'MarkerFaceColor', colori(m, :), 'MarkerEdgeColor', [1 1 1], 'LineWidth', 1.5);
end

% Tracciamento soglie di decisione ottime (linee verticali poste a meta' strada tra i simboli)
soglie = (simboli_ideali(1:end-1) + simboli_ideali(2:end)) / 2;
for s = soglie
    xline(ax, s, '--', 'Color', [0.85 0.85 0.4], 'LineWidth', 1.5);
end

% Evidenziazione distanza minima d tra i primi due simboli
mid_d = (simboli_ideali(1) + simboli_ideali(2)) / 2;
plot(ax, [simboli_ideali(1) simboli_ideali(2)], [0.25 0.25], '|-', ...
    'Color', [1 1 0.4], 'LineWidth', 1.5, 'MarkerSize', 8);
text(ax, mid_d, 0.35, sprintf('d = %d', d), 'Color', [1 1 0.4], ...
    'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');

xlabel(ax, 'Coordinata spaziale \psi(t) (Ampiezza)', 'FontSize', 11, 'Color', [0.95 0.95 0.95]);
title(ax, sprintf('Costellazione %d-PAM con Soglie di Decisione AWGN (E_b/N_0 = %d dB)', M, EbN0_dB), ...
    'FontSize', 12, 'Color', [1 1 1]);
yticks(ax, []); % Nasconde i tick Y perche' privi di significato fisico (spazio 1D)
ylim(ax, [-0.5 0.6]);
xlim(ax, [min(simboli_ideali) - 2.5, max(simboli_ideali) + 2.5]);