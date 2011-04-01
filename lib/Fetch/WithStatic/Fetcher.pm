package Fetch::WithStatic::Fetcher;
use strict;
use warnings;
use utf8;
use Carp;
use Try::Tiny;

use Smart::Args;

use Try::Tiny;
use Encode::Guess qw/ascii utf8 euc-jp shiftjis 7bit-jis/;
use Fetch::WithStatic::Types qw/HTTP_URL/;

use Furl;
use Coro;
use Coro::LWP;
use Coro::Select;
use Coro::Semaphore;

sub new {
    my $furl = Furl->new(
        agent => 'Fetch::WithStatic',
        timeout => 30,
    );
    bless {furl => $furl}, shift;
}

sub fetch {
    args my $self,
         my $url => HTTP_URL,
         my $decode => {optional => 1};

    my $res = $self->{furl}->get($url);
    my $status = $res->status;
    my $result = {status => $res->is_success ? 200 : $status};

    if ($res->is_success) {
        my $body = $res->content;

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
        $result->{reason} = $res->status_line;
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
            my $res;
            my $error;
            my $retried_500;

            FETCH: {
                try {
                    $res = $self->fetch(url => $url, decode => $decode);
                } catch {
                    $error = $_;
                };

                if ($error) {
                    $on_fail->(undef, 404, $i, $error);
                }
                elsif ($res->{status} =~ /^2/o) {
                    $on_success->($res->{content}, $res->{status}, $i);
                }
                else {
                    if ($res->{status} eq '500') {
                        unless ($retried_500) {
                            $retried_500 = 1;
                            goto FETCH;
                        }
                    }
                    $on_fail->(undef, $res->{status}, $i, $res->{reason});
                }
            }
        };
    }
    $_->join for @coro;
}

1;
