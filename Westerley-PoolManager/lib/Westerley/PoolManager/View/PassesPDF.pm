package Westerley::PoolManager::View::PassesPDF;
use utf8;
use Moose;
use namespace::autoclean;

use Cairo;
use Gtk2;
use Data::Dump qw(pp);
use File::Temp;
use List::Util qw(max);
use List::MoreUtils qw(natatime);
use Carp;
use Barcode::Code128;

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

# when you're looking from the front (e.g., with light shining through),
# how much does the image on the back need to be shifted leftwards to
# make the crop marks on both sides line up? (negative = right)
has reverse_side_left_shift => (
	is      => 'ro',
	isa     => 'Num',
	default => 0,
);

# and how much up? (negative = down)
has reverse_side_up_shift => (
	is      => 'ro',
	isa     => 'Num',
	default => 0,
);

# custom message to print on the back of the card. Note this is in Pango
# markup, see
# <https://developer.gnome.org/pango/unstable/PangoMarkupFormat.html>
has custom_message => (
	is      => 'ro',
	isa     => 'Str',
	default => '',
);

has crop_mark_size => (
	# note! scaled by the pass size. In inches at default 3.5×2" size.
	is      => 'ro',
	isa     => 'Num',
	default => 3/64,
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

has _barcode => (
	is      => 'ro',
	default => sub { Barcode::Code128->new() },
);

use constant _BARCODE_WIDTH => 1.5; # inches

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

	my $cards_per_page = $self->columns * $self->rows;
	my $page_iter = natatime $cards_per_page, @{$c->stash->{passes}};

	my @sides = ({
			plot => \&_plot_one_pass_front,
			xpos => sub {
				$self->paper_margin_left 
					+ $_[0] * ($self->pass_width + $self->pass_spacing_lr);
			},
			yadj => 0,
		},
		{
			plot => \&_plot_one_pass_back,
			xpos => sub {
				# right margin eats the remaining width
				$self->paper_width - $self->paper_margin_left
					+ $self->reverse_side_left_shift
					- $self->pass_width
					- $_[0] * ($self->pass_width + $self->pass_spacing_lr);
			},
			yadj => -$self->reverse_side_up_shift,
	});

	while (my @this_page = $page_iter->()) {
		foreach my $side (@sides) {
			my $col = 0;
			my $row = 0;
			foreach my $pass (@this_page) {
				my $xpos = $side->{xpos}($col);
				my $ypos = $self->paper_margin_top
				         + $side->{yadj}
						 + $row * ($self->pass_height + $self->pass_spacing_tb);

				my $passholder = $pass->search_related('passholder', undef,
					{
						'+columns' => 'holder_photo',
						'prefetch' => {
							family => {unit => 'street'},
							age_group => undef,
						}
					}
				)->single;

				$cr->save;
				$cr->translate($xpos, $ypos);
				my $method = $side->{plot};
				$self->$method($cr, $pass, $passholder);
				$cr->restore;

				if (++$col >= $self->columns) {
					$col = 0;
					if (++$row >= $self->rows) {
						die "handle page 2";
					}
				}
			}
			
			$cr->show_page;
		}
	}

	# need to get rid of these else the PDF isn't done.
	$cr = undef;
	$surface = undef;

	# DEBUG: show instead of print
	system { 'gv' } 'gv', $temp;

	$c->stash->{pdffile} = $temp;
}

