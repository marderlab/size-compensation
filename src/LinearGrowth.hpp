// _  _ ____ _    ____ ___ _    
//  \/  |  | |    |  |  |  |    
// _/\_ |__| |___ |__|  |  |___ 
//
// basic mechanism
// that mimics LinearGrowth by 
// increasing area of the cell 

#ifndef LINEARGrowth
#define LINEARGrowth
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class LinearGrowth: public mechanism {

protected:
    // housekeeping
    conductance * cond_pointer;

    int step_counter = 0;

public:
    // rate
    double rate = .1;

    double start = 0;
    double stop = std::numeric_limits<double>::infinity();

    // stop growth when this area is reached
    double area_max = std::numeric_limits<double>::infinity();

    // specify parameters + initial conditions for 
    // mechanism that controls a conductance 
    LinearGrowth(double rate_, double start_, double stop_, double area_max_)
    {
        rate = rate_;
        start = start_;
        stop = stop_;

        area_max = area_max_;

        if (isnan(rate)) {rate = 0;}
        if (isnan(start)) {start = 0;}
        if (isnan(stop)) {stop = std::numeric_limits<double>::infinity();}
        if (isnan(area_max)) {area_max = std::numeric_limits<double>::infinity();}
    }

    
    void integrate(void);

    void checkSolvers(int);

    void connect(conductance *);
    void connect(synapse*);
    void connect(compartment*);

    int getFullStateSize(void);
    int getFullState(double * cont_state, int idx);
    double getState(int);
    

    string getClass(void);

};


string LinearGrowth::getClass(void) {
    return "LinearGrowth";
}


double LinearGrowth::getState(int idx) {
    if (idx == 1) {return comp->A;}
    else {return std::numeric_limits<double>::quiet_NaN();}

}


int LinearGrowth::getFullStateSize(){return 1;}


int LinearGrowth::getFullState(double *cont_state, int idx) {
    // give it the current mRNA level
    cont_state[idx] = comp->A;
    idx++;
    return idx;
}


void LinearGrowth::connect(conductance * channel_) {
    mexErrMsgTxt("[LinearGrowth] This mechanism cannot connect to a channel object");
}

void LinearGrowth::connect(compartment* comp_) {
    comp = comp_;
    comp->addMechanism(this);
}

void LinearGrowth::connect(synapse* syn_) {
    mexErrMsgTxt("[LinearGrowth] This mechanism cannot connect to a synapse object");
}


void LinearGrowth::integrate(void) {

    step_counter++;

    if (step_counter < start) {return;}
    if (step_counter > stop) {return;}
    if (rate == 0) {return;}

    if (comp->A > area_max) {return;}

    double old_A =  comp->A;
    comp->A += rate*dt;
    comp->vol += rate*dt;

    // update all gbars of all channels,
    // since that is a derived property 
    for (int i = 0; i < comp->n_cond; i ++) {
        cond_pointer = comp->getConductancePointer(i);
        cond_pointer->gbar = (cond_pointer->gbar)*old_A/(comp->A);
    }


}



void LinearGrowth::checkSolvers(int k)
{
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[LinearGrowth] unsupported solver order\n");
    }
}




#endif
