use strict;
use warnings;
use Test::More;

# Test JSON data parsing logic for color support
# This tests the core logic without requiring all dependencies

sub test_color_parsing {
    my ($data, $desc) = @_;
    
    my %site_args = (
        name => $data->{name},
        handle => $data->{handle},
        desc => $data->{desc},
    );
    
    # Only add color parameters if they're specified in the JSON
    $site_args{text_color} = $data->{text_color} if $data->{text_color};
    $site_args{background_color} = $data->{background_color} if $data->{background_color};
    
    return %site_args;
}

# Test data with colors
my $data_with_colors = {
    name => "Test User",
    handle => "testuser",
    desc => "Test description",
    text_color => "#ff0000",
    background_color => "#00ff00",
};

# Test data without colors
my $data_without_colors = {
    name => "Test User", 
    handle => "testuser",
    desc => "Test description",
};

# Test data with only text color
my $data_text_only = {
    name => "Test User",
    handle => "testuser", 
    desc => "Test description",
    text_color => "#ff0000",
};

# Test with colors
my %args_with_colors = test_color_parsing($data_with_colors);
ok(exists $args_with_colors{text_color}, 'text_color included when present in JSON');
ok(exists $args_with_colors{background_color}, 'background_color included when present in JSON');
is($args_with_colors{text_color}, '#ff0000', 'text_color has correct value');
is($args_with_colors{background_color}, '#00ff00', 'background_color has correct value');

# Test without colors
my %args_without_colors = test_color_parsing($data_without_colors);
ok(!exists $args_without_colors{text_color}, 'text_color not included when absent from JSON');
ok(!exists $args_without_colors{background_color}, 'background_color not included when absent from JSON');

# Test with only text color
my %args_text_only = test_color_parsing($data_text_only);
ok(exists $args_text_only{text_color}, 'text_color included when present');
ok(!exists $args_text_only{background_color}, 'background_color not included when absent');
is($args_text_only{text_color}, '#ff0000', 'text_color has correct value when only text color specified');

done_testing;