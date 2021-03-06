
glo graphpath="${path}"+"Figures\"
global ext="png"
global exportoptions = "width(800) height(600)"

glo coarse=100
glo consumption=1.0e+03

*Fraction of non-vulnerable informal households by region
ta RegionxRural  status2 [aweight=weight750] if urbrur==1, row nofreq
ta RegionxRural  status2 [aweight=weight750] if urbrur==2, row nofreq

*Fraction of non-vulnerable informal households by employment of the hh head
*ta emp_ap2  status2 [aweight=weight750] if freq_ap2>$coarse, row nofreq
ta activite  status2 [aweight=weight750], row nofreq
 
* Distribution of household consumption among non-vulnerable informal hh
graph box consumptionpc if status2==2 & urbrur==1 & consumptionpc<$consumption, over(RegionxRural, sort(medianconsregion) label(angle(vertical))) 
graph export "$graphpath/ConsByUrban.$ext", replace $exportoptions
graph box consumptionpc if status2==2 & urbrur==2 & consumptionpc<$consumption, over(RegionxRural, sort(medianconsregion) label(angle(vertical))) 
graph export "$graphpath/ConsByRural.$ext", replace $exportoptions
graph box consumptionpc if status2==2  & consumptionpc<$consumption, over(activite, sort(medianconsactivite) label(angle(45) format(%10s))) 
graph export "$graphpath/ConsByEmpl.$ext", replace $exportoptions

* Other characteristics of non-vulnerable informal hh
foreach X of varlist privations bankaccount smalldurables largedurables terres educ_cm {
ta RegionxRural  `X' [aweight=weight750] if urbrur==1 & status2==2, row nofreq
ta RegionxRural  `X' [aweight=weight750] if urbrur==2 & status2==2, row nofreq
ta activite  `X' [aweight=weight750] if status2==2 & freq_coarse_ap2>$coarse, row nofreq
}



*tabstat consumptionpc shock* privations bankaccount smalldurables largedurables terres educ_cm urbrur formel poor if  freq_ap1>100  , by(emp_ap1) s(n mean)
*tabstat consumptionpc shock* privations bankaccount smalldurables largedurables terres educ_cm urbrur formel poor if  freq_ap2>100  , by(emp_ap2) s(n mean)

