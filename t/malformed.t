#!/usr/bin/perl -w
use strict;
use lib './lib';
use Test::More;

use DateTime;
use DateTime::Event::Cron;

my($dtc);

plan tests => 18;

# handle overfull lines gracefully (possibly from an actual crontab)
$dtc = DateTime::Event::Cron->new('* * * * * /bin/buzzard');
ok($dtc, 'full cronline');
$dtc = DateTime::Event::Cron->new([qw(* * * * * /bin/buzzard)]);
ok($dtc, 'full cron entry as array ref');
$dtc = DateTime::Event::Cron->new(
                                  '* * * * * /bin/buzzard # commentary');
ok($dtc, 'full cronline with comment');
$dtc = DateTime::Event::Cron->new(['*', '*', '*', '*', '*',
                                  '/bin/buzzard', '# commentary']);
ok($dtc, 'full cron entry as array ref w/comment');

# fail on sparse lines
eval {
  $dtc = DateTime::Event::Cron->new('# commentary');
};
ok($@ ne '', 'reject comment line');
eval {
  $dtc = DateTime::Event::Cron->new('* * *');
};
ok($@ ne '', 'reject partial line');
eval {
  $dtc = DateTime::Event::Cron->new('');
};
ok($@ ne '', 'reject empty line');
eval {
  $dtc = DateTime::Event::Cron->new(undef);
};
ok($@ ne '', 'reject undef');

# fail on environment variable lines from crontabs
eval {
  $dtc = DateTime::Event::Cron->new('BUZZARDBAIT=$CHICKEN/plucked');
};
ok($@ ne '', 'reject environment variable line');

# fail on invalid lines with correct field counts
eval {
  $dtc = DateTime::Event::Cron->new('hey exciting things * *');
};
ok($@ ne '', 'reject malformed entries');
eval {
  $dtc = DateTime::Event::Cron->new([qw(hey exciting things * *)]);
};
ok($@ ne '', 'reject malformed entries as array ref');

# well-formed crontabs with invalid ranges
eval {
  $dtc = DateTime::Event::Cron->new('69 * * * * /bin/bad');
};
ok($@ ne '', 'reject minute out of range');
eval {
  $dtc = DateTime::Event::Cron->new('* 24 * * * /bin/bad');
};
ok($@ ne '', 'reject hour out of range');
eval {
  $dtc = DateTime::Event::Cron->new('* * 77 * * /bin/bad');
};
ok($@ ne '', 'reject day out of range high');
eval {
  $dtc = DateTime::Event::Cron->new('* * 0 * * /bin/bad');
};
ok($@ ne '', 'reject day out of range low');
eval {
  $dtc = DateTime::Event::Cron->new('* * * 20 * /bin/bad');
};
ok($@ ne '', 'reject month out of range high');
eval {
  $dtc = DateTime::Event::Cron->new('* * * 0 * /bin/bad');
};
ok($@ ne '', 'reject month out of range low');
eval {
  $dtc = DateTime::Event::Cron->new('* * * * 11 /bin/bad');
};
ok($@ ne '', 'reject dow out of range');

# End of tests
