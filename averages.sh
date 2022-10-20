
#!/bin/bash
#I am going to start by making a text file with the three sample types in it
#I use this to populate a variable in the next two steps
#Cut is taking the list of sample types from Tco.fqfiles
#Sed is removing the header
#Sort is grouping by redundency for uniq to remove repeats and leave only unique names
cut -f 2 Tco.fqfiles | sed '1d;$d' | sort | uniq > sampletypes.txt

#My first go around I manually entered the sample names
#touch sampletypes.txt
#echo "WT" >> sampletypes.txt
#echo "Clone1" >> sampletypes.txt
#echo "Clone2" >> sampletypes.txt


#I'm sure that this is not the prettiest way to sort the samples, but hey, it works
#I am populating the variable "sampletypes" with the three sample types from above
#I am then taking the annotated sample table and sorting it into a text file
#for each of the three sample sample types
#I am then sorting each of these files by the replicate number (-k3,3)
#And then again by the number of hours (-k4,4) which is used in the next step
#I am then taking the top 5 entries, then the next 5 entries, and the next 5 entries
#Which thanks to the sorting are the 1st, 2nd, and 3rd replicates, respectively
#Lastly there is a single 4th replicate for 24h induced that i put in its own file
#The outputs of these are all put into text files with their appropriate label
while read sampletype
do
cat Tco.fqfiles | grep ${sampletype} > all${sampletype}.txt
sort -k3,3 -k4,4 all${sampletype}.txt | head -5 > all${sampletype}-1.txt
sort -k3,3 -k4,4 all${sampletype}.txt | head -10 > all${sampletype}-12.txt
tail -5 all${sampletype}-12.txt > all${sampletype}-2.txt
sort -k3,3 -k4,4 all${sampletype}.txt | head -15 > all${sampletype}-123.txt
tail -5 all${sampletype}-123.txt > all${sampletype}-3.txt
sort -k3,3 -k4,4 all${sampletype}.txt | tail -1 > all${sampletype}-4.txt
done < sampletypes.txt

#The result of the above code generates text files grouped by sample type and replicate number

#I am now going through and for each sample type and pulling from the replicate number file
#Which are all now sorted in the same manner
#So I am pulling all replicates of the same experimental category and putting those samples
#Into a new text file that is codefied appropriately

while read st
do
for i in {1,2,3}
do
head -1 all${st}-$i.txt >> ${st}_0_un.txt
head -2 all${st}-$i.txt | tail -1 >> ${st}_24_ind.txt
head -3 all${st}-$i.txt | tail -1 >> ${st}_24_un.txt
head -4 all${st}-$i.txt | tail -1 >> ${st}_48_ind.txt
tail -1 all${st}-$i.txt >> ${st}_48_un.txt
done
tail -1 all${st}-4.txt >> ${st}_24_ind.txt
done < sampletypes.txt


#The results of the above code generates text files labeled sampletype_hours_treatment.text
#That contain a list of the samples that are replicates of this sample category

#This is just making new text files that have JUST the Tco number for the next step
for name in *ind.txt
do
cut -c 4-7 ${name}>> ${name}-num.txt
done

for name in *un.txt
do
cut -c 4-7 ${name}>> ${name}-num.txt
done

#This is making files that only have the category identifier for the sample folders
#This will be used as a variable in the next step
ls *num.txt > samplestxt.txt
cat samplestxt.txt | rev | cut -c 13- | rev > samples.txt


#This is a script to take the file for each sample category
#Use the Tco numbers that identify the samples within that category
#Use those Tco numbers to pull the alignment count file of that sample
#And then from that export only the read counts to a new file
#I will then merge these files and make averages from them

#I used SC to stand for sample category, it is pulling from samples.txt at the bottom
#of this massive nested loop
while read sc
do
touch ${sc}_genes.txt
touch ${sc}_rep1.txt
touch ${sc}_rep2.txt
touch ${sc}_rep3.txt

#This is accessing the file with the Tco numbers for each sample in a given category
#SF stands for sample file
for sf in ${sc}.txt-num.txt
do
#we need to just get the fist item of each sample type (rep1)
head -1 ${sf} > firstsample.txt
done

#now we need to get the gene names and the first counts from rep1
#Using variabel first as just being the contents of firstsample, which is the Tco number
#of the first replicate
while read first
do
cut -f 4,5 Tco-${first}output-counts.txt > ${sc}_genes.txt
cut -f 6 Tco-${first}output-counts.txt > ${sc}_rep1.txt
done < firstsample.txt

#we need to just get the second item of each sample type (rep2)
for sf in ${sc}.txt-num.txt
do
head -2 ${sf} | tail -1 > secondsample.txt
done

#now we need to get the counts from rep2
while read second
do
cut -f 6 Tco-${second}output-counts.txt > ${sc}_rep2.txt
done < secondsample.txt

#we need to just get the third item of each sample type (rep3)
for sf in ${sc}.txt-num.txt
do
head -3  ${sf} | tail -1 > thirdsample.txt
done

#now we need to get the counts from rep3
while read third
do
cut -f 6 Tco-${third}output-counts.txt > ${sc}_rep3.txt
done < thirdsample.txt

