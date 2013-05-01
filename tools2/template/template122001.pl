#!/usr/bin/perl

#nmv typed in aaron's template script from a paper copy on 11/30/00
# perl template030801.pl standard lexicon (newlexicon)
# a couple of comments (6/21/01 NMV): 
# 1) script will try lexicon.lex first. 
# 2) If the word if not there or the symbols are different from those in standard.label, 
#     the script will try pronlex and websters's (8/7/01, in that order). 
# 3) Failing these, the user will be prompted to enter the phone sequence themselves
#
# miscellaneous comments (8/2/01):
# -- there were some discrepancies between the labels in standard.label and those that the 
# labels used themselves (ls vs l and th). 7/31/01: changed standard.label file on UNIX 
# -- OV is now labeled only on vowels that are utterance initial or before a stop 
# (previously, bug permitted OV labels before any label that began with ptkgdb, e.g. dj)
# -- OV is now labeled only on vowels that are utterance initial or before a stop # (previously, bug permitted OV labels before any label that began with ptkgdb, e.g. dj)
# -- the dj/ch labels were not being printed three times (just twice). This is now fixed.
# -- "x" not "ex" and "l" not "ls" 

# sample pronlex dictionary entry
# aback	.xb'@k

# sample webster dictionary entry
# SP: massacre
# PR: m'@<sI<kX
# BCF: 1
# ST: SUR 

# a little error checking, left over (and now disabled) from version where input files could be specified
# now input is standard.label, lexicon.lex, the two dictionarys
# output is output.label 
#if( $#ARGV == -1){
#	print "Syntax template [stand temp file][label_file][lexicon_file]\ne.g. perl 
#	#template011801.pl standard lexicon\nno extensions on standard and lexicon ";
#	exit(1); 
#}

print "\n\n8/2/01 this script \n\ta) reads in an utterance (seq of words),\n\tb) finds the phonetic transcription and \n\tc) prints out a file (output.label)\n\noutput.label can be used in the label transcription program\n w/ xkl for landmark labelers\n\nThis script produces double or triple labels in the output sequence\n for phonemes which have more than one landmark.\nIt also adds [OV] labels to help label Voice Onsets in certain contexts \n (after stops and utterance intitial)\n\n\nREQUIREMENTS: ascii versions of \n\t\tstandard.label, lexicon.lex in this directory,and WEBSTERS.TXT and pronlex.txt in /usr/users/prosody/landmark/source/ directory\n\n\n";  

#create proper filenames
$utterance = "Orthography: ";
$standard = "standard.label";  
$lexicon = "lexicon.lex";
$newLabel = "output.label"; 
$dictfile = "/usr/users/prosody/landmarks/source/WEBSTERS.TXT";
$pronlex = "/usr/users/prosody/landmarks/source/pronlex.txt";


#store utterance for file
print ("Enter the utterance: "); 
$sentence = <STDIN>;
$utterance = $utterance . $sentence; 

$sentence = lc($sentence);
@sentence = split(' ',$sentence);
	
#open and read in the STANDARD phone labels
open (STANDARD,"<".$standard) or die("$!, stopped");
@segs =<STANDARD>;
close(STANDARD);

#open the label (output) file
open(LABELFILE, ">".$newLabel) or die ("$!, stopped"); 
print LABELFILE ("Landmark File Version 2.0\n");
print LABELFILE ($utterance);
print LABELFILE ("\n");
print LABELFILE ("Flavor: transcription\n");

# open the (old) lexicon file and read in 
open (LEXICON,"<".$lexicon) or die("$!, stopped");
@lexs =<LEXICON>;
close(LEXICON);

$end = @lexs;

