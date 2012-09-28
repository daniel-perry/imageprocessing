% create a box filter with side size of SideSize

function Mask = makeBox( SideSize )

Mask = ones(SideSize,SideSize);
Mask = (1.0/(SideSize*SideSize)) * Mask;
