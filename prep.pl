# Used to pull data for list and words text files, requires tesseract 
use v5.38;
use Image::OCR::Tesseract 'get_ocr';

sub get_list($t) {
    my $sample = "Two letter list:";
    my $ind = index $t, $sample; 
    my $list_out = substr $t, $ind + length $sample;
    return $list_out;
}

sub get_words($t) {
    my $sample = "You have found ";
    my $ind = index $t, $sample;
    my $word_out = substr $t, $ind + 8 + length $sample;
    my @words_full = split "\n", $word_out;
    my @words = grep {($_)} @words_full;
    return join "\n", @words;
}

sub get_stuff($file) {
    my $t = get_ocr($file);
    if ($t =~ "Two letter list") {
	open my $FILE, ">", "list.txt" or die();
	print $FILE get_list($t);
	close $FILE;
    } else {
	open my $FILE, ">>", "words.txt" or die();
	print $FILE get_words($t);
	close $FILE;
    }
}

my @files = glob './*';
my @img;
foreach my $item (@files) {
    push @img, substr $item, 2 if ($item =~ /jpg|JPG|PNG|png/);
}
open my $FH, ">", "words.txt" or die(); 
print $FH "";
close $FH;
foreach my $file (@img) {
    get_stuff($file);
}
