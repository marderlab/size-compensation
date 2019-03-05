
function g = scaleG(g0,sigma_Ca,sigma_others)


g0(2:3) = g0(2:3)/sum(g0(2:3));
g0([1 4 5 6 8]) = g0([1 4 5 6 8])/sum(g0([1 4 5 6 8]));
g(2:3) = g0(2:3)*sigma_Ca;
g([1 4 5 6 8]) = g0([1 4 5 6 8])*sigma_others;
g(7) = g0(7);