foreach $word (@sentence){
	print "\t\t $word\n";

	$foundWord = 0; 

	# search the lexicon (usually lexicon.lex) for the word
	for($index = 0 ; $index <$end; $index ++){
	    @tokens = split(' ',$lexs[$index]); 
	   
	    if($tokens[1]  eq "$word"){
		$_ = $lexs[$index]; 

		if(/(\(.*?\))/){
			@lphns = split (/\(.|\s{1,}|\)/, $1);
		}
		$linend = @lphns;
		($junk,@lphns) = @lphns; # get rid of the first null   

		
		#double up landmarks
		#add the [OV] (onset of voicing)later 
		$linend = @lphns;
		$i =0; 
		@phns=(); 
		foreach(@lphns){ #$j=0; $j< $linend; $j++){
			push(phns,$_);		
			# double some symbols (and triple two) 
			if( /dj|ch/){
				push(phns,$_);
				push(phns,$_);
			}elsif(/sh|zh|dh|ng|th/){
				push(phns,$_);
			}elsif(/[lnmptkdbgszfvq]/){
				push(phns,$_);
			}		
		} #foreach in lphns

print "phns from lexicon.lex are @lphns";
#$wait = <STDIN>;

		$foundWord = $index; 
	    }	  
	} # found in lex 

	if($foundWord){
		$end = @segs;
		foreach $phone (@phns){
			if($phone ne " "){
				for($index =0; $index <$end; $index ++){  
						# some symbol abbreviations in lexicon.lex don't match those in standard.txt 
						# (the ref of all symbol abbreviation). In that case, look up in dictionary
					$_ = $segs[$index];
							#<
							#Time: (nil)
							#Symbol: ih
							#Prosody: (nil)
							#Polarity: unspecified
							#Features:
							#high +
							#back -
							#low -
							#const_tongue_root -
							#vowel +
							#adv_tongue_root -
							#>
					if($segs[$index] eq "Symbol: $phone\n"){
					   $foundSymbol = "yes";
		     			}
				}  # for
				if( $foundSymbol ne "yes" ){
					$foundWord = 0; 
				}
				$foundSymbol = "no";
			} # phone not the final space
		} #foreach 
	}  # if foundWord
	
	# went through whole lexicon and couldn't find word, try pronlex dictionary
	if($foundWord eq 0){ 
		# open PRONLEX dictionry file and read in 
		open (DICTIONARY,"<".$pronlex) or die("$!, stopped");
			
		do{			# get rid of preamble
			$entry = <DICTIONARY>;
			# print $entry . "\n";
		} while ( $entry =~ /^#/);
		
		do{ 
			@line = split ' ', $entry;
			if( @line[0] eq $word ){
				print "found in pronlex dictionary: $word\n"; 
				$foundWord = 1; 
				@syls = split /['\-`*<\.]/, @line[1];
				$_ = join '', @syls;
				@dphns = split (//, $_);
print "\npronlex dictionary pronunciation: @dphns\n"; 
#$wait = <STDIN>;
				@phns = (); 
				dict2LandLabels(@dphns); 
			} # line[0] is the target word 	
		}while ($entry = <DICTIONARY> and $foundWord eq 0); 
	} # if not foundword
	close (DICTIONARY);
	# end of checking Pronlex dictionary

# went through whole lexicon and couldn't find word, try Webster's dictionary
	if($foundWord eq 0){ 
		# open dictionry file and read in 
		open (DICTIONARY,"<".$dictfile) or die("$!, stopped");

		do{				# skip preamble
			$entry = <DICTIONARY>;
			# print $entry . "\n";
		} unless( $entry =~ /^SP/);

	#after preamble, searh for word in Webster's
		do{
			if( $entry eq "SP: $word\n" ){
				print "found in Webster dictionary: $entry\n"; 
				$foundWord = 1; 
				$entry = <DICTIONARY>;
				@line = split ' ', $entry;
				@syls = split /['\-`*<]/, @line[1];
				$_ = join '', @syls;
				@dphns = split (//, $_);
				print "\nWebster dictionary pronunciation: @dphns\n"; 
				@phns = ();
				dict2LandLabels(@dphns)
			}	
		}while ($entry = <DICTIONARY> and $foundWord eq 0); 
	}

	close (DICTIONARY);
	# end of checking Webster's dictionary

	# looked in lex, Websters and pronlex without success, prompt user
	if($foundWord eq 0){
		#store phoneme string and parse it
		print ("Word not found in either lexicon or dictionary.\nEnter string of phonemes: ");
		$phns = <STDIN>; 
		@phns = split(' ',$phns);

		foreach $phone (@phns){
			print( $phone);
			print("\n");
		} 
	} # add your own phones

	# concatenate all the phones in this sentence (so far) without delimiters between words
	@sentphns = (@sentphns,@phns);

} # end, while through sentence

#printing out the sequence of phones to the Labelfile (to be used in label transcription program w/ xkl) 
	print "\n\nfull sentence transcription (w/ repeated landmarks): @sentphns\n";
#$wait = <STDIN>;


# walk through the standard.label file and find the data for each lm in sentphns
	$end = @segs;
	
	$sentend = @sentphns;
#####nmv: start looking here for VO, search through the sentphones
	for($j=0; $j< $sentend;$j++){
		$phone = $sentphns[$j];

		for($index =0; $index <$end; $index ++){
			if($segs[$index] eq "Symbol: $phone\n"){
				#$_ = $phone; 
				if($phone =~ /[a.|e.|i.|o.|u.]| rr/ ){  # this is a vowel
# if($sentphns[$j-1] =~ / "p"|"t"|"k"|"b"|"d"|"g" /)
				    if(($sentphns[$j-1] =~ /[ptkbdg]/)&&($sentphns[$j-1] ne "dh")
				       &&($sentphns[$j-1] ne "dj")&&($sentphns[$j-1] ne "th")){ 
						print "in a vowel: $phone,  previous stop $sentphns[$j-1]\n";
						#$wait = <STDIN>;
						printOV();
					}    	# previous phone is a stop	
					elsif($j == 0){
						print "first phone is vowel: $phone, index $j\n";
					#	$wait = <STDIN>;
						printOV();
					}    	# vowel is first phone	
				} # if this is vowel	

				$begin =$index -2; 
				while ($segs[$begin] ne ">\n"){
					print LABELFILE ($segs[$begin]); 
					$begin ++; 
				} 
				print LABELFILE ($segs[$begin]);
				print LABELFILE ("\n");
				last;
			} # if this is a recognized symbol
		} # for loop
	} #other for loop   
#} # some big while loop ?  


close (LABELFILE); 

#get date, on Unix System;

#$date = `date`;
#chop($date);
#print "Created $newLabel on $date . \n";
#print "Created $newLex on $date . \n"; 


sub printOV{
	print LABELFILE "\n<\nTime: (nil)\nSymbol: [OV]\nProsody: (nil)\nPolarity: unspecified\nFeatures:\nconsonant -\ndistributed -\ncontinuant -\nanterior -\nsonorant -\nconstricted_glottis -\nblade -\nslack_vocal_folds -\n>\n\n";
}

sub dict2LandLabels {

	foreach (@dphns){				
	#	$_= @dphns[$j];
		if(/[AaiIEe\@aWY\^cOoUuRx\|X]/ ){
			if(/A/){   push( phns, "ah");}
			elsif(/a/){push( phns, "aa");}
			elsif(/i/){push( phns, "iy");}
			elsif(/I/){push( phns, "ih");}
			elsif(/E/){push( phns, "eh");}
			elsif(/e/){push( phns, "ey");}
			elsif(/\@/){push(phns, "ae");}
			elsif(/a/){push( phns, "aa");}
			elsif(/W/){
				push( phns, "aa");
				push( phns, "aw");
			}
			elsif(/Y/){
				push(phns,"aa");
				push(phns,"iy");
			}
			elsif(/\^/){push(phns, "ah");}	
			elsif(/c/){push( phns, "ao");}
			elsif(/O/){push( phns, "ao:iy");}
			elsif(/o/){push( phns, "ow");}
			elsif(/U/){push( phns, "uh");}
			elsif(/u/){push( phns, "uw");}
			elsif(/R/){push( phns, "rr");}
			elsif(/x/){push(phns,"x");}  # ex or x in landmark labels? 
			elsif(/\|/){push( phns, "x");} # | from websters
			elsif(/X/){push( phns, "rr");}
		}elsif(/[nm]/){
			push( phns, $_ );
			push( phns, $_ );
		}elsif(/[l]/){
			push( phns, "l");   # standard.label had an "ls" for a while
                	push( phns, "l");
		}elsif(/[rwyh]/){
			push( phns, $_);
		}elsif(/[NML]/){
			push( phns, lc($_));
			push( phns, lc($_));
		}elsif(/[ptkdbg]/){
			push (phns, $_);
			push (phns, $_);
		}elsif(/[szfv]/){
			push( phns, $_);
			push( phns, $_);
		}elsif(/[CJSZTDG]/){
			if(/C/){
				push( phns, "ch");
   				push( phns, "ch");
				push( phns, "ch");
			}elsif(/J/){
				push( phns, "dj");
				push( phns, "dj");
				push( phns, "dj");
			}elsif(/S/){
				push( phns, "sh");
				push( phns, "sh");
			}elsif(/Z/){
				push( phns, "zh");
				push( phns, "zh");
			}elsif(/T/){
				push( phns, "th");    
				#th? (tf? in standard.txt) as in "thin" Actually not in lex 
				push( phns, "th");
			}elsif(/D/){
				push( phns, "dh");
				push( phns, "dh");
			} elsif(/G/){
				push( phns, "ng");
				push( phns, "ng");
			}#elsif /G/
		} # elsif /[CJSZTDG]/
		else{ print "unknown symbol: " . $_ . "\n";}
	}# for loop 	

} # subroutine
