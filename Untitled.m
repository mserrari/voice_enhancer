clc
close all
clear all

%%
load('fcno04fz');
signal = fcno04fz;
signal = signal.';
fe     = 8000;
RSB    = 5;

axe = 15000:16000;
[signal_bruite, sigma_noise2] = ajout_bruit(RSB, signal);
packet = signal_bruite(axe);

%% Variables
% M = N*ratio (number of columns) et L = N*(1-ratio) + 1
N = length(packet);
M = floor(N / 3);
L = N + 1 - M;

%% Constructing the hanckel matrix
c = packet(1:L);
r = packet(L:N);
h = hankel(c,r);

%% Calculating the SVD of the hanckel matrix
[U,S,V] = svd(h, 'econ');
singular_values = diag(S).';

diff = singular_values(1:end-1) - singular_values(2:end);

figure
stem(singular_values)

figure
stem(diff)


%% The number of singular values above the threshold
% [~, K] = max(diff);

% K = K;

df = zeros(1,M);
packet_nonoise = signal(axe);

for K=1:M
    %% Extracting dominant singular values
    simga_main_vals = diag([diag(S(1:K,1:K)).', zeros(1,M-K)]);

    %% Reconstructing signal
    H_filtered = U * simga_main_vals * V.';
    packet_filtered = [H_filtered(1:end,1).' H_filtered(end,2:end)];
    
    df(K) = sum(abs(packet_filtered - packet_nonoise));
end

[~, K] = min(df);

%% Extracting dominant singular values && Reconstructing signal
simga_main_vals = diag([diag(S(1:K,1:K)).', zeros(1,M-K)]);
H_filtered = U * simga_main_vals * V.';
packet_filtered = [H_filtered(1:end,1).' H_filtered(end,2:end)];
df(K) = sum(abs(packet_filtered - packet_nonoise));

%%
figure;
plot(df)

%%
figure
plot(packet_nonoise); hold on
plot(packet);
plot(packet_filtered);

legend('Packet original', 'Packet bruite', 'Packet filtre')

%%
soundsc(packet_filtered);

%%
soundsc(packet_nonoise);


