clc; clear; close all

%% creation sbpa
tau = 30;
tm = 2*tau;
Te = 6;
N = tm/Te;
L = (2^N)-1;
u = idinput([L, 2], "prbs", [0 1/Te])';
t = (0:L-1)';
%u = [sin(2*pi*0.1*t) cos(2*pi*0.1*t)]'; % test avec autres signaux
%% creation systeme
A = [-1/60, 0; 0, -1/30];
B = [1, 0; -0.05, 0.05];
C = eye(2);
D = zeros(2);

sys = ss(A, B, C, D);
At = A;
Bt = B;

% discretiser
sysd = c2d(sys, Te, 'zoh');
A = sysd.A;
B = sysd.B;
C = sysd.C;
D = sysd.D;

[Y, X] = dlsim(A, B, C, D, u); 
% Y = normalize(Y, "range", [0.1 0.9]); %h et theta
% u = normalize(u, "range", [0.1 0.9]);


testX = A*Y' + B*u;
testY = C*Y' + D*u;

bornes_X = [min(testX(1,:)) max(testX(1,:)); min(testX(2,:)) max(testX(2,:))];
bornes_Y = [min(testY(1,:)) max(testY(1,:)); min(testY(2,:)) max(testY(2,:))]; % a faire quand nn norm
% univers discrous = -60 a 60 ?


figure(1)
plot(testY(1,:))
grid()

figure(2)
plot(testY(2,:))
grid()