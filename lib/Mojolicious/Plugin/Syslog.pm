package Mojolicious::Plugin::Syslog;
use Mojo::Base 'Mojolicious::Plugin';

use Sys::Syslog qw(:standard :macros);

my %PRIORITY = (
  debug => LOG_DEBUG,
  error => LOG_ERR,
  fatal => LOG_CRIT,
  info  => LOG_INFO,
  warn  => LOG_WARNING,
);

sub register {
  my ($self, $app, $config) = @_;
  my %config = %{$config || {}};

  $config{enable} //= $app->mode ne 'development';
  return unless $config{enable};

  $config{facility} ||= LOG_USER;
  $config{ident}    ||= $app->moniker;
  $config{logopt}   ||= 'ndelay,pid';

  openlog @$config{qw(ident logopt facility)};
  $app->log->unsubscribe('message') if $config{only_syslog};
  $app->log->on(message => \&_syslog);
}

sub _syslog {
  my ($log, $level, @lines) = @_;
  syslog $PRIORITY{$level}, '%s', $_ for @lines;
}

1;
