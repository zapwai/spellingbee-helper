use v5.38;
no warnings;
use List::Util qw( uniq );

## Taken from the Hints screenshot, enter the table here:
my @head = (4, 5, 6, 7, 8, 10);
my @cnt = (
    [2, 7, 1, 1, 0, 0],
    [6, 3, 4, 0, 0, 0],
    [1, 1, 0, 1, 0, 1],
    [1, 0, 1, 1, 0, 0],
    [1, 3, 2, 3, 1, 0],
    [12, 10, 3, 3, 0, 0]
);

## Put the 2-letter data (bottom of Hints) into list.txt:
open my $fh, "<", "list.txt";
my @lines = <$fh>;
close $fh;
my %cap;
for my $line (@lines) {
    for my $piece (split " ", $line) {
	my ($key, $cap) = split "-", $piece;
	my $k = (substr $key, 0, 1) . lc(substr $key, 1, 1);
	$cap{$k} = $cap;
    }
}

## Put the words you have already entered into words.txt:
open $fh, "<", "words.txt";
my @words = <$fh>;
close $fh;
chomp @words;
my %freq;
my %leng;
for my $word (@words) {
    my $lets = substr $word, 0, 2;
    $freq{$lets}++;
    $leng{$lets} = $leng{$lets} // [];
    push @{$leng{$lets}}, length $word;
}

my @let = uniq(map { substr $_, 0, 1; } (sort keys %freq));

my @out;
my $current_letter;
my $out = "";
for my $k (sort keys %cap) {
    $current_letter = $current_letter // substr $k, 0, 1;
    if (($current_letter ne substr $k, 0, 1)) {
	$current_letter = substr $k, 0, 1;
	push @out, $out unless ($out eq "");
	$out = "";
    }
    my $val = $cap{$k} - $freq{$k};
    unless ($val == 0) {
#	say "$k: ", $val, " words left.";
	$out .= "$k$val ";
    }
}
push @out, $out;
for my $out (@out) {
    $out =~ s/(\D)1 /$1 /g;
}

my %len;
for my $let (@let) {
    for my $k (sort keys %freq) {
	if ((substr $k, 0, 1) eq $let) {
	    $len{$let} = $len{$let} // [];
	    push @{$len{$let}}, @{$leng{$k}};
	}
    }
}

# say "\n  Lengths avail:";
# say "  ", join(" ", @head);
# for my $i (0 .. $#cnt) {
#     say "$let[$i] ", join(" ", @{$cnt[$i]});
# }

my %ourcnt;
for my $l (@head) {
    for my $let (@let) {
	my $tally = 0;
	for my $length (@{$len{$let}}) {
	    if ($length == $l) {
		$tally++;
	    }
	}
	$ourcnt{$let} = $ourcnt{$let} // [];
	push @{$ourcnt{$let}}, $tally;
    }
}

# say "\n  Lengths used:";
# for my $o (sort keys %ourcnt) {
#     say "$o ", "@{$ourcnt{$o}}";
# }

my @outcnt;

# say "\n Lengths left:";
# say "  ", join(" ", @head);
for my $i (0 .. $#cnt) {
    my $out = "";
#    print "$let[$i] ";
    my $mysum = 0;
    for my $j (0 .. $#head) {
	my $val = ${$cnt[$i]}[$j] - ${$ourcnt{$let[$i]}}[$j];
#	print $val, " ";
	$out .= "$val ";
	$mysum += $val;
    }
    push @outcnt, $out unless ($mysum == 0);
#    print "\n";
}

for my $i (0 .. $#out) {
    print $out[$i], ": ";
    my @wt = split " ", $outcnt[$i];
    for my $j (0 .. $#wt) {
	print "$head[$j] " x $wt[$j];
    }
    print "\n";
}
