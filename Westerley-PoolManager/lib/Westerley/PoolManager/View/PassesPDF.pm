package Westerley::PoolManager::View::PassesPDF;
use utf8;
use Moose;
use namespace::autoclean;

use Cairo;
use Gtk2;
use Data::Dump qw(pp);
use File::Temp;
use List::Util qw(max min);
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
	default => 3.125,
);

has pass_height => (
	is      => 'ro',
	isa     => 'Num',
	default => 1.875,
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

has print_command => (
	is      => 'ro',
	isa     => 'HashRef',
	default => sub { { command => 'gv' , arg => [], } },
	trigger => sub {
		my ($self, $new, undef) = @_;
		$new->{arg} //= [];
		ref($new->{arg})
			or $new->{arg} = [ $new->{arg} ];
		'' ne $new->{command}
			or die "No command";
	},
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

has debug_boxes => (
	is      => 'ro',
	isa     => 'Bool',
	default => 0,
);

has _barcode => (
	is      => 'ro',
	default => sub { Barcode::Code128->new() },
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

	# wider surely works, taller at least isn't broken.
	$self->pass_height >= 1.874 or die "Shorter than 1⅞ probably broken";
	$self->pass_width >= 3.124 or die "Narrower than 3⅛ probably broken";

	# well, not so large it doesn't fit on the paper!
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

	0 == system {$self->print_command->{command}}
		$self->print_command->{command}, @{$self->print_command->{arg}}, $temp
		or die "print: system: $!";

	$c->stash->{pdffile} = $temp;
}

use constant {
	# front
	PHOTO_HEIGHT   => 1 + 4/32,
	PHOTO_SPACING  => 0 + 2/32,
	FRONT_MARGIN   => 0 + 1/32, # for text, cutting error
	NAME_HEIGHT    => 0 + 7/32,
	ADDRESS_HEIGHT => 0 + 4/32,
	AGE_HEIGHT     => 0 + 7/32,

	# back
	BACK_MARGIN    => 2 / 32,    # larger due to random alignment error
	BARCODE_WIDTH  => 1 + 16/32,
	BARCODE_HEIGHT => 0 + 10/32,
	BARCODE_TB_SP  => 0 + 1/32,
	BARCODE_QUIET  => 0 + 5/32, # at least 7 times bar size and 4mm
	BCTEXT_HEIGHT  => 0 + 4/32,
};

sub _plot_one_pass_front {
	my ($self, $cr, $pass, $passholder) = @_;
	$cr->save;

	# name
	my $name_right = $self->pass_width - FRONT_MARGIN;
	my $name_bottom = FRONT_MARGIN + NAME_HEIGHT;
	$cr->set_source_rgb(0, 0, 0);
	$self->_plot_text($cr,
		{
			text  => $passholder->holder_name,
			rect  => [FRONT_MARGIN, FRONT_MARGIN, $name_right, $name_bottom],
			font  => 'DejaVu Serif Bold 12',
			align => 'center'
		});

	# photo
	my $photo_top = $name_bottom + PHOTO_SPACING;
	my $photo_right = PHOTO_HEIGHT * 3 / 4;
	my $photo_bottom = $photo_top + PHOTO_HEIGHT;
	$cr->save;
	$cr->translate(0, $photo_top);
	$cr->scale(PHOTO_HEIGHT/4, PHOTO_HEIGHT/4);
	$self->_plot_passholder_jpeg($cr, $passholder);
	$cr->restore;

	# notes
	my $notes_left = $photo_right + PHOTO_SPACING;
	my $notes_right = $self->pass_width - FRONT_MARGIN;
	$self->_plot_text($cr,
		{
			text => $passholder->holder_notes,
			rect => [$notes_left, $photo_top, $notes_right, $photo_bottom],
			font => 'DejaVu Serif 8',
			justify => 1,
		});

	# address
	my $address_top = $photo_bottom + PHOTO_SPACING;
	my $address_bottom = $address_top + ADDRESS_HEIGHT;
	my $address_right = $self->pass_width - FRONT_MARGIN;
	my $addr = $passholder->family->unit->house_number
	         . ' '
	         . $passholder->family->unit->street->street_name;
	$self->_plot_text($cr,
		{
			text => $addr,
			rect => [FRONT_MARGIN, $address_top, $address_right, $address_bottom],
			font => 'DejaVu Serif Bold 7',
			align => 'right',
		});

	# age box
	my $age_top = $self->pass_height - AGE_HEIGHT;
	$cr->set_source_rgb($passholder->age_group->age_group_color->as_list);
	$cr->rectangle(0, $age_top, $self->pass_width, AGE_HEIGHT);
	$cr->fill;
	$cr->set_source_rgb(0, 0, 0);
	$self->_plot_text($cr,
		{
			text => $passholder->age_group->age_group_name,
			rect => [0, $age_top, $self->pass_width, $self->pass_height],
			font => 'DejaVu Sans Bold 9',
			align => 'center',
			valign => 'middle',
		});


	# crop marks
	$self->_plot_cropmarks($cr);

	$cr->restore;
}

sub _plot_one_pass_back {
	my ($self, $cr, $pass, $passholder) = @_;
	$cr->save;

	# bar code text
	my $bctext_left = BACK_MARGIN + BARCODE_QUIET;
	my $bctext_right = $bctext_left + BARCODE_WIDTH;
	my $bctext_bottom = $self->pass_height - BACK_MARGIN;
	my $bctext_top = $bctext_bottom - BCTEXT_HEIGHT;
	$self->_plot_text($cr, 
		{
			text => _add_spaces($pass->pass_num),
			rect => [$bctext_left, $bctext_top, $bctext_right, $bctext_bottom],
			font => 'DejaVu Serif 7',
			align => 'center',
		});

	# bar code
	my $barcode_top = $bctext_top - BARCODE_TB_SP - BARCODE_HEIGHT;
	$cr->save;
	$cr->translate($bctext_left, $barcode_top);
	$cr->scale(BARCODE_WIDTH, BARCODE_HEIGHT);
	$self->_plot_barcode($cr, $pass->pass_num);
	$cr->restore;



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

	# contacts
	my $contacts_right = $self->pass_width - BACK_MARGIN;
	my $contacts_bottom = $barcode_top - BARCODE_TB_SP;
	$self->_plot_text($cr,
		{
			markup => $markup,
			rect => [BACK_MARGIN, BACK_MARGIN, $contacts_right, $contacts_bottom],
			font => 'DejaVu Serif 8',
			justify => 0,
			singlepar => 0,
		});

	# custom message
	my $custom_left = $bctext_right + BARCODE_QUIET;
	my $custom_top = $contacts_bottom;
	my $custom_bottom = $self->pass_height - BACK_MARGIN;
	pp $self->custom_message;
	'' ne $self->custom_message and $self->_plot_text($cr,
		{
			markup => $self->custom_message,
			rect => [$custom_left, $custom_top, $contacts_right, $custom_bottom],
			font => 'DejaVu Serif 8',
			justify => 1,
			singlepar => 0,
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

sub _plot_cropmarks {
	my ($self, $cr) = @_;

	$cr->save;
	$cr->set_source_rgb(0, 0, 0);
	$cr->move_to(0, 0);    # top-left
	$cr->rel_line_to(0, -$self->crop_mark_size);
	$cr->move_to(0, 0);
	$cr->rel_line_to(-$self->crop_mark_size, 0);
	$cr->move_to($self->pass_width, 0);    # top-right
	$cr->rel_line_to(0, -$self->crop_mark_size);
	$cr->move_to($self->pass_width, 0);
	$cr->rel_line_to($self->crop_mark_size, 0);
	$cr->move_to(0, $self->pass_height);      # bot-left
	$cr->rel_line_to(0, $self->crop_mark_size);
	$cr->move_to(0, $self->pass_height);
	$cr->rel_line_to(-$self->crop_mark_size, 0);
	$cr->move_to($self->pass_width, $self->pass_height);    # bot-right
	$cr->rel_line_to(0, $self->crop_mark_size);
	$cr->move_to($self->pass_width, $self->pass_height);
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

sub _draw_debug_box {
	my ($self, $cr, $rx, $ry, $rw, $rh) = @_;
	return unless $self->debug_boxes;

	$cr->save;

	my ($x1, $y1) = $cr->device_to_user(0, 0);
	my ($x2, $y2) = $cr->device_to_user(1, 1);
	my $w = min(abs($x2 - $x1), abs($y2 - $y1));

	$cr->set_source_rgba(0.5, 0.5, 0.5, 0.5);
	$cr->set_line_width($w);
	#$cr->set_dash([5*$w], 1, 0); # did not work...
	$cr->rectangle($rx, $ry, $rw, $rh);
	$cr->stroke;
	$cr->restore;

	return;
}

sub _plot_barcode {
	my ($self, $cr, $num_raw) = @_;
	my $num = sprintf('%010i', $num_raw);
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
	$cr->restore;

	$self->_draw_debug_box($cr, 0, 0, 1, 1);
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

	$self->_draw_debug_box(
		$cr,
		$opts->{rect}[0],
		$opts->{rect}[1],
		$opts->{rect}[2] - $opts->{rect}[0],
		$opts->{rect}[3] - $opts->{rect}[1]);
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

	$self->_draw_debug_box($cr, 0, 0, 3, 4);

	$cr->restore;

}

__PACKAGE__->meta->make_immutable;

1;
