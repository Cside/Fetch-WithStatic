package Fetch::WithStatic::Doc;
use utf8;
use Carp;
use Encode;
use Path::Class;
use Try::Tiny;
use HTML::TreeBuilder::Select;

use Mouse;
use namespace::autoclean;
use MouseX::AttributeHelpers;
use Smart::Args;

use Fetch::WithStatic::Util;
use Fetch::WithStatic::Types qw/HTTP_URL/;


has content => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has url => (
    is => 'rw',
    isa => HTTP_URL,
    required => 1
);

has dir => (
    is => 'rw',
    required => 1
);

has util => (
    is => 'rw',
    lazy_build => 1
);

sub _build_util {
    my ($self) = @_;
    Fetch::WithStatic::Util->new(
        url => $self->url,
        dir => $self->dir,
    );
}

has tree => (
    is => 'rw',
    isa => 'Maybe[Object]',
);

has is_html => (
    is => 'rw',
);

sub BUILD {
    my ($self) = @_;

    my $html = $self->content;
    if ($html =~ /<html/i) {
        $self->is_html(1);

        my $tree = parse_html($self->content);
        $self->tree($tree);
        $self->content('');

        $self->set(name => 'a',   selector => 'a',      attr_name => 'href');
        $self->set(name => 'css', selector => 'link',   attr_name => 'href');
        $self->set(name => 'img', selector => 'img',    attr_name => 'src');
        $self->set(name => 'js',  selector => 'script', attr_name => 'src');
    }
}

# Public API

has 'download_queue' => (
    is  => 'rw',
    isa => 'ArrayRef',
    metaclass => 'Collection::Array',
    auto_deref => 1,
    default => sub { [] },
    provides => {
        push => 'add_download_queue',
    },
);

sub as_HTML {
    my ($self) = @_;
    $self->is_html ? $self->tree->as_HTML
                   : $self->content;
}

sub self {
    my ($self) = @_;
    my $basename = $self->util->url_to_basename($self->url);
    my $file = $self->util->basename_to_file($basename);
    {
        file     => $file,
        localpath=> $file->relative,
        basename => $basename,
        path     => $file->absolute->stringify,
    };
}

# Unpub Methods

sub set {
    args my $self,
         my $name,
         my $selector,
         my $attr_name;

    my @already;
    for my $elem (grep { $_->attr($attr_name) } $self->tree->select($selector)) {
        my $path      = $elem->attr($attr_name) || '';
        my $url       = $self->util->originpath_to_url($path);
        my $file      = $self->util->originpath_to_file($path);
        my $localpath = $self->util->originpath_to_localpath($path);

        if ($name eq 'css') {
            my $rel  = $elem->attr('rel')  || '';
            my $type = $elem->attr('type') || '';
            next unless ($rel eq 'stylesheet' || $type eq 'text/css' || $path =~ /\.css$/);
        }

        if ($name =~ /(?:css|img|js)/) {
            return if in($url, @already);
            push @already, $url;
            $self->add_download_queue({
                file           => $file,
                url            => $url,
                localpath      => $localpath,
                content_filter => ($path =~ m#^https?://gist\.github\.com/#)
                                  ? \&fix_gist_content : undef,
            });
        }

        fix_path(
            attr_name => $attr_name,
            elem      => $elem,
            path      => $name eq 'a' ? $url : $localpath
        );
    }
}

# Util

sub fix_path {
    args my $attr_name,
         my $elem => 'HTML::Element',
         my $path;

    $elem->attr($attr_name, $path);
    $elem->attr('fixed', 1);
}

sub fix_gist_content {
    my $gist_content = shift;

    my $gist_css;
    try {
        my $file = file(__FILE__)->dir->parent->parent->parent->subdir('static', 'css')->file('gist.css');
        $gist_css = decode_utf8(scalar $file->slurp);
    } catch {
        croak "Cannot open gist.css: " . $_;
    };
    $gist_css =~ s/(\n|\s{2,})//g;
    $gist_css =~ s/'/\\'/g;
    $gist_css = '<style>' . $gist_css. '</style>';

    $gist_content =~ s#document\.write\((.+?)\)#document.write('$gist_css')#;
    $gist_content;
}

sub parse_html {
    my $html = shift;
    my $tree = HTML::TreeBuilder::Select->new;
    $tree->parse($html);
    $tree->eof;
    $tree;
}

sub in {
    my $search = shift;
    my @array = @_;
    die unless $search;
    scalar(grep { $_ eq @array } @array) ? 1 : 0;
}

1;
