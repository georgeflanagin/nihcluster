#! /bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=20G
#SBATCH --time=72:00:00
#SBATCH --partition=erickson
#SBATCH --array=1-10


REFERENCE=/home/perickso/private/zind_ref_genome.fasta
PICARD=/usr/local/sw/picard/picard.jar

#Define important file locations
#RAW READS indicates the folder where the raw reads are stored.
RAW_READS=/home/perickso/private/bio351

#PRIOR TO PIPELINE: make a list of samples:
#ls -d Z* > file_list.txt

#Working folder is core folder where this pipeline is being run.
WORKING_FOLDER=/home/perickso/private/bio351/mapping

#This is the location where the reference genome and all its indexes are stored.


#This is a unique number id which identifies this run
unique_run_id=`date +%N`

#Name of pipeline
PIPELINE=mapping

#Define parameters
CPU=10 # number of cores
QUAL=40 # Quality threshold for samtools
JAVAMEM=18g # Java memory

###########################################################################
###########################################################################
# Determine sample to process, "i"
###########################################################################
###########################################################################

i="ZP_"${SLURM_ARRAY_TASK_ID}


#if the sorted bam file already exists from a previous run, exit the script
if [[ `wc -l  "$WORKING_FOLDER/joint_bams/${i}.joint.srt.rmdp.bam"` > 1 ]]
then
	echo "mapping already completed, exiting"
	exit
else
	echo "beginning mapping pipeline"
fi

###########################################################################
###########################################################################
# Begin Pipeline
###########################################################################
###########################################################################
#This part of the pipeline will generate log files to record warnings and completion status

# Welcome message
echo "your unique run id is" $unique_run_id

if [[ -e "${PIPELINE}.warnings.log" ]]
then
	echo "Warning log exist"
	echo "lets move on"
	date
else
	echo "Log doesnt exist. lets fix that"
	touch $WORKING_FOLDER/${PIPELINE}.warnings.log
	date
fi

if [[ -e "${PIPELINE}.completion.log" ]]
then
	echo "Warning log exist"
	echo "lets move on"
	date
else
	echo "Log doesnt exist. lets fix that"
	touch $WORKING_FOLDER/${PIPELINE}.completion.log
	date
fi


# Move to working directory
cd $WORKING_FOLDER

###########################################################################
###########################################################################
# Generate Folders and files
###########################################################################
###########################################################################
# this part of the script will check and generate, if necessary, all of the output folders used in the script

#Generating new folders
echo "have you checked if the folders were already built with mkdir?"
if [[ -d "merged_reads" ]]
then
	echo "Working merged_reads folder exist"
	echo "lets move on"
	date
else
	echo "folder doesnt exist. lets fix that"
	mkdir $WORKING_FOLDER/merged_reads
	date
fi

if [ -d "unmerged_reads" ]
then
	echo "Working unmerged_reads folder exist"
	echo "lets move on"
	date
else
	echo "folder doesnt exist. lets fix that"
	mkdir $WORKING_FOLDER/unmerged_reads
	date
fi

if [ -d "mapping_stats" ]
then
	echo "Working mapping_stats folder exist"
	echo "lets move on"
	date
else
	echo "folder doesnt exist. lets fix that"
	mkdir $WORKING_FOLDER/mapping_stats
	date
fi


if [ -d "joint_bams" ]
then
	echo "Working joint_bams folder exist"
	echo "lets move on"
	date
else
	echo "folder doesnt exist. lets fix that"
	mkdir $WORKING_FOLDER/joint_bams
	date
fi

###########################################################################
###########################################################################
# Trim and merge reads
###########################################################################
###########################################################################
# This part of the pipeline will trim and merge the reads. It is very likely that the reads will be split into merged and unmerged. Both reads will be mapped. This loop operates using a while-read-do-done structure. the while loop is feed a file "SAMPLE_FILE" where  all sample names are stored, one name per line. This can be leveraged for parallelization.

# Setting sample name to user input

#while read i #${files}
#	do #---- Open Do------ <----

	echo ${i} "is now processing"
	date

	mkdir $WORKING_FOLDER/merged_reads/${i}
	mkdir $WORKING_FOLDER/unmerged_reads/${i}

	echo "now merging reads for" ${i}

	read1=`echo $RAW_READS/${i}/${i}*_1.fq.gz`
	read2=`echo $RAW_READS/${i}/${i}*_2.fq.gz`

	bbmerge.sh \
	in1=$read1 in2=$read2 \
	out=$WORKING_FOLDER/merged_reads/${i}/${i}.merged.reads.strict.fq \
	outu1=$WORKING_FOLDER/unmerged_reads/${i}/${i}.unmerged.reads.1.fq \
	outu2=$WORKING_FOLDER/unmerged_reads/${i}/${i}.unmerged.reads.2.fq \
	-strict

	#Sanity checks
	if [ -s $WORKING_FOLDER/merged_reads/${i}/${i}.merged.reads.strict.fq ]; then
	echo ${i} "merged reads file is not empty... thats good"
	else
	echo "File is empty -- WARNING ISSUED!"
	echo ${i} "Merged reads is empty! check the script, debug, and rerun" >> $WORKING_FOLDER/${PIPELINE}.warnings.log
	fi

	if [ -s $WORKING_FOLDER/unmerged_reads/${i}/${i}.unmerged.reads.1.fq ]; then
	echo ${i} "Pair 1 reads file is not empty... thats good"
	else
	echo "File is empty -- WARNING ISSUED!"
	echo ${i} "Pair 1 reads is empty! check the script, debug, and rerun" >> $WORKING_FOLDER/${PIPELINE}.warnings.log
	fi

	if [ -s $WORKING_FOLDER/unmerged_reads/${i}/${i}.unmerged.reads.2.fq ]; then
	echo ${i} "Pair 2 reads file is not empty... thats good"
	else
	echo "File is empty -- WARNING ISSUED!"
	echo ${i} "Pair 2 reads is empty! check the script, debug, and rerun" >> $WORKING_FOLDER/${PIPELINE}.warnings.log
	fi

	########################################
	#Now do some light trimming on the reads

