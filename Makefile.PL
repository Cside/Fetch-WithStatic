use inc::Module::Install;
name 'Fetch-WithStatic';
all_from 'lib/Fetch/WithStatic.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
