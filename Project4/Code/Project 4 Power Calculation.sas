PROC POWER;
MULTREG 
MODEL = fixed
NFULLPREDICTORS = 4
NTESTPREDICTORS = 1
PCORR=0.2 
POWER=0.8 
ALPHA= 0.01
NTOTAL=.;
RUN; 

