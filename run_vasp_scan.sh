# This here is the Bash Script that calculates F for 100 values of C and plots them as F vs c

#!/bin/bash

# --- Configuration ---
POSCAR="POSCAR"
OUTPUT="OUTPUT_F"
RESULTS="F_vs_c.dat"

# Remove old results file if present
rm -f $RESULTS

# Define range for c values (10 points between 2.0 and 5.0)
c_values=$(seq 0.7 0.01 1.3)

# Loop over each lattice constant value
for c in $c_values
do
    echo "Running for c = $c"

    # Update lattice constant (2nd line in POSCAR)
    sed -i "2s/.*/$c/" $POSCAR

    # Run VASP
    mpirun -np 2 vasp_std > $OUTPUT

    # Extract free energy F from last line containing 'F='
    F=$(grep "F=" $OUTPUT | tail -1 | awk '{for(i=1;i<=NF;i++) if ($i=="F=") print $(i+1)}' | sed 's/E.*//')

    echo "$c $F" >> $RESULTS
done

# --- Plot the results using gnuplot ---
gnuplot <<EOF
set title "Free Energy vs Lattice Constant"
set xlabel "Lattice Constant c"
set ylabel "Free Energy F (eV)"
set grid
set term pngcairo size 800,600
set output "F_vs_c.png"
plot "$RESULTS" using 1:2 with linespoints title "F vs c"
EOF

echo "All done! Data saved in $RESULTS and plot saved as F_vs_c.png"

