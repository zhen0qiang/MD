# orient the protein and membrane
gmx grompp -f minim.mdp -c dppc128.pdb -p topol_dppc.top -o dppc.tpr -maxwarn 1

gmx trjconv -s dppc.tpr -f dppc128.pdb -o dppc128_whole.gro -pbc mol -ur compact

gmx editconf -f KALP-15_processed.gro -o KALP_newbox.gro -c -box 6.41840 6.44350 6.59650

# Pack the lipids around the protein
cat KALP_newbox.gro dppc128_whole.gro > system.gro

sed -i '900i\
\
; Strong position restraints for InflateGRO\
#ifdef STRONG_POSRES\
#include "strong_posre.itp"\
#endif'  topol.top

gmx genrestr -f KALP_newbox.gro -o strong_posre.itp -fc 100000 100000 100000

echo "define = -DSTRONG_POSRES" >> minim.mdp

perl inflategro.pl system.gro 4 DPPC 14 system_inflated.gro 5 area.dat

# gmx genion -s topol.tpr -o solv_ions.gro -p topol.top -pname NA -nname CL -neutral

gmx grompp -f minim_inflategro.mdp -c system_inflated.gro -p topol.top -r system_inflated.gro -o system_inflated_em.tpr

gmx mdrun -deffnm system_inflated_em

# make molecules whole
echo 0 | gmx trjconv -s system_inflated_em.tpr -f system_inflated_em.gro -o tmp.gro -pbc mol
mv tmp.gro system_inflated_em.gro

# loop over 26 shrinking iterations
for curr in {1..26} 
do
    echo "########################################"
    echo "#"
    echo "# RUNNING SHRINKING ITERATION ${curr}..."
    echo "#"
    echo "########################################"

    prev=$((curr - 1))

    if [ $curr -eq 1 ]; then
        if [ ! -e system_inflated_em.gro ]; then
            echo "system_inflated_em.gro does not exist! Exiting."
            exit;
        fi
        # special file name if doing the first iteration
        perl inflategro.pl system_inflated_em.gro 0.95 DPPC 0 system_shrink${curr}.gro 5 area_shrink${curr}.dat
    else
        if [ ! -e system_shrink${prev}_em.gro ]; then
            echo "system_shrink${prev}_em.gro does not exist! Exiting."
            exit;
        fi
        # otherwise use minimized coordinates from previous iteration
        perl inflategro.pl system_shrink${prev}_em.gro 0.95 DPPC 0 system_shrink${curr}.gro 5 area_shrink${curr}.dat
    fi

    # run grompp and mdrun to carry out energy minimization
    gmx grompp -f minim_inflategro.mdp -c system_shrink${curr}.gro -r system_shrink${curr}.gro -p topol.top -o system_shrink${curr}_em.tpr
    gmx mdrun -deffnm system_shrink${curr}_em

    # make molecules whole
    gmx trjconv -s system_shrink${curr}_em.tpr -f system_shrink${curr}_em.gro -o tmp.gro -pbc mol
    mv tmp.gro system_shrink${curr}_em.gro

done

exit;