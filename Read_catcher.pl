#COMMAND: perl Read_catcher.pl keywords.txt FILENAME.fa / perl Read_catcher.pl keywords.txt FILENAME.fastq

#keywords should be provided as two lists separated with tab.

#! user/bin/perl -w

print "Enter the name of the output folder:\n"; 

while ($f= <STDIN>) 
	{
		chomp $f;
	
    if (-d $f) 
			{
        print "Folder '$f' already exists... Overwrite its contents(Y/N)?";
        
        while ($ow= <STDIN>) 
					{
						chomp $ow;
        
           if ($ow =~ m/^[Y]$/i)
						{
							$loc = "./$f";
							mkdir $loc unless -d $loc;                                                                                 
							print "Folder '$f' is overwrited.\n\n";
							last; 
						}
            
					elsif ($ow =~ m/^[N]$/i)
						{                                                                               
							print "\nSelect another name for the folder.\n";
							$f= <STDIN>;
							chomp $f;
							if (-d $f)
								{
              		print "Folder '$f' already exists... Overwrite its contents(Y/N)?";
								}
						else
							{
								$loc = "./$f";
								mkdir $loc unless -d $loc;                                                                                
								print "Folder '$f' created.\n\n";
								last;
							}   
						}
            
     			else
      			{	                                                                                                                                               
							print "\nInvalid command...Overwrite contents(Y/N)?";                                                          
      			}
					}
					last;                                                                                                                                                  
			} 
      	
 
    else 
    	{
    		$loc = "./$f";
   			mkdir $loc unless -d $loc;                                                                              
   			print "Folder '$f' created.\n\n";
    		last;  
    	}
	}
	               
$file1=$ARGV[0]; $file=$ARGV[1];

if ($file=~/(.*).fastq/ || $file=~/(.*).fq/)
	{
		$fastq=$ARGV[1];
		$fn=$1;			
		$fasta="$fn.fa";
		
		open (FILE, "$fastq") || die "Couldn't open $fastq\n"; 
		open (FILE2, ">", "$fasta");

		$header, $sequence;

		while(<FILE>) #creates fasta from fastq
			{
   			if ($_ =~ /^@(.*)/) #takes header
    			{
      			if($header ne "") 
       			{
							print FILE2 "\>$header\n";
							print FILE2 "$sequence\n";
      			}
    				$header = $1;
    				$sequence = "";
      		}
			elsif ($_=~/^[A-Z]+/i)
				{ 
					$sequence.= $_; #if not header, takes sequence
				}
			}
	
		print FILE2 "\>$header\n";
		print FILE2 "$sequence\n";

		close FILE; close FILE2;
	}
	
elsif ($file=~/(.*).fasta/ || $file=~/(.*).fa/)
	{
		$fasta=$ARGV[1];
	}
else
	{
		die "Invalid file type\n";
	}
	
print "Enter the name of the output files\n";
$name=<STDIN>;
chomp $name;

$file2="temp.fa"; $file3="temp2.fa"; $file9="temp0.fa"; $file=$name."_1line.fa";
$file4=$name."_selected.fasta";$file6=$name."_selected.fastq";
$file10=$name."_nonselected.fasta"; $file11=$name."_nonselected.fastq";
$file5=$name."_freq.txt";
$file7=$name."_selected_tagged.fastq"; $file8=$name."_selected_tagged.fasta";

open (INPUT, "<$fasta") || die "Couldn't open $fasta\n"; 
open (OUTPUT, ">", "$loc/$file");

while ($line1=<INPUT>) #creates one-line fasta
	{
		$line1=~s/\n/\t/g;
		$line1=~s/\>/\n\>/g;
		
		print  OUTPUT $line1;
	}
					
close INPUT; close OUTPUT;

open (INPUT1, "<$file1") || die "Couldn't open $file1\n";

while (<INPUT1>)  #puts keywords in two hashes
 {
 	if ($_=~/(.*)\t(.*)/)
 		{
 			$freq1{$1}=0;
 			$freq2{$2}=0;
 		}
 }

close INPUT1;

open (INPUT2, "<$loc/$file") || die "Couldn't open $file\n"; 
open (OUTPUT1, ">", $file2);
open (OUT, ">", "$loc/$file5");

while ($line=<INPUT2>) #searches hash values in one-line fasta and counts freq
	{ 		
			foreach  $sense (keys %freq1) 
				{	
					if ($line=~$sense) 
  					{	
  						$freq1{$sense}++;
  						print OUTPUT1 "$line\n";
  					}  				
   			}
	}

print OUT "Sense keywords\n";

foreach  $sense (sort { $freq1{$b} <=> $freq1{$a} } keys %freq1) #prints keyword and freq in file
	{
  	print OUT "$sense\t$freq1{$sense}\n";		
	}
	
close INPUT2;

open (INPUT2, "<$loc/$file") || die "Couldn't open $file\n"; 

while ($line=<INPUT2>) #searches hash values in one-line fasta and counts freq
	{ 
		foreach  $antisense (keys%freq2) 
			{		
  			if ($line=~$antisense) 
  				{		
  					$freq2{$antisense}++;  					
  					print OUTPUT1 "$line\n";
  				}
   		}

	}

print OUT "\nAntisense keywords\n";

foreach  $antisense (sort { $freq2{$b} <=> $freq2{$a} } keys %freq2) #prints keyword and freq in file
	{
  	print OUT "$antisense\t$freq2{$antisense}\n";		
	}

close INPUT2; close OUTPUT1; close OUT;

open (INPUT3, "<$file2") || die "Couldn't open $file2\n"; 
open (OUTPUT2, ">", $file3);

%duplicates=();

while (<INPUT3>) #removes duplicate lines
	{
    $duplicates{$_}++;
	}