sub _plot_one_pass_front {
	my ($self, $cr, $pass, $passholder) = @_;
	$cr->save;
	$cr->scale($self->pass_width / 3.5, $self->pass_height / 2);

	# photo
	$cr->save;
	$cr->scale(1.125/4, 1.125/4);
	$self->_plot_passholder_jpeg($cr, $passholder); 
	$cr->restore;

	# age box
	$cr->set_source_rgb($passholder->age_group->age_group_color->as_list);
	$cr->rectangle(0, 1.75, 3.5, .25);
	$cr->fill;
	$cr->set_source_rgb(0, 0, 0);
	$self->_plot_text($cr,
		{
			text => $passholder->age_group->age_group_name,
			rect => [0, 1.75, 3.5, 2],
			font => 'DejaVu Sans Bold 10',
			align => 'center',
			valign => 'middle',
		});

	# name
	$cr->set_source_rgb(0, 0, 0);
	$self->_plot_text($cr,
		{
			text => $passholder->holder_name,
			rect => [15/16, 1/32, 3.375, 17/32],
			font => 'DejaVu Serif Bold 13',
		});

	# address
	my $addr = $passholder->family->unit->house_number
	         . ' '
	         . $passholder->family->unit->street->street_name;
	$self->_plot_text($cr,
		{
			text => $addr,
			rect => [2*0.15+_BARCODE_WIDTH, 1.275, 3.375, 1.645],
			font => 'DejaVu Serif Bold 8',
			align => 'right',
			valign => 'middle',
		});

	# notes 
	$self->_plot_text($cr,
		{
			text => $passholder->holder_notes,
			rect => [1.05, 17/32, 3.375, 1.275],
			font => 'DejaVu Serif 8',
			justify => 1,
		});

	# bar code
	$cr->save;
	$cr->translate(0.15, 1.275);
	$cr->scale(_BARCODE_WIDTH, 0.370);
	$self->_plot_barcode($cr, $pass->pass_num);
	$cr->restore;

	$self->_plot_text($cr, 
		{
			text => _add_spaces($pass->pass_num),
			rect => [0.15, 1.4+0.25, 0.15+_BARCODE_WIDTH, 1.75],
			font => 'DejaVu Serif 7',
			align => 'center',
		});

	# crop marks
	$self->_plot_cropmarks($cr);

	$cr->restore;
}

sub _escape {
	# trivial and simple, surprised Catalyst doesn't provide...
	my $s = shift;

	$s =~ s/&/&amp;/g;
	$s =~ s/</&lt;/g;
	$s =~ s/>/&gt;/g;

	return $s;
}

sub _nobreak {
	# convert space to nonbreak
	my $s = shift;

	$s =~ y/ /\N{NO-BREAK SPACE}/;

	return $s;
}

sub _plot_one_pass_back {
	my ($self, $cr, $pass, $passholder) = @_;
	$cr->save;
	$cr->scale($self->pass_width / 3.5, $self->pass_height / 2);

	my @contacts = $passholder->family->search_related(
		'contacts',
		{contact_emergency => 1},
		{
			prefetch => 'contact_phones',
			order_by => ['me.contact_order', 'contact_phones.phone_label'],
		});

	my $markup = qq{<b><big>Emergency Contacts:</big></b>\n};
	foreach my $contact (@contacts) {
		$markup .= '<b>' . _escape($contact->contact_name) . '</b>';
		foreach my $phone ($contact->contact_phones) {
			$markup .= ' <span size="smaller" font_variant="smallcaps">['
			        . _escape($phone->phone_label)
			        . ']</span>'
			        . "\N{NO-BREAK SPACE}"
			        . _escape(_nobreak($phone->phone_number));
		}
		$markup .= " <i>(Note:\N{NO-BREAK SPACE}" . _escape($contact->contact_notes) . ')</i>'
			if ($contact->contact_notes ne '');
		$markup .= "\n";
	}

	# TODO: issue date. See the fix-me in C/Admin.pm

	# yes, these overlap, but the custom message is aligned to the
	# bottom. Going to hope they never cross :-D
	my $box = [2/32, 2/32, 3.5-2/32, 2-2/32];
	$self->_plot_text($cr,
		{
			markup => $markup,
			rect => $box,
			font => 'DejaVu Serif 8',
			justify => 0,
			singlepar => 0,
		});

	pp $self->custom_message;
	'' ne $self->custom_message and $self->_plot_text($cr,
		{
			markup => $self->custom_message,
			rect => $box,
			font => 'DejaVu Serif 8',
			justify => 1,
			singlepar => 0,
			valign => 'bottom',
		});
	
	# crop marks
	$self->_plot_cropmarks($cr);

	$cr->restore;
}

