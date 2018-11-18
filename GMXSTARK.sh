####################################################################################################################################################################### 
#GMXSTARK is a Gromacs input file maker.
# The entire code is written in Bourne Shell.
# Copyright (c) 2018 [Rohit Mishra and Elvis Martis]
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "GMXSTARK"), to deal
# in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# All bug reports and suggestions can be sent to elvis.martis@bcp.edu.in with subject line "GMXSTARK v1.0 bug report"
# If the use of this script results in a publication, kindly acknowledge the use for the sake promotion of this code
# Acknowledgement may be written as "The Authors acknowledge the use of "GMXSTARK" for generating the input files"
#####################################################################################################################################################################
#!/bin/bash -w
######################
# Create Directories #
######################
### Protein Directory ###
echo -e "Enter the directory containing prot.gro, lig.gro, lig.itp [.gro]: "
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" prep_folder
		if [ -e "$prep_folder" ]
		then		

			cd "$prep_folder"
			rm -f *.txt
			printf '%s\n' */ > prot_pdb.txt

			prot_filename="$prep_folder/prot_pdb.txt"
			prot_pdb=()
				while read line2
					do
						prot_pdb+=("$line2")
					done < $prot_filename

			plen=${#prot_pdb[@]}

			for (( i=0; i<${plen}; i++ ))
			do
				cd "$prep_folder/${prot_pdb[$i]}"
			count_pdb=$(ls -1 *.pdb | wc -l)
			pdb_file=$(ls -1 *.pdb)
			count_gro=$(ls -1 *.gro | wc -l)
			gro_file=$(ls -1 *.gro)
			count_itp=$(ls -1 *.itp | wc -l)
			itp_file=$(ls -1 *.itp)
			count_mdp=$(ls -1 *.mdp | wc -l)
			mdp_file=$(ls -1 *.mdp)
			if [[ "$count_pdb" == "1" && "$count_gro" == "1" && "$count_itp" == "1" ]]
			then
				echo -e "$count_pdb pdb file found $pdb_file"
				echo -e "$count_gro gro file found $gro_file"
				echo -e "$count_itp itp file found $itp_file"
					if [[ "$count_mdp" == "4" || "$count_mdp" == "5" ]]
					then
						echo -e "$count_mdp mdp files are found"
						echo -e "Please enter "no" when asked for \"MDP files for simulation\""
					break
					fi
				break
			else
				echo -e "Error: .pdb .itp .gro files not found in the entered directory. \nPlease enter the directory which contains all the three files"
				exit
			fi
			done
		break
		else
			echo -e "Error: Directory is empty. Please type again"
			i=`expr $i + 1`
		fi
	done


################# To remove this directory if it exists################
	if [ -e $prep_folder/SIMULATION ]
		then
			echo "Error: $prep_folder/SIMULATION already exists please remove that directory"
			exit
	fi

clear
###################
# GROMACS DETAILS #
###################
# CHECKS GROMACS VERSION

echo -e "Gromacs version 5 or above [yes or no]:"
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" gmxv
		if [ "$gmxv" == "yes" ]
		then		
			gmx="gmx"
			solvate="solvate"
		break
		elif [ "$gmxv" == "no" ]
		then
			gmx=""
			solvate=genbox
		break
		else
			echo -e "Error: Please enter yes or no"
			i=`expr $i + 1`
		fi
	done
echo "\n"
##################################
#   PROTEIN LIGAND SIMULATION	 #
##################################

######################################################################
# PROTEIN SIMULATION OR PROTEIN LIGAND COMPLEX SIMULATION

echo -e "Protein Ligand Simulation: 
yes :to perform protein ligand simulation
no  :to perform only protein simulation  "
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" plcs
		if [ "$plcs" == "yes" ]
		then		
			echo -e "You have selected to perform the protein ligand simulation\n"		
			echo -e "Would you like to restrain ligand position [yes or no]: "
	while [ "$i" -ge 0 ]
	do				
			read -ep ">>>" dl
			if [[ "$dl" == "yes" ]]	
			then
				ligpr="-DPOSRES_LIG"
				break
			elif [[ "$dl" ==  "no" ]]
			then
				ligpr=""
				break
			else
				echo -e "Error: Please enter yes or no"
				i=`expr $i + 1`
			fi
	done
		break
		elif [ "$plcs" == "no" ]
		then
			echo -e "You have selected to perform only protein simulation"
			break
		else
			echo -e "Error: Please enter yes or no"
			i=`expr $i + 1`
		fi
	done

clear
################################# 
# Conjugate Gradient Integrator #
#################################

#############################################################################
# CG-INTEGRATOR

echo -e "Include Conjugate Gradient integrator after Steepest Descent [yes or no]:"
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" cgintegrator
		if [ "$cgintegrator" == "yes" ]
		then		
			echo -e "Number of steps to perform cg: "
			echo -e "Note: cg steps should be less than steepest descent "
			while [ "$i" -ge 0 ]
				do
					read -ep ">>>" stepscg
					if [[ "$stepscg" == "" || "$stepscg" =~ ^[a-zA-Z]*$ ]]
					then
						echo -e "Error: Please enter yes or no"
						i=`expr $i + 1`
					else
						echo $stepscg
						echo -e "Number of steps to perform Conjugate Gradient followed by Steepest Descent [nstcgsteep]: "
							while [ "$i" -ge 0 ]
								do
								read -ep ">>>" nstcgsteep
									if [[ "$nstcgsteep" == "" || "$nstcgsteep" =~ ^[a-zA-Z]*$ ]]
									then
										echo -e "Error: Please enter yes or no"
										i=`expr $i + 1`
									else
										echo $nstcgsteep
										break
									fi
								done
						break
					fi
				done
		break
		elif [ "$cgintegrator" == "no" ]
		then
			echo -e "You will run Minimization without Conjugate Gradient"
		break
		else
			echo -e "Error: Please enter yes or no"
			i=`expr $i + 1`
		fi
	done

clear
################# 
# MDP Directory #
#################

echo -e "MDP files for simulation [yes or no]: 
yes : to create default mdp files
no  : to use your own mdp files"
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" gromp
		if [ "$gromp" == "yes" ]
		then
			echo -e "You have selected to create default mdp files"
			echo -e "Enter the number of steps for mdp file to run the minimizaion [ 50000 = 100ps ]"
			echo -e "This steps are not used for production." 
			while [ "$i" -ge 0 ]
				do
					read -ep ">>>" steps
					if [[ "$steps" =~ ^[a-zA-Z]*$ || "$steps" == "" ]]
					then
						echo -e "Error: empty return. Please type integer value"
						i=`expr $i + 1`
					else
						echo $steps
						break
					fi
				done
		break
		elif [ "$gromp" == "no" ]
		then
			echo -e "You have selected to use your custom mdp files"
			echo -e "Please make sure you have placed all the mdp files named as:
ions.mdp
em_real.mdp
em_real_cg.mdp (only if you want to use cg as a integrator)
nvt.mdp
npt.mdp
md.mdp"
		break
		else
			echo -e "Error: empty return.Please type again"
			i=`expr $i + 1`
		fi
	done

######################################################################
# MDSTEPS 

echo -e "Enter number of of steps to be used for production i.e. md  [ 500000 = 1000 ps = 1 ns ]: "
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" mdsteps
		if [[ "$mdsteps" == "" || "$mdsteps" =~ ^[a-zA-Z]*$ ]]
		then		
			echo -e "Error: Please enter integer value based on your steps to run"
			i=`expr $i + 1`
		else
			echo $mdsteps
			break
		fi
	done

clear
############################################################
#  PREPARATION, ENERGY MINIMIZATION, PRODUCTION  DETAILS   #
############################################################
# Options to choose steps to perform Molecular simulation

echo -e "Select to run the steps: 
Enter 0 To run the complete simulation
Enter 1 To run till Preparation steps
Enter 2 to run till energy minimization
Enter 3 to eliminate the production step"
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" pro
		if [[ "$pro" == "0" ]]
		then		
			pre="preparation"
			em="energy_minimization"
			epro="eliminate_production"
			cpro="complete_production"
			break
		elif [[ "$pro" == "1" ]]
		then		
			pre="preparation"
			break
		elif [[ "$pro" == "2" ]]
		then		
			pre="preparation"
			em="energy_minimization"
			break
		elif [[ "$pro" == "3" ]]
		then		
			pre="preparation"
			em="energy_minimization"
			epro="eliminate_production"
			break
		else
			echo -e "Error: Please enter 0, 1, 2, 3"
			i=`expr $i + 1`
		fi
	done

clear
###################
# PROTEIN DETAILS #
###################

# IGNORE HYDROGENS OR NOT

echo -e "Ignore HYDROGENS (-ignh) [yes or no]:"
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" ih
		if [ "$ih" == "yes" ]
		then		
			ignore="-ignh"
		break
		elif [ "$ih" == "no" ]
		then
			ignore=""
		break
		else
			echo -e "Error: Please enter yes or no"
			i=`expr $i + 1`
		fi
	done

######################################################################
# WATER MODEL FOR SOLVATION

echo -e "Water model to be used for solvation [spce, tip3p, tip4p, spc, none or tips3p]: "
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" wat
		if [[ "$wat" == "spce" || "$wat" == "tip3p" || "$wat" == "tip4p" || "$wat" == "spc" || "$wat" == "tips3p" || "$wat" == "none" ]] 
		then		
			echo $wat
		break
		else
			echo -e "Error: Please enter spce, tip3p, tip4p, spc, none or tips3p"
			i=`expr $i + 1`
		fi
	done

clear
######################################################################
# FORCE-FIELD FOR PROTEIN

echo -e "Enter the forcefield [ENTER 1-16]: "
echo -e "
 1: AMBER03 protein, nucleic AMBER94 (Duan et al., J. Comp. Chem. 24, 1999-2012, 2003)
 2: AMBER94 force field (Cornell et al., JACS 117, 5179-5197, 1995)
 3: AMBER96 protein, nucleic AMBER94 (Kollman et al., Acc. Chem. Res. 29, 461-469, 1996)
 4: AMBER99 protein, nucleic AMBER94 (Wang et al., J. Comp. Chem. 21, 1049-1074, 2000)
 5: AMBER99SB protein, nucleic AMBER94 (Hornak et al., Proteins 65, 712-725, 2006)
 6: AMBER99SB-ILDN protein, nucleic AMBER94 (Lindorff-Larsen et al., Proteins 78, 1950-58, 2010)
 7: AMBERGS force field (Garcia & Sanbonmatsu, PNAS 99, 2782-2787, 2002)
 8: CHARMM27 all-atom force field (CHARM22 plus CMAP for proteins)
 9: GROMOS96 43a1 force field
10: GROMOS96 43a2 force field (improved alkane dihedrals)
11: GROMOS96 45a3 force field (Schuler JCC 2001 22 1205)
12: GROMOS96 53a5 force field (JCC 2004 vol 25 pag 1656)
13: GROMOS96 53a6 force field (JCC 2004 vol 25 pag 1656)
14: GROMOS96 54a7 force field (Eur. Biophys. J. (2011), 40,, 843-856, DOI: 10.1007/s00249-011-0700-9)
15: OPLS-AA/L all-atom force field (2001 aminoacid dihedrals)"
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" ff
		if [[ "$ff" -ge 1 && "$ff" -le 15 ]]
		then		
			echo $ff
		break
		else
			echo -e "Error: Please enter 1-16 for forcefield"
			i=`expr $i + 1`
		fi
	done
clear

######################################################################
# GROMACS BOX SIZE AND TYPE OF EDITCONF

echo -e "Gromacs box size and type"
echo -e "Enter the solvent shell [in decimals nm (for example 1.0 nm or 10 angstrom)] : "
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" dim
		if [[ "$dim" =~ ^[0-9][.][0-9]*$ ]]
		then		
			echo $dim
		break
		elif [[ "$dim" =~ ^[0-9]*$ ]]
		then
			echo $dim		
		break
		else
			echo -e "Error: Please enter integer or float value [ 1.0, 10 ] "
			i=`expr $i + 1`
		fi
	done

echo -e "Enter the box type [cubic or triclinic or dodecahedron or octahedron]: "
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" bxty
		if [[ "$bxty" == "triclinic" || "$bxty" == "dodecahedron" || "$bxty" == "octahedron" || "$bxty" == "cubic" ]]
		then		
			echo $bxty
		break
		else
			echo -e "Error: Please enter triclinic, dodecahedron, octahedron"
			i=`expr $i + 1`
		fi
	done

echo -e "Would you like to add conc of ions: 
yes: if you would like to add the conc
no : if you would like to automatically calculate and add the ions from qtot"
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" conc
		if [[ "$conc" == "yes" ]]
		then		
			echo -e "Enter the conc of ions [ 1.0, 10 ]: "
			read -ep ">>>" conions
			if [[ "$conions" == "" ]]
			then			
			echo -e "Error: Please enter conc of ions [ 1.0, 10 ]"
				i=`expr $i + 1`
			else
				echo $conions
				break
			fi	
			
		break
		elif [[ "$conc" == "no" ]]
		then
			echo "Concentration of ions will be added directly to the system"		
		break
		else
			echo -e "Error: Please enter yes or no"
			i=`expr $i + 1`
		fi
	done

clear

##################################
# ADDITIONAL CPU AND GPU OPTIONS #
##################################

######################################################################
# THREADS TO BE USED

echo -e "Enter number of threads to be used [1cpu = 1, 4cpu = 4]: "
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" nt
		if [[ "$nt" == "" || "$nt" =~ ^[a-zA-Z]*$ ]]
		then		
			echo -e "Error: Please enter integer value based on your cpu configuration"
			i=`expr $i + 1`
		else
			echo $nt
			break
		fi
	done

######################################################################
# GPU OPTIONS

echo -e "Do you like to run your calculations on a GPU: 
Enter 0 if you do not have gpu
Enter 1 to use gpu for calculating non-bonded interaction
Enter * if you have multiple GPU and would like to use them"
	i=1
	while [ "$i" -ge 0 ]
	do
		read -ep ">>>" gp
		if [[ "$gp" == "0" ]]
		then		
			gpu=""
			break
		fi

		if [[ "$gp" == "1" ]]
		then		
			echo -e "What would you like to use for calculating non-bonded interaction [auto, gpu, cpu or cpu_gpu] "
			read -ep ">>>" nb
			if [[ "$nb" == "auto" || "$nb" == "gpu" || "$nb" == "cpu" || "$nb" == "cpu_gpu" ]]
			then
				gpu="-nb $nb"
				break
			else
				echo -e "Error: Please enter gpu, cpu, auto, cpu_gpu"
				i=`expr $i + 1`
			fi
		
		elif [[ "$gp" == "*" ]]
		then
			echo -e "Enter the gpu_id"
			read -ep ">>>" gp_id
			if [[ "$gp_id" ==  "" ]]	
			then		
				echo -e "Error: Please enter gpu, cpu, auto, cpu_gpu"
				i=`expr $i + 1`
			else
				gpu="-gpu_id $gp_id"
				break
			fi
		else
			echo -e "Error: Please enter 0, 1, *"
			i=`expr $i + 1`
		fi
	done

clear
######################################################################

###################
# Preparing Files #
###################


for (( i=0; i<${plen}; i++ ))
do
	cd "$prep_folder/${prot_pdb[$i]}"
	mkdir $prep_folder/SIMULATION 2>/dev/null
	cp -r -v $prep_folder/${prot_pdb[$i]} $prep_folder/SIMULATION 2>/dev/null
done

for (( i=0; i<${plen}; i++ ))
do
	cd "$prep_folder/SIMULATION/${prot_pdb[$i]}"
	prot_ex=$(ls -1 | grep *.pdb)
	lig_ex=$(ls -1 | grep *.gro)
	lig_itp=$(ls -1 | grep *.itp)
#####################################################################
		pchain=$(grep -E "TER" ${prot_ex%%.*}.pdb | wc -l)
		echo $pchain
######################## Create DEFAULT MDP FILES ##########################		
		if [ "$gromp" == "yes" ] && [ "$plcs" == "yes" ]
		then
#############################CG Integrator###########################
if [ "$cgintegrator" == "yes" ]
then
cat > em_real_cg.mdp << EOF5
; LINES STARTING WITH ';' ARE COMMENTS
title		= Minimization		; Title of run

; Parameters describing what to do, when to stop and what to save
integrator	= cg	; Algorithm (steep = steepest descent minimization)
emtol		= 1000.0  		; Stop minimization when the maximum force < 10.0 kJ/mol
emstep      	= 0.01      		; Energy step size
nsteps		= ${stepscg}	  	; Maximum number of (minimization) steps to perform
nstcgsteep	= ${nstcgsteep}
energygrps	= Protein ${lig_ex%%.*}	; Which energy group(s) to write to disk

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist		= 1		; Frequency to update the neighbor list and long range forces
cutoff-scheme   = Verlet
ns_type		= grid		; Method to determine neighbor list (simple, grid)
rlist		= 1.2		; Cut-off for making neighbor list (short range forces)
coulombtype	= PME		; Treatment of long range electrostatic interactions
rcoulomb	= 1.2		; long range electrostatic cut-off
vdwtype         = cutoff
vdw-modifier    = force-switch
rvdw-switch     = 1.0
rvdw		= 1.2		; long range Van der Waals cut-off
pbc		= xyz 		; Periodic Boundary Conditions
DispCorr        = no
EOF5
fi
#############################CG Integrator###########################

cat > ions.mdp << EOF1
; LINES STARTING WITH ';' ARE COMMENTS
title			= Minimization	; Title of run

; Parameters describing what to do, when to stop and what to save
integrator		= steep		; Algorithm (steep = steepest descent minimization)
emtol			= 1000.0  	; Stop minimization when the maximum force < 10.0 kJ/mol
emstep      		= 0.01      	; Energy step size
nsteps			= ${steps}	; Maximum number of (minimization) steps to perform
energygrps		= system	; Which energy group(s) to write to disk

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist		    	= 1		; Frequency to update the neighbor list and long range forces
cutoff-scheme   	= Verlet
ns_type		    	= grid		; Method to determine neighbor list (simple, grid)
rlist		    	= 1.0		; Cut-off for making neighbor list (short range forces)
coulombtype	    	= cutoff	; Treatment of long range electrostatic interactions
rcoulomb	    	= 1.0		; long range electrostatic cut-off
rvdw			= 1.0		; long range Van der Waals cut-off
pbc             	= xyz 		; Periodic Boundary Conditions
EOF1
		
cat > em_real.mdp << EOF2
; LINES STARTING WITH ';' ARE COMMENTS
title		= Minimization		; Title of run

; Parameters describing what to do, when to stop and what to save
integrator	= steep			; Algorithm (steep = steepest descent minimization)
emtol		= 1000.0  		; Stop minimization when the maximum force < 10.0 kJ/mol
emstep      	= 0.01      		; Energy step size
nsteps		= ${steps}	  	; Maximum number of (minimization) steps to perform
energygrps	= Protein ${lig_ex%%.*}	; Which energy group(s) to write to disk

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist		= 1		; Frequency to update the neighbor list and long range forces
cutoff-scheme   = Verlet
ns_type		= grid		; Method to determine neighbor list (simple, grid)
rlist		= 1.2		; Cut-off for making neighbor list (short range forces)
coulombtype	= PME		; Treatment of long range electrostatic interactions
rcoulomb	= 1.2		; long range electrostatic cut-off
vdwtype         = cutoff
vdw-modifier    = force-switch
rvdw-switch     = 1.0
rvdw		= 1.2		; long range Van der Waals cut-off
pbc		= xyz 		; Periodic Boundary Conditions
DispCorr        = no
EOF2

cat > nvt.mdp << EOF3
title                   = Protein-ligand complex NVT equilibration 
define                  = -DPOSRES ${ligpr}  ; position restrain the protein and ligand
; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = $steps    ; 2 * 50000 = 100 ps
dt                      = 0.002     ; 2 fs
; Output control
nstenergy               = 500   ; save energies every 1.0 ps
nstlog                  = 500  ; update log file every 1.0 ps
nstxout-compressed      = 500  ; save coordinates every 1.0 ps
energygrps		= Protein ${lig_ex%%.*}
; Bond parameters
continuation            = no        ; first dynamics run
constraint_algorithm    = lincs     ; holonomic constraints 
constraints             = h-bonds   ; bonds to H are constrained 
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Neighbor searching and vdW
cutoff-scheme           = Verlet
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 20        ; largely irrelevant with Verlet
rlist                   = 1.2
vdwtype                 = cutoff
vdw-modifier            = force-switch
rvdw-switch             = 1.0
rvdw                    = 1.2       ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
rcoulomb                = 1.2       ; short-range electrostatic cutoff (in nm)
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling
tcoupl                  = V-rescale                     ; modified Berendsen thermostat
tc-grps                 = Protein_${lig_ex%%.*} Water_and_ions    ; two coupling groups - more accurate
tau_t                   = 0.1   0.1                     ; time constant, in ps
ref_t                   = 300   300                     ; reference temperature, one for each group, in K
; Pressure coupling
pcoupl                  = no        ; no pressure coupling in NVT
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Dispersion correction is not used for proteins with the C36 additive FF
DispCorr                = no 
; Velocity generation
gen_vel                 = yes       ; assign velocities from Maxwell distribution
gen_temp                = 300       ; temperature for Maxwell distribution
gen_seed                = -1        ; generate a random seed
EOF3

cat > npt.mdp << EOF4
title                   = Protein-ligand complex NPT equilibration 
define                  = -DPOSRES ${ligpr}  ; position restrain the protein and ligand
; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = $steps    ; 2 * 50000 = 100 ps
dt                      = 0.002     ; 2 fs
; Output control
nstenergy               = 500       ; save energies every 1.0 ps
nstlog                  = 500       ; update log file every 1.0 ps
nstxout-compressed      = 500       ; save coordinates every 1.0 ps
nstvout     		= 500       ; save velocities every 1.0 ps
energygrps  		= Protein ${lig_ex%%.*}
; Bond parameters
continuation            = yes       ; continuing from NVT 
constraint_algorithm    = lincs     ; holonomic constraints 
constraints             = h-bonds   ; bonds to H are constrained 
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Neighbor searching and vdW
cutoff-scheme           = Verlet
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 20        ; largely irrelevant with Verlet
rlist                   = 1.2
vdwtype                 = cutoff
vdw-modifier            = force-switch
rvdw-switch             = 1.0
rvdw                    = 1.2       ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
rcoulomb                = 1.2
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling
tcoupl                  = V-rescale                     ; modified Berendsen thermostat
tc-grps                 = Protein_${lig_ex%%.*} Water_and_ions    ; two coupling groups - more accurate
tau_t                   = 0.1   0.1                     ; time constant, in ps
ref_t                   = 300   300                     ; reference temperature, one for each group, in K
; Pressure coupling
pcoupl                  = Berendsen                     ; pressure coupling is on for NPT
pcoupltype              = isotropic                     ; uniform scaling of box vectors
tau_p                   = 2.0                           ; time constant, in ps
ref_p                   = 1.0                           ; reference pressure, in bar
compressibility         = 4.5e-5                        ; isothermal compressibility of water, bar^-1
refcoord_scaling        = com
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Dispersion correction is not used for proteins with the C36 additive FF
DispCorr                = no 
; Velocity generation
gen_vel                 = no        ; velocity generation off after NVT 
EOF4

	if [ "$cpro" == "complete_production" ]
	then
cat > md.mdp << EOF5
title                   = Protein-ligand complex MD simulation 
; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = 50    ; 2 * 500000 = 1000 ps (1 ns)
dt                      = 0.002     ; 2 fs
; Output control
nstenergy               = 5000      ; save energies every 10.0 ps
nstlog                  = 5000      ; update log file every 10.0 ps
nstxout-compressed      = 5000      ; save coordinates every 10.0 ps
compressed-x-grps	= System
energygrps		= Protein ${lig_ex%%.*}
; Bond parameters
continuation            = yes       ; continuing from NPT 
constraint_algorithm    = lincs     ; holonomic constraints 
constraints             = h-bonds   ; bonds to H are constrained
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Neighbor searching and vdW
cutoff-scheme           = Verlet
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 20        ; largely irrelevant with Verlet
rlist                   = 1.2
vdwtype                 = cutoff
vdw-modifier            = force-switch
rvdw-switch             = 1.0
rvdw                    = 1.2       ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
rcoulomb                = 1.2
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling
tcoupl                  = V-rescale                     ; modified Berendsen thermostat
tc-grps                 = Protein_${lig_ex%%.*} Water_and_ions    ; two coupling groups - more accurate
tau_t                   = 0.1   0.1                     ; time constant, in ps
ref_t                   = 310   310                     ; reference temperature, one for each group, in K
; Pressure coupling 
pcoupl                  = Parrinello-Rahman             ; pressure coupling is on for NPT
pcoupltype              = isotropic                     ; uniform scaling of box vectors
tau_p                   = 2.0                           ; time constant, in ps
ref_p                   = 1.0                           ; reference pressure, in bar
compressibility         = 4.5e-5                        ; isothermal compressibility of water, bar^-1
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Dispersion correction is not used for proteins with the C36 additive FF
DispCorr                = no 
; Velocity generation
gen_vel                 = no        ; continuing from NPT equilibration 
EOF5
fi
############################################################################

			elif [ "$gromp" == "yes" ] && [ "$plcs" == "no" ]
			then
if [ "$cgintegrator" == "yes" ]
then
cat > em_real_cg.mdp << EOF5
; LINES STARTING WITH ';' ARE COMMENTS
title		= Minimization		; Title of run

; Parameters describing what to do, when to stop and what to save
integrator	= cg	; Algorithm (steep = steepest descent minimization)
emtol		= 1000.0  		; Stop minimization when the maximum force < 10.0 kJ/mol
emstep      	= 0.01      		; Energy step size
nsteps		= ${stepscg}	  	; Maximum number of (minimization) steps to perform
nstcgsteep	= ${nstcgsteep}
energygrps	= Protein	; Which energy group(s) to write to disk

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist		= 1		; Frequency to update the neighbor list and long range forces
cutoff-scheme   = Verlet
ns_type		= grid		; Method to determine neighbor list (simple, grid)
rlist		= 1.2		; Cut-off for making neighbor list (short range forces)
coulombtype	= PME		; Treatment of long range electrostatic interactions
rcoulomb	= 1.2		; long range electrostatic cut-off
vdwtype         = cutoff
vdw-modifier    = force-switch
rvdw-switch     = 1.0
rvdw		= 1.2		; long range Van der Waals cut-off
pbc		= xyz 		; Periodic Boundary Conditions
DispCorr        = no
EOF5
fi
#############################CG Integrator###########################
cat > ions.mdp << EOF1
; ions.mdp - used as input into grompp to generate ions.tpr
; Parameters describing what to do, when to stop and what to save
integrator  = steep         ; Algorithm (steep = steepest descent minimization)
emtol       = 1000.0        ; Stop minimization when the maximum force < 1000.0 kJ/mol/nm
emstep      = 0.01          ; Minimization step size
nsteps      = ${steps}         ; Maximum number of (minimization) steps to perform

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist         = 1         ; Frequency to update the neighbor list and long range forces
cutoff-scheme	= Verlet    ; Buffered neighbor searching 
ns_type         = grid      ; Method to determine neighbor list (simple, grid)
coulombtype     = cutoff    ; Treatment of long range electrostatic interactions
rcoulomb        = 1.0       ; Short-range electrostatic cut-off
rvdw            = 1.0       ; Short-range Van der Waals cut-off
pbc             = xyz       ; Periodic Boundary Conditions in all 3 dimensions
EOF1

cat > em_real.mdp << EOF2
; minim.mdp - used as input into grompp to generate em.tpr
; Parameters describing what to do, when to stop and what to save
integrator  = steep         ; Algorithm (steep = steepest descent minimization)
emtol       = 1000.0        ; Stop minimization when the maximum force < 1000.0 kJ/mol/nm
emstep      = 0.01          ; Minimization step size
nsteps      = ${steps}         ; Maximum number of (minimization) steps to perform

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist         = 1         ; Frequency to update the neighbor list and long range forces
cutoff-scheme   = Verlet    ; Buffered neighbor searching
ns_type         = grid      ; Method to determine neighbor list (simple, grid)
coulombtype     = PME       ; Treatment of long range electrostatic interactions
rcoulomb        = 1.0       ; Short-range electrostatic cut-off
rvdw            = 1.0       ; Short-range Van der Waals cut-off
pbc             = xyz       ; Periodic Boundary Conditions in all 3 dimensions
EOF2

cat > nvt.mdp << EOF3
title                   = OPLS Lysozyme NVT equilibration 
define                  = -DPOSRES  ; position restrain the protein
; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = ${steps}     ; 2 * 50000 = 100 ps
dt                      = 0.002     ; 2 fs
; Output control
nstxout                 = 500       ; save coordinates every 1.0 ps
nstvout                 = 500       ; save velocities every 1.0 ps
nstenergy               = 500       ; save energies every 1.0 ps
nstlog                  = 500       ; update log file every 1.0 ps
; Bond parameters
continuation            = no        ; first dynamics run
constraint_algorithm    = lincs     ; holonomic constraints 
constraints             = h-bonds   ; bonds involving H are constrained
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Nonbonded settings 
cutoff-scheme           = Verlet    ; Buffered neighbor searching
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 10        ; 20 fs, largely irrelevant with Verlet
rcoulomb                = 1.0       ; short-range electrostatic cutoff (in nm)
rvdw                    = 1.0       ; short-range van der Waals cutoff (in nm)
DispCorr                = EnerPres  ; account for cut-off vdW scheme
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling is on
tcoupl                  = V-rescale             ; modified Berendsen thermostat
tc-grps                 = Protein Non-Protein   ; two coupling groups - more accurate
tau_t                   = 0.1     0.1           ; time constant, in ps
ref_t                   = 300     300           ; reference temperature, one for each group, in K
; Pressure coupling is off
pcoupl                  = no        ; no pressure coupling in NVT
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Velocity generation
gen_vel                 = yes       ; assign velocities from Maxwell distribution
gen_temp                = 300       ; temperature for Maxwell distribution
gen_seed                = -1        ; generate a random seed
EOF3

cat > npt.mdp << EOF4
title                   = OPLS Lysozyme NPT equilibration 
define                  = -DPOSRES  ; position restrain the protein
; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = ${steps}     ; 2 * 50000 = 100 ps
dt                      = 0.002     ; 2 fs
; Output control
nstxout                 = 500       ; save coordinates every 1.0 ps
nstvout                 = 500       ; save velocities every 1.0 ps
nstenergy               = 500       ; save energies every 1.0 ps
nstlog                  = 500       ; update log file every 1.0 ps
; Bond parameters
continuation            = yes       ; Restarting after NVT 
constraint_algorithm    = lincs     ; holonomic constraints 
constraints             = h-bonds   ; bonds involving H are constrained
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Nonbonded settings 
cutoff-scheme           = Verlet    ; Buffered neighbor searching
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 10        ; 20 fs, largely irrelevant with Verlet scheme
rcoulomb                = 1.0       ; short-range electrostatic cutoff (in nm)
rvdw                    = 1.0       ; short-range van der Waals cutoff (in nm)
DispCorr                = EnerPres  ; account for cut-off vdW scheme
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling is on
tcoupl                  = V-rescale             ; modified Berendsen thermostat
tc-grps                 = Protein Non-Protein   ; two coupling groups - more accurate
tau_t                   = 0.1     0.1           ; time constant, in ps
ref_t                   = 300     300           ; reference temperature, one for each group, in K
; Pressure coupling is on
pcoupl                  = Parrinello-Rahman     ; Pressure coupling on in NPT
pcoupltype              = isotropic             ; uniform scaling of box vectors
tau_p                   = 2.0                   ; time constant, in ps
ref_p                   = 1.0                   ; reference pressure, in bar
compressibility         = 4.5e-5                ; isothermal compressibility of water, bar^-1
refcoord_scaling        = com
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Velocity generation
gen_vel                 = no        ; Velocity generation is off 
EOF4

	if [ "$cpro" == "complete_production" ]
	then

cat > md.mdp << EOF5
title                   = OPLS Lysozyme NPT equilibration 
; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = 50    ; 2 * 500000 = 1000 ps (1 ns)
dt                      = 0.002     ; 2 fs
; Output control
nstxout                 = 0         ; suppress bulky .trr file by specifying 
nstvout                 = 0         ; 0 for output frequency of nstxout,
nstfout                 = 0         ; nstvout, and nstfout
nstenergy               = 5000      ; save energies every 10.0 ps
nstlog                  = 5000      ; update log file every 10.0 ps
nstxout-compressed      = 5000      ; save compressed coordinates every 10.0 ps
compressed-x-grps       = System    ; save the whole system
; Bond parameters
continuation            = yes       ; Restarting after NPT 
constraint_algorithm    = lincs     ; holonomic constraints 
constraints             = h-bonds   ; bonds involving H are constrained
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Neighborsearching
cutoff-scheme           = Verlet    ; Buffered neighbor searching
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 10        ; 20 fs, largely irrelevant with Verlet scheme
rcoulomb                = 1.0       ; short-range electrostatic cutoff (in nm)
rvdw                    = 1.0       ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling is on
tcoupl                  = V-rescale             ; modified Berendsen thermostat
tc-grps                 = Protein Non-Protein   ; two coupling groups - more accurate
tau_t                   = 0.1     0.1           ; time constant, in ps
ref_t                   = 300     300           ; reference temperature, one for each group, in K
; Pressure coupling is on
pcoupl                  = Parrinello-Rahman     ; Pressure coupling on in NPT
pcoupltype              = isotropic             ; uniform scaling of box vectors
tau_p                   = 2.0                   ; time constant, in ps
ref_p                   = 1.0                   ; reference pressure, in bar
compressibility         = 4.5e-5                ; isothermal compressibility of water, bar^-1
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Dispersion correction
DispCorr                = EnerPres  ; account for cut-off vdW scheme
; Velocity generation
gen_vel                 = no        ; Velocity generation is off 
EOF5
fi

			else
				echo -e "Please check the mdp files present in the directory"
			fi

############################################################################
# 			Generating Gromacs files		   	   #	
############################################################################
if [ "$pre" == "preparation" ]
then
echo -e "$ff" | $gmx pdb2gmx \
		$ignore \
	 	-f ${prot_ex%%.*}.pdb \
		-o ${prot_ex%%.*}_processed.gro \
		-water $wat

		if [ ! -e "${prot_ex%%.*}_processed.gro" ]
			then
				echo -e "Error: \n${prot_ex%%.*}_processed.gro file was not prepared using the command: \n\t\"$gmx pdb2gmx $ignore -f ${prot_ex%%.*}.pdb -o ${prot_ex%%.*}_processed.gro -water $wat\"" 
			exit
		fi
fi
############################################################################
# 		           Creating Complex GRO			   	   #	
############################################################################
if [ "$pre" == "preparation" ]
then

if [ "$plcs" == "yes" ]
then
	sed -i "/#include \".*.ff\/forcefield.itp\"/a ; Include ligand parameters\n#include \"${lig_itp%%.*}.itp\"" topol.top
	echo "${lig_ex%%.*}		    1" >> topol.top
	sed -i  '/^$/d' ${lig_ex%%.*}.gro
	head -n +1 ${prot_ex%%.*}_processed.gro > complex.gro
	var1=$(head -n +2 ${prot_ex%%.*}_processed.gro | tail -n -1)
	var2=$(head -n +2 ${lig_ex%%.*}.gro | tail -n -1)
	expr $var1 + $var2 >> complex.gro
	tail -n +3 ${prot_ex%%.*}_processed.gro | head -n -1 >> complex.gro
	tail -n +3 ${lig_ex%%.*}.gro| head -n -1 >> complex.gro
	tail -n -1 ${prot_ex%%.*}_processed.gro >> complex.gro

		if [[ ! -e "complex.gro" ]]
			then
			echo -e "Error: \n    complex.gro was not found" 
			exit
		fi

############################################################################
#	         Defining the gromacs box and type [ complex ]		   #	
############################################################################

	$gmx editconf \
	 -f complex.gro \
	 -o ${prot_ex%%.*}_newbox.gro \
	 -c \
	 -d $dim \
	 -bt $bxty

elif [ "$plcs" == "no" ]
then
############################################################################
#         Defining the gromacs box and type [ only protein ]		   #	
############################################################################

	$gmx editconf \
	 -f ${prot_ex%%.*}_processed.gro \
	 -o ${prot_ex%%.*}_newbox.gro \
	 -c \
	 -d $dim \
	 -bt $bxty 
else
	echo -e "Error: Error in creating complex.gro or Defining the box size and type"
fi

		if [[ ! -e "${prot_ex%%.*}_newbox.gro" ]]
			then
			echo -e "Error: \n    ${prot_ex%%.*}_newbox.gro file was not prepared using the command: \n\t\"$gmx editconf -f complex.gro -o ${prot_ex%%.*}_newbox.gro -c -d $dim -bt $bxty\"" 
			exit
		fi

############################################################################
#         			Solvating the protein		   	   #	
############################################################################

	$gmx $solvate \
	     -cp ${prot_ex%%.*}_newbox.gro \
	     -cs spc216.gro \
	     -o solv.gro \
	     -p topol.top

		if [[ ! -e "solv.gro" ]]
			then
			echo -e "Error: \n    solv.gro file was not prepared using the command: \n\t\"$gmx $solvate -cp ${prot_ex%%.*}_newbox.gro -cs spc216.gro -o solv.gro -p topol.top\"" 
			exit
		fi

############################################################################
#         		Creating Grompp using ions.mdp		   	   #	
############################################################################

	$gmx grompp\
	     -f ions.mdp \
		 -c solv.gro \
		 -p topol.top \
		 -o ions.tpr

		if [[ ! -e "ions.tpr" ]]
			then
			echo -e "Error: \n    ions.tpr file was not prepared using the command: \n\t\"$gmx grompp -f ions.mdp -c solv.gro -p topol.top -o ions.tpr \"" 
			exit
		fi

############################################################################
#         		Adding ions using Genion		   	   #	
############################################################################

possitive="-1"

if [ "$pchain" == "1" ] && [ "$plcs" == "yes" ]
then
	if [ "$conc" == "no" ]
	then
	top_charge=$(grep "qtot" topol.top | sed -n '${s/.* //; p}')
	sci_top_charge=$(printf "%.0f" "$top_charge")
	y=$(echo "$sci_top_charge*$possitive" | bc -l)
		if [ "$sci_top_charge" -lt "0" ]
		then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np $y \
				-nname CL \
				-nn 0
		else
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np 0 \
				-nname CL \
				-nn $sci_top_charge
		fi
	elif [ "$conc" == "yes" ]
	then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-neutral \
				-conc ${conions}
	else 
	echo "No conc added and no charges added"
	exit
	fi

#############################################################################

elif [ "$pchain" == "2" ] && [ "$plcs" == "yes" ]
then
	if [ "$conc" == "no" ]
	then
	one_charge=$(grep "qtot" topol_Protein_chain_A.itp | sed -n '${s/.* //; p}')
	two_charge=$(grep "qtot" topol_Protein_chain_B.itp | sed -n '${s/.* //; p}')
	sci_one_charge=$(printf "%.0f" "$one_charge")
	sci_two_charge=$(printf "%.0f" "$two_charge")
	charge=$(echo "$sci_one_charge+$sci_two_charge" | bc -l)
	z=$(echo "$charge*$possitive" | bc -l)
		if [ "$charge" -lt "0" ]
		then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np $z \
				-nname CL \
				-nn 0
		else
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np 0 \
				-nname CL \
				-nn $charge
		fi
	elif [ "$conc" == "yes" ]
	then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-neutral \
				-conc ${conions}
	else 
	echo "No conc added and no charges added"
	exit
	fi

#############################################################################

elif [ "$pchain" == "3" ] && [ "$plcs" == "yes" ]
then
	if [ "$conc" == "no" ]
	then
	one_charge=$(grep "qtot" topol_Protein_chain_A.itp | sed -n '${s/.* //; p}')
	two_charge=$(grep "qtot" topol_Protein_chain_B.itp | sed -n '${s/.* //; p}')
	three_charge=$(grep "qtot" topol_Protein_chain_C.itp | sed -n '${s/.* //; p}')
	sci_one_charge=$(printf "%.0f" "$one_charge")
	sci_two_charge=$(printf "%.0f" "$two_charge")
	sci_three_charge=$(printf "%.0f" "$three_charge")
	charge=$(echo "$sci_one_charge+$sci_two_charge+$sci_three_charge" | bc -l)
	z=$(echo "$charge*$possitive" | bc -l)
		if [ "$charge" -lt "0" ]
		then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np $z \
				-nname CL \
				-nn 0
		else
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np 0 \
				-nname CL \
				-nn $charge
		fi
	elif [ "$conc" == "yes" ]
	then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-neutral \
				-conc ${conions}
	else 
	echo "No conc added and no charges added"
	exit
	fi


#############################################################################

elif [ "$pchain" == "1" ] && [ "$plcs" == "no" ] 
then
	if [ "$conc" == "no" ] 
	then
	top_charge=$(grep "qtot" topol.top | sed -n '${s/.* //; p}')
	sci_top_charge=$(printf "%.0f" "$top_charge")
	y=$(echo "$sci_top_charge*$possitive" | bc -l)
		if [ "$sci_top_charge" -lt "0" ]
		then
		echo -e "13" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np $y \
				-nname CL \
				-nn 0
		else
		echo -e "13" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np 0 \
				-nname CL \
				-nn $sci_top_charge
		fi
	elif [ "$conc" == "yes" ]
	then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-neutral \
				-conc ${conions}
	else 
	echo "No conc added and no charges added"
	exit
	fi

#############################################################################

elif [ "$pchain" == "2" ] && [ "$plcs" == "no" ]
then
	if [ "$conc" == "no" ] 
	then
	one_charge=$(grep "qtot" topol_Protein_chain_A.itp | sed -n '${s/.* //; p}')
	two_charge=$(grep "qtot" topol_Protein_chain_B.itp | sed -n '${s/.* //; p}')
	sci_one_charge=$(printf "%.0f" "$one_charge")
	sci_two_charge=$(printf "%.0f" "$two_charge")
	charge=$(echo "$sci_one_charge+$sci_two_charge" | bc -l)
	z=$(echo "$charge*$possitive" | bc -l)
		if [ "$charge" -lt "0" ]
		then
		echo -e "13" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np $z \
				-nname CL \
				-nn 0
		else
		echo -e "13" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np 0 \
				-nname CL \
				-nn $charge
		fi
	elif [ "$conc" == "yes" ]
	then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-neutral \
				-conc ${conions}
	else 
	echo "No conc added and no charges added"
	exit
	fi

#############################################################################

elif [ "$pchain" == "3" ] && [ "$plcs" == "no" ]
then
	if [ "$conc" == "no" ] 
	then
	one_charge=$(grep "qtot" topol_Protein_chain_A.itp | sed -n '${s/.* //; p}')
	two_charge=$(grep "qtot" topol_Protein_chain_B.itp | sed -n '${s/.* //; p}')
	three_charge=$(grep "qtot" topol_Protein_chain_C.itp | sed -n '${s/.* //; p}')
	sci_one_charge=$(printf "%.0f" "$one_charge")
	sci_two_charge=$(printf "%.0f" "$two_charge")
	sci_three_charge=$(printf "%.0f" "$three_charge")
	charge=$(echo "$sci_one_charge+$sci_two_charge+$sci_three_charge" | bc -l)
	z=$(echo "$charge*$possitive" | bc -l)
		if [ "$charge" -lt "0" ]
		then
		echo -e "13" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np $z \
				-nname CL \
				-nn 0
		else
		echo -e "13" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-pname NA \
				-np 0 \
				-nname CL \
				-nn $charge
		fi
	elif [ "$conc" == "yes" ]
	then
		echo -e "15" | $gmx genion \
				-s ions.tpr \
				-o solv_ions.gro \
				-p topol.top \
				-neutral \
				-conc ${conions}
	else 
	echo "No conc added and no charges added"
	exit
	fi

else
echo "No ions to add"
fi


############################### Ends Preparation############################
fi 

		if [[ ! -e "solv_ions.gro" ]]
			then
			echo -e "Error: \n    solv_ions.gro file was not prepared using the command: \n\t\"$gmx genion -s ions.tpr -0 solv_ions.gro -p topol.top ...... \"" 
			exit
		fi

############################################################################
#			Performing energy Minimization		           #
############################################################################
if [ "$em" == "energy_minimization" ]
then

if [ "$cgintegrator" == "yes" ]
then
	$gmx grompp\
	     -f em_real.mdp \
		 -c solv_ions.gro \
		 -p topol.top \
		 -o em.tpr
	$gmx grompp\
	     -f em_real_cg.mdp \
		 -c em.tpr \
		 -p topol.top \
		 -o em_cg.tpr

		if [[ ! -e "em_cg.tpr" ]]
			then
			echo -e "Error: \n    em_cg.tpr file was not prepared using the command: \n\t\"$gmx grompp -f em_real_cg.mdp -c em.tpr -p topol.top -o em_cg.tpr \"" 
			exit
		fi

elif [ "$cgintegrator" == "no" ]
then
		$gmx grompp\
	     -f em_real.mdp \
		 -c solv_ions.gro \
		 -p topol.top \
		 -o em.tpr

		if [[ ! -e "em.tpr" ]]
			then
			echo -e "Error: \n    em.tpr file was not prepared using the command: \n\t\"$gmx grompp -f em_real.mdp -c solv_ions.gro -p topol.top -o em.tpr \"" 
			exit
		fi
else
	echo -e "Error: Please check the files of gromp in em"
fi
######################## energy minimization ends here######################
fi
############################################################################
# plcs = yes and cg = yes

if [[ "$plcs" == "yes" && "$cgintegrator" == "yes" ]] 
then
###############
if [ "$em" == "energy_minimization" ]
then

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm em_cg

		if [[ ! -e "em_cg.edr" ]]
			then
			echo -e "Error: \n    em_cg.edr file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm em_cg \"" 
			exit
		fi

	echo "Potential
" | $gmx energy \
		-f em_cg.edr \
		-o potential.xvg

		if [[ ! -e "potential.xvg" ]]
			then
			echo -e "Error: \n    potential.xvg file was not prepared using the command: \n\t\"$gmx energy -f em_cg.edr -o potential.xvg \"" 
		fi

	grace -nxy potential.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile potential_${prot_ex%%.*}_${lig_ex%%.*}.png
###############
fi

###############
if [ "$epro" == "eliminate_production" ]
then

	echo "0&!aH*
q" | $gmx make_ndx \
		-f ${lig_ex%%.*}.gro \
		-o index_${lig_ex%%.*}.ndx

		if [[ ! -e "index_${lig_ex%%.*}.ndx" ]]
			then
			echo -e "Error: \n    index_${lig_ex%%.*}.ndx file was not prepared using the command: \n\t\"$gmx make_ndx -f ${lig_ex%%.*}.gro -o index_${lig_ex%%.*}.ndx \"" 
			exit
		fi

	echo "3" | $gmx genrestr \
		-f ${lig_ex%%.*}.gro \
		-n index_${lig_ex%%.*}.ndx \
		-o posre_${lig_ex%%.*}.itp \
		-fc 1000 1000 1000

		if [[ ! -e "posre_${lig_ex%%.*}.itp" ]]
			then
			echo -e "Error: \n    posre_${lig_ex%%.*}.itp file was not prepared using the command: \n\t\"$gmx genrestr -f ${lig_ex%%.*}.gro -n index_${lig_ex%%.*}.ndx -o posre_${lig_ex%%.*}.itp -fc 1000 1000 1000 \"" 
			exit
		fi


	sed -i "/#include \"${lig_itp%%.*}.itp\"/a ; Ligand position restraints\n#ifdef POSRES_LIG\n#include \"posre_${lig_itp%%.*}.itp\"\n#endif" topol.top

	echo "1|13
q" | $gmx make_ndx \
		-f em_cg.gro \
		-o index.ndx

		if [[ ! -e "index.ndx" ]]
			then
			echo -e "Error: \n    index.ndx file was not prepared using the command: \n\t\"$gmx make_ndx -f em_cg.gro -o index.ndx \"" 
			exit
		fi


	$gmx grompp \
		-f nvt.mdp \
		-c em_cg.gro \
		-r em_cg.gro \
		-p topol.top \
		-n index.ndx \
		-o nvt.tpr

		if [[ ! -e "nvt.tpr" ]]
			then
			echo -e "Error: \n    nvt.tpr file was not prepared using the command: \n\t\"$gmx grompp -f nvt.mdp -c em_cg.gro -r em_cg.gro -p topol.top -n index.ndx -o nvt.tpr \"" 
			exit
		fi


	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm nvt

		if [[ ! -e "nvt.gro" ]]
			then
			echo -e "Error: \n    nvt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm nvt \"" 
			exit
		fi


	echo "Temperature
" | $gmx energy \
		-f nvt.edr \
		-o temperature.xvg

	grace -nxy temperature.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile temperature_${prot_ex%%.*}_${lig_ex%%.*}.png


	$gmx grompp \
		-f npt.mdp \
		-c nvt.gro \
		-t nvt.cpt \
		-r nvt.gro \
		-p topol.top \
		-n index.ndx \
		-o npt.tpr

		if [[ ! -e "npt.tpr" ]]
			then
			echo -e "Error: \n    npt.tpr file was not prepared using the command: \n\t\"$gmx grompp -f npt.mdp -c nvt.gro -t nvt.cpt -r nvt.gro -p topol.top -n index.ndx -o npt.tpr \"" 
			exit
		fi


	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm npt

		if [[ ! -e "npt.gro" ]]
			then
			echo -e "Error: \n    npt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm npt \"" 
			exit
		fi


	echo "Pressure
" | $gmx energy \
		-f npt.edr \
		-o pressure.xvg

	grace -nxy pressure.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile pressure_${prot_ex%%.*}_${lig_ex%%.*}.png

	echo "Density
" | $gmx energy \
		-f npt.edr \
		-o density.xvg

	grace -nxy density.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile density_${prot_ex%%.*}_${lig_ex%%.*}.png
###############
fi
############################################################################
# plcs = yes cg = no
elif [[ "$plcs" == "yes" && "$cgintegrator" == "no" ]] 
then
################
if [ "$em" == "energy_minimization" ]
then

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm em

		if [[ ! -e "em.gro" ]]
			then
			echo -e "Error: \n    npt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm em \"" 
			exit
		fi

	echo "Potential
" | $gmx energy \
		-f em.edr \
		-o potential.xvg

	grace -nxy potential.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile potential_${prot_ex%%.*}_${lig_ex%%.*}.png
#################
fi

if [ "$epro" == "eliminate_production" ]
then

	echo "0&!aH*
q" | $gmx make_ndx \
		-f ${lig_ex%%.*}.gro \
		-o index_${lig_ex%%.*}.ndx

		if [[ ! -e "index_${lig_ex%%.*}.ndx" ]]
			then
			echo -e "Error: \n    index_${lig_ex%%.*}.ndx file was not prepared using the command: \n\t\"$gmx make_ndx -f ${lig_ex%%.*}.gro -o index_${lig_ex%%.*}.ndx \"" 
			exit
		fi

	echo "3" | $gmx genrestr \
		-f ${lig_ex%%.*}.gro \
		-n index_${lig_ex%%.*}.ndx \
		-o posre_${lig_ex%%.*}.itp \
		-fc 1000 1000 1000

		if [[ ! -e "posre_${lig_ex%%.*}.itp" ]]
			then
			echo -e "Error: \n    posre_${lig_ex%%.*}.itp file was not prepared using the command: \n\t\"$gmx genrestr -f ${lig_ex%%.*}.gro -n index_${lig_ex%%.*}.ndx -o posre_${lig_ex%%.*}.itp -fc 1000 1000 1000 \"" 
			exit
		fi

	sed -i "/#include \"${lig_ex%%.*}.itp\"/a ; Ligand position restraints\n#ifdef POSRES_LIG\n#include \"posre_${lig_ex%%.*}.itp\"\n#endif" topol.top

	echo "1|13
q" | $gmx make_ndx \
		-f em.gro \
		-o index.ndx

		if [[ ! -e "index.ndx" ]]
			then
			echo -e "Error: \n    index.ndx file was not prepared using the command: \n\t\"$gmx make_ndx -f em.gro -o index.ndx \"" 
			exit
		fi

	$gmx grompp \
		-f nvt.mdp \
		-c em.gro \
		-r em.gro \
		-p topol.top \
		-n index.ndx \
		-o nvt.tpr

		if [[ ! -e "nvt.tpr" ]]
			then
			echo -e "Error: \n    nvt.tpr file was not prepared using the command: \n\t\"$gmx gromp -f nvt.mdp -c em.gro -r em.gro -p topol.top -n index.ndx -o nvt.tpr \"" 
			exit
		fi

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm nvt

		if [[ ! -e "nvt.gro" ]]
			then
			echo -e "Error: \n    nvt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm nvt \"" 
			exit
		fi

	echo "Temperature
" | $gmx energy \
		-f nvt.edr \
		-o temperature.xvg

	grace -nxy temperature.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile temperature_${prot_ex%%.*}_${lig_ex%%.*}.png


	$gmx grompp \
		-f npt.mdp \
		-c nvt.gro \
		-t nvt.cpt \
		-r nvt.gro \
		-p topol.top \
		-n index.ndx \
		-o npt.tpr

		if [[ ! -e "npt.tpr" ]]
			then
			echo -e "Error: \n    npt.tpr file was not prepared using the command: \n\t\"$gmx gromp -f npt.mdp -c nvt.gro -t nvt.cpt -r nvt.gro -p topol.top -n index.ndx -o npt.tpr \"" 
			exit
		fi

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm npt

		if [[ ! -e "npt.gro" ]]
			then
			echo -e "Error: \n    npt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm npt \"" 
			exit
		fi

	echo "Pressure
" | $gmx energy \
		-f npt.edr \
		-o pressure.xvg

	grace -nxy pressure.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile pressure_${prot_ex%%.*}_${lig_ex%%.*}.png

	echo "Density
" | $gmx energy \
		-f npt.edr \
		-o density.xvg

	grace -nxy density.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile density_${prot_ex%%.*}_${lig_ex%%.*}.png

############
fi
############################################################################
# plcs = no cg = no

elif [[ "$plcs" == "no" && "$cgintegrator" == "no" ]]
then

if [ "$em" == "energy_minimization" ]
then

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm em

		if [[ ! -e "em.gro" ]]
			then
			echo -e "Error: \n    em.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm em \"" 
			exit
		fi

	echo "Potential
" | $gmx energy \
		-f em.edr \
		-o potential.xvg

	grace -nxy potential.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile potential_${prot_ex%%.*}.png

fi

if [ "$epro" == "eliminate_production" ]
then

	$gmx grompp \
		-f nvt.mdp \
		-c em.gro \
		-r em.gro \
		-p topol.top \
		-o nvt.tpr

		if [[ ! -e "nvt.tpr" ]]
			then
			echo -e "Error: \n    nvt.tpr file was not prepared using the command: \n\t\"$gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr \"" 
			exit
		fi

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm nvt

		if [[ ! -e "nvt.gro" ]]
			then
			echo -e "Error: \n    nvt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm nvt \"" 
			exit
		fi

	echo "Temperature
" | $gmx energy \
		-f nvt.edr \
		-o temperature.xvg

	grace -nxy temperature.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile temperature_${prot_ex%%.*}.png


	$gmx grompp \
		-f npt.mdp \
		-c nvt.gro \
		-t nvt.cpt \
		-r nvt.gro \
		-p topol.top \
		-o npt.tpr

		if [[ ! -e "npt.tpr" ]]
			then
			echo -e "Error: \n    npt.tpr file was not prepared using the command: \n\t\"$gmx grompp -f npt.mdp -c nvt.gro -t nvt.cpt -r nvt.gro -p topol.top -o npt.tpr \"" 
			exit
		fi

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm npt

		if [[ ! -e "npt.gro" ]]
			then
			echo -e "Error: \n    npt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm npt \"" 
			exit
		fi

	echo "Pressure
" | $gmx energy \
		-f npt.edr \
		-o pressure.xvg

	grace -nxy pressure.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile pressure_${prot_ex%%.*}.png

	echo "Density
" | $gmx energy \
		-f npt.edr \
		-o density.xvg

	grace -nxy density.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile density_${prot_ex%%.*}.png
###############
fi

############################################################################
# plcs = no cg = yes
elif [[ "$plcs" == "no" && "$cgintegrator" == "yes" ]]
then
#################
if [ "$em" == "energy_minimization" ]
then

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm em_cg

		if [[ ! -e "em_cg.gro" ]]
			then
			echo -e "Error: \n    em_cg.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm em_cg \"" 
			exit
		fi

	echo "Potential
" | $gmx energy \
		-f em_cg.edr \
		-o potential.xvg

	grace -nxy potential.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile potential_${prot_ex%%.*}.png
###############
fi

if [ "$epro" == "eliminate_production" ]
then

	$gmx grompp \
		-f nvt.mdp \
		-c em_cg.gro \
		-r em_cg.gro \
		-p topol.top \
		-o nvt.tpr

		if [[ ! -e "nvt.tpr" ]]
			then
			echo -e "Error: \n    nvt.tpr file was not prepared using the command: \n\t\"$gmx grompp -f nvt.mdp -c em_cg.gro -r em_cg.gro -p topol.top -o nvt.tpr \"" 
			exit
		fi

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm nvt

		if [[ ! -e "nvt.gro" ]]
			then
			echo -e "Error: \n    nvt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm nvt \"" 
			exit
		fi

	echo "Temperature
" | $gmx energy \
		-f nvt.edr \
		-o temperature.xvg

	grace -nxy temperature.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile temperature_${prot_ex%%.*}.png


	$gmx grompp \
		-f npt.mdp \
		-c nvt.gro \
		-t nvt.cpt \
		-r nvt.gro \
		-p topol.top \
		-o npt.tpr 

		if [[ ! -e "npt.tpr" ]]
			then
			echo -e "Error: \n    em_cg.gro file was not prepared using the command: \n\t\"$gmx grompp -f npt.mdp -c nvt.gro -t nvt.cpt -r nvt.gro -p topol.top -o npt.tpr \"" 
			exit
		fi

	$gmx mdrun \
		-nt $nt \
		$gpu \
		-v \
		-deffnm npt

		if [[ ! -e "npt.gro" ]]
			then
			echo -e "Error: \n    npt.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm npt \"" 
			exit
		fi

	echo "Pressure
" | $gmx energy \
		-f npt.edr \
		-o pressure.xvg

	grace -nxy pressure.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile pressure_${prot_ex%%.*}.png

	echo "Density
" | $gmx energy \
		-f npt.edr \
		-o density.xvg

	grace -nxy density.xvg \
		-hdevice PNG \
		-hardcopy \
		-printfile density_${prot_ex%%.*}.png
fi

else
echo "Wrong choice"
exit
fi

	if [ "$cpro" == "complete_production" ]
	then
		$gmx grompp \
			-f md.mdp \
			-c npt.gro \
			-t npt.cpt \
			-n index.ndx \
			-p topol.top \
			-o md_0_1.tpr

		if [[ ! -e "md_0_1.tpr" ]]
			then
			echo -e "Error: \n    md_0_1.tpr file was not prepared using the command: \n\t\"$gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_o_1.tpr \"" 
			exit
		fi

		$gmx mdrun \
			-nt $nt \
			$gpu \
			-v \
			-deffnm md_0_1

		if [[ ! -e "md_0_1.gro" ]]
			then
			echo -e "Error: \n    md_0_1.gro file was not prepared using the command: \n\t\"$gmx mdrun -nt $nt $gpu -v -deffnm md_0_1.gro \"" 
			exit
		fi

	fi

done
############################################################################
#				End of while loop			   #
############################################################################
#
echo "Double check all the files that are generated using this script"
echo "report bugs to elvis.martis@bcp.edu.in or rkmishra3893@gmail.com"
echo "It takes intelligence to identify Intelligent People. --Meenakshi Venkataraman"
exit
