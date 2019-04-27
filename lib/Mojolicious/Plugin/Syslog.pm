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
  my ($self, $app, $params) = @_;
  my %config = %{$params || {}};

  $config{enable} //= $ENV{MOJO_SYSLOG_ENABLED} // $app->mode ne 'development';
  return unless $config{enable};

  $config{facility} ||= $ENV{MOJO_SYSLOG_FACILITY} || LOG_USER;
  $config{ident}    ||= $ENV{MOJO_SYSLOG_IDENT}    || $app->moniker;
  $config{logopt}   ||= $ENV{MOJO_SYSLOG_LOGOPT}   || 'ndelay,pid';

  $config{access_log} //= $ENV{MOJO_SYSLOG_ACCESS_LOG};
  $config{access_log} = '%H "%P" (%I) %C %M (%Ts, %R/s)'
    if ($config{access_log} || '') eq '1';

  openlog @config{qw(ident logopt facility)};
  $app->log->unsubscribe('message') if $config{only_syslog};
  $app->log->unsubscribe(message => \&_syslog);
  $app->log->on(message => \&_syslog);

  $self->_add_access_log($app, \%config) if $config{access_log};
}

sub _add_access_log {
  my ($self, $app, $config) = @_;

  $app->hook(
    before_routes => sub {
      shift->helpers->timing->begin(__PACKAGE__);
    }
  );

  $app->hook(
    after_dispatch => sub {
      my $c = shift;

      my $timing  = $c->helpers->timing;
      my $elapsed = $timing->elapsed(__PACKAGE__) // 0;
      my $rps     = $timing->rps($elapsed) // '??';

      my $req  = $c->req;
      my $res  = $c->res;
      my $code = $res->code;

      my %MSG = (
        C => $code,
        H => $req->method,
        I => $req->request_id,
        M => $res->message || $res->default_message($code),
        P => $req->url->path->to_abs_string,
        R => $rps,
        T => $elapsed,
      );

      my $level   = $res->is_server_error ? 'warn' : 'info';
      my $message = $config->{access_log};
      $message =~ s!\%([CHIMPRT])!$MSG{$1}!g;
      $c->app->log->$level($message);
    }
  );
}

sub _syslog {
  my ($log, $level, @lines) = @_;
  syslog $PRIORITY{$level}, '%s', $_ for map { chomp; $_ } @lines;
}

1;
