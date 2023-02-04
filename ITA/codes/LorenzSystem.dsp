// import faust standard library
import("stdfaust.lib");

// Lorenz System 
LorenzSystem(x0, y0, z0, dt, beta, rho, sigma) = LorenzSystemEquations ~ si.bus(3) : 
    par(i, 3, _ * 0.002)
    with {
        x_init = x0-x0'; y_init = y0-y0'; z_init = z0-z0';
        LorenzSystemEquations(x, y, z) =
            (x + (sigma * (y - x)) * dt + x_init),
            (y + ((rho * x) - (x * z) - y) * dt + y_init),
            (z + ((x * y) - (beta * z)) * dt + z_init);
    };

// Lorenz System Parameters
X = 1.2;
Y = 1.3;
Z = 1.6;
DT = .002;
BETA = 8/3;
RHO = 100;
SIGMA = 10;

process = LorenzSystem(X, Y, Z, DT, BETA, RHO, SIGMA);