sub _plot_cropmarks {
	my ($self, $cr) = @_;

	$cr->save;
	$cr->set_source_rgb(0, 0, 0);
	$cr->move_to(0, 0);    # top-left
	$cr->rel_line_to(0, -$self->crop_mark_size);
	$cr->move_to(0, 0);
	$cr->rel_line_to(-$self->crop_mark_size, 0);
	$cr->move_to(3.5, 0);    # top-right
	$cr->rel_line_to(0, -$self->crop_mark_size);
	$cr->move_to(3.5, 0);
	$cr->rel_line_to($self->crop_mark_size, 0);
	$cr->move_to(0, 2);      # bot-left
	$cr->rel_line_to(0, $self->crop_mark_size);
	$cr->move_to(0, 2);
	$cr->rel_line_to(-$self->crop_mark_size, 0);
	$cr->move_to(3.5, 2);    # bot-right
	$cr->rel_line_to(0, $self->crop_mark_size);
	$cr->move_to(3.5, 2);
	$cr->rel_line_to($self->crop_mark_size, 0);
	$cr->set_line_width(1 / 8 / 72);
	$cr->stroke;
	$cr->restore;
}

sub _add_spaces {
	my $s = shift;
	$s =~ s/(...)(?=.)/$1 /g;
	return $s;
}

sub _plot_barcode {
	my ($self, $cr, $num_raw) = @_;
	my $num = sprintf('%10i', $num_raw);
	my $code = $self->_barcode->barcode($num);
	my $code_len = length($code);

	$cr->save;
	$cr->scale(1/$code_len, 1);
	for (my $x = 0; $x < $code_len; ++$x) {
		$cr->rectangle($x, 0, 1, 1);
		if ('#' eq substr($code, $x, 1)) {
			$cr->set_source_rgb(0,0,0);
		} else {
			$cr->set_source_rgb(1,1,1);
		}
		$cr->fill;
	}

	$cr->restore
}

sub _plot_text {
	my ($self, $cr, $opts) = @_;
	defined $opts->{rect} or croak "_plot_text requires a rect";
	defined $opts->{font} or croak "_plot_text requires a font";
	$opts->{justify} //= 0;
	$opts->{align} //= 'left';
	$opts->{singlepar} //= 1;
	$opts->{valign} //= 'top';

	defined $opts->{text}
		or defined $opts->{markup}
		or croak "_plot_text requires text or markup";
	defined $opts->{text}
		and defined $opts->{markup}
		and croak "_plot_text requires EITHER text OR markup (XOR)";

	my $width = $opts->{rect}[2] - $opts->{rect}[0];
	my $height = $opts->{rect}[3] - $opts->{rect}[1];
	croak "width < 0" if $width < 0;
	croak "height < 0" if $height < 0;

	$cr->save;

	# DEBUG
	#$cr->rectangle($opts->{rect}[0], $opts->{rect}[1], $width, $height);
	#$cr->set_line_width(0.5/72);
	#$cr->stroke;

	$cr->move_to($opts->{rect}[0], $opts->{rect}[1]);

	# pango seems to not work with tiny resolutions... so let's give it
	# something around the actual device resolution.
	$cr->scale(1/600, 1/600);

	my $layout = Pango::Cairo::create_layout($cr);
	Pango::Cairo::Context::set_resolution($layout->get_context, 600);
	$layout->context_changed;
	$layout->set_ellipsize('middle');
	$layout->set_width(Pango->scale * 600 * $width);
	$layout->set_height(Pango->scale * 600 * $height);
	$layout->set_wrap('word_char');
	$layout->set_justify($opts->{justify});
	$layout->set_alignment($opts->{align});
	$layout->set_single_paragraph_mode($opts->{singlepar});
	$layout->set_text($opts->{text})     if defined $opts->{text};
	$layout->set_markup($opts->{markup}) if defined $opts->{markup};
	$layout->set_font_description(
		Pango::FontDescription->from_string($opts->{font}));

	if ('top' ne $opts->{valign}) {
		# no built-in pango way AFAIK.
		my (undef, $h) = $layout->get_size;
		$h /= 600 * Pango->scale;

		my $offset;
		if ('middle' eq $opts->{valign}) {
			$offset = ($height-$h) / 2;
		} elsif ('bottom' eq $opts->{valign}) {
			$offset = $height-$h;
		} else {
			croak "Unknown valign: $opts->{valign}";
		}

		$cr->move_to(600 * $opts->{rect}[0],
			600 * ($offset + $opts->{rect}[1]));
	}

	Pango::Cairo::show_layout($cr, $layout);


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
