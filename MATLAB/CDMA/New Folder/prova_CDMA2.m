% prova_CDMA.m
% Richiede la funzione CDMAsim.m nella stessa cartella.

%close all;
clear all; close all; clc;


% Parametri: puoi impostarli anche dalla Command Window
if ~exist('Tb','var'), Tb = 64000; end
if ~exist('Tc','var'), Tc = 2000; end
if ~exist('MC','var'), MC = 100000; end
if ~exist('utenti','var'), utenti = [1 5 10 15 20 25 30 35 40]; end
if ~exist('EbN0dB_fisso','var'), EbN0dB_fisso = 3; end

% Rumore uguale nei casi verde e rosso
N0 = Tb/10^(EbN0dB_fisso/10);

% Vettori dei risultati
pVerde = zeros(size(utenti));
pRosso = zeros(size(utenti));
pBlu = zeros(size(utenti));

tVerde = 0.5*erfc(sqrt(Tb/N0))*ones(size(utenti));
tRosso = zeros(size(utenti));
tBlu = zeros(size(utenti));

tic;

for k = 1:numel(utenti)

    N = utenti(k);

    % VERDE: N utenti separati, nessuna interferenza reciproca
    errori = 0;

    for u = 1:N
        s = 2*(rand(1,MC) < 0.5)-1;
        w = sqrt(N0/2)*randn(1,MC);

        y = s*sqrt(Tb) + w;
        stimati = 2*(y >= 0)-1;

        errori = errori + sum(stimati ~= s);
    end

    pVerde(k) = errori/(N*MC);

    % ROSSO: interferenza multiutente e AWGN
    [pRosso(k),tRosso(k)] = CDMAsim(N,Tb,Tc,MC,N0);

    % BLU: interferenza multiutente senza AWGN
    [pBlu(k),tBlu(k)] = CDMAsim(N,Tb,Tc,MC,0);

    fprintf('N = %d completato\n',N);

end

toc;

% Tutto su una sola figura
figure;
hold on;
grid on;

% Verde: teoria e punti Monte Carlo
plot(utenti,tVerde,'-', ...
    'Color',[0 0.6 0],'LineWidth',1.5, ...
    'DisplayName','Solo AWGN, utenti separati');

plot(utenti,pVerde,'o', ...
    'Color',[0 0.6 0],'MarkerFaceColor',[0 0.6 0], ...
    'HandleVisibility','off');

% Rosso: teoria e punti Monte Carlo
plot(utenti,tRosso,'r-','LineWidth',1.5, ...
    'DisplayName','Interferenza + AWGN');

plot(utenti,pRosso,'ro','MarkerFaceColor','r', ...
    'HandleVisibility','off');

% Blu: teoria e punti Monte Carlo
plot(utenti,tBlu,'b-','LineWidth',1.5, ...
    'DisplayName','Solo interferenza');

plot(utenti,pBlu,'bo','MarkerFaceColor','b', ...
    'HandleVisibility','off');

xlabel('Numero totale di utenti');xlabel('Numero totale di utenti');
ylabel('Probabilita di errore sul bit');

% Titolo che mostra i parametri della prova
title(sprintf('Lc = %.0f | Eb/N0 = %.1f dB', ...
    Tb/Tc, EbN0dB_fisso));

% Stessa scala verticale per confrontare le prove
ylim([0 0.3]);

legend('Location','best');
hold off;