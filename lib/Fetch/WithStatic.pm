package Fetch::WithStatic;
use strict;
use warnings;
our $VERSION = '0.01';

use Encode;
use Encode::Guess qw/ascii utf8 euc-jp shiftjis 7bit-jis/;
use utf8;

use Perl6::Say;
use Carp qw/croak/;
use Try::Tiny;

use Class::Accessor::Lite (
    rw => [ qw(furl encoder) ],
);
use Coro;
use Coro::LWP;
use Coro::Semaphore;
use Furl;

use Fetch::WithStatic::Doc;
use Fetch::WithStatic::Util;

sub new {
    my $furl = Furl->new(
        agent => "Fetch::WithStatic/$VERSION ",
        timeout => 30,
        max_redirect => 0,
    );

    bless { furl => $furl, }, shift;
}

sub get {
    my ($self, $url, $savedir) = @_;

    croak "Malformed URL: $url" unless $url =~ m#^https?://#;
    $url .= '/' unless ($url =~ m#^https?://(.+)#)[0] =~ qr{/};

    my $util = Fetch::WithStatic::Util->conf(savedir => $savedir, url => $url);

    my $html = $self->fetch($url, decode => 1);
    my $this = $util->this;
    say "Saved: " . $this->basename;

    my $doc = Fetch::WithStatic::Doc->new($html, util => $util);
    $self->save_statics($doc->statics);
    $self->save($doc->as_HTML, $this, encode => 1);

    say "Success!";
    say "open '" . $this->stringify . "'";
}

sub save {
    my ($self, $content, $file, %opt) = @_;
    $content = $self->encoder->encode($content) if $opt{encode} && $self->encoder;

    my $writer = $file->openw or croak;
    $writer->print($content)  or croak;
    $writer->close;
}

sub save_statics {
    my ($self, $statics) = @_;

    my @coro;
    my $semaphore = new Coro::Semaphore 30;

    for my $static (@{$statics}) {
        push @coro, async {
            my $content;
            my $filename = $static->{file}->basename;
            my $error = 0;

            try {
                $content = $self->fetch($static->{url});
            } catch {
                say "Failed to get: $filename";
                $error = 1;
            };

            unless ($error) {
                try {
                    $self->save($content, $static->{file});
                    say "Saved: $filename";
                } catch {
                    say "Failed to save: $filename";
                };
            }
        };
    }

    $_->join for @coro;
}

sub fetch {
    my ($self, $url, %opt) = @_;

    my $res = $self->furl->get($url);
    if ($res->code =~ /^2/) {
        my $content = $res->content;

        if ($opt{decode}) {
            my $encoder = Encode::Guess->guess($content);
            if (ref $encoder) {
                $self->encoder($encoder);
                return $encoder->decode($content);
            } else {
                return $content;
            }
        } else {
            return $content;
        }
    } else {
        croak "Fatal error: [" . $res->status . "] $url";
    }
}

1;

__END__

=head1 NAME

Fetch::WithStatic -

=head1 SYNOPSIS

  use Fetch::WithStatic;

  my $fetcher = Fetch::WithStatic->new;

  # save to your current dir
  $fetcher->get($url);

  # save to a optional dir
  $fetcher->get($url, '/path/to/dir');

=head1 DESCRIPTION

Fetch::WithStatic is a easy downloader for web pages;
This module also downloads static files(.js, .css, and img), automatically.

=head1 AUTHOR

Cside E<lt>cside.story@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
