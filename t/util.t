use strict;
use Test::More;

use Test::Exception;
use Fetch::WithStatic::Util;

use File::HomeDir;
use FindBin;
use Path::Class;

subtest "croak_ok" => sub {

    dies_ok {
        Fetch::WithStatic::Util->conf;
    };
    dies_ok {
        Fetch::WithStatic::Util->conf( savedir => '~/' );
    };
    dies_ok {
        Fetch::WithStatic::Util->conf( url => 'XXXXXXX' );
    };
    dies_ok {
        Fetch::WithStatic::Util->conf( savedir => '~/', url => undef );
    };
    lives_ok {
        Fetch::WithStatic::Util->conf( url => 'http://example.com/' );
    };
    lives_ok {
        Fetch::WithStatic::Util->conf( savedir => '~/', url => 'http://example.com/' );
    };
    lives_ok {
        Fetch::WithStatic::Util->conf( savedir => '~/', url => 'https://example.com/' );
    };

    done_testing;
};

subtest "savedir" => sub {
    my $home = File::HomeDir->my_home;
    my $util = Fetch::WithStatic::Util->conf(
        savedir => '~',
        url => 'http://example.com/'
    );
    is $util->savedir, $home;

    # $util = Fetch::WithStatic::Util->conf(
    #     savedir => '~/',
    #     url => 'http://example.com/'
    # );
    # is $util->savedir, $home;

    $util = Fetch::WithStatic::Util->conf(
        savedir => '~/foo/bar',
        url => 'http://example.com/'
    );
    is $util->savedir, File::HomeDir->my_home . '/foo/bar';
    # TODO Win32

    done_testing;
};

subtest "filename_from_url" => sub {
    my $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => 'http://example.com/'
    );
    is $util->filename_from_url('http://example.com/file.html'), 'file.html';
    is $util->filename_from_url('http://example.com/file.htm'), 'file.htm';
    is $util->filename_from_url('http://example.com/foo/bar/file.html'), 'file.html';
    is $util->filename_from_url('http://example.com/file.XXX'), 'file.XXX.html';
    is $util->filename_from_url('http://example.com/foo/bar'), 'bar.html';
    is $util->filename_from_url('http://example.com/foo/bar/'), 'index.html';
    is $util->filename_from_url('http://example.com/foo.bar'), 'foo.bar.html';
    is $util->filename_from_url('http://example.com/foo/bar/file.html'), 'file.html';
    is $util->filename_from_url('http://example.com/foo/bar/?foo=bar'), 'index.html';
    is $util->filename_from_url('http://example.com/foo/bar?foo=bar'), 'bar.html';
    is $util->filename_from_url('http://example.com/'), 'index.html';
    is $util->filename_from_url('http://example.com/index'), 'index.html';
    is $util->filename_from_url('http://example.com/index.html?foo=bar'), 'index.html';
    is $util->filename_from_url('http://example.com/index?foo=bar'), 'index.html';
    is $util->filename_from_url('http://example.com/?foo=bar'), 'index.html';
    is $util->filename_from_url('http://example.com?foo=bar'), 'index.html';
    is $util->filename_from_url('http://example.com/bar.html'), 'bar.html';

    done_testing;
};

subtest url_from_filepath => sub {
    my $base = 'http://example.com';
    my $path = '/foo/bar/baz.html';
    my $url = $base . $path;
    my $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => $url
    );
    is $util->url_from_filepath('/static/img.jpg'), "$base/static/img.jpg";
    is $util->url_from_filepath('static/img.jpg'), "$base/foo/bar/static/img.jpg";
    is $util->url_from_filepath('http://example.com/img.jpg'), "http://example.com/img.jpg";

    $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => "$base/",
    );
    is $util->url_from_filepath('/static/img.jpg'), "$base/static/img.jpg";
    is $util->url_from_filepath('static/img.jpg'), "$base/static/img.jpg";

    is $util->url_from_filepath('/static/img.jpg'), "$base/static/img.jpg";
    is $util->url_from_filepath('static/img.jpg'), "$base/static/img.jpg";

    $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => "$base/?foo=bar",
    );
    is $util->url_from_filepath('/static/img.jpg'), "$base/static/img.jpg";
    is $util->url_from_filepath('static/img.jpg'), "$base/static/img.jpg";

    $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => "$url?foo=bar",
    );

    $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => "$url/?foo=bar",
    );

    $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => "$url/?foo=bar",
    );

    done_testing;
};

subtest "path_to_local" => sub {
    my $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => 'http://example.com/foo/bar.html'
    );
    is $util->path_to_local('static/foo/bar'), 'static/example.com/foo/static/foo/bar';
    is $util->path_to_local('/static/foo/bar'), 'static/example.com/static/foo/bar';
    is $util->path_to_local('bar'), 'static/example.com/foo/bar';
    is $util->path_to_local('/bar'), 'static/example.com/bar';

    $util = Fetch::WithStatic::Util->conf(
        savedir => '~/',
        url => 'http://example.com/'
    );
    is $util->path_to_local('static/foo/bar'), 'static/example.com/static/foo/bar';
    is $util->path_to_local('/static/foo/bar'), 'static/example.com/static/foo/bar';

    done_testing;
};

done_testing;
