use strict;
use Test::More;

use Test::Exception;
use Fetch::WithStatic::Util;
use File::HomeDir;
use Cwd;
use File::Spec::Functions;

subtest "dir" => sub {
    my $home = File::HomeDir->my_home;
    my $cr_dir = Cwd::getcwd;
    my $check_dir = sub {
        my ($input, $expected) = @_;
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $util = Fetch::WithStatic::Util->new(
            dir => $input,
            url => 'http://example.com/'
        );
        note($util->dir);
        is $util->_dir->stringify, $expected;
    };

    $check_dir->('~', $home);
    $check_dir->('.', catfile($cr_dir));
    $check_dir->('..', catfile($cr_dir, '..'));
    $check_dir->($home, $home);
    $check_dir->(undef, $cr_dir);

    done_testing;
};

subtest "croak_ok" => sub {

    dies_ok {
        Fetch::WithStatic::Util->new;
    };
    dies_ok {
        Fetch::WithStatic::Util->new( dir => '~/' );
    };
    dies_ok {
        Fetch::WithStatic::Util->new( url => 'XXXXXXX' );
    };
    dies_ok {
        Fetch::WithStatic::Util->new( dir => '~/', url => undef );
    };
    dies_ok {
        Fetch::WithStatic::Util->new( url => 'http://example.com/' );
    };
    lives_ok {
        Fetch::WithStatic::Util->new( dir => '~/', url => 'http://example.com/' );
    };
    lives_ok {
        Fetch::WithStatic::Util->new( dir => '~/', url => 'https://example.com/' );
    };

    done_testing;
};

subtest "methods" => sub {
    use_ok("Fetch::WithStatic::Util");
    my $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => 'http://example.com/'
    );
    isa_ok $util, "Fetch::WithStatic::Util";
    can_ok $util, "url_to_basename";
    can_ok $util, "originpath_to_url";
    can_ok $util, "originpath_to_localpath";
    can_ok $util, "originpath_to_basename";
    can_ok $util, "originpath_to_file";
    can_ok $util, "basename_to_file";

    done_testing;
};

subtest "url_to_basename" => sub {
    my $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => 'http://example.com/'
    );
    is $util->url_to_basename('http://example.com/file.html'), 'file.html';
    is $util->url_to_basename('http://example.com/file.htm'), 'file.htm';
    is $util->url_to_basename('http://example.com/foo/bar/file.html'), 'file.html';
    is $util->url_to_basename('http://example.com/file.XXX'), 'file.XXX.html';
    is $util->url_to_basename('http://example.com/foo/bar'), 'bar.html';
    is $util->url_to_basename('http://example.com/foo/bar/'), 'index.html';
    is $util->url_to_basename('http://example.com/foo.bar'), 'foo.bar.html';
    is $util->url_to_basename('http://example.com/foo/bar/file.html'), 'file.html';
    is $util->url_to_basename('http://example.com/foo/bar/?foo=bar'), 'index.html';
    is $util->url_to_basename('http://example.com/foo/bar?foo=bar'), 'bar.html';
    is $util->url_to_basename('http://example.com/'), 'index.html';
    is $util->url_to_basename('http://example.com/index'), 'index.html';
    is $util->url_to_basename('http://example.com/index.html?foo=bar'), 'index.html';
    is $util->url_to_basename('http://example.com/index?foo=bar'), 'index.html';
    is $util->url_to_basename('http://example.com/?foo=bar'), 'index.html';
    is $util->url_to_basename('http://example.com?foo=bar'), 'index.html';
    is $util->url_to_basename('http://example.com/bar.html'), 'bar.html';
    dies_ok { $util->url_to_basename('ftp://example.com/bar.html'); };
    dies_ok { $util->url_to_basename('example.com/bar.html'); };
    dies_ok { $util->url_to_basename('http://'); };

    done_testing;
};

subtest originpath_to_url => sub {
    my $base = 'http://example.com';
    my $path = '/foo/bar/baz.html';
    my $url = $base . $path;
    my $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => $url
    );
    is $util->originpath_to_url('/static/img.jpg'), "$base/static/img.jpg";
    is $util->originpath_to_url('static/img.jpg'), "$base/foo/bar/static/img.jpg";
    is $util->originpath_to_url('http://example.com/img.jpg'), "http://example.com/img.jpg";

    $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => "$base/",
    );
    is $util->originpath_to_url('/static/img.jpg'), "$base/static/img.jpg";
    is $util->originpath_to_url('static/img.jpg'), "$base/static/img.jpg";

    is $util->originpath_to_url('/static/img.jpg'), "$base/static/img.jpg";
    is $util->originpath_to_url('static/img.jpg'), "$base/static/img.jpg";

    $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => "$base/?foo=bar",
    );
    is $util->originpath_to_url('/static/img.jpg'), "$base/static/img.jpg";
    is $util->originpath_to_url('static/img.jpg'), "$base/static/img.jpg";

    done_testing;
};

subtest "originpath_to_localpath" => sub {
    my $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => 'http://example.com/foo/bar.html'
    );
    is $util->originpath_to_localpath('static/foo/bar'), 'static/example.com/foo/static/foo/bar';
    is $util->originpath_to_localpath('/static/foo/bar'), 'static/example.com/static/foo/bar';
    is $util->originpath_to_localpath('bar'), 'static/example.com/foo/bar';
    is $util->originpath_to_localpath('/bar'), 'static/example.com/bar';

    $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => 'http://example.com/'
    );
    is $util->originpath_to_localpath('static/foo/bar'), 'static/example.com/static/foo/bar';
    is $util->originpath_to_localpath('/static/foo/bar'), 'static/example.com/static/foo/bar';

    done_testing;
};

subtest "basename_to_file" => sub {
    my $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => 'http://example.com/foo/bar.html'
    );
    isa_ok $util->basename_to_file('index.html'), "Path::Class::File";
    my $home = File::HomeDir->my_home;
    is $util->basename_to_file('foo.html')->stringify, catfile($home, 'foo.html');
    dies_ok{ $util->basename_to_file(catfile($home, 'index.html'))};

    done_testing;
};

subtest "originpath_to_file" => sub {
    my $util = Fetch::WithStatic::Util->new(
        dir => '~/',
        url => 'http://example.com/foo/bar.html'
    );
    my $home = File::HomeDir->my_home;
    note(explain([catfile($home, 'static', 'example.com', 'foo', 'path', 'to')]));
    is($util->originpath_to_file('path/to')->stringify,
        catfile($home, 'static', 'example.com', 'foo', 'path', 'to')
      );
    done_testing;
};

done_testing;
