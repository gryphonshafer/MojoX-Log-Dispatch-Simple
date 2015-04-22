package MojoX::Log::Dispatch::Simple;
# ABSTRACT: Simple Log::Dispatch replacement of Mojo::Log

use strict;
use warnings;

use Mojo::Base 'Mojo::EventEmitter';
use Mojo::Util 'encode';

# VERSION

has history          => sub { [] };
has level            => 'debug';
has max_history_size => 10;
has dispatch         => undef;
has format_cb        => undef;

sub new {
    my $self = shift->SUPER::new(@_);
    $self->on( message => sub {
        my ( $self, $level ) = ( shift, shift );
        return unless ( $self->_active_level($level) );

        push( @{ $self->history }, [ time, $level, @_ ] );
        shift @{ $self->history } while ( @{ $self->history } > $self->max_history_size );

        $self->dispatch->log( level => $level, message => encode( 'UTF-8', $_ ) ) for (@_);
    } );
    return $self;
}

sub _log {
    shift->emit( 'message', @_ );
    return;
}

{
    my $levels = {
        debug => 1,
        info  => 2,
        warn  => 3,
        error => 4,
        fatal => 5,

        notice    => 2,
        warning   => 3,
        critical  => 4,
        alert     => 5,
        emergency => 5,
        emerg     => 5,

        err  => 4,
        crit => 4,
    };

    sub _active_level {
        my ( $self, $level ) = @_;
        return ( $levels->{$level} >= $levels->{ $ENV{MOJO_LOG_LEVEL} || $self->level } ) ? 1 : 0;
    }

    sub helpers {
        my ( $self, $c ) = ( shift, shift );

        for my $level ( (@_) ? @_ : keys %$levels ) {
            $c->helper( $level => sub {
                my ($self) = shift;
                $self->app->log->$level($_) for (@_);
                return;
            } );
        }

        return $self;
    }
}

sub format {
    my ($self) = @_;
    return $self->format_cb || sub { localtime(shift) . ' [' . shift() . '] ' . join( "\n", @_, '' ) };
}

sub debug { shift->_log( 'debug',      @_ ) }
sub info  { shift->_log( 'info',       @_ ) }
sub warn  { shift->_log( 'warn',       @_ ) }
sub error { shift->_log( 'error',      @_ ) }
sub fatal { shift->_log( 'emergency',  @_ ) }

sub notice    { shift->_log( 'notice',    @_ ) }
sub warning   { shift->_log( 'warn',      @_ ) }
sub critical  { shift->_log( 'critical',  @_ ) }
sub alert     { shift->_log( 'alert',     @_ ) }
sub emergency { shift->_log( 'emergency', @_ ) }
sub emerg     { shift->_log( 'emergency', @_ ) }

sub err  { shift->_log( 'error',    @_ ) }
sub crit { shift->_log( 'critical', @_ ) }

sub is_debug { shift->_active_level('debug') }
sub is_info  { shift->_active_level('info')  }
sub is_warn  { shift->_active_level('warn')  }
sub is_error { shift->_active_level('error') }
sub is_fatal { shift->_active_level('fatal') }

sub is_notice    { shift->_active_level('notice')    }
sub is_warning   { shift->_active_level('warning')   }
sub is_critical  { shift->_active_level('critical')  }
sub is_alert     { shift->_active_level('alert')     }
sub is_emergency { shift->_active_level('emergency') }
sub is_emerg     { shift->_active_level('emergency') }

sub is_err  { shift->_active_level('error')    }
sub is_crit { shift->_active_level('critical') }

1;
__END__ MojoX::Log::Dispatch::Simple MojoX-Log-Dispatch-Simple

=pod

=begin :badges

