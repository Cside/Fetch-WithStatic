package Fetch::WithStatic::Fetcher;
use strict;
use warnings;
use utf8;
use Carp;
use Try::Tiny;

use Smart::Args;

use Encode::Guess qw/ascii utf8 euc-jp shiftjis 7bit-jis/;
use Fetch::WithStatic::Types qw/HTTP_URL/;

use AnyEvent::HTTP;
use Coro;
use Coro::LWP;
use Coro::AnyEvent;
use Coro::Semaphore;

sub new { bless {}, shift; }

sub fetch {
    args my $self,
         my $url => HTTP_URL,
         my $decode => {optional => 1};

    http_request(
        GET => $url,
        headers => { "user-agent" => "Fetch::WithStatic" },
        timeout => 30,
        Coro::rouse_cb,
    );
    my ($body, $header) = Coro::rouse_wait;
    my $status = $header->{Status};

    my $result = {status => $status};
    if ($status =~ /^2/) {
        my $encoer;

        if ($decode) {
            my $encoder = Encode::Guess->guess($body);
            if (ref $encoder) {
                $result->{content} = $encoder->decode($body);
                $result->{encoder} = $encoder;
                return $result;
            }
        }
        $result->{content} = $body;
    }
    else {
        $result->{reason} = $header->{Reason};
    }
    return $result;
}

sub fetch_multi {
    args my $self,
         my $urls => 'ArrayRef',
         my $on_success => 'CodeRef',
         my $on_fail => 'CodeRef',
         my $decode => {optional => 1};

    my @coro;
    my $semaphore = new Coro::Semaphore 50;
    for my $queue ( map{
                       { i => $_, url => $urls->[$_] }
                                                     }(0 .. $#${urls}) ) {
        push @coro, async {
            my $url = $queue->{url};
            my $i   = $queue->{i};
            my $guard = $semaphore->guard;
            my $res = $self->fetch(url => $url, decode => $decode);

            if ($res->{status} =~ /^2/) {
                $on_success->($res->{content}, $res->{status}, $i);
            } else {
                $on_fail->(undef, $res->{status}, $i, $res->{reason});
            }
        };
    }
    $_->join for @coro;
}

1;
