use Feature::Compat::Class;

class App::LinkSite::Social {
  use strict;
  use warnings;
  use feature qw[say signatures];
  no if $] >= 5.038, 'warnings', qw[experimental::signatures experimental::class];

  field $service :param;
  field $handle :param;
  field $url :param = undef;

  # TODO: This needs to be a class field.
  field $urls = {
    facebook   => {
      url  => "https://facebook.com/",
      name => 'Facebook',
    },
    'x-twitter' => {
      # This is currently still the correct URL
      url  => "https://twitter.com/",
      name => 'X/Twitter',
    },
    instagram  => {
      url  => "https://instagram.com/",
      name => 'Instagram',
    },
    tiktok     => {
      url  => "https://tiktok.com/@",
      name => 'TikTok',
    },
    linkedin   => {
      url  => "https://linkedin.com/in/",
      name => 'LinkedIn',
    },
    substack   => {
      url  => "https://XXXX.substack.com/",
      name => 'Substack',
    },
    github     => {
      url  => "https://github.com/",
      name => 'GitHub',
    },
    medium     => {
      url  => "https://XXXX.medium.com/",
      name => 'Medium',
    },
    reddit     => {
      url  => "https://reddit.com/user/",
      name => 'Reddit',
    },
    quora      => {
      url  => "https://quora.com/profile/",
      name => 'Quora',
    },
    mastodon   => {
      # Hmm...
      url  => "https://fosstodon.org/@",
      name => 'Mastodon',
    },
    threads    => {
      url  => "https://www.threads.net/@",
      name => 'Threads',
    },
    bluesky   => {
      url  => 'https://bsky.app/profile/',
      name => 'Bluesky',
    },
    letterboxd => {
      url  => 'https://letterboxd.com/',
      name => 'Letterboxd',
    },
    lastfm => {
      url  => 'https://last.fm/user/',
      name => 'last.fm',
    },
  };

  method service { return $service }
  method handle { return $handle }
  method url { return $url }

  method mk_social_link {
    return $url if $url;

    my $social_url;

    if (exists $urls->{$service}) {
      $social_url = $urls->{$service}{url};
    } else {
      warn('Unknown social service: ', $service);
      return;
    }

    if ($social_url =~ /XXXX/) {
      $social_url =~ s/XXXX/$handle/g;
    } else {
      $social_url .= $handle;
    }

    return $social_url;
  }

  method social_icon_template {
    return q[<a title='%s' href='%s'><i class='fa-brands fa-3x fa-%s'></i></a>];
  }

  method mk_social_icon {
    return sprintf $self->social_icon_template,
      $urls->{$service}{name}, $self->mk_social_link(), $service;
  }
}

1;
