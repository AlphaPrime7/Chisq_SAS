* author: Tingwei Adeck
* date: 2022-11-06
* purpose: perform a chi-square analysis on M&M data
* license: public domain
* Input: manual entry into SAS (Alternative encoding a txt or csv file can work here)
* Output: Chisq_MM_SAS.pdf
* Description: Perform a Chisq Goodness of Fit (GOF) test on M&M data obtained from a sample (My bag)
* Chisq is made of a GOF test and Association test
* Results: Coach line workers to focus on the Yellow and Orange color as they seem to have a hard time separating those;


%let path=/home/u40967678/sasuser.v94;
  
libname chisq
	"&path/sas_umkc/input";

ods pdf file=
    "&path/sas_umkc/output/Chisq_MM_SAS.pdf";

options papersize=(8in 11in) nonumber nodate;


data chisq.chisq_MM;
  input 
    Category: $7.
    Cat_code
    Freq
    Exp_prop: percent6.
    Exp_Freq;
    
  datalines;
	Orange 1 2.00 1667% 09.34
	Yellow 2 20.00 1667% 09.34
	Red 3 09.00 1667% 09.34
	Brown 4 11.00 1667% 09.34
	Green 5 05.00 1667% 09.34
	Blue 6 09.00 1667% 09.34
	;

run;

proc format;
	picture mypct (round) low-high='009.99%'; 
run;

proc datasets lib=chisq nolist;
	modify chisq_MM;
	format Exp_prop mypct.;
run;

title "M&M chi-sq goodness of fit Set-up";
proc print data= chisq.chisq_MM(obs=6);
run;

/*perform Chi-Square Goodness of Fit test-Equal proportions*/
title "M&M chi-sq goodness of fit analysis-EP proper";
proc freq data=chisq.chisq_MM;
	tables Category / chisq;
	weight Freq;
run;

/*perform Chi-Square Goodness of Fit test-Unequal proportions*/
title "M&M chi-sq goodness of fit analysis-UP proper";
proc freq data=chisq.chisq_MM;
	tables Category / TestP=(0.24 0.13 0.16 0.20 0.13 0.14) nocum;
	weight Freq;
ods output OneWayFreqs=chisq.FreqOut;
output out=chisq.FreqStats N ChiSq;
run;

/* create macro variables for sample size and chi-square statistic */
data _NULL_;
   set chisq.FreqStats;
   call symputx("NumObs", N);         
   call symputx("TotalChiSq", _PCHI_);
run;

title "chi-sq GOF Freq statistics";
proc print data=chisq.FreqStats;
run;
 
/* compute the proportion of chi-square statistic that is contributed
   by each cell in the one-way table */
data chisq.chisq_debug;
   set chisq.FreqOut;
   ExpectedFreq = &NumObs * TestPercent / 100;
   Deviation = Frequency - ExpectedFreq;
   ChiSqContrib = Deviation**2 / ExpectedFreq;  /* (O - E)^2 / E */
   ChiSqPropor = ChiSqContrib / &TotalChiSq;    /* proportion of chi-square contributed by this cell */
   format ChiSqPropor 5.3;
run;

title "M&M chi-sq GOF Debug-All attributes";
proc print data=chisq.chisq_debug; 
run;

title "M&M chi-sq GOF Debug";
proc print data=chisq.chisq_debug; 
   var F_Category Category Frequency TestPercent ExpectedFreq Deviation ChiSqContrib ChiSqPropor; 
run;

title "M&M Proportion of Chi-Square Statistic for Each Category";
proc sgplot data=chisq.chisq_debug;
   vbar F_Category / response=ChiSqPropor datalabel=ChiSqPropor;
   xaxis discreteorder=data;
   yaxis label="Proportion of Chi-Square Statistic" grid;
run;

ods pdf close;
