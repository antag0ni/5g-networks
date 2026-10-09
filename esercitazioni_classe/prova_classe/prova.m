%{
===========================================================================
MODELLO TEORICO: Canale Binario Simmetrico (BSC) e Stima Monte Carlo della BER
===========================================================================
1. TRASMETTITORE (Sorgente di informazione):
   - Generazione di una sequenza di N variabili casuali i.i.d. (indipendenti 
     e identicamente distribuite) con distribuzione di Bernoulli simmetrica:
     P(X = 0) = P(X = 1) = 0.5.

2. MODELLO DI CANALE (Binary Symmetric Channel - BSC):
   - Il canale introduce rumore additivo modulo 2 (operatore XOR):
     Y = X ⊕ C
   - Il vettore di rumore C è costituito da variabili di Bernoulli i.i.d.:
     P(C = 1) = pe       (probabilità di transizione / flip del bit)
     P(C = 0) = 1 - pe   (probabilità di trasmissione corretta)
   - Proprietà del BSC:
     P(Y = 1 | X = 0) = P(Y = 0 | X = 1) = pe
     P(Y = 0 | X = 0) = P(Y = 1 | X = 1) = 1 - pe

3. RIVELATORE E VALUTAZIONE DEGLI ERRORI:
   - Un errore si verifica quando Y != X, che per definizione di somma 
     in GF(2) equivale all'evento {C = 1}.
   - La variabile indicatrice di errore vale:
     err_i = 1 se y_i != x_i, altrimenti 0.

4. STIMA STATISTICA (Metodo Monte Carlo):
   - La probabilità di errore pe viene stimata tramite la frequenza 
     relativa degli errori:
     hat(pe) = (1/N) * sum_{i=1}^N err_i
   - Per la Legge Forte dei Grandi Numeri (LLN):
     hat(pe) converge quasi certamente a pe per N -> ∞.
   - Per il Teorema del Limite Centrale (CLT), l'errore di stima ha 
     distribuzione asintoticamente normale:
     Var[hat(pe)] = (pe * (1 - pe)) / N
===========================================================================
%}

function prova(pe,N)
% Stringa in input
x=rand(1,N)<.5;
% Simulo il canale
c=rand(1,N)<pe;
% Stringa in uscita
y=xor(x,c);
% Stringa di errore
err=not(x==y);
% Stima della probabilità di errore
hatpe=sum(err)/N;

fprintf('Probabilità di errore = %f\n', pe);
fprintf('Stima della prob. di errore = %f\n', hatpe);
end