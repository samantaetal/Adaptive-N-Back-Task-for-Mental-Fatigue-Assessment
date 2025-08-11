# Adaptive-N-Back-Task-for-Mental-Fatigue-Assessment
This Repository contains the MATLAB implementation of a novel adaptive N-Back memory recall task to effectively induce and assess mental fatigue.
Sample pre-processed data is available at: https://drive.google.com/file/d/1visOA_juw2uNxWyjR14H_iE6AnNr282N/view?usp=sharing

Instructions of using the code:
All codes are written using MATLAB R2024b. 

To run the experiment, users first need to install Psychtoolbox (http://psychtoolbox.org/) and all of its dependencies as described in the official website. Then they need to download two folders named as 'pvt' and 'nBack' from this repository and add the path to matlab session.

The script, 'MentalFatigue_Complete_Paradigm.m' utilizes all necessary functions from those two folders to successfully run the experiment. Upon executing the complete paradigm code, users will have the flexibility to adapt the runtime of the PVT and N-Back task before commencement of the experiment. Once started, the complete experiment will be executed sequentially as described in the manuscript.

Pre-processing of the raw data has been done using dedicated MEGIN data analysis software which can not be shared due to licence restrictions but the parameters are described in detail in the main manuscript.

Remaining scripts were used for analysing the pre-processed data of individual participants.
