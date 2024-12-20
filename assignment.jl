using HiGHS, JuMP
#ENV["CPLEX_STUDIO_BINARIES"] = "C:\\Program Files\\IBM\\ILOG\\CPLEX_Studio221\\cplex\\bin\\x64_win64\\"
import Pkg
Pkg.add("CPLEX")
Pkg.build("CPLEX")
model = Model(HiGHS.Optimizer)

#maximale electricitetisproductie door 3 generatoren
pgmin1 = 100
pgmin2 = 10
pgmin3 = 10
pgmax1 = 220
pgmax2 = 100
pgmax3 = 220

S = 36.6 #MJ/m³

eload = 256

e3 = 0.2*eload
e4 = 0.4*eload
e5 = 0.4*eload

#max power through a powerline
plmax1 = 200
plmax = 100

omzet = 4.11 #kcf/psig = 4.11 m3/kpa
#maximal flow through pipeline
C12 = 50.6*omzet 
C24 = 50.1*omzet
C25 = 37.5*omzet
C53 = 43.5*omzet
C56 = 45.3*omzet

omzet2 = 0.007876 #kcf/h = 0.007876 m3/s
#gas levering in bronnen
gmin4 = 1500*omzet2
gmin6 = 2000*omzet2
gmax4 = 5000*omzet2
gmax6 = 6000*omzet2

price = 1

omzet3 = 6.89476 #psig = 6.89476 kPa
#minimal and maximal pressures
pmin1 = 105*omzet3
pmin2 = 120*omzet3
pmin3 = 125*omzet3
pmin4 = 136*omzet3
pmin5 = 140*omzet3
pmin6 = 155*omzet3
pmax1 = 110*omzet3
pmax2 = 135*omzet3
pmax3 = 140*omzet3
pmax4 = 155*omzet3
pmax5 = 155*omzet3
pmax6 = 175*omzet3

g2 = 3000*omzet2
g3 = 1500*omzet2

#furnace
furmin = 0
furmax2 = 1200*omzet2
furmax3 = 600*omzet2
eff_f = 0.95

#heat load
h2 = 340.9455
h6 = 169.2664

eff_CHP_h = 0.25 #https://archive.ipcc.ch/publications_and_data/ar4/wg3/en/ch4s4-3-5.html
eff_CHP_e = 0.4

@variable(model, S_fur2)
@variable(model, S_chp2)
@variable(model, S_fur3)
@variable(model, S_chp3)
@variable(model, G1)
@variable(model, Gas4)
@variable(model, Gas6)
@variable(model, f12)
@variable(model, f24)
@variable(model, f25)
@variable(model, f56)
@variable(model, f53)
@variable(model, p1)
@variable(model, p2)
@variable(model, p3)
@variable(model, p4)
@variable(model, p5)
@variable(model, p6)
@variable(model, pl12)
@variable(model, pl14)
@variable(model, pl24)
@variable(model, pl45)
@variable(model, pl56)
@variable(model, pl36)
@variable(model, pl23)

@objective(model, Min, G1+price*(Gas4+Gas6))

@constraint(model, h2 == eff_f*S_fur2*S + eff_CHP_h*S_chp2)
@constraint(model, h6 == eff_f*S_fur3*S + eff_CHP_h*S_chp3)
@constraint(model, f12 == 0)
@constraint(model, f12==f24+f25+g2+S_fur2+S_chp2)
@constraint(model, f53==g3+S_chp3+S_fur3)
@constraint(model, f24+Gas4==0)
@constraint(model, f25+f53==f56)
@constraint(model, f56+Gas6==0)
@constraint(model, G1 == pl14+pl12)
@constraint(model, pl12==pl24+pl23+eff_CHP_e*S_chp2*S)
@constraint(model, pl23+pl36==e3)
@constraint(model, pl14+pl24==e4+pl45)
@constraint(model, pl45==e5+pl56)
@constraint(model, pl56+eff_CHP_e*S_chp3*S==pl36)


@constraint(model,pgmin1<=G1<=pgmax1)
@constraint(model,pgmin2<=eff_CHP_e*S_chp2*S<=pgmax2)
@constraint(model,pgmin3<=eff_CHP_e*S_chp3*S<=pgmax3)

@constraint(model,-plmax1<=pl12<=plmax1)
@constraint(model,-plmax<=pl14<=plmax)
@constraint(model,-plmax<=pl24<=plmax)
@constraint(model,-plmax<=pl23<=plmax)
@constraint(model,-plmax<=pl45<=plmax)
@constraint(model,-plmax<=pl56<=plmax)
@constraint(model,-plmax<=pl36<=plmax)

@constraint(model,gmin4<=Gas4<=gmax4)
@constraint(model,gmin6<=Gas6<=gmax6)

@constraint(model,pmin1<=p1<=pmax1)
@constraint(model,pmin2<=p2<=pmax2)
@constraint(model,pmin3<=p3<=pmax3)
@constraint(model,pmin4<=p4<=pmax4)
@constraint(model,pmin5<=p5<=pmax5)
@constraint(model,pmin6<=p6<=pmax6)

@constraint(model,furmin<=S_fur2*eff_f<=furmax2)
@constraint(model,furmin<=S_fur3*eff_f<=furmax3)

@constraint(model, f12==C12*(p1-p2))
@constraint(model, f24==C24*(p2-p4))
@constraint(model, f25==C25*(p2-p5))
@constraint(model, f56==C56*(p5-p6))
@constraint(model, f53==C53*(p5-p3))


println("HELP")

optimize!(model)
println(termination_status(model))

println(objective_value(model))