###########################################################################
###########################################################################
# Map reads to a reference
###########################################################################
###########################################################################
# this part will map reads to the reference genome. Because the reads are likely split into two groups, this script will loop over both types of reads. After reads have been mapped, they will be compressed into bam files, sorted, and duplicates will be removed. I will also conduct an intermediary QC step with Qualimap. Because there are inherent QC steps here, I have avoided adding extra "warnings" in the log. Remember to take a look at the qualimap and the flagstat outputs to check for inconsistencies.

	for j in merged unmerged
	do # Begin loop of j

		########################################
#J loop#	# Starting mapping
	echo "I will first map ${j} reads of" ${i}

#J loop#	# I will conduct the mapping with BWA-MEM

	if [[ ${j} == "merged" ]]; then
		echo "seems this is merged data, lets map it"
		bwa mem \
		-M \
		-t $CPU \
		$REFERENCE \
		$WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.reads.strict.fq \
		> $WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.sam

#bwa mem -M -t $CPU $REFERENCE $WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.reads.strict.fq > $WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.sam

	elif [[ ${j} == "unmerged" ]]; then
		echo "seems this is unmerged data, lets map it using a 1-2 approach"
		bwa mem \
		-M \
		-t $CPU \
		$REFERENCE \
		$WORKING_FOLDER/unmerged_reads/${i}/${i}.${j}.reads.1.fq \
		$WORKING_FOLDER/unmerged_reads/${i}/${i}.${j}.reads.2.fq \
		> $WORKING_FOLDER/unmerged_reads/${i}/${i}.${j}.sam

	else
		echo "I cant tell what type of data is this -- WARNING!"
		echo ${i} "Something is wrong at the mapping stage" $(date) \
		  $Project_name.warnings.$unique_run_id.log
	fi

#J loop#	#I will now extract some summary stats
	samtools flagstat \
	--threads $CPU \
	$WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.sam \
	> $WORKING_FOLDER/${j}_reads/${i}/${i}.flagstats_raw_${j}.sam.txt

#J loop#	#build bam files
	samtools view \
	-b \
	-q $QUAL \
	--threads $CPU  \
	$WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.sam \
	> $WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.bam

#J loop#	# Sort with picard
	# Notice that once a file has been sorted it is added the "srt" suffix
	java -Xmx$JAVAMEM \
	-jar $PICARD SortSam \
	I=$WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.bam \
	O=$WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.srt.bam \
	SO=coordinate \
	VALIDATION_STRINGENCY=SILENT

#J loop# Remove duplicates with picard
	# Notice that once a file has been sorted it is added the "rmdp" suffix
	java -Xmx$JAVAMEM \
	-jar $PICARD MarkDuplicates \
	I=$WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.srt.bam \
	O=$WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.srt.rmdp.bam \
	M=$WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.dupstat.txt \
	VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true



#J loop#	# Housekeeping
	mv $WORKING_FOLDER/${j}_reads/${i}/${i}.flagstats_raw_${j}.sam.txt \
	$WORKING_FOLDER/mapping_stats
	mv $WORKING_FOLDER/${j}_reads/${i}/${i}.${j}.dupstat.txt \
	$WORKING_FOLDER/mapping_stats

#J loop#
	done # End loop of j

###########################################################################
###########################################################################
# Merge and asses the final file
###########################################################################
###########################################################################
# Here I will merge the bam outputs from the merge and unmerged portions of the pipeline. Subsequently, I will once again sort and remove duplicated, before performing the final QC on the aligment.

# Merge bams
java -Xmx$JAVAMEM \
 -jar $PICARD MergeSamFiles \
 I=$WORKING_FOLDER/merged_reads/${i}/${i}.merged.srt.rmdp.bam  \
 I=$WORKING_FOLDER/unmerged_reads/${i}/${i}.unmerged.srt.rmdp.bam  \
 O=$WORKING_FOLDER/joint_bams/${i}.joint.bam

# Sort merge bams
java -Xmx$JAVAMEM \
 -jar $PICARD SortSam \
 I=$WORKING_FOLDER/joint_bams/${i}.joint.bam \
 O=$WORKING_FOLDER/joint_bams/${i}.joint.srt.bam \
 SO=coordinate \
 VALIDATION_STRINGENCY=SILENT

# Remove duplicates of final file
java -Xmx$JAVAMEM \
 -jar $PICARD MarkDuplicates \
 I=$WORKING_FOLDER/joint_bams/${i}.joint.srt.bam \
 O=$WORKING_FOLDER/joint_bams/${i}.joint.srt.rmdp.bam  \
 M=$WORKING_FOLDER/mapping_stats/${i}.joint.dupstat.txt \
 VALIDATION_STRINGENCY=SILENT \
 REMOVE_DUPLICATES=true



###########################################################################
###########################################################################
# Inform that sample is done
###########################################################################
###########################################################################
# This part of the pipeline will produce a notification of completion.

echo ${i} " completed" >> $WORKING_FOLDER/${PIPELINE}.completion.log

echo "pipeline completed" $(date)
