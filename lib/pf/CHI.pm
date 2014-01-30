package pf::CHI;

=head1 NAME

pf::CHI add documentation

=cut

=head1 DESCRIPTION

pf::CHI

=cut

use strict;
use warnings;
use base qw(CHI);
use CHI::Driver::Memcached;
use CHI::Driver::RawMemory;
#use pf::CHI::Driver::Role::Memcached::Clear;
use pf::file_paths;
use pf::IniFiles;
use List::MoreUtils qw(uniq);

our $chi_config = pf::IniFiles->new( -file => $chi_config_file, -allowempty => 1) or die;

sub chiConfigFromIniFile {
    my %args = (
        defaults => {
            serializer => 'Storable'
        },
        memoize_cache_objects => 1,
    );
    my @keys = uniq map { s/ .*$//; $_; } $chi_config->Sections;
    foreach my $key (@keys) {
        $args{$key} = sectionData($chi_config,$key);
    }
    foreach my $storage (values %{$args{storage}}) {
        foreach my $param (qw(servers traits roles)) {
            if(exists $storage->{$param}) {
                $storage->{$param} = [split /\s*,\s*/,$storage->{$param}];
            }
        }
        foreach my $param (qw(dir_create_mode file_create_mode umask_on_store)) {
            if(exists $storage->{$param}) {
                my $val = $storage->{$param};
                $storage->{$param} = oct($val) if $val =~  /^0/;
            }
        }
    }
    return \%args;
}

sub sectionData {
    my ($config,$section) = @_;
    my %args;
    foreach my $param ($config->Parameters($section)) {
        $args{$param} = $config->val($section,$param);
    }
    my @sections = uniq map { s/^$section ([^ ]+).*$//;$1 } grep { /^$section / } $config->Sections;
    foreach my $name (@sections) {
        $args{$name} = sectionData($config,"$section $name");
    }
    return \%args;
}

__PACKAGE__->config(chiConfigFromIniFile());

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and::or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;
