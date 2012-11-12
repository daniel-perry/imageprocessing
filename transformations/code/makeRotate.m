function [M] = makeRotate( Deg )
Rad = (pi/180) * Deg;
M = [ cos(Rad) sin(Rad) 0; -sin(Rad) cos(Rad) 0; 0 0 1 ];
