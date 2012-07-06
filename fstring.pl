use v5.12;

my %function = (
    sum => \&sum,
    min => \&min,
    max => \&max,
    plus => \&plus,
    minus => \&minus,
    neg => \&neg,
);

my %variable = (
    pi => 3.14,
    x => 5,
    y => 6,
);



my @test = (
    'x=$x',
    'y=$y',
    '\pi = $pi',
    '$x+$y',
    'dollar sign: $$',
    '[$$y]',
    '$neg($x)',
    'x + y = $plus($x, $y)',
    'x - y = $minus($x, $y)',
    '10 - 7 = $minus(10, 7)',
    'max(9, 7) = $max(9, 7)',
    'max(x, y) = $max($x, $y)',
    'max(8, $y) = $max(8, $y)',
    'max(min(3,4),2)=$max($min(3,4),2)',
    '$max($min(3, 4), $min(10, 20))',
    'example $$ $pi $sum($min($min(1, 3), 2), $max(3, 4), 5); $max(100, 200)! $max($pi, 4) $max(3, $min($pi, 5))',
);

say parse($_) for @test;

sub sum {
    my (@args) = @_;
    
    my $sum = 0;
    $sum += $_ for @args;
    
    return $sum;
}

sub max {
    my (@args) = @_;

    return $args[0] >= $args[1] ? $args[0] : $args[1];
}

sub min {
    my (@args) = @_;

    return $args[0] <= $args[1] ? $args[0] : $args[1];
}

sub plus {
    my (@args) = @_;
    
    return $args[0] + $args[1];
}

sub minus {
    my (@args) = @_;
    
    return $args[0] - $args[1];
}

sub neg {
    my (@args) = @_;
    
    return -$args[0];
}

sub parse {
    my ($string) = @_;
   
    my $pos = 0;  
    my ($before, $after) = split /\$/, $string, 2;
    
    my ($processed, $not_processed) = subparse($after);
    my $ret = $before . $processed;
    
    $ret .= parse($not_processed) if $not_processed;
    
    return $ret;
}

sub subparse {
    my ($string) = @_; # always started with an implicit '$'
    
    my ($ret, $rest) = ('', '');
    
    given($string) {
        ($ret, $rest) = subparse_escape($string)  when /^\$/;
        ($ret, $rest) = subparse_function($1, $2) when /^([a-zA-Z0-9_-]+)(\(.*)$/;
        ($ret, $rest) = subparse_variable($1, $2) when /^([a-zA-Z0-9_-]+)(.*)$/;
        ($ret, $rest) = ($string, '');
    }
    
    return ($ret, $rest);
}

sub subparse_escape {
    my ($string) = @_;
    
    my $ret = '$';
    my $rest = substr $string, 1;

    return ($ret, $rest);
}

sub subparse_function {
    my ($name, $rest) = @_;    
   
    my $ret = '';
    my $p;
    my $level = 0;
    for ($p = 0; $p != length $rest; $p++) {
        my $ch = substr $rest, $p, 1;

        $level++ if $ch eq '(';
        $level-- if $ch eq ')';
        
        last unless $level;
    }
    
    my $args = substr $rest, 1, $p - 1;
    $rest = substr $rest, $p + 1;
    
    $args = parse($args);
    my @args = split /\s*,\s*/, $args;
    if (exists $function{$name}) {
        $ret = $function{$name}->(@args);
    }
    else {
        # ERROR: function not found
    }
    #say "CALL $name($args)";

    return ($ret, $rest);
}

sub subparse_variable {
    my ($name, $rest) = @_;
    
    my $ret = '';
    
    if (exists $variable{$name}) {
        $ret = $variable{$name};
    }
    else {
        # ERROR: variable not found
    }

    return ($ret, $rest);
}
