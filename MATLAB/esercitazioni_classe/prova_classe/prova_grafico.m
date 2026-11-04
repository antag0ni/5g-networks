clear all; close all; clc;

pe = 0.01; N = 1e9;

count = 0;
M = 1e5;
N_rimanenti = N;

N_processati = 0;                    
n_blocchi = ceil(N/M);                    
storia_N = zeros(1, n_blocchi);            
storia_hatpe = zeros(1, n_blocchi);        
idx = 0; 

while N_rimanenti > 0
    chunk = min(N_rimanenti, M);

    % Stringa in input
    x=rand(1, chunk)<.5;
    % Simulo il canale 
    c=rand(1, chunk)<pe;
    % Stringa in uscita
    y=xor(x,c);
    % Conto l'errore
    count=count+sum(x~=y);

    N_rimanenti = N_rimanenti - chunk;
    
    N_processati = N_processati + chunk;
    idx = idx + 1;
    storia_N(idx) = N_processati;
    storia_hatpe(idx) = count / N_processati;
    
    %Stampa completamento
    completato = (N - N_rimanenti) / N * 100;
    fprintf('Completamento: %.1f%%\r', completato);
end
fprintf('\n');

% Stima della probabilità di errore
hatpe=count/N;
fprintf('Probabilità di errore = %g\n', pe);
fprintf('Stima della prob. di errore = %g\n', hatpe);

% Grafico
figure;
semilogx(storia_N, storia_hatpe, 'b-', 'LineWidth', 1.5);
hold on;
yline(pe, 'r--', 'LineWidth', 1.5);
hold off;
xlabel('Numero di bit simulati (N)');
ylabel('Stima della probabilità di errore');
title(sprintf('Convergenza della stima Monte Carlo (p_e = %g)', pe));
legend('Stima \phi_{p_e}', 'Valore teorico p_e', 'Location', 'best');
grid on;
