#
# Copyright 2019 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package storage::oracle::zs::restapi::mode::components::slot;

use strict;
use warnings;

sub check {
    my ($self) = @_;

    $self->{output}->output_add(long_msg => 'checking slots');
    $self->{components}->{slot} = { name => 'slot', total => 0, skip => 0 };
    return if ($self->check_filter(section => 'slot'));

    foreach my $chassis (values %{$self->{results}}) {
        foreach (@{$chassis->{slot}}) { 
            my $instance = $chassis->{name} . ':' . $_->{label};
            
            next if ($self->check_filter(section => 'slot', instance => $instance));
            $self->{components}->{slot}->{total}++;

            my $status = $_->{faulted} ? 'faulted' : 'ok';
            $self->{output}->output_add(
                long_msg => sprintf(
                    "slot '%s' status is '%s' [instance = %s]",
                    $instance, $status, $instance,
                )
            );

            my $exit = $self->get_severity(label => 'default', section => 'slot', value => $status);
            if (!$self->{output}->is_status(value => $exit, compare => 'ok', litteral => 1)) {
                $self->{output}->output_add(
                    severity => $exit,
                    short_msg => sprintf("Slot '%s' status is '%s'", $instance, $status)
                );
            }
        }
    }
}

1;
