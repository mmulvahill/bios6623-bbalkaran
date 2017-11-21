*************   P   R   O   G   R   A   M       H   E   A   D   E   R   *****************
*****************************************************************************************
*                                                                                       *
*   PROGRAM:    Project3.sas                                                            *
*   PURPOSE:    Data Analysis of Project 3  - Data Cleaning                             *
*   AUTHOR:     Bridget Balkaran                                                        *
*   CREATED:    2017-11-06                                                              *
*                                                                                       *
*   COURSE:     BIOS 6623 - Advanced Data Analysis                                      *
*   DATA USED:  Project3Data.csv                                                        *
*   MODIFIED:   DATE  2017-11-13                                                        *
*               ----------  --- ------------------------------------------------------- *
*                                                                                       *
*                                                                                       *
*****************************************************************************************
***********************************************************************************; RUN;

PROC IMPORT
		DATAFILE	= "/home/bridgetbalkaran0/my_courses/BIOS_6623 Advanced Data Analysis/Project _3/Project3Data.csv"
		OUT			= Project3.MemoryData
		DBMS		= CSV
		REPLACE		;
	RUN;
	


/* Create counts for number of timepoints*/ 
proc sql;
	create table Project3.MemoryData_Clean as
	select *, 
		count(id) as Num_ID,
 		count(blockr) as num_BlockR,
 		count(animals) as num_animals,
 		count(logmemI) as num_logmemI,
 		count(logmemII) as num_logmemII
	from Project3.Memorydata
	group by ID
	order by ID;
quit;

DATA illus; 
	SET Project3.memorydata_clean; 
	If num_BlockR < 3 then Delete; 
	If num_animals < 3 then Delete;
	if num_logmemI < 3 then Delete; 
	IF num_logmemII < 3 then Delete; 
	RUN; 

Proc Means DATA  = Project3.MEMORYDATA_CLEAN;                      *Min age here is 67.7 use this as age adjustment in model; 
Where demind = 1; 
RUN ; 

DATA Project3.Memorydata_Clean;
	SET Project3.Memorydata_Clean; 
	age_new  = age - 67.7; 
	RUN; 

	

/*create dataset looking at subjects at entry, not multiple obs */ 	
DATA Work.MemoryData3;      
	SET Project3.memorydata_clean;
	By id;
	Firstid = FIrst.id;
	IF Firstid = 1;
	*FirstBlockR = First.BlockR;
	*IF FirstblockR = 1;
	RUN; 

/*Use this data to get summary statistics for study pop at entry */ 
PROC MEANS DATA = Project3.Memorydata_Clean mean std min max nmiss;        *Min age here is 59.5 years, use this as adjustment in model;
	RUN;                                                          * age should be 67; 

*******************************************************************************************************;
/* Create subset datasets for analysis of each outcome var. These are the datasets that will be used in the analysis. */


/*BlockR*/ 	
/*Remove subjects with < 3 timepoints, Create changepoint variable */ 	
DATA Project3.BlockR; 
	SET Project3.MemoryData_Clean; 
	If Num_BlockR < 3 THEN Delete;
	DROP animals num_animals logmemI num_logmemI logmemII num_logmemII; 
	Changepoint = 0; 
	Tau = 4;
	If age - ageonset < Tau THEN Changepoint = 0;                     
	ELSE IF age - ageonset = Tau Then Changepoint = 0; 
	ELSE Changepoint = Age - ageonset + Tau;
	RUN; 
/*BlockR - how many subjects in this dataset? */ 
DATA Project3.BlockR2; /*n = 192*/ 
	SET Project3.BlockR;
	By id; 
	FirstId = first.id;
	IF Firstid = 1;   
	RUN;
	
	
	
	
	

/*Animals*/ 
/*Remove subjcts with < 3 Timepoints, Create changepoint */ 	
DATA Project3.Animals; 
	SET Project3.Memorydata_Clean; 
	If Num_Animals < 3 THEN Delete;
	DROP  blockR num_blockR logmemI num_logmemI logmemII num_logmemII; 
	Changepoint = 0; 
	If age - ageonset + 4 >= 0 THEN Changepoint = age - ageonset + 4;  
	RUN;
	
/* Animals  - How many subjects in this dataset? */ 
DATA Project3.Animals2; /* n = 187*/ 
	SET Project3.Animals;
	By id; 
	FirstId = first.id;
	IF Firstid = 1;   
	RUN;



/*LogMemI*/ 
/*Create Changepoint*/ 
DATA Project3.LogMemI; 
	SET Project3.Memorydata_Clean; 
	If Num_LogMemI < 3 THEN Delete;
	DROP blockR num_blockR animals num_animals logmemII num_logmemII;
	Changepoint = 0; 
	Tau = 4;
	If age - ageonset < Tau THEN Changepoint = 0;                     
	ELSE IF age - ageonset = Tau Then Changepoint = 0; 
	ELSE Changepoint = Age - ageonset + Tau;
	RUN;
