* MNH: ECohorts derived variable creation (Ethiopia)

* C Arsenault, S Sabwa, K Wright

/*

	This file creates derived variables for analysis from the MNH ECohorts South Africa (KZN) dataset. 

*/
u "$za_data_final/eco_m1_za.dta", clear

*------------------------------------------------------------------------------*
* MODULE 1
*------------------------------------------------------------------------------*
	* SECTION A: META DATA
	* All facilities are public primary care facilities
	
*------------------------------------------------------------------------------*	
	* SECTION 2: HEALTH PROFILE
	
			egen phq9_cat = rowtotal(phq9*)
			recode phq9_cat (0/4=1) (5/9=2) (10/14=3) (15/19=4) (20/27=5)
			label define phq9_cat 1 "none-minimal 0-4" 2 "mild 5-9" 3 "moderate 10-14" ///
			                        4 "moderately severe 15-19" 5 "severe 20+" 
			label values phq9_cat phq9_cat

			egen phq2_cat= rowtotal(phq9a phq9b)
			recode phq2_cat (0/2=0) (3/6=1)
			
			encode m1_203, gen(other_major_hp)
			recode other_major_hp (1 3/4 10 15 16 18/21 =0)
			replace other_major_hp = 1 if other_major_hp!=0
			lab drop other_major_hp
		
*------------------------------------------------------------------------------*	
	* SECTION 3: CONFIDENCE AND TRUST HEALTH SYSTEM
			recode m1_302 (999=.)
	
*------------------------------------------------------------------------------*	
	* SECTION 5: BASIC DEMOGRAPHICS
			gen educ_cat=m1_503
			recode educ_cat (3=2) (4=3) (5=4)
			lab def educ_cat 1 "Some primary" 2 "Completed primary or some secondary" ///
							 3 "Completed secondary" 4"Higher education"	 
			lab val educ_cat educ_cat
