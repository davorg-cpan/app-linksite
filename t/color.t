use strict;
use warnings;
use Test::More;
use App::LinkSite::Site;

# Test the creation of an App::LinkSite::Site object with color values
my $site = App::LinkSite::Site->new(
    name             => 'Test Name',
    handle           => 'Test Handle',
    image            => 'test_image.jpg',
    desc             => 'Test Description',
    og_image         => 'test_og_image.png',
    site_url         => 'http://example.com',
    text_color       => '#FF0000',
    background_color => '#00FF00',
);
isa_ok($site, 'App::LinkSite::Site', 'Created an App::LinkSite::Site object with colors');

# Test the text_color method
is($site->text_color, '#FF0000', 'text_color method returns "#FF0000"');

# Test the background_color method
is($site->background_color, '#00FF00', 'background_color method returns "#00FF00"');

# Test with default values (undefined color values)
my $site_default = App::LinkSite::Site->new(
    name     => 'Test Name',
    handle   => 'Test Handle',
    image    => 'test_image.jpg',
    desc     => 'Test Description',
    og_image => 'test_og_image.png',
    site_url => 'http://example.com',
);
isa_ok($site_default, 'App::LinkSite::Site', 'Created an App::LinkSite::Site object without colors');

# Colors should be undefined when not provided
is($site_default->text_color, undef, 'text_color is undef when not provided');
is($site_default->background_color, undef, 'background_color is undef when not provided');

done_testing;