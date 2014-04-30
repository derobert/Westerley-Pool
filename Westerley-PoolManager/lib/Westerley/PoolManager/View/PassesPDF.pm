package Westerley::PoolManager::View::PassesPDF;
use utf8;
use Moose;
use namespace::autoclean;

use Cairo;
use Gtk2;
use Data::Dump qw(pp);
use File::Temp;
use List::Util qw(max);

extends 'Catalyst::View';

=head1 NAME

Westerley::PoolManager::View::PassesPDF - Catalyst View

=head1 DESCRIPTION

Catalyst View.


=encoding utf8

=head1 AUTHOR

Anthony DeRobertis,,,

=head1 LICENSE

GPLv3

=cut

# All of this is in inches.
has paper_width => (
	is      => 'ro',
	isa     => 'Num',
	default => 8.5,
);

has paper_height => (
	is      => 'ro',
	isa     => 'Num',
	default => 11,
);

has paper_margin_left => (
	is      => 'ro',
	isa     => 'Num',
	default => 0.5,
);

has paper_margin_right => (
	is      => 'ro',
	isa     => 'Num',
	default => 0.5,
);

has paper_margin_top => (
	is      => 'ro',
	isa     => 'Num',
	default => 1,
);

has paper_margin_bottom => (
	is      => 'ro',
	isa     => 'Num',
	default => 1,
);

has pass_width => (
	is      => 'ro',
	isa     => 'Num',
	default => 3.5,
);

has pass_height => (
	is      => 'ro',
	isa     => 'Num',
	default => 2,
);

has pass_spacing_lr => (
	is      => 'ro',
	isa     => 'Num',
	default => 0.125,
);

has pass_spacing_tb => (
	is      => 'ro',
	isa     => 'Num',
	default => 0.125,
);

has columns => (
	is      => 'ro',
	isa     => 'Int',
	lazy    => 1,
	builder => '_build_columns',
);

has rows => (
	is      => 'ro',
	isa     => 'Int',
	lazy    => 1,
	builder => '_build_rows',
);

sub _build_columns {
	my $self = shift;
	$self->_count_tiles(
		$self->paper_width
			- $self->paper_margin_left
			- $self->paper_margin_right,
		$self->pass_width, $self->pass_spacing_lr
	);
}

sub _build_rows {
	my $self = shift;
	$self->_count_tiles(
		$self->paper_height
			- $self->paper_margin_top
			- $self->paper_margin_bottom,
		$self->pass_height, $self->pass_spacing_tb
	);
}

sub _count_tiles {
	my ($self, $avail, $width, $spacing) = @_;

	# one is special; it doesn't need spacing.
	$avail -= $width;

	return 0 if $avail < 0; # f—ed config; BUILD will error.

	# 1 is the special 1; .01 is because fp isn't exact
	int(1.01 + $avail / ($width + $spacing));
}

sub BUILD {
	my $self = shift;

	$self->columns > 0 or die "Must have a least one column";
	$self->rows > 0    or die "Must have a least one row";

	# calculate used width
	my $width = $self->paper_margin_left + $self->paper_margin_right;
	$width += $self->columns * $self->pass_width;
	$width += ($self->columns - 1) * $self->pass_spacing_lr;

	# fp math is not exact, so allow a small fudge factor
	die "Configuration exceeds the width of the page (need $width)"
		if $self->paper_width + 0.01 < $width;

	# and again for height
	my $height = $self->paper_margin_top + $self->paper_margin_bottom;
	$height += $self->rows * $self->pass_height;
	$height += ($self->rows - 1) * $self->pass_spacing_tb;

	die "Configuration exceeds the height of the page (need $height)"
		if $self->paper_height + 0.01 < $height;
	
	printf STDERR <<REPORT, $self->paper_width, $self->paper_height, $self->pass_width, $self->pass_height, $width, $height, $self->columns, $self->rows
[PDF] Configured for %gx%g inch paper and %gx%g inch passes.
[PDF] Using total of %gx%g inches for %i columns, %i rows.
[PDF] NOTE: Extra space (if any) is added to right and/or bottom margins.
REPORT
}

sub process {
	my ($self, $c) = @_;


	my $temp = File::Temp->new(
		TEMPLATE => 'passes-XXXXXXXX',
		SUFFIX => '.pdf',
		TMPDIR => 1,
	);

	$c->log->debug("Created tempoary PDF file: $temp");

	my $surface = Cairo::PdfSurface->create(
		$temp,
		72 * $self->paper_width,
		72 * $self->paper_height
	);
	my $cr = Cairo::Context->create($surface);
	$cr->scale(72, 72);

	my $col = 0;
	my $row = 0;
	foreach my $pass (@{$c->stash->{passes}}) {
		my $xpos = $self->paper_margin_left
		         + $col * ($self->pass_width + $self->pass_spacing_lr);
		my $ypos = $self->paper_margin_top
		         + $row * ($self->pass_height + $self->pass_spacing_tb);

		$cr->save;
		$cr->translate($xpos, $ypos);
		$self->_plot_one_pass($cr, $pass);
		$cr->restore;

		if (++$col >= $self->columns) {
			$col = 0;
			if (++$row >= $self->rows) {
				die "handle page 2";
			}
		}
	}
	
	$cr->show_page;

	# need to get rid of these else the PDF isn't done.
	$cr = undef;
	$surface = undef;

	# DEBUG: show instead of print
	system { 'gv' } 'gv', $temp;

	$c->stash->{pdffile} = $temp;
}

sub _plot_one_pass {
	my ($self, $cr, $pass) = @_;
	$cr->save;
	$cr->scale($self->pass_width / 3.5, $self->pass_height / 2);

	my $passholder = $pass->search_related('passholder', undef,
		{'+columns' => 'holder_photo', 'prefetch' => 'age_group'})->single;

	# photo
	$cr->save;
	$cr->scale(1.125/4, 1.125/4);
	$self->_plot_passholder_jpeg($cr, $passholder); 
	$cr->restore;

	# age box
	$cr->set_source_rgb($passholder->age_group->age_group_color->as_list);
	$cr->rectangle(0, 1.75, 3.5, .25);
	$cr->fill;


	# DEBUG #
	$cr->set_source_rgb(0, 0, 0);
	$cr->rectangle(0, 0, 3.5, 2);
	$cr->set_line_width(0.5/72);
	$cr->stroke;

	$cr->restore;
}

# plot image inside a 3:4 rectangle at 0,0
# TODO: center
sub _plot_passholder_jpeg {
	my ($self, $cr, $passholder) = @_;
	$cr->save;

	my $pbl = Gtk2::Gdk::PixbufLoader->new_with_type('jpeg');
	$pbl->write($passholder->holder_photo);
	$pbl->close;
	my $pb = $pbl->get_pixbuf;

	Gtk2::Gdk::Cairo::Context::set_source_pixbuf($cr, $pb, 0, 0);

	my $scale = max($pb->get_height / 4, $pb->get_width / 3);
	my $m = $cr->get_source->get_matrix;
	$m->scale($scale, $scale);
	$cr->get_source->set_matrix($m);

	$cr->rectangle(0, 0, 3, 4);
	$cr->fill;

	$cr->restore;

}

__PACKAGE__->meta->make_immutable;

1;
