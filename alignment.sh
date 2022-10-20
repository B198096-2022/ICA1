
#!/bin/bash
#Copies the T. congolese genome to working directory
cp /localdisk/data/BPSM/ICA1/Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz .
#Take all of the files and gunzip them, now they are just a .fq file
find . -name "*.gz" | parallel gunzip

#Make a list of all of the file filenames
cut -f 1 Tco.fqfiles >> filenames-L.txt
tail -n +2 filenames-L.txt > filenames.txt
cut -c 4-7 filenames.txt > filenumbers.txt

#This creates 6 bowtie2 idex files for the reference genome that will be used for the bowtie2 command
#The --quiet option reduces what gets printed to the screen
bowtie2-build TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta T_congelense_index

#This is now taking every file name and running it through the bowtie2 Command
#It is using the filenumbes.txt to make a variable containing all of the file numberedfastqcsummary2
#Then it is running through and converting the variable into the file name
#The -p 96 increases the number of threads to 96, which is the number of samples being processed
while read filename
do
bowtie2 --no-unal -p 96 -x T_congelense_index -1 Tco-${filename}_1.fq -2 Tco-${filename}_2.fq -S Tco-${filename}output.sam
echo -e "$filename being aligned"
done < filenumbers.txt

#This now makes a list of all of the sam files and removes the .sam
#I now realize that I could have used the filename varaible from above again...
#But this worked and I don't want to risk breaking it
ls *.sam > samnames.txt
cut -c 1-14 samnames.txt > samnamescut.txt

#This is a little script that converts the sam files into bam filenames
#I created a samname variable populated with the samnamescut.txt from above
#This then runs through the sam to bam command for all of them and converts the name to .bam file
#The @32 is specifying that i want the command to run on 32 cores to speed up the process
#without this it takes several minutes
while read samname
do
samtools view -S -b -@32 ${samname}.sam > ${samname}.bam
echo -e "Converting ${samname}.sam to ${samname}.bam"
done < samnamescut.txt
#That's the end of the alignment step :)

