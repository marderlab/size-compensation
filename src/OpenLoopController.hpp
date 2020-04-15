// _  _ ____ _    ____ ___ _
//  \/  |  | |    |  |  |  |
// _/\_ |__| |___ |__|  |  |___
//
// Open loop controller -- does not implment feedback
// but blindly integrates mRNA and channels in open loop

#ifndef OPENLOOPCONTROLLER
#define OPENLOOPCONTROLLER
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class OpenLoopController: public mechanism {

protected:
    int step_counter = 0;
public:
    // timescales
    double tau_m = std::numeric_limits<double>::infinity();
    double tau_g = 5e3;

    // mRNA concentration
    double m = 0;

    // area of the container this is in
    double container_A;


    double stop = std::numeric_limits<double>::infinity();
    double start = 0;

    // stop when we get to this area
    double area_max = std::numeric_limits<double>::infinity();


    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    OpenLoopController(double tau_m_, double tau_g_, double m_, double start_, double stop_, double area_max_)
    {

        tau_m = tau_m_;
        tau_g = tau_g_;
        m = m_;


        area_max = area_max_;

        start = start_;
        stop = stop_;

        if (isnan(start)) {start = 0;}
        if (isnan(stop)) {stop = std::numeric_limits<double>::infinity();}


        if (tau_g<=0) {mexErrMsgTxt("[OpenLoopController] tau_g must be > 0. Perhaps you meant to set it to Inf?\n");}
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

string OpenLoopController::getClass() {
    return "OpenLoopController";
}


double OpenLoopController::getState(int idx) {
    if (idx == 1) {return m;}
    else if (idx == 2) {return channel->gbar;}
    else {return std::numeric_limits<double>::quiet_NaN();}

}


int OpenLoopController::getFullStateSize(){return 2; }


int OpenLoopController::getFullState(double *cont_state, int idx) {
    // give it the current mRNA level
    cont_state[idx] = m;

    idx++;

    // and also output the current gbar of the thing
    // being controller
    if (channel)
    {
      cont_state[idx] = channel->gbar;
    }
    else if (syn)
    {
        cont_state[idx] = syn->gmax;
    }
    idx++;
    return idx;
}


void OpenLoopController::connect(conductance * channel_) {

    // connect to a channel
    channel = channel_;


    // make sure the compartment that we are in knows about us
    (channel->container)->addMechanism(this);



    controlling_class = (channel_->getClass()).c_str();

    // attempt to read the area of the container that this
    // controller should be in.
    container_A  = (channel->container)->A;



}

void OpenLoopController::connect(compartment* comp_) {
    mexErrMsgTxt("[OpenLoopController] This mechanism cannot connect to a compartment object");
}

void OpenLoopController::connect(synapse* syn_) {

    mexErrMsgTxt("[OpenLoopController] This mechanism cannot connect to a synapse object");

}


void OpenLoopController::integrate(void) {


    step_counter++;


    if ((channel->container)->A > area_max) {return;}
    if (step_counter < start) {return;}
    if (step_counter > stop) {return;}



    container_A  = (channel->container)->A;

    // integrate mRNA
    m += (dt/tau_m);

    // mRNA levels below zero don't make any sense
    if (m < 0) {m = 0;}

    // copy the protein levels from this channel
    double gdot = ((dt/tau_g)*(m - channel->gbar*container_A));

    // make sure it doesn't go below zero
    if (channel->gbar + gdot < 0) {
        channel->gbar = 0;
    } else {
        channel->gbar += gdot/container_A;
    }

}



void OpenLoopController::checkSolvers(int k) {
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[OpenLoopController] unsupported solver order\n");
    }
}




#endif
