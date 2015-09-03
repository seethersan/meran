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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::DB::Object::AutoBase2;
use base 'Rose::DB::Object';
use C4::Modelo::DB::AutoBase1;
use base qw(Rose::DB::Object::Helpers);
sub init_db { 
    if (!$DB){
       $DB = C4::Modelo::DB::AutoBase1->new_or_cached;
       $DB->dbh->do("set names 'utf8'");
    }
    return $DB;
 }
=item
    Returns true (1) if the row was loaded successfully
    undef if the row could not be loaded due to an error, 
    zero (0) if the row does not exist.
=cut
sub load{
    my $self = $_[0]; # Copy, not shift
    my $error = 1;
    eval {
    
         unless( $self->SUPER::load(speculative => 1, nonlazy => 1,) ){
                $error = 0;
         }
        return $self->SUPER::load(@_);
    };
    if($@){
        $error = undef;
    }
    return $error;
}
=item
Imprime el nombre de la clase
=cut
 
sub getPk{
    my ($self) = shift;
    return (''.$self->meta->primary_key);
}
sub getByPk{
    my ($self) = shift;
    my ($value_id) = @_;
   
    
    my $pk = $self->meta->primary_key;
    my $self_like = $self->meta->class->new($pk => $value_id);
  
    
    $self_like->load();
    return($self_like);
}
sub getInvolvedFilterString{
	
    my ($self) = shift;
    my ($tabla, $value)= @_;
    my @filtros;
    
    my $table_name = $tabla->meta->table;
    
    my $instance = $tabla->getByPk($value);
    
    $value = $instance->get_key_value();
    my $filter_string = $table_name."@".$value;
    push (@filtros, ( marc_record => {like => '%'.$filter_string.'%'} ) );
   C4::AR::Debug::debug("********************* REFERENCIAS ************************** \n getInvolvedFilterString en $table_name =========> TABLA $tabla VALUE $value ************************************** \n");
    return($filter_string,\@filtros);
	
}
sub get_key_value{
    my ($self) = shift;
    
    return ($self->getPkValue);
}
sub replaceByThis{
    my ($self) = shift;
    my ($new_id)=@_;
    my @filtros;
    my ($used_or_not,$referer_involved,$data_array) = C4::AR::Referencias::mostrarReferencias($self->getAlias(),$self->getPkValue);
    foreach my $tabla (@$data_array){
        if (!$tabla->{'tabla_catalogo'}){
            my ($clave_tabla_referente,$tabla_referente) = C4::AR::Referencias::getTablaInstanceByTableName($tabla->{'tabla_object'}->getTabla_referente);
            $tabla_referente->replaceBy($tabla->{'tabla_object'}->getCampo_referente,$self->get_key_value,$new_id);
        }
    }
}
sub getRelated{
    my ($self)=shift;
    my @filtros;
    my $related = $self->getAll(0,0,1);
    return ($related);
}
sub getPkValue{
    my ($self) = shift;
    return ($self->{$self->getPk});
}
sub getInvolvedCount{
 
     return (0);
}
sub toString{
    my ($self)=shift;
    return $self->meta->class;
}
sub getTableName{
    my ($self)=shift;
    return $self->meta->table;
}
=item
    CHAIN OF RESPONSIBILITY
    HandleRequest = createFromAlias, implementado como un  TemplateMethod compuesto por 
    createFromAlias (TemplateMethod), nextChain, nextMember (HookMethods)
=cut
sub createFromAlias{
    my ($self)      = shift;
    my $classAlias  = shift;
    my $class;
    use Switch;
    switch ($classAlias) {
        case 'autor' { return C4::Modelo::CatAutor->new()}
        case 'tipo_ejemplar' {return C4::Modelo::CatRefTipoNivel3->new()}
        case 'ui' {return C4::Modelo::PrefUnidadInformacion->new()}
        case 'idioma' {return C4::Modelo::RefIdioma->new()}  
        case 'pais' {return C4::Modelo::RefPais->new()} 
        case 'disponibilidad' {return C4::Modelo::RefDisponibilidad->new()}
        case 'tipo_prestamo' {return C4::Modelo::CircRefTipoPrestamo->new()}
        case 'soporte' {return C4::Modelo::RefSoporte->new()}
        case 'nivel_bibliografico' {return C4::Modelo::RefNivelBibliografico->new()}
        case 'tema' {return C4::Modelo::CatTema->new()}
        case 'tipo_socio' {return C4::Modelo::UsrRefCategoriaSocio->new()}
        case 'tipo_documento_usr' {return C4::Modelo::UsrRefTipoDocumento->new()}
        case 'estado' {return C4::Modelo::RefEstado->new()}
        case 'ciudad' {return C4::Modelo::RefLocalidad->new()}
        case 'editorial' {return C4::Modelo::CatEditorial->new()}
        case 'perfiles_opac' {return C4::Modelo::CatPerfilOpac->new()}
        case 'colaborador' {return C4::Modelo::RefColaborador->new()}
        case 'signatura' {return C4::Modelo::RefSignatura->new()}
        case 'acm' {return C4::Modelo::RefAcm->new()}
        case 'nivel2' {return C4::Modelo::CatRegistroMarcN2->new()}
        case 'usr_estado' {return C4::Modelo::UsrEstado->new()}
        case 'usr_regularidad' {return C4::Modelo::UsrRegularidad->new()}
	    else {C4::AR::Debug::debug("NO EXISTE LA TABLA DE REFERENCIA ".$classAlias) }
    }
}
sub printAsTableElement{
    my ($self)=shift;
    my $classAlias = shift;
    my $campos = $self->getCamposAsArray;
    my $td;
    my $editId = 1;
    foreach my $campo (@$campos){
        
        $td.="<td class='editable' id='".$self->getAlias."___".$campo."___".$self->getPkValue."___".$editId."'>". C4::AR::Utilidades::escapeData($self->{$campo})."</td>";
        $editId++;
    }
    return ($td);
}
sub modifyFieldValue{
    my ($self)=shift;
    my ($field,$value) = @_;
    $self->{$field} = $value;
    if ($self->meta->class eq "C4::Modelo::CatAutor"){
      $self->setCompleto();
    }
    $self->save;
}
    
