package Westerley::PoolManager::Controller::Admin;
use utf8;
use Moose;
use namespace::autoclean;
use List::Util qw(max);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Westerley::PoolManager::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

	if ($c->req->params->{by_num}) {
		my $num = 0 + $c->req->params->{unit_num}; # force to number
		$c->res->redirect( $c->uri_for_action('admin/show_unit', $num), 303);
		$c->detach;
	}

	if ($c->req->params->{by_address}) {
		my $unit = $c->model('Pool::Unit')->find({ house_number => $c->req->params->{house_number}, street_ref => $c->req->params->{street_ref}});
		if ($unit) {
			$c->res->redirect( $c->uri_for_action('admin/show_unit', $unit->unit_num), 303);
			$c->detach;
		} else {
			$c->stash->{notfound} = 1
		}
	}

	$c->stash->{streets} = [
		$c->model('Pool::Street')->search(undef, {order_by => 'street_name'})
			->all
		];
}

sub show_unit :Path('/unit') Args(1) {
	my ( $self, $c, $unit_num ) = @_;

	if (my $op = $c->req->params->{op}) {
		if ('add' eq $op) {
			$c->model('Pool::Family')->create({
					unit_num    => $unit_num,
					family_name => $c->req->params->{family_name}});
		} elsif ('delete' eq $op) {
			$c->model('Pool::Family')->find($c->req->params->{family_num})
				->delete;
		} elsif ('edit' eq $op) {
			$c->res->redirect($c->uri_for_action('admin/edit_family', $c->req->params->{family_num}), 303);
		} else {
			die "Uknown op";
		}
	}

	$c->stash->{families} = $c->model('Pool::Family')
		->search({unit_num => $unit_num}, {order_by => 'family_name'});
}

sub edit_family : Path('/family') Args(1) {
	my ($self, $c, $family_num ) = @_;

	if (my $op = $c->req->params->{op}) {
		if ('c:add' eq $op) {
			$c->res->redirect($c->uri_for_action('/admin/edit_contact', $family_num, 'new'), 303);
		} elsif ($op =~ /^c:edit:(\d+)$/) {
			$c->res->redirect($c->uri_for_action('/admin/edit_contact', $family_num, $1), 303);
		} elsif ('p:add' eq $op) {
			$c->res->redirect($c->uri_for_action('/admin/edit_passholder', $family_num, 'new'), 303);
		} elsif ($op =~ /^p:edit:(\d+)$/) {
			$c->res->redirect($c->uri_for_action('/admin/edit_passholder', $family_num, $1), 303);
		} else {
			die "Unknown op '$op'";
		}
		$c->detach
	}

	my $family = $c->model('Pool::Family')->find($family_num)
		or die "Family not found";

	$c->stash->{family} = $family;
	$c->stash->{contacts} = $family->contacts->search(
		undef,
		{
			order_by => [qw(me.contact_order contact_phones.phone_label)],
			prefetch => 'contact_phones'
		});
	$c->stash->{passholders}
		= $family->passholders->search(undef, {order_by => 'holder_name'});

}

sub edit_contact : Path('/contact') Args(2) {
	my ($self, $c, $family_num, $contact_num) = @_;

	my $contact;
	if ('new' eq $contact_num) {
		$contact = $c->model('Pool::Contact')
			->new_result({family_num => $family_num});
	} else {
		$contact = $c->model('Pool::Contact')->find($contact_num)
			or die "No such contact";
	}

	$c->stash->{extra_phones} = 1;
	$c->stash->{contact} = $contact;
	$c->stash->{extra_phones} = max(0 + $c->req->params->{extra_phones}, 1);

	# amazingly, this works fine with new.
	$c->stash->{phones} = [
		$contact->contact_phones->search(undef, {order_by => 'phone_label'})
	];

	if (defined(my $op = $c->req->params->{op})) {
		if ('add' eq $op) {
			++$c->stash->{extra_phones};
		} elsif ('save' eq $op) {
			$c->model('Pool')->schema->txn_do(sub {
				$contact->contact_emergency(
					$c->req->params->{contact_emergency} ? 1 : 0
				);
				$contact->contact_admin(
					$c->req->params->{contact_admin} ? 1 : 0
				);

				# would do $contact->family->contacts->max_order but it
				# generates a lot of extra queries for some reason
				$contact->contact_order(
					defined $c->req->params->{contact_order}
						&& '' ne $c->req->params->{contact_order}
					? $c->req->params->{contact_order}
					: 10 + $c->model('Pool::Contact')
						->search({family_num => $contact->family_num})
						->max_order
				);
				$contact->contact_name($c->req->params->{contact_name});
				$contact->contact_notes($c->req->params->{contact_notes});
				$contact->update_or_insert;

				$contact->contact_phones->delete;
				for (my $n = 0; defined $c->req->params->{"phone_${n}_phone_label"}; ++$n) {
					my $label = $c->req->params->{"phone_${n}_phone_label"};
					my $num = $c->req->params->{"phone_${n}_phone_number"};

					next if $num =~ /^\s*$/;

					if (10 == ($num =~ y/0-9//)) {
						# format if its 10 digits
						$num =~ y/0-9//cd;
						$num =~ /^(\d{3})(\d{3})(\d{4})$/
							or die "wtf; '$num' didn't match";
						$num = "($1) $2-$3";
					}

					$contact->contact_phones->create({
							phone_number => $num,
							phone_label => $label,
					});
				}
			});
			$c->res->redirect($c->uri_for_action('admin/edit_family', $contact->family_num), 303);
			$c->detach;
		} else {
			die "Unknown op '$op'";
		}
	}
}

sub edit_passholder : Path('/passholder') Args(2) {
	my ($self, $c, $family_num, $passholder_num) = @_;

	my $passholder;
	if ('new' eq $passholder_num) {
		$passholder = $c->model('Pool::Passholder')
			->new_result({family_num => $family_num});
	} else {
		$passholder = $c->model('Pool::Passholder')->find($passholder_num)
			or die "No such passholder";
	}

	$c->stash->{passholder} = $passholder;
}


=encoding utf8

=head1 AUTHOR

Anthony DeRobertis,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
