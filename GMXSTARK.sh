# GMXSTARK v1.0 is a Gromacs input file maker.
# The entire code is written in Bourne Shell.
# Copyright (c) 2016 [Elvis Martis]
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "GMXSTARK v1.0"), to deal
# in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# All bug reports and suggestions can be sent to elvis.martis@bcp.edu.in with subject line "GMXSTARK v1.0 bug report"
# If the use of this script results in a publication, kindly acknowledge the use for the sake promotion of this code
# Acknowledgement may be written as "The Authors acknowledge the use of "GMXSTARK v1.0" for generating the input files"

#/bin/bash -w
# Change directory
read -p "Enter the Working Directory : " work
cd $work
echo $work
# Locating Gromacs installation directory
which mdrun = gromacs_path ## need to change this its not doing what it is suppose to do
echo "$gromacs_path" ## need to change
# Setting the correct GROMACS version
read -p "Gromacs version 5 or above [yes or no] : " gmxv
If [ $gmxv=yes ]
then
	$gmx=gmx
	$solvate=solvate
else
	$gmx=("")
	$solvate=genbox
fi
# Defining the input files and selecting water model and forcefield
read -p "Enter the name of your protein [without any extension eg .pdb] : " pdb
read -p "Enter the name for your output gro file [without any extension eg .gro] : " gro1
read -p "Enter the water model to be used for solvation [Recommended SPC or TIP3P] : " wat
read -p "Enter the forcefield [Usestring value- 1 to 16 see manual] : " ff
read -p "Enter the default name of topology [for topol.top] : " topol 
# Generating gromacs files
$gmx pdb2gmx \
	 -f ${pdb}.pdb \
	 -o ${gro1}.gro \ 
	 -water $wat \
	 -ff $ff 
# Defining the Gromacs box size and type
read -p "Enter the output name for editconf [without any extension eg .gro] : " gro2
read -p "Enter the solvent shell [in decimals nm (for example 1.0 for 1.0 nm or 10 angstrom)] : " dim 
read -p "Enter the box type [cubic or triclinic or docdecahedron or octahedron] : " bxty   
$gmx editconf \ # check with gmx lower then 5
	 -f ${gro1}.gro \
	 -o ${gro2}.gro \
	 -c \
	 -d $dim \ 
	 -bt $bxty 
read -p "Enter the output name for solvate : " gro3  
read -p "Enter solvent configuration [Default is spc216.gro]: " solconfig
$gmx $solvate \ # this is also different
     -cp ${gro2}.gro \
     -cs ${solconfig}.gro \
     -o ${gro3}.gro \
     -p ${topol}.top
# preparing files to add ions
echo "The mdp can be obtained from http://www.bevanlab.biochem.vt.edu/Pages/Personal/justin/gmx-tutorials/lysozyme/Files/ions.mdp"
read -p "Should I download that for you [yes or no] ? : " DWLD
If [ $DWLD=yes ]
then
	wget -b http://www.bevanlab.biochem.vt.edu/Pages/Personal/justin/gmx-tutorials/lysozyme/Files/ions.mdp
fi
read -p "Enter the MDP file ions [without extension .mdp] : " ions
read -p "Enter a name for .tpr file [default is "ions"] : " tpr1
$gmx grompp\
     -f ${ions}.mdp \
	 -c ${gro3}.gro \
	 -p ${topol}.top \
	 -o ${trp1}.tpr
read -p "Enter the output name for ions [without extension eg .gro] : " gro4
read -p "Set counter ion type [NA for sodium or CL for Chloride ] : "iontype
if [ $iontype = NA ]
then
  echo "adding Na+ ions for negatively charged system"
  $name=pname
elif [ $iontype = CL ]
then
  echo "adding CL- ions for positively charged system"
  $name=nname
else
  echo "Adding counterions to maintain desired salt concentration"
  $name=conc ## add condition for this to bypass defining -nn
fi
read -p "Enter the number of counterions [only integers allowed] : " numions
if [$numions=int]
then
	echo "Adding ions now"
else
    echo "Number ions cannot be a floating point, please use integers. Quiting..."
	exit
fi
$gmx genion \
     -s ${trp1}.tpr \
	 -o ${gro4}.gro \
	 -p ${topol}.top \
	 -$name $iontype \
	 -nn $numions





echo "Double check all the files that are generated using this script"
echo "report bugs to elvis.martis@bcp.edu.in"
echo "It takes intelligence to identify Intelligent People. --Meenakshi Venkataraman"
exit






