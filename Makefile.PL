use inc::Module::Install;
name 'Fetch-WithStatic';
all_from 'lib/Fetch/WithStatic.pm';

# requires '';
requires 'HTML::TreeBuilder::Select';
requires 'Class::Accessor::Lite';
requires 'File::HomeDir';
requires 'Path::Class';
requires 'URI';
requires 'Encode::Guess';
requires 'Perl6::Say';
requires 'Try::Tiny';
requires 'Coro';
requires 'Coro::LWP';
requires 'Coro::Semaphore';
requires 'Furl';
requires 'Pod::Usage';
requires 'Getopt::Long';
requires 'List::MoreUtils';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'Fetch::WithStatic::Util';
test_requires 'File::HomeDir';
test_requires 'FindBin';
test_requires 'Path::Class';

install_script('bin/fetch-static');

auto_set_repository;
auto_include;
WriteAll;
