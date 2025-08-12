use strict;
use warnings;
use Test::More;
use App::LinkSite::Site;

# Test the creation of an App::LinkSite::Site object
my $site = App::LinkSite::Site->new(
    name     => 'Test Name',
    handle   => 'Test Handle',
    image    => 'test_image.jpg',
    desc     => 'Test Description',
    og_image => 'test_og_image.png',
    site_url => 'http://example.com',
);

# Test default color values (should be undef if not set)
is($site->text_color, undef, 'text_color is undef by default');
is($site->background_color, undef, 'background_color is undef by default');

# Test custom color values
my $site2 = App::LinkSite::Site->new(
    name     => 'Test Name',
    handle   => 'Test Handle',
    image    => 'test_image.jpg',
    desc     => 'Test Description',
    og_image => 'test_og_image.png',
    site_url => 'http://example.com',
    text_color => '#123456',
    background_color => '#abcdef',
);
is($site2->text_color, '#123456', 'text_color returns custom value');
is($site2->background_color, '#abcdef', 'background_color returns custom value');
isa_ok($site, 'App::LinkSite::Site', 'Created an App::LinkSite::Site object');

# Test the name method
is($site->name, 'Test Name', 'name method returns "Test Name"');

# Test the handle method
is($site->handle, 'Test Handle', 'handle method returns "Test Handle"');

# Test the image method
is($site->image, 'test_image.jpg', 'image method returns "test_image.jpg"');

# Test the desc method
is($site->desc, 'Test Description', 'desc method returns "Test Description"');

# Test the og_image method
is($site->og_image, 'test_og_image.png', 'og_image method returns "test_og_image.png"');

# Test the site_url method
is($site->site_url, 'http://example.com', 'site_url method returns "http://example.com"');

done_testing;
