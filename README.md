# How neurons can compensate for changes in cell size 

![](https://user-images.githubusercontent.com/6005346/64710225-8c3c1f00-d485-11e9-9141-e1182d05bc11.png)

This repository contains code that reproduces all figures from "Homeostatic plasticity rules that compensate for cell size are susceptible to channel deletion" by Srinivas Gorur-Shandilya, Eve Marder and Timothy O'Leary.

A preprint is available [here](https://www.biorxiv.org/content/10.1101/753608v1.abstract)

## Installation 

Assuming you use git, install the required code and dependencies using:

```bash
# this repo
git clone https://github.com/marderlab/size-compensation

# the neuron simulator this uses
git clone https://github.com/sg-s/xolotl

# dependencies 
git clone https://github.com/sg-s/srinivas.gs_mtools
git clone https://github.com/sg-s/cpplab
```

## Reproducing figures in the paper

In your MATLAB prompt, simply run the appropriate script to make the figure as you see it in the paper. For example, running

```
make_fig_1
```

in the `fig1` folder will generate this: 

![](https://user-images.githubusercontent.com/6005346/64710385-dae9b900-d485-11e9-9bb5-ac2f6db9ceff.png)


This project uses the [xolotl](https://go.brandeis.edu/xolotl) neuron and network simulator, which is freely available for you to use. 

![](https://user-images.githubusercontent.com/6005346/41205222-30b6f3d4-6cbd-11e8-983b-9125585d629a.png)