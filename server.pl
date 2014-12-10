#!/usr/bin/perl

use 5.010_000;
use strict;
use warnings;

BEGIN {

    mkdir '/tmp/.altair/docstore/' unless -e '/tmp/.altair/docstore/';
}

use Mojolicious::Lite;
use Mojo::Util;
use Mojo::JSON;
use Mojo::Log;
use File::Slurp;
use File::Copy;
use IO::Dir;
use IO::File;

plugin 'JSONConfig' => {file => 'server.config'};

my $LOG = Mojo::Log->new;
my $DOCUMENTS = app->config->{documents};


any '/' => sub {

    my $self = shift;
    $self->redirect_to('index.html');
};

get '/documents/results.json' => sub {

    my $self = shift;

    my $json = Mojo::JSON->new;
    return $self->render(
        text => $json->encode({data => get_results($DOCUMENTS)}));
};

get '/documents/:category/results.json' => [category => qr/\w+/] => sub {

    my $self = shift;

    my $category = $self->param('category');

    my $json = Mojo::JSON->new;
    return $self->render(
        text => $json->encode({data => get_results("$DOCUMENTS/$category/")}));
};

get '/documents/:category/results.json' => [category => qr/\w+/] => sub {

    my $self = shift;

    my $category = $self->param('category');

    my $json = Mojo::JSON->new;
    return $self->render(
        text => $json->encode({data => get_results("$DOCUMENTS/$category/")}));
};

get '/documents/:category/:group/results.json' =>
  [category => qr/\w+/, group => qr/\w+/] => sub {

    my $self = shift;

    my $category = $self->param('category');
    my $group    = $self->param('group');

    my $json = Mojo::JSON->new;
    return $self->render(text =>
          $json->encode({data => get_results("$DOCUMENTS/$category/$group/")})
    );
  };

get '/documents/:category/:group/:document' => [
    category      => qr/\w+/,
    group         => qr/\w+/,
    document      => qr/\w+/
  ] => sub {

    my $self = shift;

    my $category   = $self->param('category');
    my $group      = $self->param('group');
    my $document   = $self->param('document');

    my $outData = File::Slurp::read_file(
        "$DOCUMENTS/$category/$group/$document");

    $outData = Mojo::JSON::decode_json($outData);

    return $self->render(json => $outData);

  };

sub get_results {

    my $directory = IO::Dir->new(shift);

    my @results;

    if (defined $directory) {

        while (defined($_ = $directory->read)) {

            next if $_ eq 'README.md';
            next if $_ =~ m/^\./g;
            push @results, {name => $_};
        }

        undef $directory;
    }

    return \@results;
}

app->start();
