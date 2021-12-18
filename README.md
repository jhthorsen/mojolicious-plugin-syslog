# NAME

Mojolicious::Plugin::Syslog - A plugin for enabling a Mojolicious app to log to syslog

# SYNOPSIS

    use Mojolicious::Lite;
    plugin syslog => {facility => 'local0'};

# DESCRIPTION

[Mojolicious::Plugin::Syslog](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3ASyslog) is a [Mojolicious](https://metacpan.org/pod/Mojolicious) plugin for making
[Mojo::Log](https://metacpan.org/pod/Mojo%3A%3ALog) use [Sys::Syslog](https://metacpan.org/pod/Sys%3A%3ASyslog) in addition (or instead) of file logging.

This can be useful when starting Hypnotoad through Systemd, but want simple
logging of error messages to syslog.

This plugin can also be used for only access logging, as an alternative to
[Mojolicious::Plugin::AccessLog](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AAccessLog). This is done by forcing ["enable"](#enable) to
"0" and enabling ["access\_log"](#access_log).

# METHODS

## register

    $app->plugin(syslog => \%config);
    $self->register($app, \%config);

Used to register the plugin in your [Mojolicious](https://metacpan.org/pod/Mojolicious) application. Available
config parameters are:

- access\_log

    Used to enable logging of access to resources with a route enpoint. This means
    that static files will not be logged, even if this option is enabled. It is
    also possible to set the default value using the `MOJO_SYSLOG_ACCESS_LOG`
    environment variable.

    This can be "v1", "v2" or a custom format. The default is currently "v1", but
    that might change in the future.

        .---------------------------------------.
        | Version | Format                      |
        |---------|-----------------------------|
        | v1      | %H "%P" (%I) %C %M (%Ts)    |
        | v2      | %R %H %U %C "%F" "%A" (%Ts) |
        '---------------------------------------'

    Supported log variables:

        .----------------------------------------------------.
        | Variable | Value                                   |
        |----------|-----------------------------------------|
        | %A       | User-Agent request header               |
        | %C       | Response status code, ex "200"          |
        | %F       | Referer request header                  |
        | %H       | HTTP request method, ex "GET", "POST"   |
        | %I       | Mojolicious request ID                  |
        | %M       | Response message, ex OK                 |
        | %P       | Request URL path                        |
        | %R       | Remote address                          |
        | %T       | Time in seconds for this request        |
        | %U       | Absolute request URL, without user info |
        '----------------------------------------------------'

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

    Set this to true to disabled the default [Mojo::Log](https://metacpan.org/pod/Mojo%3A%3ALog) logging to file/stderr.

# AUTHOR

Jan Henning Thorsen

# COPYRIGHT AND LICENSE

Copyright (C) 2019, Jan Henning Thorsen.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.
