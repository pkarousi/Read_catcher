~~~~~~~~~~Read catcher~~~~~~~~~~
Read_catcher.pl requires two input files: A keyword file (.txt file) and a FASTQ (.fastq) or FASTA (.fasta)  file. 
Read_catcher.pl and the two input files should be located in the same folder. A succesfull run can be done using the following command:

perl Read_catcher_v2.pl keywordfile.txt FASTA_file.fasta (provided) OR perl Read_catcher.pl keywordfile.txt FASTQ_file.fastq

The keyword file needs to be a text file providing sence and antisence keywords, using tab as delimiter. The keywords can contain Perl regular expressions.

The user will be asked to enter the name of the output folder. If the given name already exists, the user will be asked to overwritte the folder, or provide a new folder name.
Next, the user will be asked to tag the FASTA or FASTQ records with the output file name.

After a succesfull run, the following files will be produced:
- OUTPUTFILENAME_freq.txt --> Provides sense and antisense keywords, and their frequency within FASTA and FASTQ files, listed in descending row based on their frequency.
- OUTPUTFILENAME_selected.fasta --> Provides records in which at least one keyword is found in FASTA file format.
- OUTPUTFILENAME_selected.fastq --> Provides records in which at least one keyword is found in FASTQ file format.

If the user chooses to tag files, the following files will be also produced:
- OUTPUTFILENAME_selected_tagged.fasta --> Provides records in which at least one keyword is found in FASTA file format, after having tagged each record with the output file name.
- OUTPUTFILENAME_selected_tagged.fastq --> Provides records in which at least one keyword is found in FASTQ file format, after having tagged each record with the output file name.

If a FASTQ file is used as input file, the following file will be also produced:
- INPUTFILENAME.fa --> The FASTQ file used as input file is converted to FASTA file.