=item
Esta funcion devuelve los campos de la tabla del objeto llamador
=cut
sub getCamposAsHash{
    my ($self) = shift;
    my @arregloJSON;
    my $camposArray = $self->meta->columns;
    use C4::Modelo::PrefTablaReferenciaConf;
    foreach my $campo (@$camposArray){
        my $ptrc    = C4::Modelo::PrefTablaReferenciaConf->new();
        my $c       = $ptrc->getConf($self->meta->table, $campo);
        if($c){
            if($c->getVisible()){
    ## FIXME ."" se esta concatenando $campo con "" pq sino se rompe, cosa de locos
                my %hash_temp; 
                $hash_temp{'key'}               = $campo."";
                $hash_temp{'value'}             = $c->getCampoAlias();
                push (@arregloJSON, \%hash_temp);
            }
        }
    }
    return(@arregloJSON);
}
sub getDefaultValue{
    my ($self) = shift;
 
    my $classAlias  = shift;
    my $class;
    use Switch;
    switch ($classAlias) {
        case 'cat_autor' { return C4::AR::Preferencias::getValorPreferencia("defaultUI");}
        case 'tipo_ejemplar' {return C4::AR::Preferencias::getValorPreferencia("defaultTipoNivel3");}
        case 'ui' {return C4::AR::Preferencias::getValorPreferencia("defaultUI");}
        case 'idioma' {return C4::AR::Preferencias::getValorPreferencia("defaultIdioma");}  
        case 'pais' {return C4::AR::Preferencias::getValorPreferencia("defaultPais");} 
        case 'disponibilidad' {return C4::AR::Preferencias::getValorPreferencia("defaultDisponibilidad");}
        case 'tipo_prestamo' {return C4::AR::Preferencias::getValorPreferencia("defaultissuetype");}
        case 'soporte' {return C4::AR::Preferencias::getValorPreferencia("defaultSoporte");}
        case 'nivel_bibliografico' {return C4::AR::Preferencias::getValorPreferencia("defaultNivelBibliografico");}
        case 'tipo_documento_usr' {return C4::AR::Preferencias::getValorPreferencia("defaultTipoDoc");}
        case 'estado' {return C4::AR::Preferencias::getValorPreferencia("defaultEstado");}
        case 'ciudad' {return C4::AR::Preferencias::getValorPreferencia("defaultCiudad");}
        else {C4::AR::Debug::debug("NO EXISTE LA TABLA DE REFERENCIA ".$classAlias) }
    }
}
sub getCamposAsArray{
    my ($self)=shift;
    my $arreglo;
    my $camposArray = $self->meta->columns;
    my @campos_sin_id;
    my $pk = $self->getPk;
    
    foreach my $campo (@$camposArray){
      if ( ($campo ne 'id') && ($campo ne 'agregacion_temp') && ($campo ne $pk)){
          push (@campos_sin_id,$campo);
      }
    
    }    
    return(\@campos_sin_id);
}
sub validate_fields {
    my ($self)  = shift;
    my ($fields_array_ref_to_validate)  = @_;
    my $result              = 0; 
    my $fields_array_ref    = $self->getCamposAsArray();
    foreach my $fv (@$fields_array_ref_to_validate){
        @res = grep(/$fv/, @$fields_array_ref); 
        if (scalar(@res) > 0) {
            $result = 1;
        }
    }
    if($result == 0){
        C4::AR::Debug::debug("AutoBase2 => validate_fields => ERROR en la configuaracion del catalogo tabla => ".$self->meta->table);        
    }
    return $result;
}
sub getCampos{
    my ($self) = shift;
    my $fieldsString = C4::AR::Utilidades::joinArrayOfString($self->meta->columns);
    return($fieldsString);
}
sub addNewRecord{
    my ($self) = shift;
    my $fields = $self->getCamposAsArray();
    foreach my $field (@$fields){
      $self->{$field} = C4::AR::Filtros::i18n('_SIN_VALOR_');
    }
    $self->save();
    
    #parche loco
    
    if ($self->meta->table eq "usr_ref_categoria_socio"){
    	$self->conformarUsrRegularidad();
    }
    #elsif ($self->meta->table eq "ref_estado"){
    #  $self->setCodigo('STATE002');
    #}
    
    return $self;
}
sub getAlias{
    use C4::Modelo::PrefTablaReferencia;
    my ($self)=shift;
    my $nombreTabla = $self->meta->table;
    my $prefTablaRef = C4::Modelo::PrefTablaReferencia->new();
    return($prefTablaRef->getAliasForTable($nombreTabla));
}
=item
Devuelve si es o no la ultima tabla de la cadena de referencias
=cut
sub lastTable {
    return (0);
}
sub default {
    return (0);
}
sub log{
    my ($self)=shift;
    use C4::AR::Debug;
    my ($data, $metodoLlamador)=@_;
    C4::AR::Debug::log($self, $data, $metodoLlamador);
}
sub debug{
    my $self = shift;
	foreach my $msg (@_){
		C4::AR::Debug::debugObject($self, $msg);
	}
}
sub sortByString{
    my ($self)=shift;
    my ($campo)=@_;
    my $fieldsString = " ".$self->getCampos;
    my $index = rindex $fieldsString," ".$campo." ";
    if ($index != -1){
        return ($campo);
    }
    else
        {
            return ($self->defaultSort);
        }
}
=item
$self->meta
       key: column_db_value_hash_keys => value:
       key: nonlazy_column_names_string_sql => value:
       key: db => value:
       key: nonlazy_column_mutator_method_names => value:
       key: table => value: usr_persona
       key: delete_sql => value:
       key: update_sql_with_inlining_start => value:
       key: allow_auto_initialization => value: 0
       key: primary_key_sequence_names => value:
       key: select_nonlazy_columns_sql => value:
       key: column_rw_method_names => value: ARRAY(0xa4abef0)
       key: insert_sql => value:
       key: primary_key => value: id_persona
       key: nonpersistent_column_mutator_method_names => value:
       key: column_undef_overrides_default => value:
       key: insert_columns_placeholders_sql => value:
       key: nonpersistent_column_accessor_method => value:
       key: default_smart_modification => value: 0
       key: num_columns => value:
       key: load_sql => value:
       key: fq_table_sql => value:
       key: column_names_sql => value:
       key: has_lazy_columns => value: 0
       key: column_names_string_sql => value:
       key: load_all_sql => value:
       key: column_mutator_method => value: HASH(0xa491988)
       key: update_all_sql => value:
       key: db_id => value: defaultdefault
       key: unique_keys => value: ARRAY(0xa437c20)
       key: get_column_sql_tmpl => value:
       key: column_name_to_method_name_mapper => value: 0
       key: insert_changes_only_sql_prefix => value:
       key: select_columns_sql => value:
       key: original_class => value: Rose::DB::Object::Metadata
       key: dbi_requires_bind_param => value:
       key: primary_key_column_mutator_names => value:
       key: fq_table => value:
       key: nonpersistent_column_names => value: ARRAY(0xa464bc8)
       key: nonpersistent_columns_ordered => value: ARRAY(0xa464e44)
       key: nonpersistent_column_accessor_method_names => value: ARRAY(0xa464bd4)
       key: nonlazy_column_db_value_hash_keys => value:
       key: column_names => value: ARRAY(0xa49724c)
       key: convention_manager => value: Rose::DB::Object::ConventionManager=HASH(0xa3f9dcc)
       key: column_accessor_method => value: HASH(0xa491940)
       key: auto_prime_caches => value: 0
       key: columns => value: HASH(0xa4617dc)
       key: class => value: C4::Modelo::UsrPersona
       key: nonlazy_column_names => value:
       key: foreign_keys => value: HASH(0xa464bec)
       key: nonpersistent_column_mutator_method => value:
       key: update_sql_prefix => value:
       key: relationships => value: HASH(0xa3f9e08)
       key: nonlazy_column_accessor_method_names => value:
       key: select_columns_string_sql => value:
       key: is_initialized => value: 1
       key: auto_load_related_classes => value: 1
       key: fq_primary_key_sequence_names => value:
       key: columns_ordered => value: ARRAY(0xa4617e8)
       key: select_nonlazy_columns_string_sql => value:
       key: primary_key_column_accessor_names => value:
       key: insert_sql_with_inlining_start => value:
       key: column_accessor_method_names => value: ARRAY(0xa4ac094)
       key: column_mutator_method_names => value: ARRAY(0xa4ac31c)
       key: primary_key_column_db_value_hash_keys => value:
       key: is_auto_initializating => value: 0
       key: column_rw_method => value: HASH(0xa491acc)
       key: lazy_column_names => value:
       key: method_columns => value:
=cut
1;
