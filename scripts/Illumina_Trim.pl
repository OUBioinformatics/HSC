#!/usr/bin/env perl
use strict;
use warnings;
#--INCLUDE PACKAGES-----------------------------------------------------------$
use IO::String;
use File::Basename;
use File::Copy;
use Cwd;
#-----------------------------------------------------------------------------$
#----SUBROUTINES--------------------------------------------------------------$
#-----------------------------------------------------------------------------$
sub get_file_data
    {
    my ($file_name) = @_;
    my @file_content;
    open (PROTEINFILE, $file_name);
    @file_content = <PROTEINFILE>;
    close PROTEINFILE;
    return @file_content;
    } # end of subroutine get_file_data;


    sub WriteArrayToFile
    {
    my ($filename, @in) = @_;
    my $a = join (@in, "\n");
    open (OUTFILE, ">$filename");
    foreach my $a (@in)
      {
      print OUTFILE $a;
      print OUTFILE "\n";
      }
    close (OUTFILE);
     }

#-----------------------------------------------------------------------------
# Input parameters
#-----------------------------------------------------------------------------

my $ForwardReads = $ARGV[0];
my $ReverseReads = $ARGV[1];
my $minLen = $ARGV[2];
my $maxLen = $ARGV[3];
my $minQ = $ARGV[4];
my $ResultDirectory = $ARGV[5];


if (not defined $ARGV[2] ) { $minLen = 50;}
if (not defined $ARGV[3] ) { $maxLen = 250;}
if (not defined $ARGV[4] ) { $minQ =30;}
if (not defined $ARGV[5] ) { $ResultDirectory = cwd();}
    
    
my @adapter_array;

#-----------------------------------------------------------------------------
# test if reads zipped; if yes, unzip
#-----------------------------------------------------------------------------

my @testzip = split (/\./,$ForwardReads);
my $test_zip_length = scalar (@testzip);
if ($testzip[$test_zip_length-1] eq "gz") 
    {
    system ("gunzip ".$ForwardReads);
    $ForwardReads =~ s/.gz//g;
    printf $ForwardReads;
    }
@testzip = split (/\./,$ReverseReads);
$test_zip_length = scalar (@testzip);
if($testzip[$test_zip_length-1] eq "gz") 
    {
    system ("gunzip ".$ReverseReads);
    $ReverseReads =~ s/.gz//g;
    printf $ReverseReads;
    }

#-----------------------------------------------------------------------------
# Run fastQC
#-----------------------------------------------------------------------------

system("mkdir -p ".$ResultDirectory."/temp");
#system("fastqc ".$ForwardReads." -o ".$ResultDirectory."/temp");
#system("fastqc ".$ReverseReads." -o ".$ResultDirectory."/temp");
system("fastqc ".$ForwardReads." -o ".$ResultDirectory);  #not putting them into temp directory any more
system("fastqc ".$ReverseReads." -o ".$ResultDirectory);

#-----------------------------------------------------------------------------
# remove nextera transposons with trim_galore
#-----------------------------------------------------------------------------

my $system_string;
$system_string = "trim_galore --phred33 --paired -q ".$minQ." --nextera -o ".$ResultDirectory."/ ".$ForwardReads." ".$ReverseReads;
system($system_string);
my $f_b = $ForwardReads; $f_b =~ s/.fastq//;
my $r_b = $ReverseReads; $r_b =~ s/.fastq//;

$system_string = ("mv ".$ForwardReads." ".$f_b.".old");
system ($system_string);
printf $system_string."\n\n";

$system_string =  ("mv ".$ReverseReads." ".$r_b.".old");
system ($system_string);
printf $system_string."\n\n";

$system_string = ("mv ".$f_b."_val_1.fq ".$f_b.".fastq");
system ($system_string);
printf $system_string."\n\n";

$system_string = ("mv ".$r_b."_val_2.fq ".$r_b.".fastq");
system ($system_string);
printf $system_string."\n\n";

#-------------get forward adapters--------------------------------------------
#-----------------------------------------------------------------------------

my $f = $ForwardReads."c"; $f =~ tr/.fastqc/_fastqc/;
my ($filename, $dirs, $suffix) = fileparse($f);
 
printf "\n\n";
system("unzip ".$ResultDirectory."/temp/".$filename.".zip -d ".$ResultDirectory."/temp/");
my @Fanalysis = get_file_data ($ResultDirectory."/temp/".$filename."/fastqc_data.txt");
($filename, $dirs, $suffix) = fileparse($ForwardReads);
my $Ffilename = $filename;
my $active =0;
foreach my $s (@Fanalysis)
  {
  my @ug = split (/\t/, $s);
  if ($ug[0] eq ">>Overrepresented sequences")
     {$active = 1;next;}
  if ($s eq "#Sequence	Count	Percentage	Possible Source\n")
     {next;} 
  if ($s eq ">>END_MODULE\n")
     {$active = 0;next;}
  if ($active == 1)
     {
     my @tt = split (/\t/, $s); 
     if (length $tt[0] >5)
        {
        push (@adapter_array, "-b ".$tt[0]);
        printf ("\n".$tt[0]);
        }
     }  
  }

#-----------------------------------------------------------------------------
#---------get reverse adapters------------------------------------------------
#-----------------------------------------------------------------------------


$f = $ReverseReads."c"; $f =~ tr/.fastqc/_fastqc/;
($filename, $dirs, $suffix) = fileparse($f);
printf "\n\n";
system("unzip ".$ResultDirectory."/temp/".$filename.".zip -d ".$ResultDirectory."/temp/");
my @Ranalysis = get_file_data ($ResultDirectory."/temp/".$filename."/fastqc_data.txt");
($filename, $dirs, $suffix) = fileparse($ReverseReads);
my $Rfilename = $filename;

