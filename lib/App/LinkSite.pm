use Feature::Compat::Class;

class App::LinkSite {
  use strict;
  use warnings;
  use feature qw[say signatures];
  no if $] >= 5.038, 'warnings', qw[experimental::signatures experimental::class];

  use Template;
  use JSON;
  use Path::Tiny;
  use File::Find;
  use File::Basename;
  use FindBin '$Bin';
  use Data::Printer;

  use App::LinkSite::Site;
  use App::LinkSite::Link;
  use App::LinkSite::Social;

  field $file :param = 'links.json';
  field $src :param = "$Bin/../src";
  field $out :param = 'docs';
  field $ga4 :param = undef;
  field $font_awesome_kit :param = undef;
  field $site :param = undef;

  method src { return $src }
  method out { return $out }
  method ga4 { return $ga4 }
  method font_awesome_kit { return $font_awesome_kit }
  method site { return $site }

  field $tt;

  ADJUST {
    my $json = path($file)->slurp;
    my $data = JSON->new->decode($json);

    debug(np $data);

    $ga4 = $data->{ga4} // '';
    $font_awesome_kit = $data->{font_awesome_kit} // '';

    $tt = Template->new({
      # Templates in the CPAN distro directory
      INCLUDE_PATH => $src,
      # Output in the data directory
      OUTPUT_PATH  => $out,
      VARIABLES    => {
        ga4              => $ga4,
        font_awesome_kit => $font_awesome_kit,
      }
    });

    my $socials = [ map {
      $_->{handle} //= $data->{handle};
      App::LinkSite::Social->new(%$_)
    } $data->{social}->@* ];

    my $links = [ map { App::LinkSite::Link->new(%$_) } $data->{links}->@* ];

    $site = App::LinkSite::Site->new(
      name    => $data->{name},
      handle  => $data->{handle},
      image   => $data->{image},
      desc    => $data->{desc},
      og_image => $data->{og_image},
      site_url => $data->{site_url},
      socials => $socials,
      links   => $links,
    );
  }

  method run {
    debug("src is: $src");
    debug("out is: $out");
    path($out)->mkdir;
    find( { wanted => sub { $self->do_this }, no_chdir => 1 }, $src);

    if ($site->image or $site->og_image) {
      debug("Copy images");
      path('./img')->copy("$out/img");
    }

    if (-f './CNAME') {
      debug("Copy CNAME");
      path('./CNAME')->copy("$out/CNAME");
    }
  }

  method do_this {
    if ($File::Find::name eq $src or $File::Find::name eq "$src/") {
      debug("Skipping $File::Find::name");
      return;
    }

    my $path = $File::Find::name =~ s|^$src/||r;

    if (/\.tt$/) {
      debug("Process $path to", basename($path, '.tt'));
      $tt->process($path, { site => $self->site }, basename($path, '.tt'))
        or die $tt->error;
    } else {
      if (-d) {
        debug("Make directory $path");
        path("$out/$path")->mkdir;
      } elsif (-f) {
        debug("Copy $path");
        path("$src/$path")->copy("$out/$path");
      } else {
        debug("Confused by $File::Find::name");
      }
    }
  }

  sub debug {
    warn "@_\n" if $ENV{LINKSITE_DEBUG};
  }
}

1;
