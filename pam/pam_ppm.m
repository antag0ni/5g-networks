clear; clc; close all;
N = 1e7;          % numero di bit
A = 1;            % ampiezza del segnale
EbN0dB = -20:.5:20;

hatpe_pam = zeros(size(EbN0dB));
pe_pam    = zeros(size(EbN0dB));
hatpe_ppm = zeros(size(EbN0dB));
pe_ppm    = zeros(size(EbN0dB));

% Stringa in input
x = rand(1,N) < .5;

% Mappatura PAM antipodale: 0 -> -A, 1 -> +A
s_pam = A*(2*x - 1);

% Mappatura PPM binaria: 0 -> [A, 0], 1 -> [0, A]  (due slot)
s_ppm1 = A*(~x);   % ampiezza nel primo slot (bit 0)
s_ppm2 = A*( x);   % ampiezza nel secondo slot (bit 1)

for k = 1:length(EbN0dB)
    EbN0  = 10^(EbN0dB(k)/10);
    sigma = sqrt(A^2/(2*EbN0));    % Eb = A^2 per entrambe le modulazioni

    % ---------- PAM ----------
    r = s_pam + sigma*randn(1,N);
    d0 = abs(r - (-A));
    d1 = abs(r - (+A));
    y_pam = d1 < d0;
    hatpe_pam(k) = sum(x ~= y_pam)/N;
    pe_pam(k)    = qfunc(A/sigma);          % = Q(sqrt(2 Eb/N0))

    % ---------- PPM ----------
    r1 = s_ppm1 + sigma*randn(1,N);         % slot 1
    r2 = s_ppm2 + sigma*randn(1,N);         % slot 2 (rumore indipendente)
    % Decisore a minima distanza: equivale a scegliere lo slot con r maggiore
    y_ppm = r2 > r1;
    hatpe_ppm(k) = sum(x ~= y_ppm)/N;
    pe_ppm(k)    = qfunc(A/(sqrt(2)*sigma)); % = Q(sqrt(Eb/N0))

    fprintf(['Eb/N0 = %4.1f dB | PAM: teor = %e sim = %e | ' ...
             'PPM: teor = %e sim = %e\n'], EbN0dB(k), ...
             pe_pam(k), hatpe_pam(k), pe_ppm(k), hatpe_ppm(k));
end

% Grafico
figure;
semilogy(EbN0dB, pe_pam, 'b-', EbN0dB, hatpe_pam, 'bo', ...
         EbN0dB, pe_ppm, 'r-', EbN0dB, hatpe_ppm, 'rs', ...
         'LineWidth', 1.2);
grid on;
xlabel('E_b/N_0 [dB]');
ylabel('P_e');
legend('PAM teorica', 'PAM simulata', 'PPM teorica', 'PPM simulata', ...
       'Location', 'southwest');
title('PAM antipodale vs PPM binaria, decisore a minima distanza');
ylim([1e-6 1]);