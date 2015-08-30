## OVERVIEW

### PURPOSE

- RNAseq Transcriptome data analysis notes, code, and instructions

### WHAT YOU WILL NEED

- VM or desktop computer with at least 8GB or RAM
- linux operating system '
- installation of latest version of Docker (see link below for instructions based on OS)
  (https://docs.docker.com/installation/)


' If you are using a desktop, I would recommend a dedicated linux machine. I frequently do this with a virutal box under Windows, but the machine I use has 32GB of RAM. Windows is very memory hungry and you have to accomodate running linux ontop of another OS

### SOFTWARE

The script requires pulling and running a docker repository. The docker I use contains a lot of software, not all of it is needed. In the long run, it might be worth making a docker that just contains the software essential for QC. For now I use the docker repository:

bwawrik/bioinformatics:latest

(https://hub.docker.com/r/bwawrik/bioinformatics/)

This docker contains :

DOCKER ‘bwawrik/bioinformatics:latest’ Software contents:

Bioperl			http://www.bioperl.org/wiki/Main_Page
Biopieces			https://code.google.com/p/biopieces/
Biopython    			http://biopython.org/wiki/Main_Page    	
BLAST suite 			http://blast.ncbi.nlm.nih.gov	
blat           			http://www.kentinformatics.com/
bowtie          			http://bowtie-bio.sourceforge.net/index.shtml	
bowtie2			http://bowtie-bio.sourceforge.net/bowtie2/index.shtml
bwa            			http://bio-bwa.sourceforge.net/
CAP3			http://seq.cs.iastate.edu/cap3.html
CDBtools			http://sourceforge.net/projects/cdbtools/	
cd-hit			http://weizhongli-lab.org/cd-hit/	
ChimeraSlayer		http://microbiomeutil.sourceforge.net/	
Cutadapt			https://code.google.com/p/cutadapt/
CytoScape			http://www.cytoscape.org/	
Diamond			http://ab.inf.uni-tuebingen.de/software/diamond/
ea-utils.1.1.2-537     		https://code.google.com/p/ea-utils/		
EMIRGE			https://github.com/csmiller/EMIRGE
FastQC			http://www.bioinformatics.babraham.ac.uk/projects/fastqc/
fastx-toolkit 0.0.12  		http://hannonlab.cshl.edu/fastx_toolkit/		
FragGeneScan		http://omics.informatics.indiana.edu/FragGeneScan/	
gnuplot         			http://www.gnuplot.info/	
HMMER 3.0       		http://hmmer.janelia.org/	
HomerTools			http://homer.salk.edu/homer/ngs/homerTools.html	
idba				https://code.google.com/p/hku-idba/
Jellyfish      	 		http://www.genome.umd.edu/jellyfish.html	
MaxBin			http://sourceforge.net/projects/maxbin/
MEGAN 4         		http://ab.inf.uni-tuebingen.de/software/megan5/	
mummer          		http://mummer.sourceforge.net/	
muscle          			http://www.ebi.ac.uk/Tools/msa/muscle/	
prodigal			http://prodigal.ornl.gov/
Pysam			https://pypi.python.org/packages/source/p/pysam/	
Ray 2.2.0			http://denovoassembler.sourceforge.net/
RDP Classifier		http://downloads.sourceforge.net/project/rdp-classifier	
Samtools			http://samtools.sourceforge.net/
SeqPrep			https://github.com/jstjohn/SeqPrep	
SMALT           		https://www.sanger.ac.uk/resources/software/smalt/	
SourceTracker		http://downloads.sourceforge.net/project/sourcetracker	
Trimmomatic			http://www.usadellab.org/cms/?page=trimmomatic	
Velvet    			https://www.ebi.ac.uk/~zerbino/velvet/	
vserach			https://github.com/torognes/vsearch
RAPSearch2.23_64bits  http://sourceforge.net/projects/rapsearch2/



