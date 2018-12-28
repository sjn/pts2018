#!/usr/bin/env perl

use Mojolicious::Lite;
use Data::Dumper;
use Template;
plugin 'proxy';

my $root = app->home."/../";

my $template = Template->new({
    INCLUDE_PATH => "${root}actdocs/templates/",
    DEBUG => 1
}) || die $Template::ERROR;

my %tt_helpers = (
    make_uri_info => sub {
        my ($a, $b) = @_;
        return "/$a/$b";
    }
);

push @{app->static->paths}, "${root}wwwdocs";



get '/pts2018' => sub {
    my $self = shift;
    $template->process('ui',
                       \%tt_helpers,
                       sub { $self->render(data=>shift); }
                   ) || die $template->error();

};

get '/' => sub {
    my $self = shift;
    $self->redirect_to('/pts2018');
};


my @proxy = qw( /css/act-base.css /css/schedule.css /js/act.js /btn_donate_LG.gif /favicon.ico );

foreach my $u (@proxy) {
    get $u => sub {
        my $c = shift;
        my $url = "http://act.qa-hackathon.org".$u;
        warn "Proxying to $url\n";
        $c->proxy_to($url);
    };
}

app->start;


