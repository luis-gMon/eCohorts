# eCohorts

# MNH ECohorts(Eco) Data Processing Code
Shalom Sabwa, Kate Wright, Catherine Arsenault

**This repository contains the .do files used to process and analyze data from the MNH: eCohorts.** 

## About the survey: 
The MNH E-Cohort data was fielded starting May 2023 in eight sites in Ethiopia, Kenya, India and South Africa. The original E-Cohort survey instruments consist of five modules and are available in the shared Dropbox folder (though some country-specific adaptations may have been included).

The five modules consist of:
- Module 1 (M1) is the baseline in-person recruitment module conducted during the first antenatal care visit.

- Module 2 (M2) is the monthly phone survey follow-up during pregnancy. This is the only module that may be repeated multiple times.

- Module 3 (M3) is the phone survey conducted once the woman reports give birth or that the pregnancy ended. This survey should be administered at least two weeks postpartum.

- Module 4 (M4) is the phone survey conducted one month after M3 (6-8 weeks postpartum).

- Module 5 (M5) is the endline in-person survey conducted one month after M4 (10-12 weeks postpartum)


## Countries: 
Currently, the ECohorts has been conducted in 3 countries: Kenya, South Africa, and Ethiopia 

## Files in this repository: 
The "mainPVS.do" file sets globals and runs all .do files for data cleaning and preparation. Each country-specific creation file (e.g., crECo_cln_ET.do) cleans country data. The "crEco_der.do" file creates derived variables for analysis. The "anEco_mtbl.do" file creates weighted descriptive tables from these data. 
