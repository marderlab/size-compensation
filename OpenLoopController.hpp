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
    bool converged = false;
public:
    // timescales
    double tau_m = std::numeric_limits<double>::infinity();
    double tau_g = 5e3;

    // mRNA concentration
    double m = 0;

    // area of the container this is in
    double container_A;

    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    OpenLoopController(double tau_m_, double tau_g_, double m_)
    {

        tau_m = tau_m_;
        tau_g = tau_g_;
        m = m_;


        // turn it on
        converged = false;

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

        // if (converged) {return;}


        // // when target is reach, stop immediately 
        // if ((channel->container)->Ca_target < (channel->container)->Ca) {
        //     converged = true;
        //     mexPrintf("model converged\n");
        // }

        


        // integrate mRNA
        m += (dt/tau_m);

        // mRNA levels below zero don't make any sense
        if (m < 0) {m = 0;}

        // copy the protein levels from this channel
        double gdot = ((dt/tau_g)*(m - channel->gbar*container_A));

        // make sure it doesn't go below zero
        if (channel->gbar_next + gdot < 0) {
            channel->gbar_next = 0;
        } else {
            channel->gbar_next += gdot/container_A;
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
