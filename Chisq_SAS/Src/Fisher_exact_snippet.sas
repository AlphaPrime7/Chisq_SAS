/*works best with raw data*/
proc freq;
    tables Color_code*Group / fisher;
run;