*------------------------------------------------------------------------------*	
	* SECTION 6: USER EXPERIENCE
			foreach v in m1_601 m1_605a m1_605b m1_605c m1_605d m1_605e m1_605f ///
			             m1_605g m1_605h {
				recode `v' (2=1) (3/5=0), gen(vg`v')
			}
			egen anc1ux=rowmean(vgm1_605a-vgm1_605h) // this is different than ETH!
			
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
			recode anc1fetal_hr  (2=.) 
			replace anc1fetal_hr=. if m1_804==1 // only applies to those in 2nd or 3rd trimester
			gen anc1urine = m1_705
			egen anc1blood = rowmax(m1_706 m1_707) // finger prick or blood draw
			gen anc1hiv_test =  m1_708a
			gen anc1syphilis_test = m1_710a
			gen anc1blood_sugar_test = m1_711a
			gen anc1ultrasound = m1_712
			recode  m1_713a (2=1) (3=0), gen(anc1ifa)
			recode m1_713b (2=1) (3=0) (98 .d =0), gen(anc1calcium)
			gen anc1tt = m1_714a
			gen anc1depression = m1_716c
			gen anc1edd =  m1_801
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
										
			* Q713 Other treatments/medicine at first ANC visit 
			gen anc1food_supp = m1_713c
			gen anc1mental_health_drug = m1_713f
			gen anc1hypertension = m1_713h
			gen anc1diabetes = m1_713i
			gen anc1hiv= m1_713k
			foreach v in anc1food_supp anc1mental_health_drug anc1hypertension ///
						 anc1diabetes anc1hiv {
			recode `v' (3=0) (2=1)
			}
			* Instructions and advanced care
			egen specialist_hosp= rowmax(m1_724e m1_724c) 
			
			recode m1_709b (98=.)
*------------------------------------------------------------------------------*	
	* SECTION 8: CURRENT PREGNANCY
			/* Gestational age at ANC1
			Here we should recalculate the GA based on LMP (m1_802c and self-report m1_803 */
			
			egen dangersigns = rowmax(m1_814a m1_814b m1_814c m1_814d m1_814e m1_814f m1_814g)
			
		    gen ga_edd = 40-((m1_802a - date_m1)/7)
			gen ga = trunc(ga_edd)
			replace ga = m1_803 if ga==.
			
			replace ga=. if ga <0
			gen trimester = ga
			recode trimester 0/12 = 1 13/26 = 2 27/42 = 3
			
			* Asked about LMP
			gen anc1lmp= m1_806
			
			* Screened for danger signs 
			recode m1_815 (1=0) (2/96=1) (.a .d .r=.) , gen(anc1danger_screen)
			replace anc1danger_screen = 0 if m1_815_other=="She told the nurse that she bleeds and the nurse said there is no such thing"
		
*------------------------------------------------------------------------------*	
	* SECTION 9: RISKY HEALTH BEHAVIOR
			recode  m1_901 (1/2=1) (3=0) (4=.)
			egen risk_health = rowmax( m1_901  m1_905)
			recode m1_902 (2=0)
			egen stop_risk = rowmax( m1_902   m1_907)
			
*------------------------------------------------------------------------------*	
	* SECTION 10: OBSTETRIC HISTORY
			gen nbpreviouspreg = m1_1001-1 // nb of pregnancies including current minus current pregnancy
			gen pregloss = nbpreviouspreg-m1_1002 // nb previous pregnancies (not including current) minus previous births
			replace pregloss = 0 if pregloss <0 // assuming these are all twins/triplets
			gen stillbirths = m1_1002 - m1_1003 // nb of deliveries/births minus nb babies born alive
			replace stillbirth = 0 if stillbirth ==-1 // 2 live babies for 1 delivery =  twins
			replace stillbirths = 1 if stillbirths>1 & stillbirths<.
*------------------------------------------------------------------------------*	
	* SECTION 11: IPV
	
	egen physical_verbal = rowmax(m1_1101 m1_1103)
*------------------------------------------------------------------------------*	
	* SECTION 12: ECONOMIC STATUS AND OUTCOMES
			/*Asset variables
			* I used the WFP's approach to create the wealth index
			// the link can be found here https://docs.wfp.org/api/documents/WFP-0000022418/download/ 

			pca safewater bankacc car motorbik bicycle roof wallmat floormat fuel refrig phone telev radio electr toilet  // most are pro-urban variables
			predict wealthindex
			xtile quintile = wealthindex, nq(5)
			tab quintile */
			
			gen registration_cost= m1_1218a_1 // registration
			replace registration = . if registr==0
			gen med_vax_cost =  m1_1218b_1 // med or vax
			replace med_vax_cost = . if med_vax_cost==0
			gen labtest_cost =  m1_1218c_1 // lab tests
			replace labtest_cost= . if labtest_cost==0
			egen indirect_cost = rowtotal (m1_1218d_1 m1_1218e_1  )
			replace indirect = . if indirect==0
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


			replace Hb = Hb_card if Hb==.a | Hb==. // use the card value if the test wasn't done
				// Reference value of 11 from: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8990104/
			gen anemic= 0 if Hb>=11 & Hb<. 
			replace anemic=1 if Hb<11

			drop Hb_card



			
			* BMI 
			gen height_m = height_cm/100
			gen BMI = weight_kg / (height_m^2)
			gen low_BMI= 1 if BMI<18.5 
			replace low_BMI = 0 if BMI>=18.5 & BMI<.

			
			
*------------------------------------------------------------------------------*	
* Labelling new variables 
	lab var phq9_cat "PHQ9 Depression level Based on sum of all 9 items"
	lab var other_major_hp "Has other major health problems"
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
	lab var anc1food_supp "Received food supplement directly or a prescription at ANC1"
	lab var anc1ifa "Received iron and folic acid pills directly or a prescription at ANC1"
	lab var anc1tq "Technical quality score 1st ANC"
	lab var counsel_nutri "Counselled about proper nutrition at ANC1"
	lab var counsel_exer "Counselled about exercise at ANC1"
	lab var counsel_complic  "Counselled about signs of pregnancy complications"
	lab var counsel_birthplan "Counselled on birth plan at ANC1"
	lab var anc1counsel "Counselling quality score 1st ANC"
	lab var specialist_hosp  "Told to go see a specialist or to go to hospital for ANC"
	lab var dangersigns "Experienced at least one danger sign so far in pregnancy"
	lab var pregloss "Number of pregnancy losses (Nb pregnancies > Nb births)"
	lab var HBP "High blood pressure at 1st ANC"
	lab var anemic "Anemic (Hb <11.0)"
	lab var height_m "Height in meters"
	lab var BMI "Body mass index"
	lab var low_BMI "BMI below 18.5 (low)"
								 
save "$za_data_final/eco_m1_za_der.dta", replace
	