* Descriptive stats using EMICOV 2011

glo path="C:\Users\WB452275\Dropbox\Xsupport\Benin\"
glo pathdata="${path}"+"Data\EMICOV_2011"

* 0. select variables of interest from different modules

* emploi2011.dta
glo identifiers_2 ="m01_01 "
glo identifiers_1 ="m_id1 m_id2 m_id3"
glo varemploi = "weight emp_ap1-emp_ap3 "
*glo varemploi = "weight emp_ap1-emp_ap3 branche activite formel sitprof2"

use "${pathdata}/emploi2011.dta", clear
rename weight750 weight

keep $identifiers_1 $identifiers_2 $varemploi
sort $identifiers_1 $identifiers_2
save emploi_temp, replace


* menage2011.dta
glo varmenage ="URBRUR 		P0NM   						Taille      DEPTOT    									M03_110A-M03_110N M03_118A-M03_118F M03_119 M03_120 M03_121 M03_122A-M03_122F M03_123"

use "${pathdata}/menage2011.dta", clear

renvars M_ID1 M_ID2 M_ID3, lower
keep $identifiers_1 $varmenage
sort $identifiers_1 
renvars _all, lower
rename P0NM2011 P0NM
rename P0M2011 P0M
rename tailmen_c Taille
save menage_temp, replace
 

* individu2011.dta
glo varindividu ="nomdept  m01_03 m01_04 m01_07 m01_08 m01_11d m01_17n m01_20b"

use "${pathdata}/individu2011.dta", clear

renvars _all, lower
keep $identifiers_1 $identifiers_2 $varindividu
sort $identifiers_1 $identifiers_2

save indiv_temp, replace
 
 
* RSAL3.dta (shocks)
glo varRSAL4 ="sal_b2 sal_b2_txt sal_b3 sal_b4 sal_b5"


use "${pathdata}/Damien\RSAL4_Apur.dta", clear

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


use "${pathdata}/EMICoV2011_Securite\RSAL3.dta", clear

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
g year=2011
save Econ_shocks2011.dta, replace

*Tables:

*1. Check some descriptives stats against other data sources
* Female heads of households
ta nomdept m01_04 [aweight=weight750], row nofreq
* Ethnic composition

*2. Fraction of households with a serious shock in past year
g shock_year1=(sal_b5==1)
g shock_year2=(sal_b5==2)

*3. Distribution of days with deprivations within past week
egen privations=rowmax(sal_b1_01-sal_b1_13)

*4. Fraction of households with a bank account
g bankaccount=m03_123
replace bankaccount=0 if m03_123==2

*5. Fraction of households with different durables/assets
foreach x of varlist m03_110a-m03_118f m03_119 m03_121 {
replace `x'=0 if `x'==2
}
egen smalldurables=rowtotal(m03_110a-m03_110n)
egen largedurables=rowmax(m03_118a-m03_118f)
g terres=m03_119
g betail=m03_121



*7. Occupation
g coarse_ap1=int(emp_ap1/10)
g coarse_ap2=int(emp_ap2/100)
ta coarse_ap1
ta coarse_ap2
bysort emp_ap1 : g freq_ap1=_N
bysort emp_ap2 : g freq_ap2=_N
bysort coarse_ap1 : g freq_coarse_ap1=_N
bysort coarse_ap2 : g freq_coarse_ap2=_N

label define coarse_ap1 11 "Cultures non-permanentes" 14 "Production animale" ///
50 "Extraction" 

label define activite2 1 "Salariés (public)" 2 "Salariés (privé formel)" 3 "Salariés (privé informel)" 4 "Agriculteurs industriels" 5 " Agriculteurs vivriers" 6 "Eleveurs" 7 "Pêcheurs" 8 "Indépendants" 9 "Inactifs" 10 "Chômeurs"
label values activite activite2

*8. Alphabetisation
g alphabet=m01_20b_cm

*9. stuff
g ones=1
g space="_"

*10. Regionxrural
replace nomdept="Oueme" if nomdept=="Ouémé"
decode urbrur, g(urbrur_str)
g RegionxRural= nomdept+space+urbrur_str


* Economic status of household
g poor = p0m2011
g status=.
replace status=1 if formel==1
replace status=5 if formel==0 & poor==100
replace status=4 if formel==0 & poor==0 & shock_year1==1 
replace status=3 if formel==0 & poor==0 & shock_year2==1
replace status=2 if formel==0 & poor==0 & shock_year1==0 & shock_year2==0
label define status 1 "Formel" 5 "Informel_pauvre" 3 "Informel_vulnerable2" 4 "Informel_vulnerable1" 2 "Informel_non-pauvre_non-vulnerable"

label values status status

g status2=.
replace status2=1 if formel==1
replace status2=4 if formel==0 & poor==100
replace status2=3 if formel==0 & poor==0 & (shock_year1==1 | shock_year2==1)
replace status2=2 if formel==0 & poor==0 & shock_year1==0 & shock_year2==0
label define status2 1 "Formel" 4 "Informel_pauvre" 3 "Informel_vulnerable"  2 "Informel_non-pauvre_non-vulnerable"

label values status2 status2

*6. Consumption
g consumptionpc=tdeptot/1000
g consumption=deptot
label variable consumptionpc "Consommation par tête (000FCFA)"
bysort RegionxRural: egen medianconsregion=median(consumptionpc) if status2==2
bysort coarse_ap2: egen medianconsap2=median(consumptionpc) if status2==2
bysort activite: egen medianconsactivite=median(consumptionpc) if status2==2


tabstat consumptionpc consumption poor shock_year1 shock_year2 bankaccount smalldurables largedurables terres formel educ_cm urbrur, s(n mean min p25 p50 p75 max ) c(s)

save Econ_shocks.dta, replace

