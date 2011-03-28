package Fetch::WithStatic::Util;
use Mouse;
use namespace::autoclean;
use Smart::Args;

use utf8;
use Carp;
use File::HomeDir qw/my_home/;
use Path::Class;
use File::Spec;
use URI;

use Fetch::WithStatic::Types qw/HTTP_URL BASENAME/;

has url => (
    is => 'rw',
    isa => HTTP_URL,
    required => 1,
);

has dir => (
    is => 'rw',
    required => 1,
);

has _dir => (
    is => 'rw',
    lazy_build => 1,
);

sub _build__dir {
    my ($self) = @_;
    my $dir = $self->dir || '.';
    my $home = File::HomeDir->my_home;
    $dir =~ s/^~/$home/;
    $dir = dir($dir);
    my $dir_abs = $dir->absolute;

    unless (-d $dir_abs->stringify) {
        eval {
            mkdir $dir_abs->stringify;
        };
        croak "Failed to make a new dir: " . $dir_abs->stringify if $@;
    }
    $dir_abs;
}

# Public Methods

sub url_to_basename {
    args_pos my $self,
             my $url => HTTP_URL;

    my $basename = do {
        my @segments = URI->new($url)->path_segments;
        pop @segments;
    };
    $basename = 'index.html' if ! $basename;
    $basename .= '.html' unless $basename =~ /\.(html|htm)$/;
    $basename;
}

sub originpath_to_basename {
    args_pos my $self,
             my $path;
    file($path)->basename;
}

sub originpath_to_url {
    args_pos my $self,
             my $path;

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

sub originpath_to_localpath {
    args_pos my $self,
             my $path;
    my $url = $self->originpath_to_url($path);
    my @dir = split '/', ($url =~ (m#https?://([^?]+)#))[0];
    File::Spec->catfile('static', @dir);
}


sub basename_to_file {
    args_pos my $self,
             my $basename => BASENAME;
    $self->_dir->file($basename);
}

sub originpath_to_file {
    args_pos my $self,
             my $path;
    my $localpath = $self->originpath_to_localpath($path);
    my $file = $self->_dir->file($localpath);
    my $dir = $file->dir;
    unless (-d $dir->stringify) {
        eval {
            $dir->mkpath;
        };
    }
    $file;
}

1;
