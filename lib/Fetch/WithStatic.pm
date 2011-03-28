package Fetch::WithStatic;
use Mouse;
use namespace::autoclean;
use Smart::Args;

use Encode;
use utf8;
use Carp;
use Try::Tiny;

use Fetch::WithStatic::Doc;
use Fetch::WithStatic::Util;
use Fetch::WithStatic::Fetcher;

our $VERSION = '0.03';

has silent => (
    is => 'rw',
    isa => 'Bool',
);

has fetcher => (
    is => 'rw',
    default => sub {
        Fetch::WithStatic::Fetcher->new
    },
);

sub get {
    args my $self,
         my $url,
         my $dir => {optional => 1},
         my $silent => {default => 1, optional => 1};

    $self->silent($silent);

    my $res = $self->fetcher->fetch(url => $url, decode => 1);
    my $status = $res->{status};

    if ($status =~ /^2/) {
        my $doc;
        $doc = Fetch::WithStatic::Doc->new(
            content => $res->{content},
            url     => $url,
            dir     => $dir,
        );
        $self->save_statics($doc->download_queue) if $doc->is_html;

        $self->save(
            content => $doc->as_HTML,
            file    => $doc->self->{file},
            encoder => $res->{encoder},
        );

        $self->log("Saved: " . $doc->self->{basename});
        $self->log("Success!", "Open \'" . $doc->self->{path} . "\'");
    }
    else {
        $self->log("Failed: [$status] " . $res->{reason});
    }
    return $status;
}

sub save {
    args my $self,
         my $content,
         my $file => 'Path::Class::File',
         my $encoder => {optional => 1};

    if ($encoder) {
        $content = $encoder->encode($content)
    }

    my $writer = $file->openw or croak "Cannot open $file";
    $writer->print($content)  or croak "Cannot write on $file";
    $writer->close;
}

sub save_statics {
    my ($self, @queue) = @_;
    my @urls = map { $_->{url} } @queue;

    $self->fetcher->fetch_multi(
        urls => \@urls,
        on_success => sub {
            my ($content, $status, $i) = @_;
            my $static         = $queue[$i];
            my $path           = $static->{localpath};
            my $file           = $static->{file};
            my $content_filter = $static->{content_filter};
            my $error  = 0;
            try {
                $self->save(
                    content => $content_filter ? $content_filter->($content) : $content,
                    file    => $file,
                );
            } catch {
                $self->log("Failed to save $path: $_");
                $error = 1;
            };
            $self->log("Saved: " . $path) unless $error;
        },
        on_fail => sub {
            my (undef, $status, $i, $reason) = @_;
            my $static = $queue[$i];
            my $path = $static->{localpath};
            $self->log("Failed to get $path: $reason");
        },
    );
}

use Perl6::Say;

sub log {
    my ($self, @log) = @_;
    unless ($self->silent) {
        say $_ for @log;
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
  $fetcher->get(
      url => $url
  );

  # save to a optional dir
  $fetcher->get(
      url => $url,
      dir => '/path/to/dir'
  );

  # view log
  $fetcher->get(
      url => $url,
      sirent => 0,
  );

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
