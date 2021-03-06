* Descriptive stats using EMICOV 2011

glo path="C:\Users\WB452275\Dropbox\Xsupport\Benin\"
glo pathdata="${path}"+"Data\EMICOV_2015"

* 0. select variables of interest from different modules

* emploi2015.dta
glo identifiers_2 ="m01_01 "
glo identifiers_1 ="v01 v02 v03"
glo varemploi = "weight emp_ap1-emp_ap3 "

use "${pathdata}/Module_Emploi_EMICOV2015-BM.dta", clear
renvars _all, lower
rename weight920 weight
forvalues i=1(1)3 {
	rename ap`i' emp_ap`i'
}

keep $identifiers_1 $identifiers_2 $varemploi
sort $identifiers_1 $identifiers_2
save emploi_temp, replace


* menage2015.dta
glo varmenage ="urbrur 		P0NM   						Taille      deptot   	M03_110A-M03_110N M03_118A-M03_118F M03_119 M03_120 M03_121 M03_122A-M03_122F M03_123"

use "${pathdata}/Damien/menage2015.dta", clear
sort V01 V02 V03
save temp, replace

use "${pathdata}/Damien/Fichier menage produit_2015.dta", clear
duplicates drop V01 V02 V03, force
sort V01 V02 V03

merge V01 V02 V03 using temp
ta _merge
capture drop _merge

renvars V01 V02 V03, lower


keep $identifiers_1 $varmenage 
sort $identifiers_1 
renvars _all, lower

save menage_temp, replace
 

* individu2015.dta

glo varindividu ="nomdept  m01_03 m01_04 m01_07 m01_08 m01_11d m01_17n m01_20b"

use "${pathdata}/Damien/individu2015.dta", clear

renvars _all, lower
decode m00_depa, generate(nomdept)


keep $identifiers_1 $identifiers_2 $varindividu   
sort $identifiers_1 $identifiers_2

save indiv_temp, replace
 
 
* RSAL3.dta (shocks)
glo varRSAL4 ="sal_b2 sal_b2_txt sal_b3 sal_b4 sal_b5"


use "${pathdata}/Damien\RSAL4_Apur.dta", clear

rename M_ID1 V01
rename M_ID2 V02
rename M_ID3 V03
renvars _all, lower
keep $identifiers_1 $varRSAL4
sort $identifiers_1 

keep if sal_b3==1 //only keep shocks that affected hh significantly
sort $identifiers_1 sal_b5 //keep only the most serious shock
bysort $identifiers_1: g order=_n
keep if order==1
drop order

save RSAL4_temp, replace
 
 * RSAL3.dta
glo varRSAL3 ="sal_b1_01-sal_b1_13"


use "${pathdata}/Damien\RSAL3_Apur.dta", clear

rename M_ID1 V01
rename M_ID2 V02
rename M_ID3 V03
renvars _all, lower
keep $identifiers_1 $varRSAL3
sort $identifiers_1 

save RSAL3_temp, replace
 
 
* 1. merge employment info with economic shock info and individual info

use indiv_temp, clear
merge 1:1 $identifiers_1 $identifiers_2 using emploi_temp

ta _merge m01_03
keep if m01_03==1
keep if _merge==3
drop _merge


merge m:1 $identifiers_1 using menage_temp

ta _merge
keep if _merge==3
drop _merge

merge m:1 $identifiers_1 using RSAL3_temp

ta _merge
keep if _merge==3
drop _merge

merge m:1 $identifiers_1 using RSAL4_temp

ta _merge
keep if _merge==3 | _merge==1
drop _merge

*codebook
g year=2015


save Econ_shocks2015.dta, replace
