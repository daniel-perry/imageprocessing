function [M] = makeTranslate( tx, ty )
M = [ 1 0 tx; 0 1 ty; 0 0 1 ];
