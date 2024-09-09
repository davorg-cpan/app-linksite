use strict;
use warnings;
use Test::More tests => 3;
use App::LinkSite;

# Test the creation of an App::LinkSite object
my $linksite = App::LinkSite->new();
isa_ok($linksite, 'App::LinkSite', 'Created an App::LinkSite object');

# Test the src method
is($linksite->src, 'src', 'src method returns "src"');

# Test the out method
is($linksite->out, 'docs', 'out method returns "docs"');
