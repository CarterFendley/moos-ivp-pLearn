FROM moosivp/moos-ivp:r9177-gui
LABEL maintainer = Michael Misha Novitzky <michael.novitzky@westpoint.edu>

ENV MOOS="moos-ivp-aquaticus"
ENV PATH="/home/moos/${MOOS}/bin:${PATH}"
ENV IVP_BEHAVIOR_DIRS="${IVP_BEHAVIOR_DIRS}:/home/moos/${MOOS}/lib"

# System Dependencies
USER root
RUN usermod -aG sudo moos
RUN echo "moos:moos" | chpasswd
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libncurses-dev sudo python2.7-dev python-pip python-tk && apt-get clean
RUN apt-get install -y vim emacs-nox tmux git
RUN pip2 install --no-cache-dir numpy matplotlib 'tensorflow==1.5' 'keras==2.0.8' colorama h5py
USER moos

# Aquaticus tree
RUN svn co "https://oceanai.mit.edu/svn/${MOOS}-oai/trunk/" "${HOME}/${MOOS}"
RUN cd "${HOME}/${MOOS}" && ./build.sh

# pLearn tree
ENV PLEARN="exported_pLearn"
ENV PATH="/home/moos/${PLEARN}/bin:${PATH}"
ENV IVP_BEHAVIOR_DIRS="/home/moos/${PLEARN}/lib:${IVP_BEHAVIOR_DIRS}"
# In the exported version of pLearn the Constants file will be in the 
ENV PYTHONPATH="${PYTHONPATH}:/home/moos/${PLEARN}/:/home/moos/${PLEARN}/src/lib_python"

RUN mkdir ${PLEARN}
COPY --chown=moos:moos . ${PLEARN}/
RUN cd ${PLEARN} && ./build.sh
