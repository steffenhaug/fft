%% Define the grid
L = 1;  % Length of interval
N = 32; % Gridpoints
x = linspace(0, L, N);

% Fourier "frequencies":
k = (2*pi/L)*fftshift(-N/2 : N/2-1)';

%% Initial condition:
u0 = 0.5 * (x<=L/2);
U0 = fft(u0);

%% Solve with ODE-solver in the frequency domain
function dUdt = step(t, U, k)
    dUdt = -(k.^2) .* U;
end
[t, U] = ode45(@(t, U) step(t, U, k), 0:0.01:10, U0);

%% Recover the spatial signal from the ODE solution
for i = 1:length(t)
    u(i,:) = ifft(U(i,:));
end
