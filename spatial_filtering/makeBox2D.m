% create a box filter with side size of SideSize

function Mask = makeBox2D( SideSize )

Mask = ones(SideSize,SideSize);
Mask = (1.0/(SideSize*SideSize)) * Mask;
