use utf8;
package Westerley::PoolManager::Schema::Result::DocVerPassholderView;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("DocVerPassholderView");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(<<VIEW);
   SELECT
          d.document_num
        , d.document_name
        , d.passholder_min_age
        , d.passholder_max_age
        , (SELECT
                  MAX(dv.version_date)
             FROM document_versions dv
            WHERE dv.document_num = d.document_num
          )                      AS doc_most_recent
        , pd.most_recent         AS passholder_most_recent
     FROM
          documents d
LEFT JOIN passholder_documents pd
       ON (d.document_num = pd.document_num AND pd.passholder_num = ?)
    WHERE
          DATEDIFF_YM(CURRENT_DATE, ?) >= d.passholder_min_age
      AND DATEDIFF_YM(CURRENT_DATE, ?) < d.passholder_max_age
VIEW

__PACKAGE__->add_columns(
  "document_num",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "documents_document_num_seq",
  },
  "document_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "passholder_min_age",
  { data_type => "interval", is_nullable => 0 },
  "passholder_max_age",
  { data_type => "interval", is_nullable => 0 },
  "doc_most_recent",
  { data_type => "date", is_nullable => 1 },
  "passholder_most_recent",
  { data_type => "date", is_nullable => 1 },
);

__PACKAGE__->belongs_to(
  "document",
  "Westerley::PoolManager::Schema::Result::Document",
  { document_num => "document_num" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

__PACKAGE__->has_many(
  "document_versions",
  "Westerley::PoolManager::Schema::Result::DocumentVersion",
  { "foreign.document_num" => "self.document_num" },
  { cascade_copy => 0, cascade_delete => 0 },
);


__PACKAGE__->meta->make_immutable;
1;
