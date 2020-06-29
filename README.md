# How neurons can compensate for changes in cell size 

![](https://user-images.githubusercontent.com/6005346/64710225-8c3c1f00-d485-11e9-9141-e1182d05bc11.png)

This repository contains code that reproduces all figures from "Homeostatic plasticity rules that compensate for cell size are susceptible to channel deletion" by Srinivas Gorur-Shandilya, Eve Marder and Timothy O'Leary.

A preprint is available [here](https://www.biorxiv.org/content/10.1101/753608v1.abstract)

## Installation 

Assuming you use git, install the required code and dependencies using:

```bash
# this repo
# tested with git hash 3c7f434ed7ae4666c760abafa25670a211843ee7
git clone https://github.com/marderlab/size-compensation

# the neuron simulator this uses
git clone https://github.com/sg-s/xolotl 

# dependencies 
# tested with git hash e1c7450bd51256c04b415d9b422236ee313c8288
git clone https://github.com/sg-s/srinivas.gs_mtools



git clone https://github.com/sg-s/cpplab
```

## Reproducing figures in the paper

You will first have to download some data, available [here](https://github.com/marderlab/size-compensation/releases) and tell MATLAB where the data is using:

```
setpref('size_comp','data','/link/to/where/you/downloaded/data')
```

Then, in your MATLAB prompt, simply run the appropriate script to make the figure as you see it in the paper. For example, running

```
fig1.make
```
will make

![](https://user-images.githubusercontent.com/6005346/86020389-dc28aa00-b9f5-11ea-8cd1-9cbfb262fdcb.png)


This project uses the [xolotl](https://go.brandeis.edu/xolotl) neuron and network simulator, which is freely available for you to use. 

![](https://user-images.githubusercontent.com/6005346/41205222-30b6f3d4-6cbd-11e8-983b-9125585d629a.png)