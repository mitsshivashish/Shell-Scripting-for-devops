#!/usr/bin/env bash

# 1. Generate test data and feed it via stdin
cat > data.txt << 'EOF' 
name,age,city
alice,30,nyc
bob,25,boston
carol,35,seattle
dave,40,nyc
eve,22,boston
frank,28,nyc
EOF

# From CSV stdin (name,age,city), print average age per city

# TODO: Implement using awk and print city + average age with two decimals

awk -F, 'NR>1 { sum[$3]+=$2; count[$3]++ } END{ for(c in sum) printf "%s %.2f\n", c, sum[c]/count[c] }' data.txt
