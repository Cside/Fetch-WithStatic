package Fetch::WithStatic::Util;
use strict;
use warnings;
use utf8;
use Carp qw/croak carp/;
use Class::Accessor::Lite (
    rw => [ qw/savedir url/ ],
);
use File::HomeDir qw/my_home/;
use Path::Class qw//;
use URI;
use Cwd;

sub conf {
    my ($class, %opt) = @_;
    my $self = bless \%opt, $class;
    croak "Need url." unless $opt{url};
    croak "Invalid URL: $opt{url}" unless $opt{url} =~ m#^https?://#;

    my $savedir = $opt{savedir};

    my $cr_dir = Cwd::getcwd;
    $savedir ||= $cr_dir;
    my $home = File::HomeDir->my_home;
    $savedir =~ s#^~#$home#;
    $savedir = Path::Class::dir($savedir);

    if ($savedir->is_relative) {
        $savedir = Path::Class::dir($cr_dir)->subdir($savedir);
    }

    unless (-d $savedir->stringify) {
        croak "No such directory: " . $savedir->stringify;
    }

    $self->savedir($savedir);
    $self;
}

sub filename_from_url {
    my ($self, $url) = @_;
    my $filename = do {
        my @segments = URI->new($url)->path_segments; 
        pop @segments;
    };
    $filename = 'index.html' if ! $filename;
    $filename .= '.html' unless $filename =~ /\.(html|htm)$/;
    $filename;
}

sub url_from_filepath {
    my ($self, $path) = @_;

    my $url = $self->url;

    my $root = sub {
        my $uri = URI->new(shift);
        $uri->scheme . '://' . $uri->host;
    };

    my $dir = sub {
        my $uri = URI->new(shift);
        my @segments = $uri->path_segments;
        shift @segments; pop @segments;
        @segments ? $uri->scheme . '://' . $uri->host . '/' . join '/', @segments
                  : $uri->scheme . '://' . $uri->host;

    };

    if ($path =~ m#^https?://#) {
        return $path;
    }
    elsif ($path =~ m#^/#) {
        return $root->($url) . $path;
    }
    elsif ($path =~ m#^[^/]#) {
        return $dir->($url) . '/' . $path;
    }
}

sub path_to_local {
    my ($self, $path) = @_;

    my $path_on_html = 'static/' . ($self->url_from_filepath($path) =~ (m#https?://([^?]+)#))[0];
    $path_on_html;
}

sub this {
    my ($self) = @_;
   $self->savedir->file( $self->filename_from_url($self->url) );
}

sub file {
    my ($self, $path) = @_;
    my $file = $self->savedir->file( $self->path_to_local($path) );

    my $dir = $file->dir;
    unless (-d $dir->stringify) {
        eval {
            $dir->mkpath;
        };
    }
    $file
}

1;

