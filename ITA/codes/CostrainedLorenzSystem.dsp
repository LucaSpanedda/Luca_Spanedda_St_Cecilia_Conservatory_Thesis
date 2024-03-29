// import faust standard library
import("stdfaust.lib");

// Hyperbolic Tangent Saturator Parameter
THRESHOLD = 1000;
// Hyperbolic Tangent Saturator Function
saturator(lim, x) = lim * ma.tanh( x / (max(lim, ma.EPSILON)) );

// DC Blocker Parameters
ZERO = 1;
POLE = .995;
// DC Blocker Filter Function
dcblocker(zero, pole, x) = x : _ <: _, mem : _, * (zero) : - : + ~ * (pole);

// Costrained (Modified) Lorenz System 
LorenzSystem(x0, y0, z0, dt, beta, rho, sigma, tanHrange) = 
    (LorenzSystemEquations : par(i, 3, dcblocker(ZERO, POLE)) : par(i, 3, saturator(tanHrange))) ~
        si.bus(3) : par(i, 3, _ / (tanHrange)) :> (_ / 3)
    with {
        x_init = x0-x0'; y_init = y0-y0'; z_init = z0-z0';

        LorenzSystemEquations(x, y, z) =
            (x + (sigma * (y - x)) * dt + x_init),
            (y + ((rho * x) - (x * z) - y) * dt + y_init),
            (z + ((x * y) - (beta * z)) * dt + z_init);
    };

process = LorenzSystem(1.2, 1.3, 1.6, .150, 2, 3.4, 1.9, THRESHOLD);