
#!/bin/bash
#I am very pleased with this script
#The user is prompted to run this shell script and provide
#The two samples that they want compared
#This pulls those two sample names into the script as variables called $1 and $2

#I begin by using my samplesindex.txt file and grepping for the sample name that
#the user provided, and then cut the index number for that sampel
#I do that for both of the samples and put them in variables top and bottom
top=$(cat samplesindex.txt | grep "$1" | cut -f 1)
bot=$(cat samplesindex.txt | grep "$2" | cut -f 1)

#I then need to pull those varaibles into an awk script
#I just renamed the variables t and b for inside the awk script
#I then use the varaibles num for numerator, den for denomenator, and fold for foldchange
#I then take in the allavg.txt file, which has all of the columns of average counts for
#each sample, and use the $t and $b variable to specify the field from which tho pull
#the sample's averages
#I had problem with dividing by zero so I also had to include a conditional and if
#The denomenator is non-zero it calculates fold as numerator/denomenator
#But if the denomenator is zero it prints N/A
#!/usr/bin/awk
awk -v t="$top" -v b="$bot" 'BEGIN{num=0; den=0 ;fold=0;}
{
  num=$t; den=$b;
  if (den > 0)
    fold=num/den
  else if (den==0)
    fold="N/A"
  print fold
}' allavg.txt > foldtestlong.txt

#I now am truncating the decimals in the cut line
#Then adding the gene names and and descriptions to the file
#Then adding a header to the file
#Then finally sorting the foldchange data to present in descending order
#And finally, a nice final touch, using the sample name varaibles to create an
#output file that specifies the samples it contains
#close with presenting the head of the file and directing the user to the full file

cut -c 1-6 foldtestlong.txt > foldtest.txt
paste foldtest.txt WT_0_un_genes.txt > labeledfoldtest.txt
echo -e "Fold Change \t Gene Name \t Gene Description" > ${1}_over_${2}_fold.txt
sort -k1,1nr labeledfoldtest.txt >> ${1}_over_${2}_fold.txt
echo "# Top 10 fold change results"
head ${1}_over_${2}_fold.txt
echo -e "\n # Note: for genes in the second sample with zero reads output is N/A \n "
echo -e "# full analysis available in ${1}_over_${2}_fold.txt \n"
echo -e "\n #To compare more samples enter:"
echo "# ./foldchange.sh sampletype_hours_ind/un sampletype_hours_ind/un"

