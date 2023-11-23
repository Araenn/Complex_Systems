clc; clear; close all

%% creation sbpa
tau = 30;
tm = 2*tau;
Te = 6;
N = tm/Te;
L = (2^N)-1;
u = idinput([L, 2], "prbs", [0 1/Te])';

%% creation systeme
A = [-1/60, 0; 0, -1/30];
B = [1, 0; -0.05, 0.05];
C = eye(2);
D = zeros(2);

sys = ss(A, B, C, D);
% discretiser
sysd = c2d(sys, Te, 'zoh');
A = sysd.A;
B = sysd.B;
C = sysd.C;
D = sysd.D;

[Y, X] = dlsim(A, B, C, D, u);
U = normalize(X, "range", [0.1 0.9]);
Y = normalize(Y, "range", [0.1 0.9]);

figure
plot(u(1,:))
hold on
plot(u(2,:))

figure
plot(U(:,1))
hold on
plot(U(:,2))

figure
plot(Y(:,1))
hold on
plot(Y(:,2))