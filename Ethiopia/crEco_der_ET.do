* MNH: ECohorts derived variable creation (Ethiopia)
* Date of last update: August 2023
* S Sabwa, K Wright, C Arsenault

/*

	This file creates derived variables for analysis from the MNH ECohorts Ethiopia dataset. 

*/

***************************** Deriving variables *******************************

*u "$et_data_final/eco_m1m2_et.dta", clear

u "$user/Dropbox/SPH Kruk QuEST Network/Core Research/Ecohorts/MNH Ecohorts QuEST-shared/Data/Ethiopia/02 recoded data/eco_m1m2_et.dta", clear
*------------------------------------------------------------------------------*
* MODULE 1
*------------------------------------------------------------------------------*
	* SECTION A: META DATA
			gen facility_own = facility
			recode facility_own (2/11 14 16/19 =1) ///
							    (1 13 15 20 21 22 96 =2)
			
			lab def facility_own 1 "Public" 2 "Private"
			lab val facility_own facility_own 
			
			gen facility_lvl = facility 
			recode facility_lvl (2/6 8/12 14 16 17 19  =1) (7 18 =2) ///
								(1 13 15 20 21 22 96 =3) 
			
			lab def facility_lvl 1"Primary" 2 "Secondary" 3 "Private"
			lab val facility_lvl facility_lvl
*------------------------------------------------------------------------------*	
	* SECTION 7: VISIT TODAY: CONTENT OF CARE
			* Technical quality of first ANC visit
			gen anc1bp = m1_700 
			gen anc1weight = m1_701 
			gen anc1height = m1_702
			egen anc1bmi = rowtotal(m1_701 m1_702)
			recode anc1bmi (1=0) (2=1)
			gen anc1muac = m1_703
			gen anc1fetal_hr = m1_704
			recode anc1fetal_hr  (2=.) // only applies to those in 2nd or 3rd trimester
			gen anc1urine = m1_705
			egen anc1blood = rowmax(m1_706 m1_707) // finger prick or blood draw
			gen anc1hiv_test =  m1_708a
			gen anc1syphilis_test = m1_710a
			gen anc1blood_sugar_test = m1_711a
			gen anc1ultrasound = m1_712
			gen anc1ifa =  m1_713a
			recode anc1ifa (2=1) (3=0)
			gen anc1tt = m1_714a

			egen anc1tq = rowmean(anc1bp anc1weight anc1height anc1muac anc1fetal_hr anc1urine ///
								 anc1blood anc1ultrasound anc1ifa anc1tt ) // 10 items
								  
			* Counselling at first ANC visit
			gen counsel_nutri =  m1_716a  
			gen counsel_exer=  m1_716b
			gen counsel_complic =  m1_716e
			gen counsel_comeback = m1_724a
			gen counsel_birthplan =  m1_809
			egen anc1counsel = rowmean(counsel_nutri counsel_exer counsel_complic ///
								counsel_comeback counsel_birthplan)
			
*------------------------------------------------------------------------------*	
	* SECTION 13: HEALTH ASSESSMENTS AT BASELINE

			* High blood pressure (HBP)
			egen systolic_bp= rowmean(bp_time_1_systolic bp_time_2_systolic bp_time_3_systolic)
			egen diastolic_bp= rowmean(bp_time_1_diastolic bp_time_2_diastolic bp_time_3_diastolic)
			gen systolic_high = 1 if systolic_bp >=140 & systolic_bp <.
			replace systolic_high = 0 if systolic_bp<140
			gen diastolic_high = 1 if diastolic_bp>=90 & diastolic_bp<.
			replace diastolic_high=0 if diastolic_high <90
			egen HBP= rowmax (systolic_high diastolic_high)
			drop systolic* diastolic*
			
			* Anemia 
			gen Hb= m1_1309 // test done by E-Cohort data collector
			gen Hb_card= m1_1307 // hemoglobin value taken from the card
				replace Hb_card = "12.6" if Hb_card=="12.6g/d" | Hb_card=="12.6g/dl"
				replace Hb_card = "13" if Hb_card=="13g/dl" 
				replace Hb_card= "14.6" if Hb_card=="14.6g/dl"
				replace Hb_card = "15" if Hb_card=="15g/dl"
				replace Hb_card= "16.3" if Hb_card=="16.3g/dl"
				replace Hb_card= "16.6" if Hb_card=="16.6g/dl"
				replace Hb_card= "16" if Hb_card=="16g/dl"
				replace Hb_card= "17.6" if Hb_card=="17.6g/dl"
				replace Hb_card="11.3" if Hb_card=="113"
			destring Hb_card, replace
			replace Hb = Hb_card if Hb==.a // use the card value if the test wasn't done
				// Reference value of 10 from: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8990104/
			gen anemic= 1 if Hb<10
			replace anemic=0 if Hb>=10 & Hb<. 
			drop Hb*
			
			* MUAC
			recode muac (999=.)
			gen malnutrition = 1 if muac<23
			replace malnutrition = 0 if muac>=23 & muac<.
			
			* BMI 
			gen height_m = height_cm/100
			gen BMI = weight_kg / (height_m^2)
			gen low_BMI= 1 if BMI<18.5 
			replace low_BMI = 0 if BMI>=18.5 & BMI<.

*------------------------------------------------------------------------------*	
* Labelling new variables 
	lab var facility_own "Facility ownership"
	lab var anc1bp "Blood pressure taken at ANC1"
	lab var anc1weight "Weight taken at ANC1"
	lab var anc1height "Height measured at ANC1"
	lab var anc1bmi "Both Weight and Height measured at ANC1"
	lab var anc1muac "Upper arm measured at ANC1"
	lab var anc1urine "Urine test done at ANC1"
	lab var anc1blood "Blood test done at ANC1 (finger prick or blood draw)"
	lab var anc1hiv_test "HIV test done at ANC1"
	lab var anc1syphilis_test "Syphilis test done at ANC1"
	lab var anc1ultrasound "Ultrasound done at ANC1"
	lab var anc1ifa "Received iron and folic acid pills directly or a prescription at ANC1"
	lab var anc1tq "Technical quality score 1st ANC"
	lab var counsel_nutri "Counselled about proper nutrition at ANC1"
	lab var counsel_exer "Counselled about exercise at ANC1"
	lab var counsel_complic  "Counselled about signs of pregnancy complications"
	lab var counsel_birthplan "Counselled on birth plan at ANC1"
	lab var anc1counsel "Counselling quality score 1st ANC"
	lab var HBP "High blood pressure at 1st ANC"
	lab var anemic "Anemic (Hb <10.0)"
	lab var height_m "Height in meters"
	lab var malnutrition "Acute malnutrition MUAC<23"
	lab var BMI "Body mass index"
	lab var low_BMI "BMI below 18.5 (low)"
	
	
save "$user/Dropbox/SPH Kruk QuEST Network/Core Research/Ecohorts/MNH Ecohorts QuEST-shared/Data/Ethiopia/02 recoded data/eco_m1m2_et_der.dta", replace
