% helper script to make figures
% for a talk

close all

model_hash = '0dea7e804b9255ac7bba7df3c3b015ff';

load([model_hash '_0.voronoi'],'-mat')

x0 = sum(v.data.g0(2:3));
y0 = sum(v.data.g0([1 4 5 6 8]));

figure('outerposition',[300 300 1200 1001],'PaperUnits','points','PaperSize',[1200 901]); hold on

clear ax
ax = subplot(2,2,1); hold on
v.findBoundaries(ax)
p = ax.Children;
uistack(p(2),'top')
axis square
xlabel(ax,'\Sigma g_{Ca} (uS/mm^2)')
ylabel(ax,'\Sigma g_{others} (uS/mm^2)')
c = lines(10);
scatter(x0,y0,48,c(5,:),'o','filled')


plot(ax,[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'k--');



for i = 1:length(p)
	if i == 2
		p(i).FaceAlpha = 1;
		p(i).FaceColor = c(5,:);
	else
		p(i).FaceAlpha = .35;
	end
end

clear pax
idx = [3 4 7 8];
for i = 1:4
	pax(i) = subplot(4,4,idx(i)); hold on
	set(pax(i),'YLim',[-80 50],'XLim',[0 3])

	set(gca,'XTick',[])
	pax(i).Position(4) = .12;
end
drawnow



x = singleCompartment.makeNeuron();
singleCompartment.disableControllers(x)
x.t_end = 5e3;


r = rectangle(pax(1));
r.Position = [0 -100 5 200];
r.FaceColor = [c(5,:) .35];
x.set('*gbar',v.data.g0)
x.reset
x.integrate;
V = x.integrate;
st = xtools.findNSpikeTimes(V,100);
[~,idx]=max(diff(st));
V(1:st(idx)) = [];
time = (1:length(V))*x.dt*1e-3;
plot(pax(1),time,V,'k')

r = rectangle(pax(2));
r.Position = [0 -100 5 200];
r.FaceColor = [c(4,:) .35];
scatter(ax,100.2915,2.2569e+03,48,c(4,:),'o','filled')
g = singleCompartment.perturb.scaleG(v.data.g0,100.2915,2.2569e+03);
x.set('*gbar',g)
x.reset
x.integrate;
V = x.integrate;
st = xtools.findNSpikeTimes(V,100);
[~,idx]=max(diff(st));
V(1:st(idx)) = [];
time = (1:length(V))*x.dt*1e-3;
plot(pax(2),time,V,'k')


r = rectangle(pax(3));
r.Position = [0 -100 5 200];
r.FaceColor = [c(1,:) .35];
scatter(ax,55.7175, 1.2538e+03,48,c(1,:),'o','filled')
g = singleCompartment.perturb.scaleG(v.data.g0,55.7175, 1.2538e+03);
x.set('*gbar',g)
x.reset;
x.integrate;
V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(pax(3),time,V,'k')



r = rectangle(pax(4));
r.Position = [0 -100 5 200];
r.FaceColor = [c(2,:) .35];
scatter(ax,x0, y0/4,48,c(2,:),'o','filled')
g = singleCompartment.perturb.scaleG(v.data.g0,x0, y0/4);
x.set('*gbar',g)
x.reset;
x.integrate;
V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(pax(4),time,V,'k')


% plot equi-calcium line

load([ model_hash '_calcium.voronoi'],'-mat')

X = v.boundaries(1).regions.x;
Y = v.boundaries(1).regions.y;
X(mathlib.aeq(X,x0*10)) = NaN;
plot(ax,X,Y,'r','LineWidth',3)

set(ax,'XScale','log','YScale','log','XLim',v.x_range,'YLim',v.y_range)


clear handles
handles.no_control.ax = ax;
handles.no_control.pax = pax;




% plot the integral control solutioon

load([model_hash '_1.voronoi'],'-mat')

clear ax
ax = subplot(2,2,3); hold on
v.findBoundaries(ax)
axis square
p = ax.Children;
for i = 1:length(p)
	if i == 5
		p(i).FaceColor = c(5,:);
	end

end
clear pax
idx = [11 12 15 16];
for i = 1:4
	pax(i) = subplot(4,4,idx(i)); hold on
	set(pax(i),'YLim',[-80 50],'XLim',[0 3])
	if i < 3
		set(gca,'XTick',[])
	end

	if i == 3
		xlabel('Time (s)')
		ylabel('V_m (mV)')
	end
	
end




plot(ax,[v.x_range(1) v.x_range(2)], [v.y_range(1) v.y_range(2)],'k--');
plot(ax,X,Y,'r','LineWidth',3)


x = singleCompartment.makeNeuron();
singleCompartment.disableControllers(x)
x.t_end = 5e3;


r = rectangle(pax(1));
r.Position = [0 -100 5 200];
r.FaceColor = [c(5,:) .35];
x.set('*gbar',v.data.g0)
x.reset
x.integrate;
V = x.integrate;
st = xtools.findNSpikeTimes(V,100);
[~,idx]=max(diff(st));
V(1:st(idx)) = [];
time = (1:length(V))*x.dt*1e-3;
plot(pax(1),time,V,'k')
scatter(ax,x0, y0,48,c(5,:),'o','filled')


singleCompartment.configureControllers(x);


r = rectangle(pax(2));
r.Position = [0 -100 5 200];
r.FaceColor = [c(5,:) .35];
scatter(ax,10, 100,48,c(5,:),'o','filled')
g = singleCompartment.perturb.scaleG(v.data.g0,10,100);
x.set('*gbar',g)
x.reset;
x.t_end = 100e3;
[~,~,C] = x.integrate;
x.t_end = 5e3;
V = x.integrate;
st = xtools.findNSpikeTimes(V,100);
[~,idx]=max(diff(st));
V(1:st(idx)) = [];
time = (1:length(V))*x.dt*1e-3;
plot(pax(2),time,V,'k')
C(:,7) = [];
g = C(:,2:2:end);
X = sum(g(:,[2:3]),2); 
Y = sum(g(:,[1 4 5 6 8]),2); 
plotlib.trajectory(ax,X,Y,'Color','k')

r = rectangle(pax(3));
r.Position = [0 -100 5 200];
r.FaceColor = [c(1,:) .35];
scatter(ax,1e3, 1e2,48,c(1,:),'o','filled')
g = singleCompartment.perturb.scaleG(v.data.g0,1e3,1e2);
x.set('*gbar',g)
x.set('*Controller.m',g*x.AB.A)
x.AB.CaT.E = 30;
x.AB.CaS.E = 30;
x.reset;
x.t_end = 100e3;
[~,~,C] = x.integrate;
x.t_end = 5e3;
V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(pax(3),time,V,'k')
C(:,7) = [];
g = C(:,2:2:end);
X = sum(g(:,[2:3]),2); 
Y = sum(g(:,[1 4 5 6 8]),2); 
plotlib.trajectory(ax,X,Y,'Color','k')

r = rectangle(pax(4));
r.Position = [0 -100 5 200];
r.FaceColor = [c(2,:) .35];
scatter(ax,250, 250,48,c(2,:),'o','filled')
g = singleCompartment.perturb.scaleG(v.data.g0,250,250);
x.set('*gbar',g)
x.set('*Controller.m',g*x.AB.A)
x.AB.CaT.E = 30;
x.AB.CaS.E = 30;
x.reset;
x.t_end = 100e3;
[~,~,C] = x.integrate;
x.t_end = 5e3;
V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(pax(4),time,V,'k')
C(:,7) = [];
g = C(:,2:2:end);
X = sum(g(:,[2:3]),2); 
Y = sum(g(:,[1 4 5 6 8]),2); 
plotlib.trajectory(ax,X,Y,'Color','k')

xlabel(ax,'\Sigma g_{Ca} (uS/mm^2)')
ylabel(ax,'\Sigma g_{others} (uS/mm^2)')

handles.control.ax = ax;
handles.control.pax = pax;

% finally, plot every single end point 
% to show that they end up on the red
% line
% g = v.results.gbar;
% X = sum(g(:,2:3),2);
% Y = sum(g(:,[1 4 5 6 8]),2);
% plot(ax,X,Y,'k+')

figlib.pretty('plw',1,'lw',1,'fs',18)

drawnow

handles.no_control.ax.XLim = v.x_range;
handles.no_control.ax.YLim = v.y_range;
handles.control.ax.XLim = v.x_range;
handles.control.ax.YLim = v.y_range;

handles.no_control.ax.Position = [.1 .6 .37 .37];
handles.control.ax.Position = [.1 .11 .37 .37];

axlib.move(handles.no_control.pax(3:4),'up',.05)
axlib.move(handles.no_control.pax,'up',.03)
axlib.move(handles.control.pax(3:4),'up',.05)

for i = 1:length(pax)
	pax(i).Position(4) = .12;
	handles.no_control.pax (i).Position(4) = .12;
end


% labels
figlib.label('delete_all',true)
axlib.label(handles.no_control.ax,'a','font_size',36,'x_offset',-.01,'y_offset',-.03);
axlib.label(handles.no_control.pax(1),'b','font_size',36,'x_offset',-.05,'y_offset',.01)
axlib.label(handles.control.ax,'c','font_size',36,'x_offset',-.01,'y_offset',-.03);
axlib.label(handles.control.pax(1),'d','font_size',36,'x_offset',-.05,'y_offset',.01)