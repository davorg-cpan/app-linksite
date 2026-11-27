use strict;
use warnings;
use Test::More;
use FindBin '$Bin';
use File::Spec;
use File::Temp 'tempdir';
use IPC::Open3;
use Path::Tiny;

my $caller = tempdir(CLEANUP => 1);
path($caller, 't')->mkpath;
path($Bin, 'links.json')->copy(path($caller, 't', 'links.json'));

my $input = path($caller, 'links.json');
my $original = "Personal link data\n\0\xff\n";
$input->spew_raw($original);

my $lib = File::Spec->rel2abs("$Bin/../lib");
my $output;
my $pid = open3(undef, $output, $output, $^X, '-e', q{
    my $directory = shift @ARGV;
    chdir $directory or die "Cannot enter $directory: $!";
    exec {$^X} $^X, @ARGV;
    die "Cannot start file-parameter test: $!";
}, $caller, "-I$lib", "$Bin/file-parameter.t");

my $diagnostics = do { local $/; <$output> };
close $output;
waitpid $pid, 0;
is($?, 0, 'file-parameter test passes from a caller content directory')
    or diag $diagnostics;
ok($input->is_file, 'existing links.json survives the test');
SKIP: {
    skip 'links.json was removed', 1 unless $input->is_file;
    is($input->slurp_raw, $original, 'existing links.json is byte-for-byte unchanged');
}

done_testing;