done < samples.txt


#Then of the three cell types 24hr induced has a 4th sample
#This is just a miniture version of the code above, and I did the
#three samples by hand since there were only three and it seemed
#more straightforward to do this way than automate it for only
#3 samples sine I was able to just reuse the code

tail -1 WT_24_ind.txt-num.txt > fourthsample.txt
while read fourth
do
cut -f 6 Tco-${fourth}output-counts.txt > WT_24_ind_rep4.txt
done < fourthsample.txt

tail -1 Clone1_24_ind.txt-num.txt > fourthsample.txt
while read fourth
do
cut -f 6 Tco-${fourth}output-counts.txt > Clone1_24_ind_rep4.txt
done < fourthsample.txt

tail -1 Clone2_24_ind.txt-num.txt > fourthsample.txt
while read fourth
do
cut -f 6 Tco-${fourth}output-counts.txt > Clone2_24_ind_rep4.txt
done < fourthsample.txt


#Now we merge everything together
while read sc
do
paste ${sc}_rep1.txt ${sc}_rep2.txt ${sc}_rep3.txt ${sc}_genes.txt > ${sc}_counts.txt
done < samples.txt


#Now we need to add the extra column of rep4 for the 24_ind groups
#I was having errors with having the counts.txt file on both sides of the paste
#by trial and error I discovered that haivng a temporary file inbetween avoids this
paste WT_24_ind_rep4.txt WT_24_ind_counts.txt > WT_24_ind_countstemp.txt
cat WT_24_ind_countstemp.txt > WT_24_ind_counts.txt
paste Clone1_24_ind_rep4.txt Clone1_24_ind_counts.txt > Clone1_24_ind_countstemp.txt
cat Clone1_24_ind_countstemp.txt > Clone1_24_ind_counts.txt
paste Clone2_24_ind_rep4.txt Clone2_24_ind_counts.txt > Clone2_24_ind_countstemp.txt
cat Clone2_24_ind_countstemp.txt > Clone2_24_ind_counts.txt

#This takes the replicat count files and averages each row
#I then had problems with the outputs being long repeating decimals so
#The cut line is simply truncating the decimal
while read sc
do
awk -F"\t" 'BEGIN{sum=0; avg=0}{sum=$1+$2+$3; avg=sum/3; print avg}' ${sc}_counts.txt >> ${sc}_avglong.txt
cut -c 1-4 ${sc}_avglong.txt > ${sc}_avg.txt
done < samples.txt

#Then the 24_ind samples need to be averaged across 4 replicates
awk -F"\t" 'BEGIN{sum=0; avg=0}{sum=$1+$2+$3+$4; avg=sum/4; print avg}' WT_24_ind_counts.txt > WT_24_ind_avg.txt
awk -F"\t" 'BEGIN{sum=0; avg=0}{sum=$1+$2+$3+$4; avg=sum/4; print avg}' Clone1_24_ind_counts.txt > Clone1_24_ind_avg.txt
awk -F"\t" 'BEGIN{sum=0; avg=0}{sum=$1+$2+$3+$4; avg=sum/4; print avg}' Clone2_24_ind_counts.txt > Clone2_24_ind_avg.txt


#This merges the averages
paste *avg.txt > allavg.txt

#This adds the gene name and descriptor to the table of averages
paste allavg.txt WT_0_un_genes.txt > labeledavg.txt

#This is making a header for the averages table
#It is utilizing the samples.txt file and using the while loop to read this file
#and for each line adding the next sample name (seperated by a tab) to the growing
#list (the variable "header")
#For some reason it started with an unwanted tab so I cut that out
#Then I put the header into a new file and put the averages file below it
unset ${header}
header=$()
while read sample
do
header="${header}${sample}\t"
done < samples.txt
header="${header}Gene Name\tGene Description"
echo -e ${header} > headerl.txt
cut -f 2-  headerl.txt > allsamplesavg.txt

cat labeledavg.txt >> allsamplesavg.txt

#This makes an index of the sample names
#Generating a list of the sample names and their order as they appear in the
#table of averages side by side
#I will use this for the fold change, utilizing this file to direct the command to the
#Desired columns of averages
#!/usr/bin/awk
awk -F"\t" 'BEGIN{count=0}
{
count=count+1
print count
}' samples.txt > index.txt
paste index.txt samples.txt > samplesindex.txt

#And that's the end of the sample organization and averaging step :)

#After this portion of the code runs it shows the head of the averages table
#Directs the user to the full file if they wish to see it
#And then prompts the user to run the foldchange script

echo -e "\n"
echo -e "# Here is the top of the list of all samples' averge counts per gene \n"
head allsamplesavg.txt
echo -e "\n "
echo -e "# The full average counts file can be found at allsamplesavg.txt \n \n \n"



echo "#  to perform pairwise foldchange analysis enter:"
echo -e "#  ./foldchange.sh sampletype_hours_ind/un sampletype_hours_ind/un \n"
echo "#  For example to compare Clone1_48_induced to WT_48_uninduced enter:"
echo "#  ./foldchange.sh Clone1_48_ind WT_48_un"

