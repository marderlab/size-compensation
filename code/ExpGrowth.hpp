// _  _ ____ _    ____ ___ _    
//  \/  |  | |    |  |  |  |    
// _/\_ |__| |___ |__|  |  |___ 
//
// basic mechanism
// that mimics exponential growth by 
// increasing area of the cell 

#ifndef EXPGrowth
#define EXPGrowth
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class ExpGrowth: public mechanism {

protected:
    // housekeeping
    conductance * cond_pointer;

    int step_counter = 0;

public:
    // rate
    double rate = .01;

    double start = 0;
    double stop = std::numeric_limits<double>::infinity();

    // specify parameters + initial conditions for 
    // mechanism that controls a conductance 
    ExpGrowth(double rate_, double start_, double stop_)
    {
        rate = rate_;
        start = start_;
        stop = stop_;

        if (isnan(rate)) {rate = 0;}
        if (isnan(start)) {start = 0;}
        if (isnan(stop)) {stop = std::numeric_limits<double>::infinity();}
    }

    
    void integrate(void);

    void checkSolvers(int);

    void connect(conductance *);
    void connect(synapse*);
    void connect(compartment*);

    int getFullStateSize(void);
    int getFullState(double * cont_state, int idx);
    double getState(int);

};


double ExpGrowth::getState(int idx) {
    if (idx == 1) {return comp->A;}
    else {return std::numeric_limits<double>::quiet_NaN();}

}


int ExpGrowth::getFullStateSize(){return 1;}


int ExpGrowth::getFullState(double *cont_state, int idx) {
    // give it the current mRNA level
    cont_state[idx] = comp->A;
    idx++;
    return idx;
}


void ExpGrowth::connect(conductance * channel_) {
    mexErrMsgTxt("[ExpGrowth] This mechanism cannot connect to a channel object");
}

void ExpGrowth::connect(compartment* comp_) {
    comp = comp_;
    comp->addMechanism(this);
}

void ExpGrowth::connect(synapse* syn_) {
    mexErrMsgTxt("[ExpGrowth] This mechanism cannot connect to a synapse object");
}


void ExpGrowth::integrate(void) {

    step_counter++;

    if (step_counter < start) {return;}
    if (step_counter > stop) {return;}
    if (rate == 0) {return;}

    double old_A =  comp->A;
    comp->A *= (1+rate*dt);
    comp->vol *= (1+rate*dt);

    // update all gbars of all channels,
    // since that is a derived property 
    for (int i = 0; i < comp->n_cond; i ++) {
        cond_pointer = comp->getConductancePointer(i);
        cond_pointer->gbar_next = (cond_pointer->gbar_next)*old_A/(comp->A);
    }


}



void ExpGrowth::checkSolvers(int k)
{
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[ExpGrowth] unsupported solver order\n");
    }
}




#endif
