% Rappresentazione Costellazione 3-PPM in Dark Mode
clear; clc; close all;

%% 1. Parametri e Generazione Dati
M = 3;                  % N = M = 3 dimensioni
Es = 1;                 % Energia per simbolo
EbN0_dB = 10;           % SNR in dB
num_punti = 300;        % Punti ricevuti per ciascun simbolo

% Vettori della costellazione ideale s_1, s_2, s_3
S = sqrt(Es) * eye(M);

% Parametri rumore AWGN
Eb = Es / log2(M);
EbN0_lin = 10^(EbN0_dB / 10);
N0 = Eb / EbN0_lin;
sigma = sqrt(N0 / 2);

% Generazione nuvole di punti ricevuti con canale AWGN
r1 = S(:, 1) + sigma * randn(M, num_punti);
r2 = S(:, 2) + sigma * randn(M, num_punti);
r3 = S(:, 3) + sigma * randn(M, num_punti);

%% 2. Rendering 3D in Dark Mode
fig = figure('Color', [0.12 0.12 0.12]);
ax = axes('Parent', fig);
hold(ax, 'on');

% Configurazione assi e griglia scura
set(ax, 'Color', [0.18 0.18 0.18], ...
        'XColor', [0.90 0.90 0.90], ...
        'YColor', [0.90 0.90 0.90], ...
        'ZColor', [0.90 0.90 0.90], ...
        'GridColor', [0.60 0.60 0.60], ...
        'GridAlpha', 0.35);
grid(ax, 'on');

% Nuvole di punti ricevuti (colori al neon/chiari ad alta visibilità)
scatter3(ax, r1(1,:), r1(2,:), r1(3,:), 18, [0.30 0.85 1.00], 'filled', 'MarkerFaceAlpha', 0.55);
scatter3(ax, r2(1,:), r2(2,:), r2(3,:), 18, [1.00 0.50 0.30], 'filled', 'MarkerFaceAlpha', 0.55);
scatter3(ax, r3(1,:), r3(2,:), r3(3,:), 18, [0.40 1.00 0.50], 'filled', 'MarkerFaceAlpha', 0.55);

% Simboli ideali della costellazione (vertici)
h1 = plot3(ax, S(1,1), S(2,1), S(3,1), 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', [0.00 0.60 1.00], 'MarkerEdgeColor', [1 1 1], 'LineWidth', 1.5);
h2 = plot3(ax, S(1,2), S(2,2), S(3,2), 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', [1.00 0.30 0.10], 'MarkerEdgeColor', [1 1 1], 'LineWidth', 1.5);
h3 = plot3(ax, S(1,3), S(2,3), S(3,3), 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', [0.20 0.90 0.30], 'MarkerEdgeColor', [1 1 1], 'LineWidth', 1.5);

% Segmenti della distanza euclidea tra i simboli: d = sqrt(2*Es)
line_col = [0.85 0.85 0.85];
plot3(ax, [S(1,1) S(1,2)], [S(2,1) S(2,2)], [S(3,1) S(3,2)], '--', 'Color', line_col, 'LineWidth', 1.3);
plot3(ax, [S(1,2) S(1,3)], [S(2,2) S(2,3)], [S(3,2) S(3,3)], '--', 'Color', line_col, 'LineWidth', 1.3);
plot3(ax, [S(1,3) S(1,1)], [S(2,3) S(2,1)], [S(3,3) S(3,1)], '--', 'Color', line_col, 'LineWidth', 1.3);

% Etichetta della distanza euclidea sul segmento s1-s2
mid = (S(:,1) + S(:,2)) / 2;
text(ax, mid(1)+0.05, mid(2)+0.05, mid(3)+0.05, 'd = \surd(2\epsilon_s)', ...
    'FontSize', 11, 'FontWeight', 'bold', 'Color', [1 1 0.4]);

% Titolo e coordinate assi
xlabel(ax, '\psi_1(t)', 'FontSize', 11, 'Color', [0.95 0.95 0.95]);
ylabel(ax, '\psi_2(t)', 'FontSize', 11, 'Color', [0.95 0.95 0.95]);
zlabel(ax, '\psi_3(t)', 'FontSize', 11, 'Color', [0.95 0.95 0.95]);
title(ax, sprintf('Costellazione 3-PPM con AWGN (E_b/N_0 = %d dB)', EbN0_dB), ...
    'FontSize', 12, 'Color', [1 1 1]);

% Legenda scura
lgd = legend(ax, [h1, h2, h3], ...
    {'s_1 = [\surd\epsilon_s, 0, 0]^T', ...
     's_2 = [0, \surd\epsilon_s, 0]^T', ...
     's_3 = [0, 0, \surd\epsilon_s]^T'}, ...
    'Location', 'northeast');
set(lgd, 'TextColor', [0.95 0.95 0.95], ...
         'Color', [0.22 0.22 0.22], ...
         'EdgeColor', [0.45 0.45 0.45]);

view(ax, 45, 30);
axis(ax, 'equal');