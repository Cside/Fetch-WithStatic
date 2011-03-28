use inc::Module::Install;
name 'Fetch-WithStatic';
all_from 'lib/Fetch/WithStatic.pm';

# requires '';

requires 'AnyEvent::HTTP';
requires 'Coro';
requires 'Coro::AnyEvent';
requires 'Coro::LWP';
requires 'Coro::Semaphore';
requires 'File::HomeDir';
requires 'HTML::TreeBuilder::Select';
requires 'Mouse';
requires 'MouseX::AttributeHelpers';
requires 'MouseX::Types';
requires 'MouseX::Types::Mouse';
requires 'Path::Class';
requires 'Perl6::Say';
requires 'Smart::Args';
requires 'Try::Tiny';
requires 'URI';
requires 'namespace::autoclean';

tests 't/*.t';
author_tests 'xt';

test_requires 'File::Find::Rule';
test_requires 'File::HomeDir';
test_requires 'HTML::TreeBuilder::Select';
test_requires 'Test::Exception';
test_requires 'Path::Class';

install_script('bin/fetch-static');

auto_set_repository;
auto_include;
WriteAll;
