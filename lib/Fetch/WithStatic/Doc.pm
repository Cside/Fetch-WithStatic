package Fetch::WithStatic::Doc;
use strict;
use warnings;
use utf8;
use Carp;
use Class::Accessor::Lite (
    rw => [ qw/tree statics util/ ],
);
use HTML::TreeBuilder::Select;
use List::MoreUtils qw/uniq/;

sub new {
    my ($class, $html, %opt) = @_;

    croak "Needs html."                     unless $html;
    croak "HTML parse error: Invalid HTML." unless $html =~ /<html/i;

    my $tree = HTML::TreeBuilder::Select->new;
    $tree->parse($html);
    $tree->eof;

    my $self = bless {tree => $tree}, $class;
    $self->util($opt{util}) if $opt{util};

    $self->extract_statics($html);

    $self;
}

sub extract_statics {
    my ($self, $html) = @_;
    my $tree = $self->tree;

    my @statics;

    my $push = sub {
        my ($elem, $attr_name) = @_;
        my $path = $elem->attr($attr_name);
        if ($path) {
            push @statics, {
                elem      => $elem,
                attr_name => $attr_name,
                path      => $path,
                url       => $self->util->url_from_filepath($path),
                file      => $self->util->file($path),
            };
        }
    };

    $push->($_, 'href') for do {
        my @css;
        push @css, $tree->select('link[type="text/css"]');
        push @css, $tree->select('link[rel="stylesheet"]');
        grep { $_ } uniq(@css);
    };
    $push->($_, 'src')  for $tree->select('img');
    $push->($_, 'src')  for $tree->select('script[type="text/javascript"]');

    $self->statics(\@statics);
}

sub as_HTML {
    my ($self) = @_;
    $self->fix_paths;
    $self->tree->as_HTML;
}

sub fix_paths {
    my ($self) = @_;
    map {
        my $elem      = $_->{elem};
        my $attr_name = $_->{attr_name};
        my $path      = $_->{path};
        $elem->attr($attr_name, $self->util->path_to_local($path));
    }
    @{$self->statics};
}

1;
