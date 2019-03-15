

% make functions of size
% for the atom



figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(1,2,1); hold on
title('Isometric scaling')
all_L = logspace(-2,1.5,1e3);


[A,V] = cuboid(all_L);
plot(A,V,'k')


ff = fit(A(:),V(:),'poly2');
plot(A,ff(A),'k--')

xlabel('Surface area')
ylabel('Volume')


ff = fit(A(:),V(:),'poly1');
plot(A,ff(A),'r--')



% now the fractal 

subplot(1,2,2); hold on
title('Fractal growth')

A = NaN*all_L;
V = NaN*all_L;

all_L = logspace(-2,1,1e3);

for i = 1:length(all_L)
	[A(i),V(i)] = fractalAV(all_L(i), 1e-4, .75, @cuboid);
end

plot(A,V,'r')


ff = fit(A(:),V(:),'poly1');
plot(A,ff(A),'r--')

ff = fit(A(:),V(:),'poly2','Upper',[Inf 0 Inf],'Lower',[0 0 0]);
plot(A,ff(A),'k--')

xlabel('Surface area')
ylabel('Volume')


figlib.pretty()