=for markdown
[![Build Status](https://travis-ci.org/gryphonshafer/MojoX-Log-Dispatch-Simple.svg)](https://travis-ci.org/gryphonshafer/MojoX-Log-Dispatch-Simple)
[![Coverage Status](https://coveralls.io/repos/gryphonshafer/MojoX-Log-Dispatch-Simple/badge.png)](https://coveralls.io/r/gryphonshafer/MojoX-Log-Dispatch-Simple)

=end :badges

=head1 SYNOPSIS

    # from inside your startup() most likely...

    use Log::Dispatch;
    use MojoX::Log::Dispatch::Simple;

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    );

    my ($self) = @_; # Mojolicious object from inside startup()
    $self->log($mojo_logger);

    # ...then later inside a controller...

    $self->app->log->debug('Debug-level message');
    $self->app->log->info('Info-level message');

    # ...or back to your startup() to setup some helpers...

    $mojo_logger->helpers($self);
    $mojo_logger->helpers( $self, qw( debug info warn error ) );

    # ...so that in your controllers you can...

    $self->debug('Debug-level message');
    $self->info('Info-level message');

    # ...or do it all at once, in the startup() most likely...

    $self->log( MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    )->helpers($self) );

=head1 DESCRIPTION

This module provides a really simple way to replace the built-in L<Mojo::Log>
with a L<Log::Dispatch> object, and yet still support all the L<Mojo::Log>
log levels and other functionality L<Mojolicious> assumes exists. To make it
even easier, you can install helpers to all the log levels, all from the same
single line of code.

    $self->log( MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    )->helpers($self) );

The module makes absolutely no assumptions about how you want to use
L<Log::Dispatch>. In fact, it's entirely neutral about L<Log::Dispatch>. If you
want to use a library that offers a similar interface, go for it.

=head1 PRIMARY METHODS

These are methods that you would likely use from within your C<startup()>
subroutine:

=head2 new

This method instantiates an object. It requires a "dispatch" parameter, which
should be a L<Log::Dispatch> object (or an object with a similar signature).
The method allow accepts an optional "level" parameter, which is used to set
the log level for your L<Mojolicious> application.

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    );

Optionally, you can also provide a "format_cb" value, which should be a
reference to a subroutine that will be used to format entries that appear
on the L<Mojolicious> error reporting web page. This formatting will have
nothing at all to do with whatever your L<Log::Dispatch> does.

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch  => Log::Dispatch->new,
        level     => 'debug',
        format_cb => sub {
            localtime(shift) . ' [' . shift() . '] ' . join( "\n", @_, '' )
        },
    );

By default, when you're looking at one of these L<Mojolicious> error reporting
web pages, you'll see the past 10 log entries listed. You can change that
by passing in a "max_history_size" value.

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch         => Log::Dispatch->new,
        max_history_size => 20,
    );

=head2 helpers

You can optionally tell this library to create helpers to each of the log
levels, or to a selection of them. This method requires that you pass in
a reference to the L<Mojolicious> object. If that's all you pass in, the
method will create a helper for every log level.

    $mojo_logger->helpers($mojo_obj);

You can optionally pass in the names of the log levels you want helpers created
for, and the method will only create methods for those levels.

    $mojo_logger->helpers( $mojo_obj, qw( debug info warn ) );

=head1 LOG LEVELS

Unfortunately, L<Mojolicious> and L<Log::Dispatch> have slightly different
ideas as to what log levels should exist. This module supports all of them,
because why not, right? Here's a list of the supported log levels, some with
aliases.

=for :list
* debug
* info
* notice
* warn, warning
* error, err
* critical, crit
* alert
* emergency, emerg, fatal

You can also test for log level by either just reading C<$obj->level> or by
running an "is_*" method. For every log level listed above, there's a
corresponding "is_*" method.

    my $log_level_at_or_above_notice = $obj->is_notice;

=head1 POST-INSTANTIATION MEDDLING

Following the creation of the object from this library, you can still
manipulate various attributes, which are:

=for :list
* dispatch (a L<Log::Dispatch> object)
* level
* max_history_size
* format_cb (a subref)
* history (an arrayref)

So you can do things like:

    $obj->dispatch->remove('debug');

=head1 SEE ALSO

L<Mojolicious>, L<Log::Dispatch>.

You can also look for additional information at:

=for :list
* L<GitHub|https://github.com/gryphonshafer/MojoX-Log-Dispatch-Simple>
* L<CPAN|http://search.cpan.org/dist/MojoX-Log-Dispatch-Simple>
* L<MetaCPAN|https://metacpan.org/pod/MojoX::Log::Dispatch::Simple>
* L<AnnoCPAN|http://annocpan.org/dist/MojoX-Log-Dispatch-Simple>
* L<Travis CI|https://travis-ci.org/gryphonshafer/MojoX-Log-Dispatch-Simple>
* L<Coveralls|https://coveralls.io/r/gryphonshafer/MojoX-Log-Dispatch-Simple>
* L<CPANTS|http://cpants.cpanauthors.org/dist/MojoX-Log-Dispatch-Simple>
* L<CPAN Testers|http://www.cpantesters.org/distro/M/MojoX-Log-Dispatch-Simple.html>

=for Pod::Coverage alert crit critical debug emerg emergency err fatal format info is_alert is_crit is_critical is_debug is_emerg is_emergency is_err is_error is_fatal is_info is_notice is_warn is_warning notice warn warning

=cut