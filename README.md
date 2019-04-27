# NAME

Mojolicious::Plugin::Syslog - A plugin for enabling a Mojolicious app to log to syslog

# SYNOPSIS

    use Mojolicious::Lite;
    plugin syslog => {facility => 'local0'};

# DESCRIPTION

[Mojolicious::Plugin::Syslog](https://metacpan.org/pod/Mojolicious::Plugin::Syslog) is a [Mojolicious](https://metacpan.org/pod/Mojolicious) plugin for making
[Mojo::Log](https://metacpan.org/pod/Mojo::Log) use [Sys::Syslog](https://metacpan.org/pod/Sys::Syslog) in addition (or instead) of file logging.

This can be useful when starting Hypnotoad through Systemd, but want simple
logging of error messages to syslog.

# METHODS

## register

    $app->plugin(syslog => \%config);
    $self->register($app, \%config);

Used to register the plugin in your [Mojolicious](https://metacpan.org/pod/Mojolicious) application. Available
config parameters are:

- access\_log

    Used to enable logging of access to resources with a route enpoint. This means
    that static files will not be logged, even if this option is enabled.

    This can be "1" or a string. Will use the default format, if "1" is specified:

        %H "%P" (%I) %C %M (%Ts)
         |   |    |   |  |   \- Time in seconds for this request
         |   |    |   |  \- Response message, ex "OK"
         |   |    |   \- Response code, ex 200, 404, ...
         |   |    \- A unique identified for this request
         |   \- The path requested
         \- The HTTP method used, ex GET, POST ...

    Default to the "MOJO\_SYSLOG\_ACCESS\_LOG" environment variable or disabled by
    default.

    This feature and format is highly EXPERIMENTAL.

- enable

    Need to be true to activate this plugin. Will use the "MOJO\_SYSLOG\_ENABLE"
    environment variable or default to true if ["mode" in Mojolicious](https://metacpan.org/pod/Mojolicious#mode) is something
    else than "development"

- facility

    The syslog facility to use. Default to "MOJO\_SYSLOG\_FACILITY" environment
    variable or default to "user".

    The default is EXPERIMENTAL.

- ident

    The syslog ident to use. Default to "MOJO\_SYSLOG\_IDENT" environment variable or
    ["moniker" in Mojolicious](https://metacpan.org/pod/Mojolicious#moniker).

- only\_syslog

    Set this to true to disabled the default [Mojo::Log](https://metacpan.org/pod/Mojo::Log) logging to file/stderr.

# AUTHOR

Jan Henning Thorsen

# COPYRIGHT AND LICENSE

Copyright (C) 2019, Jan Henning Thorsen.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.
