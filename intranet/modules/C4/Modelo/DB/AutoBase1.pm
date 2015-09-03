# Meran - MERAN UNLP is a ILS (Integrated Library System) wich provides Catalog,
# Circulation and User's Management. It's written in Perl, and uses Apache2
# Web-Server, MySQL database and Sphinx 2 indexing.
# Copyright (C) 2009-2013 Grupo de desarrollo de Meran CeSPI-UNLP 
# <desarrollo@cespi.unlp.edu.ar>
#
# This file is part of Meran.
#
# Meran is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Meran is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::DB::AutoBase1;
use strict;
use C4::Context;
use base 'Rose::DB';
__PACKAGE__->use_private_registry;
    my $context = new C4::Context;
    
    my $driverDB= 'mysql';
    my $database;
    my $hostname;
    my $user;
    my $pass;
    my $use_socket;
    my $socket;
    
    my $dsn;
    
    my $DB=undef;
  
=item
 if (defined($context)){
    $driverDB = 'mysql';
    $database = $context->config('database');
    $hostname = $context->config('hostname');
    $user = $context->config('user');
    $pass = $context->config('pass');
}
=cut
 if (defined($context)){
    $driverDB = 'mysql';
	use CGI::Session;
	use C4::AR::Debug;
	my $session = CGI::Session->load();
    
=item
$context->config('userINTRA') y/o $context->config('userOPAC') pueden ser:
admin = usuario Aministrador (TODOS los permisos sobre la base)
dev = Desarrollador
intra = usuario comun de la INTRA
opac = ususario comun de OPAC (MENOR cant. de permisos sobre la base)
=cut
	$user = $context->config('userOPAC');
	$pass = $context->config('passOPAC');
	if($session->param('type') eq 'intranet'){
		$user = $context->config('userINTRA');
		$pass = $context->config('passINTRA');
	}
    
    $database = $context->config('database');
    
    $use_socket = $context->config('use_socket');
    
    if ($use_socket){
        $socket   = $context->config('socket');
        $dsn="dbi:mysql:dbname=".$database.";mysql_socket=".$socket;
    }
    else{
        $hostname = $context->config('hostname');
        $dsn="dbi:mysql:dbname=".$database.";host=".$hostname;
    }
    
}
        
__PACKAGE__->register_db
(
  connect_options => {RaiseError => 1},
  driver          => $driverDB,
  dsn             => $dsn,
  username        => $user,
  password        => $pass,
  #mysql_enable_utf8 => 1,
  post_connect_sql => ["SET NAMES utf8"], 
);
1;
