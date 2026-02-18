use strict;
use warnings;
use Test::More;
use FindBin '$Bin';
use File::Copy;
use App::LinkSite;

# Test that we can pass a custom file parameter
my $linksite = App::LinkSite->new(file => 't/links.json');
isa_ok($linksite, 'App::LinkSite', 'Created an App::LinkSite object with file parameter');

# Test that the file parameter is correctly stored
is($linksite->file, 't/links.json', 'file parameter is correctly set');

# Test default file parameter
copy 't/links.json', 'links.json';
my $linksite_default = App::LinkSite->new();
is($linksite_default->file, 'links.json', 'default file parameter is "links.json"');
unlink 'links.json';

done_testing;
