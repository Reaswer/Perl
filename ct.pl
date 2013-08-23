#!"C:\strawberry\perl\bin\perl.exe"
#Directory with output files
opendir DIR, "F:\\Coverage\\TC stats\\output_name\\13" or die "Cannot open directory: $!";
#Exclude "." and ".."
my @files = grep !/^\.\.?$/, readdir(DIR);

my %file_hash;
my %result_file_hash;

#Sort hash by value
sub value
{
   $file_hash{$a} <=> $file_hash{$b};
}
sub read_file_into_hash
{
        open (FILE, $_[0]) or die "can't open file $_[0]\n";
        print "Read $_[0] into hash\n";

        while ($line=<FILE>)
        {
                chomp ($line);
                (my $tc, my $percent) = split(/\s+/,$line);
                
                $file_hash{$tc}=$percent;
        }
        close (FILE); 
}

sub compare_files
{
        print "Compare\n";

        open (FILE, $_[0]) or die "can't open file $_[0]\n";

        while ($line=<FILE>)
        {
                chomp ($line);
                (my $tc, my $percent) = split(/\s+/,$line);
                
                if (defined $file_hash{$tc})
                {
                        my $percent = ($file_hash{$tc} + $percent) / 2;
                        $result_file_hash{$tc} = $percent;
                        #print "$tc_f2 -> $file_1_hash{$tc_f2}\n";
                }
        
        }
        %file_hash=();
        %file_hash=%result_file_hash;
        %resualt_file_hash=();
        close (FILE); 
}

my $path1='F:\\Coverage\\TC stats\\output_name\\13\\'.'TCSTATUS.TRAX1305'.'.output';
read_file_into_hash($path1);

#Read all files in directory
for my $i (1 .. 4)
{
        #print $files[$i];
        my $path2='F:\\Coverage\\TC stats\\output_name\\13\\'.'TCSTATUS.TRAX130'.$i.'.output';
        
        compare_files($path2);
}

#Write data to output
my $out='F:\\Coverage\\TC stats\\output_summary\\summary';
open (FLW,'>', $out) || die "Can't open output file:$!";

foreach my $k (sort value (keys(%file_hash)))
{
        print FLW "$k \t $file_hash{$k}\n";
}
#close (FLW);
#close (FILE2);