/* How many subjects in this dataset?*/
DATA Project3.LogMemI2; /* n = 193*/ 
	SET Project3.LogMemI;
	By id; 
	FirstId = first.id;
	IF Firstid = 1;   
	RUN;
	
	
/*LogMemII*/ 
/*Create Changepoint*/	
DATA Project3.LogMemII;  
	SET Project3.Memorydata_Clean;
	If Num_LogMemII < 3 THEN Delete;
	DROP blockR num_blockR animals num_animals logmemI num_logmemI; 
	Changepoint = 0; 
	If age - ageonset + 4 >= 0 THEN Changepoint = age - ageonset + 4;                     
	RUN;

PROC SORT DATA  = Project3.LogMemII;
BY ID age;
RUN; 	
	
/*How many subjects in this dataset */ 	
DATA Project3.LogMemII2; /*n = 193*/ 
	SET Project3.LogMemII;
	By id; 
	FirstId = first.id;
	IF Firstid = 1;   
	RUN;

******************************************************************************************************; 
	
/*statistics for table 1 - need to subset by demind = 0 and demind = 1*/              ****Need to look at this again, this is by obs not sub; 



/*Summary of Data by demind = 1*/
PROC MEANS DATA=Project3.memorydata n nmiss mean std min max  skew kurtosis;
VARS SES Age BlockR Animals logmemI logmemII Ageonset Cdr;
WHERE Demind = 1;
RUN; 

PROC FREQ DATA = Project3.Memory2;
Where demind = 1;
Tables Demind Gender ;
RUN;  

/*proc means by demind = 0*/
PROC MEANS DATA=Project3.Memory2  n nmiss mean std min max  skew kurtosis;
VARS SES Age BlockR Animals logmemI logmemII Ageonset cdr;
WHERE Demind = 0;
RUN; 

PROC FREQ DATA = Project3.Memory2;
Where demind = 0;
Tables Demind Gender  ;
RUN;

/*Examine Data*/ 	
PROC UNIVARIATE DATA = Project3.memorydata_clean;
	QQPLOT;
	RUN; 


/*Look at longitudinal plots - original plots including all subjects*/ 	 

PROC SGplot DATA  = Project3.Memorydata;
	series x=age y= logmemI/  group = id;
	where demind =1;
	RUN; 
	
PROC SGplot DATA  = Project3.Memorydata;
	series x=age y= logmemI/  group = id;
	where demind =0;
	RUN; 
	

PROC SGplot DATA  = Project3.Memorydata;
	series x=age y= logmemII/  group = id;
	RUN; 

PROC SGplot DATA  = Project3.Memorydata;
	series x=age y= animals/  group = id;
	RUN; 
	
PROC SGplot DATA  = Project3.Memorydata;
	series x=age y= BlockR/  group = id;
	RUN; 

PROC SGplot DATA  = Project3.Memorydata;
	series x=age y= ageonset/  group = id;
	RUN; 
	
	
/*longitudinal plots including only those in the analysis*/
PROC SGPANEL DATA  = Project3.LogMemI;
	panelby demind;
	*refline axis = age  changepoint;
	series x = age y=logmemI/ group = id;
	title  "Logical Memory I Story A Score by Age in those without and with MCI/Dementia";
	RUN; 
	
PROC SGPANEL DATA  = Project3.MemoryData2;
	panelby demind;
	series x = age y=logmemII/ group = id;
	title  "Logical Memory II Story A Score by Age in those without and with MCI/Dementia";
	RUN; 
	
PROC SGPANEL DATA  = Project3.MemoryData2;
	panelby demind;
	series x = age y=Animals/ group = id;
	title  "Category Fluency for Animals Score by Age in those without and with MCI/Dementia";
	RUN; 
	
PROC SGPANEL DATA  = Project3.MemoryData2;
	panelby demind;
	series x = age y=BlockR/ group = id;
	title  "Block Design Test Score by Age in those without and with MCI/Dementia";
	RUN; 




/*Longitudinal plots by age at  dx */                                
PROC SGPANEL DATA  = Project3.MemoryData2;
	panelby demind;
	series x = age y=logmemI/ group = id;
	title  "Logical Memory I Story A Score by Age in those without and with MCI/Dementia";
	RUN; 

PROC SGPANEL DATA  = Project3.MemoryData2;
	panelby demind;
	series x = age y=logmemII/ group = id;
	title  "Logical Memory II Story A Score by Age in those without and with MCI/Dementia";
	RUN; 

PROC SGPANEL DATA  = Project3.MemoryData2;
	panelby demind;
	series x = age y=Animals/ group = id;
	title  "Category Fluency for Animals Score by Age in those without and with MCI/Dementia";
	RUN; 

PROC SGPANEL DATA  = Project3.MemoryData2;
	panelby demind;
	series x = ageo y=BlockR/ group = id;
	title  "Block Design Test Score by Age in those without and with MCI/Dementia";
	RUN; 





