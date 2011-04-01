package Fetch::WithStatic::Types;
use strict;
use warnings;

use MouseX::Types -declare => [
  qw(HTTP_URL BASENAME)
];
use MouseX::Types::Mouse qw/Str/;

subtype HTTP_URL,
    as 'Str',
    where { $_ =~ /^s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+$/o },
    message { "Must be a valid http url" };

subtype BASENAME,
    as 'Str',
    where { $_ !~ /(?:\\|\/)/o },
    message { "Mustt be a valid basename" };

1;