print OUTPUT2 keys %duplicates;
    
close INPUT3; close OUTPUT2;

#unlink $file2;

open (OUTPUT0, ">", $file9); 
open (FILE0, "<$loc/$file") || die "Couldn't open $file\n";
open (FILE00, "<$file3") || die "Couldn't open $file3\n";

%selected;
@selected{map { unpack 'A*', $_ } <FILE00>} = ();

while (<FILE0>) # prints in file reads not containing any keyword, after comparing selected with input data
	{
    print OUTPUT0 unless exists $selected{unpack 'A*', $_};
	}

close FILE0; close FILE00; close OUTPUT0;

open (INPUT4, "<$file3") || die "Couldn't open $file3\n"; 
open (OUTPUT3, ">", "$loc/$file4");

while ($line2=<INPUT4>) #creates fasta from selected one-line fasta
	{
		$line2=~s/^\s*$//; #removes empty lines
		$line2=~s/\t/\n/g;
		$line2=~s/\n\n/\n/g;
		print OUTPUT3 $line2;
	}
	
close INPUT4; close OUTPUT3;

unlink $file3;
unlink "$loc/$file"; #deletes one-line fasta. if needed, add a '#' before unlink.

open (INPUT14, "<$file9") || die "Couldn't open $file3\n"; 
open (OUTPUT13, ">", "$loc/$file10");

while ($line2=<INPUT14>) #creates fasta from non-selected one-line fasta
	{
		$line2=~s/^\s*$//; #removes empty lines
		$line2=~s/\t/\n/g;
		$line2=~s/\n\n/\n/g;
		print OUTPUT13 $line2;
	}
	
close INPUT14; close OUTPUT13;

unlink $file9;

print "Tag SELECTED fasta file? (Y/N)\n";

while ($answer1= <STDIN>) 
	{
		chomp $answer1;
		
		if ($answer1 =~ m/^[Y]$/i)
			{
				open (FILE5, "<$loc/$file4") || die "Couldn't open $file4\n";
				open (FILE6, ">", "$loc/$file8");

				while ($line=<FILE5>) #substitutes > and tags lines.
					{
						$line=~s/\>/\>$name\_/g;
						print FILE6 $line;
					}
				
				close FILE5; close FILE6;
			}
			
		elsif ($answer1 =~ m/^[N]$/i)
			{ 
				unlink $file8;
			}
		last; 
	}


print "Do you need FASTQ files? (Y/N)\n";

while ($answer1= <STDIN>) 
	{
		chomp $answer1;
		
		if ($answer1 =~ m/^[Y]$/i)
			{
			open (FILE, "$loc/$file4") || die "Couldn't open $file4\n"; 
open (FILE2, ">", "$loc/$file6");

$header1, $sequence1, $sequence_length, $sequence_quality;

while(<FILE>) #creates fastq from selected fasta
	{
    chomp $_;
    
    if ($_ =~ /^>(.+)/) #takes header
    	{
      			if($header1 ne "") 
       				{
								print FILE2 "\@$header1\n";
								print FILE2 "$sequence1\n";
								print FILE2 "+\n";
								print FILE2 "$sequence_quality\n";
      				}
    				$header1 = $1;
		 				$sequence1 = "";
						$sequence_length = "";
						$sequence_quality = "";
       }
       
		else 
			{ 
				$sequence1.= $_; #if not header, takes sequence
				$sequence_length = length($_); 
				
				for($i=0; $i<$sequence_length; $i++) #places notional quality score
					{
						$sequence_quality.= "-"
					} 
			}
	}
	
print FILE2 "\@$header1\n";
print FILE2 "$sequence1\n";
print FILE2 "+\n";
print FILE2 "$sequence_quality\n";

close FILE; close FILE2;

open (FILE11, "$loc/$file10") || die "Couldn't open $file4\n";
open (FILE12, ">", "$loc/$file11");

$header2, $sequence2, $sequence_length2, $sequence_quality2;

while(<FILE11>)  #creates fastq from non-selected fasta
	{
    chomp $_;
    
    if ($_ =~ /^>(.+)/) #takes header
    	{
      			if($header2 ne "") 
       				{
								print FILE12 "\@$header2\n";
								print FILE12 "$sequence2\n";
								print FILE12 "+\n";
								print FILE12 "$sequence_quality2\n";
      				}
    				$header2 = $1;
		 				$sequence2 = "";
						$sequence_length2 = "";
						$sequence_quality2 = "";
       }
       
		else 
			{ 
				$sequence2.= $_; #if not header, takes sequence
				$sequence_length2 = length($_); 
				
				for($i=0; $i<$sequence_length2; $i++) #places notional quality score
					{
						$sequence_quality2.= "-"
					} 
			}
	}
	
print FILE12 "\@$header2\n";
print FILE12 "$sequence2\n";
print FILE12 "+\n";
print FILE12 "$sequence_quality2\n";

close FILE11; close FILE12;



print "Tag SELECTED fastq file? (Y/N)\n";

while ($answer= <STDIN>) 
	{
		chomp $answer;
		
		if ($answer =~ m/^[Y]$/i)
			{
				open (FILE3, "<$loc/$file6") || die "Couldn't open $file6\n";
				open (FILE4, ">", "$loc/$file7");

				while ($line=<FILE3>) #substitutes @ and tags lines.
					{
						if ($line=~ /^@(.*)/)
						{
							$line=~s/\@/\@$name\_/g;
						}
						print FILE4 $line;
					}
				
				close FILE3; close FILE4;
			}
			
		elsif ($answer =~ m/^[N]$/i)
			{ 
				unlink $file7;
			}
		last; 
	}
			}
			
		elsif ($answer1 =~ m/^[N]$/i)
			{ 
				unlink $file6;
				unlink $file11;
			}
		last; 
	}








