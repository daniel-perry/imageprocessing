function Mask = makeBox1D( sideSize )
Mask = ones(1,sideSize);
Mask = (1.0/sideSize) * Mask;
