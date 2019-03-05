% similarNeuronTestFunc
% master test function that we use to look
% at our collection of neurons with
% similar beheaviours but different 
% maximal conductances

function status = similarNeuronTestFunc(x);

status = 1;

g0 = x.get('*gbar');

% no integral control, map space
singleCompartment.perturb.analyzeWithoutControl(x);

% no integral control, find Calcium nullcline 
x.set('*gbar',g0);
singleCompartment.perturb.findCalciumNullcline(x);

% with integral control, map space
x.set('*gbar',g0);
singleCompartment.perturb.analyzeWithControl(x);

% delete channels 
x.set('*gbar',g0);
singleCompartment.perturb.deleteChannels(x); 

status = 0;