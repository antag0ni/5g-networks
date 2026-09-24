function prova_ottimizzato(pe,N)
count=0;
M = 1e8;
N_rimanenti = N;
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
%Stampa completamento
    completato = (N - N_rimanenti) / N * 100;
    fprintf('Completamento: %.1f%%\r', completato);
end
% Stima della probabilità di errore
hatpe=count/N;
fprintf('Probabilità di errore = %g\n', pe);
fprintf('Stima della prob. di errore = %g\n', hatpe);
end