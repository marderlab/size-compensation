// _  _ ____ _    ____ ___ _
//  \/  |  | |    |  |  |  |
// _/\_ |__| |___ |__|  |  |___
//
// Noisy Integral controller, as in O'Leary et al
// This controller can control either a synapse
// or a conductance
// This version has an added parameter that controls
// noise in the calcium target or the timescales

#ifndef NOISYINTEGRALCONTROLLER
#define NOISYINTEGRALCONTROLLER
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class NoisyIntegralController: public mechanism {

protected:

public:
    // timescales
    double tau_m = std::numeric_limits<double>::infinity();
    double tau_g = 5e3;

    // noise amplitudes
    double tau_noise = 0;
    double target_noise = 0;


    // mRNA concentration
    double m = 0;

    // area of the container this is in
    double container_A;

    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    NoisyIntegralController(double tau_m_, double tau_g_, double m_, double tau_noise_, double target_noise_)
    {

        tau_m = tau_m_;
        tau_g = tau_g_;
        m = m_;

        tau_noise = tau_noise_;
        target_noise = target_noise_;

        if (tau_g<=0) {mexErrMsgTxt("[NoisyIntegralController] tau_g must be > 0. Perhaps you meant to set it to Inf?\n");}
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

string NoisyIntegralController::getClass() {
    return "NoisyIntegralController";
}


double NoisyIntegralController::getState(int idx) {
    if (idx == 1) {return m;}
    else if (idx == 2) {return channel->gbar;}
    else {return std::numeric_limits<double>::quiet_NaN();}

}


int NoisyIntegralController::getFullStateSize(){return 2; }


int NoisyIntegralController::getFullState(double *cont_state, int idx){
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


void NoisyIntegralController::connect(conductance * channel_) {

    // connect to a channel
    channel = channel_;


    // make sure the compartment that we are in knows about us
    (channel->container)->addMechanism(this);



    controlling_class = (channel_->getClass()).c_str();

    // attempt to read the area of the container that this
    // controller should be in.
    container_A  = (channel->container)->A;


}

void NoisyIntegralController::connect(compartment* comp_) {
    mexErrMsgTxt("[NoisyIntegralController] This mechanism cannot connect to a compartment object");
}

void NoisyIntegralController::connect(synapse* syn_) {

    mexErrMsgTxt("[NoisyIntegralController] This mechanism cannot connect to a synapse object");

}


void NoisyIntegralController::integrate(void) {


    // if the target is NaN, we will interpret this
    // as the controller being disabled
    // and do nothing
    if (isnan((channel->container)->Ca_target)) {return;}

    double Ca_error = (channel->container)->Ca_target - (channel->container)->Ca_prev;

    // integrate mRNA

    double tau_m_eff = (tau_m*(1+conductance::gaussrand()*tau_noise*dt));

    m += (dt/tau_m_eff)*(Ca_error);

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



void NoisyIntegralController::checkSolvers(int k) {
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[NoisyIntegralController] unsupported solver order\n");
    }
}




#endif
