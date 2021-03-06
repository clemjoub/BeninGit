
*Tables:
use Econ_shocks2015.dta, clear

*1. Check some descriptives stats against other data sources
* Female heads of households
ta nomdept m01_04 [aweight=weight], row nofreq
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

/*
label define activite2 1 "Salariés (public)" 2 "Salariés (privé formel)" 3 "Salariés (privé informel)" 4 "Agriculteurs industriels" 5 " Agriculteurs vivriers" 6 "Eleveurs" 7 "Pêcheurs" 8 "Indépendants" 9 "Inactifs" 10 "Chômeurs"
label values activite activite2
*/

*8. Alphabetisation
g alphabet=m01_20b

*9. stuff
g ones=1
g space="_"

*10. Regionxrural

capture replace nomdept="Oueme" if nomdept=="Ouémé"
decode urbrur, g(urbrur_str)
g RegionxRural= nomdept+space+urbrur_str


* Economic status of household
g poor = p0nm /*check whether correct measure of poverty*/
/*g status=.
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
*/

*6. Consumption
g consumptionpc=deptot/(1000*taille)
g consumption=deptot/1000
label variable consumptionpc "Consommation par tête (000FCFA)"
bysort RegionxRural: egen medianconsregion=median(consumptionpc) if status2==2
bysort coarse_ap2: egen medianconsap2=median(consumptionpc) if status2==2
*bysort activite: egen medianconsactivite=median(consumptionpc) if status2==2


tabstat consumptionpc consumption poor shock_year1 shock_year2 bankaccount smalldurables largedurables terres formel educ_cm urbrur, s(n mean min p25 p50 p75 max ) c(s)