$active =0;
foreach my $s (@Ranalysis)
  {
  my @ug = split (/\t/, $s);  
  if ($ug[0] eq ">>Overrepresented sequences")
     {$active = 1;next;}
  if ($s eq "#Sequence	Count	Percentage	Possible Source\n")
     {next;}
  if ($s eq ">>END_MODULE\n")
     {$active = 0;next;}
  if ($active == 1)
     {
     my @tt = split (/\t/, $s);
     if (length $tt[0] >5)
        {
        push (@adapter_array, "-b ".$tt[0]);
       printf ("\n".$tt[0]);
        }
     }
  }

push (@adapter_array, "-b GATCGGAAGAGCACACGTCTGAACTCCAGTCAC");
push (@adapter_array, "-b AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT");
#push (@adapter_array, "-b AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT");
push (@adapter_array, "-e 0.15");
push (@adapter_array, "-q ".$minQ);
push (@adapter_array, "-n 2");


#-----------------------------------------------------------------------------
#--write adapter file---------------------------------------------------------
#-----------------------------------------------------------------------------

my $outfile_name = $ResultDirectory."/temp/".$Ffilename.".conf";

WriteArrayToFile ($outfile_name, @adapter_array);

#-----------------------------------------------------------------------------
#--trim adapter sequences-----------------------------------------------------
#-----------------------------------------------------------------------------
printf "\n\n";
my $confstring;
foreach my $ty (@adapter_array) { $confstring .= $ty." ";}
system ("cutadapt ".$confstring.$ForwardReads." > ".$ResultDirectory."/temp/".$Ffilename.".cutadapt");
system ("cutadapt ".$confstring.$ReverseReads." > ".$ResultDirectory."/temp/".$Rfilename.".cutadapt");


#-----------------------------------------------------------------------------
#-trim to Q30-----------------------------------------------------------------
#-----------------------------------------------------------------------------

$confstring = "read_fastq -e base_33 -i ".$ResultDirectory."/temp/".$Ffilename.".cutadapt | trim_seq -m ".$minQ." | write_fastq -o ".$ResultDirectory."/temp/".$Ffilename.".cutadapt.q30 -x\n";
system ($confstring);
$confstring = "read_fastq -e base_33 -i ".$ResultDirectory."/temp/".$Rfilename.".cutadapt | trim_seq -m ".$minQ." | write_fastq -o ".$ResultDirectory."/temp/".$Rfilename.".cutadapt.q30 -x\n";
system ($confstring);

#-----------------------------------------------------------------------------
#- remove poly-A----------
#-----------------------------------------------------------------------------
chdir($ResultDirectory."/temp/");
$confstring = "homerTools trim -3 AAAAAA ".$ResultDirectory."/temp/".$Ffilename.".cutadapt.q30";
system($confstring);
$confstring = "homerTools trim -3 AAAAAA ".$ResultDirectory."/temp/".$Rfilename.".cutadapt.q30";
system($confstring);

#-----------------------------------------------------------------------------
#-MINLEN: 50; paired only; MAXLEN (CROP):250----------------------------------
#-----------------------------------------------------------------------------

$confstring = "trimmomatic PE -phred33 ".$ResultDirectory."/temp/".$Ffilename.".cutadapt.q30.trimmed ".$ResultDirectory."/temp/".$Rfilename.".cutadapt.q30.trimmed ".$Ffilename.".trimmed.paired.fq.gz.fastq ".$Ffilename.".trimmed.unpaired.fq.gz ".$Rfilename.".trimmed.paired.fq.gz.fastq ".$Rfilename.".trimmed.unpaired.fq.gz MINLEN:".$minLen." CROP:".$maxLen;
printf "\n\n".$confstring."\n\n";
system($confstring);

#-----------------------------------------------------------------------------
#-Run qc on paired files
#-----------------------------------------------------------------------------
system("fastqc ".$ResultDirectory."/temp/".$Ffilename.".trimmed.paired.fq.gz.fastq -o ".$ResultDirectory);
system("fastqc ".$ResultDirectory."/temp/".$Rfilename.".trimmed.paired.fq.gz.fastq -o ".$ResultDirectory);

#$confstring = "cp ".$ResultDirectory."/temp/".$Ffilename.".trimmed.paired.fq.gz.fastq ".$ResultDirectory."/".$Ffilename.".QCed.fastq";

$confstring = "cp ".$ResultDirectory."/temp/".$Ffilename.".trimmed.paired.fq.gz.fastq ".$ResultDirectory."/F.QCed.fastq";
system($confstring);

#$confstring = "cp ".$ResultDirectory."/temp/".$Rfilename.".trimmed.paired.fq.gz.fastq ".$ResultDirectory."/".$Rfilename.".QCed.fastq";

$confstring = "cp ".$ResultDirectory."/temp/".$Rfilename.".trimmed.paired.fq.gz.fastq ".$ResultDirectory."/R.QCed.fastq";
system($confstring);

#-----------------------------------------------------------------------------
#Convert to fasta
#-----------------------------------------------------------------------------

$confstring = "read_fastq -i ".$ResultDirectory."/R.QCed.fastq | write_fasta -o ".$ResultDirectory."/R.QCed.fasta -x";
system ($confstring);

$confstring = "read_fastq -i ".$ResultDirectory."/F.QCed.fastq | write_fasta -o ".$ResultDirectory."/F.QCed.fasta -x";
system ($confstring);

#------------------------------



#-------------------
#clearnup
#--------------------

system ("rm -rf ".$ResultDirectory."/temp/");
#system ("rm  ".$ResultDirectory."/*.unpaired.fq.gz");
#system ("rm .$ResultDirectory."*.zip");




