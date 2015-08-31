### HOW TO QC AN ILLUMINA RUN FILE / PROCEDURE
 
- I'm assuming you have a dockerized VM, but his should work no differently on a regular linux box
- Start by downloading the docker which contains the softare deployment: bwawrik/bioinformatics:latest

```sh 
docker pull bwawrik/bioinformatics:latest
```
- Make a data directory. I'll make '/data' in root here. Just replace your own path below

```sh 
mkdir /data
```

- Start the docker and mount /data. 

```sh 
docker run -t -i -v /data:/data bwawrik/bioinformatics:latest
```

- You can mount any directory instead of '/data' here and rename it here. So, for example, if you wanted to mount '/data' as '/cheesecake' you would execute the prior command as:

```sh 
docker run -t -i -v /data:/cheesecake bwawrik/bioinformatics:latest
```

- Change your directory to /data

```sh 
cd /data
```

 - copy your data into the folder.  This is also not strictly necessary so long your indicate an output path on the script, but I find its best to just copy the files to run the script. It keeps things together.  
 - Here are some example files:

```sh
wget https://github.com/bwawrik/MBIO5810/raw/master/sequence_data/232_R1_40k.fastq.gz
wget https://github.com/bwawrik/MBIO5810/raw/master/sequence_data/232_R2_40k.fastq.gz
gunzip *
```

- Now lets run the QC script on the sample files:

```sh
perl Illumina_Trim.pl 232_R1_40k.fastq.gz 232_R2_40k.fastq.gz 
```

- This produces a bunch of output files

| File | Description |
| :--- | :---------- |
|232_R1_40k.fastq.trimmed.paired.fq.gz_fastqc.html | QC report on trimmed forward read file|
|232_R1_40k.fastq.trimmed.paired.fq.gz_fastqc.zip | zipped verion of prior file|
|232_R1_40k.fastq_trimming_report.txt | QC stats on trimmed forward read file|
|232_R1_40k.old | original forward read file |
|232_R1_40k_fastqc.html | QC report on original forward read file|
|232_R1_40k_fastqc.zip | zipped version of prior file |
|232_R2_40k.fastq.trimmed.paired.fq.gz_fastqc.html | QC report on trimmed reverse read file|
|232_R2_40k.fastq.trimmed.paired.fq.gz_fastqc.zip | zipped version of prior file |
|232_R2_40k.fastq_trimming_report.txt ||
|232_R2_40k.old | original reverse read file |
|232_R2_40k_fastqc.html | QC report on original reverse read file |
|232_R2_40k_fastqc.zip | zipped version of prior file |
|F.QCed.fasta | Trimmed forward read file in fasta format |
|F.QCed.fastq | Trimmed forward read file in fastq format |
|R.QCed.fasta | Trimmed reverse read file in fasta format |
|R.QCed.fastq | Trimmed reverse read file in fastq format |


### EXAMPLES OF ISSUES THAT NEEED ADRESSING

#### READ QUALITY

![READ QUALITY] (images/E5358E41-40A2-48A0-A2D1-153B48B4C351.jpg)

#### UNTRIMMED ADAPTER

![UNTRIMMED ADAPTER] (images/A66A5797-194E-4FD9-B299-7E292A29DDB9.jpg)

#### BIMODALGC-PLOT

![POSSIBLE CONTAMINATION] (images/20256071-7539-4EDC-B5F6-8341F41D86F2.jpg)

#### PROBLEMS WITH ILLUMINA RUN

![POSSIBLE BAD RUN] (images/C2237B90-781F-4D1A-A78E-C3586D9F6A3B.jpg)

#### POLY-N RUNS

![POLY-N RUNS] (images/57EBEB0A-24D1-4CC9-96D2-A852E5A5D7A6.jpg)

#### DEVIATION OF NUCLEOTIDE FREQUENCIES FROM AVERAGE

![DEVIATION FROM NUCLEOTIDE FREQUENCY AVERAGES] (images/F6B96830-2700-4CA1-89D3-1EE0AC5E9C89.jpg)



