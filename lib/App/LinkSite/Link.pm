use Feature::Compat::Class;

class App::LinkSite::Link {
  use strict;
  use warnings;
  no if $] >= 5.038, 'warnings', 'experimental::class';

  field $title :reader :param;
  field $subtitle :reader :param = '';
  field $link :reader :param;
  field $new_link :reader(is_new) :param(new) = 0;

  method mk_link {
    my $a_tag = q[<a href="] . $self->link . q[" class="text-decoration-none">] . $self->title . q[</a>];
    my $subtitle = $self->subtitle ? q[<br><small class="text-muted">] . $self->subtitle . q[</small>] : '';

    my @li_classes = qw[list-group-item list-group-item-action];
    push @li_classes, 'new-link' if $self->is_new;

    return qq[<li class='@li_classes'>$a_tag$subtitle</li>];
  }
}

1;
