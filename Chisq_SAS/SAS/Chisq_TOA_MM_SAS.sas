* author: Tingwei Adeck
* date: 2022-11-06
* purpose: Test of association between my bag and class bag
* license: public domain
* Input: manual entry into SAS (Alternative encoding a txt or csv file can work here)
* Output: Chisq_TOA_MM_SAS.pdf
* Description: mybag and class proportions are independent (odds ratio is 1)
* Chisq is made of a GOF test and Association test
* Results: association between my bag and class (odds ratio significantly different from 1)-Fisher exact test is used here;

%let path=/home/u40967678/sasuser.v94;


libname chisq
	"&path/sas_umkc/input";
    
filename chisqt
    "&path/sas_umkc/input/bag_class.txt";   

ods pdf file=
    "&path/sas_umkc/output/Chisq_TOA_MM_SAS.pdf";

options papersize=(8in 11in) nonumber nodate;


data chisq.chisqt;
  infile chisqt dlm=',';
  input 
   Color_code $ 
   Color_code_num	
   Group $
   group_code	
   Freq;

label
   Color_code="orange or not orange"
   Color_code_num="1=orange and 0=not orange"
   Group="my bag vs class"
   group_code="code for the groups"
   Freq="count or frequency of color vs no color";
run;

data chisq.chisqt_edit;
   length Color_code $10;
   format Color_code $10.;
   set chisq.chisqt;
   if Group = 'Group' then delete;
run;

title "Chi-sq association test set-up";
proc print
  data=chisq.chisqt_edit;
run;

title "Chi-sq association test of bag_size vs likelihood of selecting the orange color";
proc freq data = chisq.chisqt;
	tables Group*Color_code /chisq;
	weight Freq;
run;

ods pdf close;