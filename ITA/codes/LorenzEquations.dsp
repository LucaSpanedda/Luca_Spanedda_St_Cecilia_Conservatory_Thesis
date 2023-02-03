// import faust standard library
import("stdfaust.lib");

LorenzSystem(x0, y0, z0, dt, beta, rho, sigma) = LorenzSystemEquations
    with {
        x_init = x0-x0';    y_init = y0-y0';    z_init = z0-z0';
        
        LorenzSystemEquations(x, y, z) = 
            (x + sigma * (y - x) * dt + x_init), 
            (y + (rho * x - x * z - y) * dt + y_init),  
            (z + (x * y - beta * z) * dt + z_init);
    };

process = LorenzSystem(1.2, 1.3, 1.6, .01, 1.073, 3.518, 10);