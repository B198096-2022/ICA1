
#!/bin/bash
#I am copying the annotated genome file to the working directory
cp /localdisk/data/BPSM/ICA1/TriTrypDB-46_TcongolenseIL3000_2019.bed .

#This is just making a list of all of my file names to use in the next step
ls *.bam > bamnames.txt
cut -c 1-14 bamnames.txt > bamnamescut.txt

#Using the variable bamname as the list of all of the file names
#I am converting all of the bam files into bed files
while read bamname
do
bedtools bamtobed -i ${bamname}.bam > ${bamname}.bed
echo -e "Converting ${bamname}.bam to ${bamname}.bed"
done < bamnamescut.txt

#I am then using the same variable to run a bedtools intersect, which is
#using the full genome as the template (the -a file) and then for each
#sample file it goes through each sequence entry and looks for where on the
#template genome it aligns with. I am using the count feature (-c) which generates
#a tally of all of the times that a sequence aligns with a given gene in the template
#genome, so the final result shows how many reads in the sample aligned to each gene
while read bamname
do
bedtools intersect -a TriTrypDB-46_TcongolenseIL3000_2019.bed -b ${bamname}.bed -c > ${bamname}-counts.txt
echo -e "Calculating counts for ${bamname}.bed"
done < bamnamescut.txt

#I output the counts to a file for each sample, which I will now use in the next step
##That's the end of the count step :)

