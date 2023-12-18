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
Ao = [-1/60, 0; 0, -1/30];
Bo = [1, 0; -0.05, 0.05];
Co = eye(2);
Do = zeros(2);

sys = ss(Ao, Bo, Co, Do);

% discretiser
sysd = c2d(sys, Te, 'zoh');
A = sysd.A;
B = sysd.B;
C = sysd.C;
D = sysd.D;

[Y, X] = dlsim(A, B, C, D, u); 
Y = normalize(Y, "range", [0.1 0.9]); %h et theta
u = normalize(u, "range", [0.1 0.9]);

testX = A*Y' + B*u;
testY = C*Y' + D*u;
%% reseau neurones
nb_neurones_entree = 4;
%nb_neurones_cc = 2*nb_neurones_entree + 1;
nb_neurones_cc = input("Nombre de neurones en couche cachée : ");
nb_neurones_sortie = 2;

% initialisation
w1 = randn(nb_neurones_entree, nb_neurones_cc)';
w2 = randn(nb_neurones_cc, nb_neurones_sortie)';
b1 = randn(nb_neurones_cc, 1);
b2 = randn(nb_neurones_sortie, 1);
niter = 100;
Lambda = linspace(0.01, 0.99, niter);


for l = 1:niter
    lambda = Lambda(l);
    for k = 1:length(u)
        entree = [u(1,k); u(2,k); Y(k,1)'; Y(k,2)'];
        a1 = w1 * entree + b1;
        for i = 1:length(a1)
            v1(i) = sigm(a1(i));
        end
        a2 = w2 * v1' + b2;
        for i = 1:length(a2)
            v2(i) = sigm(a2(i));
        end

        erreur(1) = Y(k,1)' - v2(1);
        erreur(2) = Y(k,2)' - v2(2);

        for i = 1:length(a2)
            delta2(i) = sigm_deriv(a2(i)) * (erreur(i));
        end 

        w2 = w2 + lambda .* (delta2' .* v1);
        b2 = b2 + lambda .* delta2';
        for i = 1:length(a1)-1
            delta1(i,:) = sigm_deriv(a1(i)) * w2(i) * delta2(1);
            delta1(i+1,:) = sigm_deriv(a1(i)) * w2(i) * delta2(2);
        end 
        w1 = w1 + lambda * delta1 * entree';

        sortie1(k) = v2(1)';
        sortie2(k) = v2(2)';
    end
    E(1,l) = mean(abs(sortie1 - Y(:,1)'));
    E(2,l) = mean(abs(sortie2 - Y(:,2)'));
end

entree = [u(1,:); u(2,:); Y(:,1)'; Y(:,2)'];
target = [Y(:,1)'; Y(:,2)'];
%% affichage
figure
plot(u(1,:))
hold on
plot(u(2,:))
grid on
title("Entrée BDD")

figure
plot(u(1,:))
hold on
plot(Y(:,1))
grid on
title("Temperature")
legend("Entree", "Sortie")

figure
plot(u(2,:))
hold on
plot(Y(:,2))
grid on
title("Puissance")
legend("Entree", "Sortie")

figure
plot(Y(:,1))
grid on
hold on
plot(sortie1)
legend("Avant modèle", "Après modèle")
title("Temperature")

figure
plot(Y(:,2))
grid on
hold on
plot(sortie2)
legend("Avant modèle", "Après modèle")
title("Puissance")

figure
plot(E(1,:))
hold on
plot(E(2,:))
grid on
title("Erreur selon les itérations")
legend("Temperature", "Puissance")
hold off