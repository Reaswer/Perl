#!"C:\strawberry\perl\bin\perl.exe"
use strict;
#use warnings;

use Data::Dumper;

#Parsing status constants
my $stS = 'S';
my $stA = 'A';
my $stC = 'C';
my $stF = 'F';
my $stE = 'E';
my $stM = 'M';
my $stR = 'SUBERR';

#Status counters
my $S = 0;
my $A = 0;
my $C = 0;
my $F = 0;
my $E = 0;
my $M = 0;
my $R = 0;
        
my @tc_info;
my $tc_status;
my $tc_name;
my $tc;
my $status;
my $driver;
my %hash;
my %summary;

#Array of TC names
my @TC;

sub clean_status
{
         $tc_info[0] = 0;
         $tc_info[1] = 0;
         $tc_info[2] = 0;
         $tc_info[3] = 0;
         $tc_info[4] = 0;
         $tc_info[5] = 0;
         $tc_info[6] = 0;
}

sub update_status
{
        #Probably, there is a better way to obtain switch/case bahavior... 
        {
        #Check status of the test case         
        if($_[0] eq $stS)
        { @{$hash{$tc_name}}[0]++;
                last; } 
                       
        if($_[0] eq $stA)
        { @{$hash{$tc_name}}[1]++;
                last; } 
                                        
        if($_[0] eq $stC)
        { @{$hash{$tc_name}}[2]++;
                last; }
                                                                
        if($_[0] eq $stF)
        { @{$hash{$tc_name}}[3]++;
                last; }
                                                                                
        if($_[0] eq $stE)
        { @{$hash{$tc_name}}[4]++;
                last; } 
        
        if($_[0] eq $stM)
        { @{$hash{$tc_name}}[5]++;
                last; }
        
        if($_[0] eq $stR)
        { @{$hash{$tc_name}}[6]++;
                last; }
        }
}

#Sort hash by value
sub value
{
   $summary{$a} <=> $summary{$b};
}

#Directory with output files
opendir DIR, "F:\\Coverage\\TC stats" or die "Cannot open directory: $!";
#Exclude "." and ".."
my @files = grep !/^\.\.?$/, readdir(DIR);;

#Read all files in directory
foreach my $h (@files)
{
        #Create a full path to file
        print "$h\n";
        my $fh='F:\\Coverage\\TC stats\\'.$h;
        open (FLR, $fh) or die "Could not open $fh\n";
        
        while (<FLR>)
        {
                chomp;
                ($tc, $status, $driver) = (split /\s+/)[3,4,5];
                
                # Pattern for dirver name
                # A* or S[0-9]*
                if ($driver =~ m/^A|^S[0-9]/)
                {
                        $tc = $tc.' '.$status.' '.$driver;
                        
                        #Create array with TC's names and their status
                        push (@TC, $tc);
                }
        }

        my @sorted_TC = sort @TC;

        #-------------------------------------------------------
        #Create hash with the following structure:
        # TC_1 => (S,A,C,F,E,M,SUBERR)
        #               ...
        # TC_n => (S,A,C,F,E,M,SUBERR)
        #-------------------------------------------------------
        #I know this loop is very C-like... need to change it...
        #-------------------------------------------------------
        for (my $i=0; $i<=$#sorted_TC; $i++)
        {
                ($tc_name, $tc_status) = split /\s+/, $sorted_TC[$i];
        
                update_status($tc_status);
                
                push @{ $hash{$tc_name} }, @tc_info;
        
                while ( defined($sorted_TC[$i+1]))
                {
                        (my $next_tc_name, my $next_tc_status) = split /\s+/, $sorted_TC[$i+1];
                        
                        #Check next tc name
                        if($tc_name eq $next_tc_name)
                        {
                                update_status($next_tc_status);
                                $i++;
                        }else
                        {       
                                #Not sure is it OK to clean array like this?
                                @tc_info=();
                                last;
                        }
                 }
        }

        #-------------------------------------------------------
        #Create hash with following structure:
        # TC_1 => $score
        #       ...
        # TC_n => $score
        #-------------------------------------------------------
        foreach my $k (keys %hash)
        {
                #Total numbers of runs
                my $total = 0;
                
                # Percent of successful runs
                my $score = 0;   
           
                foreach my $v (@{$hash{$k}})
                {
                        $total += $v;
                }
        
                $score = @{$hash{$k}}[0] / $total;
        
                $summary{$k} = $score;
        }
        
        #Write data to output
        my $out='F:\\Coverage\\TC stats\\output_name\\'.$h."."."output";
        open (FLW,'>', $out) || die "Can't open output file:$!";
        
        #Print sorted by value hash
        #  foreach my $k (sort value (keys(%summary)))
        #  {
        #          print FLW "$k \t $summary{$k}\n";
        #  }
        #-------------------------------------------------------
        #Print sorted by name hash
        
        foreach my $k (sort (keys(%summary)))
        {
                print FLW "$k \t $summary{$k}\n";
        }
        
        close (FLW);
        close (FLR);

        %hash = ();
        %summary = ();
        @tc_info = ();
        @sorted_TC = ();
        @TC = ();
        #$tc_status;
        #$tc_name;
        #$tc;
        #$status;
        #$driver;
        
        
}
closedir(DIR);
