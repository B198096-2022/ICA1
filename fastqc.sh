
#!/bin/bash
#first we need to acquire the data
cp /localdisk/data/BPSM/ICA1/fastq/*.gz .
cp /localdisk/data/BPSM/ICA1/fastq/Tco.fqfiles .
#Take all of the files labeled .fq.gz
#Then run fastqc on them using the command parallel to run them in parallel (faster!)
find . -name "*.fq.gz" | parallel fastqc
#Citing the source of the parallel command
#uses  O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
#  ;login: The USENIX Magazine, February 2011:42-47.

#Then I unzipped all of the fastqc files that were generated
find *.zip | parallel unzip

#Make files for all of the summary categories and add a label at the top
#These will be populated in the next step
echo "File Name" > fastqcnames2.txt
echo "Results of Basic Statistics" > fastqcbasic2.txt
echo "Passes" > fastqcpass2.txt
echo "Warnings" > fastqcwarn2.txt
echo "Fails" > fastqcfail2.txt
#Pull out all of the summary.txt files from inside of the fastqc directories made for each file
#I made a variable fastqcfiles which contains all of the fastqc directories
#Then for each fastqc directory it puts the directory name into the names files
#Then it opens the summary.txt file and puts the basic statistics summary into its repsective file
#Then it counts the number of pass/fail/warn in the summery.txt file and send those off to their files
for fastqcfiles in *fastqc
do
echo ${fastqcfiles} >> fastqcnames2.txt
grep Basic ${fastqcfiles}/summary.txt >> fastqcbasic2.txt
grep -c PASS ${fastqcfiles}/summary.txt >> fastqcpass2.txt
grep -c WARN ${fastqcfiles}/summary.txt >> fastqcwarn2.txt
grep -c FAIL ${fastqcfiles}/summary.txt >> fastqcfail2.txt
done

#I cut out just the "pass/fail basic statistics"
cut -f 1-2 fastqcbasic2.txt > fastqcbasic-cut2.txt

#I then merged all of these files to make one large fastqc summary output file
paste fastqcnames2.txt fastqcbasic-cut2.txt fastqcpass2.txt fastqcwarn2.txt fastqcfail2.txt > fastqcsummary2.txt

#Creating a space to make the results easire to see
echo -e "\t \t \t"

#Show the summary file
cat fastqcsummary2.txt

echo "# For full fastqc results summary of any given sample enter:"
echo "# cat ./sampleTconame_fastqc/summary.txt"
echo "# For example, to view fastqc summary for Tco-6307_2 enter: "
echo "# cat ./Tco-6307_2_fastqc/summary.txt"
#Thats the end of quality control :)

