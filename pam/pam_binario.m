clear; clc; close all;

N = 1e7;          % numero di bit
A = 1;            % ampiezza del segnale
EbN0dB = 0:.5:10;
hatpe = zeros(size(EbN0dB));
pe = zeros(size(EbN0dB));

% Stringa in input
x = rand(1,N)<.5;

% Mappatura PAM antipodale: 0 -> -A, 1 -> +A
s = A*(2*x - 1);

for k = 1:length(EbN0dB)
    EbN0 = 10^(EbN0dB(k)/10);
    sigma = sqrt(A^2/(2*EbN0));
    
    % Canale AWGN
    r = s + sigma*randn(1,N);

    % Decisore a minima distanza
    d0 = abs(r - (-A));     % distanza da s0 = -A
    d1 = abs(r - (+A));     % distanza da s1 = +A
    y = d1 < d0;            % sceglie il simbolo più vicino (1 se più vicino a +A)

    % Stringa di errore
    err = (x~=y);

    % Stima della probabilità di errore
    hatpe(k) = sum(err)/N;

    % Probabilità di errore teorica
    pe(k) = qfunc(A/sigma);

    fprintf('Eb/N0 = %2d dB | teorica = %e | simulata = %e\n', EbN0dB(k), pe(k), hatpe(k));

end

% Grafico
figure;
semilogy(EbN0dB, pe, 'b-', EbN0dB, hatpe, '-o');
grid on;
xlabel('E_b/N_0 [dB]');
ylabel('P_e');
legend('Teorica', 'Simulata');
title('PAM binario antipodale, decisore a minima distanza');
